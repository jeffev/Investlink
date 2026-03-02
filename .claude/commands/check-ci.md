Verifique o status atual do CI/CD do InvestLink no GitHub.

Execute em sequência:
1. `cd /d/Investlink && gh run list --limit 5 --json status,conclusion,workflowName,headBranch,createdAt`
2. Se houver algum run com `conclusion: failure`, execute: `gh run view <id> --log-failed 2>&1 | grep -E "error|Error|failed|Failed" | head -20`

Reporte:
- Status dos últimos 5 runs (workflow, branch, resultado)
- Se houver falha: qual step falhou e por quê
- Recomendação de ação se necessário

Não leia arquivos de workflow — apenas use o gh CLI.
