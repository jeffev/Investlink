#!/usr/bin/env python3
"""
Hook PreToolUse: intercepta comandos pytest na suite completa e reduz verbosidade.

Substitui -v por -q --tb=short para que Claude receba apenas falhas + resumo,
em vez de 133 linhas de "PASSED" que consomem contexto desnecessariamente.

Testes específicos (com ::) não são alterados para preservar detalhes de debug.
"""
import json
import sys

data = json.load(sys.stdin)
tool_name = data.get("tool_name", "")
command = data.get("tool_input", {}).get("command", "")

# Só intercepta pytest rodando a suite inteira (sem :: = não é teste específico)
is_full_suite = (
    tool_name == "Bash"
    and "pytest" in command
    and "tests/unit/" in command
    and "::" not in command
)

if is_full_suite:
    modified = command
    if " -v" in modified:
        modified = modified.replace(" -v", " -q --tb=short")
    elif " -q" not in modified:
        modified = modified + " -q --tb=short"

    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "allow",
            "updatedInput": {"command": modified}
        }
    }))
else:
    print(json.dumps({}))
