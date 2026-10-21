# Codex Cloud environment

Configure o setup command do ambiente para `bash scripts/setup-cloud.sh`. O processo instala/valida dependências no ambiente de execução e não altera políticas de sandbox.

Depois que a instalação terminar, execute `npx --yes rea-agents@6.7.0 setup` em uma sessão interativa e aprove somente o plano esperado. Se a configuração MCP precisar estar no ambiente Codex, cadastre `rea` nas configurações de MCP do ambiente. Configuração de exemplo em TOML:

```toml
[mcp_servers.rea]
command = "npx"
args = ["--yes", "rea-agents@6.7.0", "mcp"]
startup_timeout_sec = 30
```

Configure `GHIDRA_INSTALL_DIR` e `JAVA_HOME` como variáveis de ambiente persistentes caso o serviço MCP rode em um processo diferente do setup. Para Ghidra baixado por este script, o valor padrão é `~/.local/opt/ghidra_12.1.4_PUBLIC`; use o caminho do JDK 21 detectado no ambiente. Não adicione credenciais a variáveis versionadas no repositório.
