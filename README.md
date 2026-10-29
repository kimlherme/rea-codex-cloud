# REA + Ghidra no Codex Cloud

Ambiente reproduzível para usar **Reverse Engineer Anything (REA)** com Ghidra em um ambiente Linux x86_64 do Codex Cloud. REA disponibiliza CLI, MCP e workflows para análise local de binários.

> Use apenas em arquivos que você tem autorização para analisar. O ambiente não desativa sandbox, não executa o alvo e não tenta contornar proteções.

## O que este repositório prepara

- Java JDK 21 e ferramentas auxiliares para Ghidra.
- Ghidra 12.1.4 oficial, instalado em `~/.local/opt/ghidra_12.1.4_PUBLIC` e verificado com o SHA-256 publicado pelo projeto.
- REA CLI/MCP (`rea-agents`) e validação das instalações.
- Documentação de como conectar o MCP ao Codex.

O REA não instala Java nem Ghidra por conta própria. Este setup instala Ghidra separadamente e só registra o MCP depois que o operador revisar e aprovar o plano do `rea setup`.

## Executar no Codex Cloud

1. Crie um ambiente Linux x86_64 com rede habilitada para instalar dependências.
2. Configure o comando de setup do ambiente como:

   ```bash
   bash scripts/setup-cloud.sh
   ```

3. Depois do setup, rode no terminal do ambiente:

   ```bash
   npx --yes rea-agents@6.7.0 doctor --provider ghidra --json
   npx --yes rea-agents@6.7.0 setup
   ```

   Revise o plano que o REA mostrar antes de aprovar. Reinicie/reconecte o agente depois da configuração.

4. Valide:

   ```bash
   bash scripts/doctor.sh
   ```

O ambiente de execução do Codex Cloud e a configuração MCP da sessão podem ter ciclos de vida diferentes. Se o Codex não mostrar as ferramentas REA após reiniciar, adicione ao ambiente MCP do Codex a configuração abaixo e use um caminho absoluto para o Java e para o Ghidra:

```toml
[mcp_servers.rea]
command = "npx"
args = ["--yes", "rea-agents@6.7.0", "mcp"]
startup_timeout_sec = 30
```

Mantenha o Node.js disponível no `PATH` do processo MCP. Consulte as configurações MCP do ambiente Codex usado pelo seu workspace; não coloque tokens ou credenciais neste repositório.

## Requisitos e limites

- Linux x86_64 (Codex Cloud); o teste REA+Ghidra deste setup não cobre ARM64.
- Node.js 22.19+ (ou 24.11+) e npm.
- JDK 21 de 64 bits, incluindo `javac`.
- Cerca de 2 GB livres para download e extração do Ghidra.
- Binário autorizado no workspace do ambiente.

REA documenta suporte ao Ghidra 12.1.4. Este projeto fixa essa versão para evitar incompatibilidade silenciosa. Para atualizar, confira primeiro a compatibilidade no REA e altere versão e checksum juntos.

## Comandos úteis

```bash
# Reinstala/valida os componentes do ambiente
bash scripts/setup-cloud.sh

# Diagnósticos somente leitura
bash scripts/doctor.sh

# Consultar uma função após configurar o REA
npx --yes rea-agents@6.7.0 function ./caminho/arquivo funcao \
  --provider ghidra --json
```

A análise é estática e somente leitura. Ghidra importa o arquivo e gera informações/pseudocódigo; isso não recupera o código-fonte original. Não execute o binário analisado no ambiente.

## Componentes MCP opcionais

O REA já fornece seu próprio MCP. MCPs extras devem ser adicionados somente quando o trabalho precisar deles. Evite registrar servidores com acesso irrestrito ao shell, filesystem ou rede. Nunca salve chaves, tokens, arquivos de amostra privados ou resultados sensíveis no Git.

## Licenças

Este repositório de setup usa MIT. REA, Ghidra, Java e quaisquer MCPs adicionais têm licenças próprias; consulte os respectivos projetos antes de redistribuir.

## Fontes oficiais

- [REA: instalação e configuração do Ghidra](https://reverseengineeranything.app/get-started/)
- [Código e limites atuais do REA](https://github.com/imft-debug/reverse-engineer-anything-REA)
- [Releases do Ghidra e SHA-256](https://github.com/NationalSecurityAgency/ghidra/releases)
- [Pacote REA no npm](https://www.npmjs.com/package/rea-agents)

<!-- Teste do GitHub Sidebar: alteração temporária para validar o pull request. -->
