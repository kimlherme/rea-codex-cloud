#!/usr/bin/env bash
set -Eeuo pipefail

readonly GHIDRA_VERSION="12.1.4"
readonly GHIDRA_SHA256="ddac49f903da9d5bac833e5cc79395098b9c33cfd3279be5f31bd00387d2d4db"
readonly GHIDRA_RELEASE_TAG="Ghidra_${GHIDRA_VERSION}_build"
readonly REA_VERSION="6.7.0"
readonly GHIDRA_HOME="${GHIDRA_INSTALL_DIR:-${HOME}/.local/opt/ghidra_${GHIDRA_VERSION}_PUBLIC}"
readonly OPT_DIR="${HOME}/.local/opt"
readonly TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

fail() { printf 'ERRO: %s\n' "$*" >&2; exit 1; }
info() { printf '\n==> %s\n' "$*"; }

[[ "$(uname -s)" == "Linux" ]] || fail "Este setup foi feito para Linux x86_64."
[[ "$(uname -m)" == "x86_64" ]] || fail "REA/Ghidra neste setup exigem x86_64; arquitetura detectada: $(uname -m)."
command -v curl >/dev/null || fail "Instale curl e tente novamente."
command -v unzip >/dev/null || fail "Instale unzip e tente novamente."
command -v node >/dev/null || fail "Node.js 22.19+ não encontrado. Instale-o no ambiente Codex Cloud."
command -v npm >/dev/null || fail "npm não encontrado."

node -e 'const [a,b]=process.versions.node.split(".").map(Number); if ((a===22 && b<19) || (a===23) || (a===24 && b<11) || a<22) process.exit(1)' \
  || fail "Node.js precisa ser 22.19+ ou 24.11+. Detectado: $(node --version)."

if ! command -v java >/dev/null || ! command -v javac >/dev/null; then
  info "JDK 21 não encontrado; tentando instalar openjdk-21-jdk-headless."
  if command -v apt-get >/dev/null && [[ "$(id -u)" == "0" ]]; then
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-21-jdk-headless
  elif command -v sudo >/dev/null && command -v apt-get >/dev/null; then
    sudo apt-get update
    sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-21-jdk-headless
  else
    fail "Instale um JDK 21 (com javac) no ambiente Codex Cloud e rode novamente."
  fi
fi

java -version 2>&1 | head -n 1 | grep -Eq 'version "21([.]|\\")' || fail "Java 21 não foi encontrado. Configure JAVA_HOME para um JDK 21."
command -v javac >/dev/null || fail "O JDK precisa incluir javac; um JRE não basta."

mkdir -p "$OPT_DIR"
if [[ ! -x "$GHIDRA_HOME/support/analyzeHeadless" ]]; then
  info "Baixando Ghidra ${GHIDRA_VERSION} do release oficial e conferindo SHA-256."
  api="https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/tags/${GHIDRA_RELEASE_TAG}"
  asset_url="$(curl --fail --silent --show-error --location "$api" | node -e '
    let s=""; process.stdin.on("data", d => s += d); process.stdin.on("end", () => {
      const r=JSON.parse(s); const a=(r.assets||[]).find(x => /^ghidra_12\.1\.4_PUBLIC_.*\.zip$/.test(x.name));
      if (!a || !a.browser_download_url) process.exit(2); process.stdout.write(a.browser_download_url);
    });')" || fail "Ghidra release asset não foi localizado na API oficial."
  archive="$TMP_DIR/ghidra.zip"
  curl --fail --silent --show-error --location "$asset_url" -o "$archive"
  printf '%s  %s\n' "$GHIDRA_SHA256" "$archive" | sha256sum --check --status || fail "SHA-256 do Ghidra não confere. Arquivo removido."
  unzip -q "$archive" -d "$TMP_DIR/extracted"
  extracted="$(find "$TMP_DIR/extracted" -maxdepth 1 -type d -name "ghidra_${GHIDRA_VERSION}_PUBLIC" -print -quit)"
  [[ -n "$extracted" ]] || fail "A pasta esperada não apareceu no arquivo do Ghidra."
  [[ ! -e "$GHIDRA_HOME" ]] || fail "Destino existe, mas não contém uma instalação válida do Ghidra: $GHIDRA_HOME. Remova ou escolha outro GHIDRA_INSTALL_DIR."
  mv "$extracted" "$GHIDRA_HOME"
fi

export GHIDRA_INSTALL_DIR="$GHIDRA_HOME"
export JAVA_HOME="${JAVA_HOME:-$(dirname "$(dirname "$(readlink -f "$(command -v javac)")")")}"
export PATH="$JAVA_HOME/bin:$HOME/.local/bin:$PATH"

info "Validando Ghidra, Java e REA."
[[ -x "$GHIDRA_INSTALL_DIR/support/analyzeHeadless" ]] || fail "analyzeHeadless não encontrado em $GHIDRA_INSTALL_DIR."
java -version 2>&1 | head -n 1
javac -version
npx --yes "rea-agents@${REA_VERSION}" doctor --provider ghidra --json

cat <<EOF

Setup de dependências concluído.
Ghidra: $GHIDRA_INSTALL_DIR
JAVA_HOME: $JAVA_HOME

Agora execute interativamente para revisar/aprovar a configuração MCP do REA:
  GHIDRA_INSTALL_DIR="$GHIDRA_INSTALL_DIR" JAVA_HOME="$JAVA_HOME" npx --yes rea-agents@${REA_VERSION} setup
EOF
