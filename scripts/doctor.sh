#!/usr/bin/env bash
set -Eeuo pipefail

GHIDRA_VERSION="12.1.4"
REA_VERSION="6.7.0"
GHIDRA_INSTALL_DIR="${GHIDRA_INSTALL_DIR:-${HOME}/.local/opt/ghidra_${GHIDRA_VERSION}_PUBLIC}"
export GHIDRA_INSTALL_DIR

printf 'Sistema: %s/%s\n' "$(uname -s)" "$(uname -m)"
command -v node >/dev/null && node --version || echo 'Node.js: ausente'
command -v npm >/dev/null && npm --version || echo 'npm: ausente'
command -v java >/dev/null && java -version 2>&1 | head -n 1 || echo 'Java: ausente'
command -v javac >/dev/null && javac -version || echo 'javac: ausente'
printf 'Ghidra: %s\n' "$GHIDRA_INSTALL_DIR"
[[ -x "$GHIDRA_INSTALL_DIR/support/analyzeHeadless" ]] || { echo 'Ghidra analyzeHeadless: ausente' >&2; exit 1; }
npx --yes "rea-agents@${REA_VERSION}" doctor --provider ghidra --json
npx --yes "rea-agents@${REA_VERSION}" doctor --client codex --json
