#!/usr/bin/env bash
#
# Executado NO SERVIDOR, recebido pelo ssh a partir do docker-release.yml.
#
# Contrato: o servidor guarda em $DEPLOY_PATH o docker-compose.prod.yml (enviado
# pelo deploy) e um .env com os segredos (criado à mão, nunca versionado nem
# transmitido daqui).
set -euo pipefail

: "${DEPLOY_PATH:?DEPLOY_PATH não informado}"
: "${IMAGE_TAG:?IMAGE_TAG não informado}"
: "${GHCR_OWNER:?GHCR_OWNER não informado}"

COMPOSE_FILE="docker-compose.prod.yml"
HEALTH_ATTEMPTS="${HEALTH_ATTEMPTS:-40}"
HEALTH_INTERVAL="${HEALTH_INTERVAL:-5}"

cd "$DEPLOY_PATH"

if [ ! -f "$COMPOSE_FILE" ]; then
  echo "ERRO: $DEPLOY_PATH/$COMPOSE_FILE não existe." >&2
  exit 1
fi

if [ ! -f .env ]; then
  echo "ERRO: $DEPLOY_PATH/.env não existe. Ele guarda POSTGRES_PASSWORD," >&2
  echo "JWT_SECRET_KEY e ADMIN_PASSWORD e é criado no servidor, não pelo CI." >&2
  exit 1
fi

compose() { docker compose -f "$COMPOSE_FILE" "$@"; }

# Registro da versão que está no ar hoje: é o alvo do rollback.
PREVIOUS_TAG="$(cat .deployed_tag 2>/dev/null || true)"

export IMAGE_TAG GHCR_OWNER

if [ -n "${GHCR_TOKEN:-}" ]; then
  echo "$GHCR_TOKEN" | docker login ghcr.io -u "${GHCR_USER:?GHCR_USER não informado}" --password-stdin
  # O token é de uso único desta execução; não deve ficar em ~/.docker/config.json.
  trap 'docker logout ghcr.io >/dev/null 2>&1 || true' EXIT
fi

wait_until_healthy() {
  local service="$1" container status attempt=1

  container="$(compose ps -q "$service")"
  if [ -z "$container" ]; then
    echo "ERRO: serviço $service não chegou a subir." >&2
    return 1
  fi

  while [ "$attempt" -le "$HEALTH_ATTEMPTS" ]; do
    status="$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "$container")"
    case "$status" in
      healthy) return 0 ;;
      exited|dead) echo "ERRO: $service parou ($status)." >&2; return 1 ;;
    esac
    sleep "$HEALTH_INTERVAL"
    attempt=$((attempt + 1))
  done

  echo "ERRO: $service não ficou saudável em $((HEALTH_ATTEMPTS * HEALTH_INTERVAL))s." >&2
  return 1
}

rollback() {
  if [ -z "$PREVIOUS_TAG" ]; then
    echo "AVISO: nenhuma versão anterior registrada — não há para onde voltar." >&2
    echo "Os contêineres ficam como estão para inspeção." >&2
    return
  fi

  echo "Revertendo para $PREVIOUS_TAG"
  # As migrações já aplicadas pela versão nova NÃO voltam: o rollback recupera
  # o código, não o schema. Migração destrutiva exige intervenção manual.
  IMAGE_TAG="$PREVIOUS_TAG" compose up -d
}

echo "==> Baixando imagens ($IMAGE_TAG)"
compose pull

echo "==> Subindo"
compose up -d --remove-orphans

# As tabelas da CVM e do histórico anual pertencem ao pipeline: o
# `flask db upgrade` do backend não as cria, e sem elas o score de ação sai
# sem o guard rail de consistência de lucro. É `create_all(checkfirst=True)`,
# então repetir a cada deploy não custa nada.
echo "==> Migração do pipeline de dados"
compose --profile tools run --rm data_science python database/migrations.py

echo "==> Aguardando saúde"
if ! wait_until_healthy backend || ! wait_until_healthy frontend; then
  echo "==> Últimas linhas do backend:"
  compose logs --tail 80 backend || true
  rollback
  exit 1
fi

echo "$IMAGE_TAG" > .deployed_tag
docker image prune -f --filter "until=168h" >/dev/null || true

echo "==> Deploy concluído: $IMAGE_TAG"
