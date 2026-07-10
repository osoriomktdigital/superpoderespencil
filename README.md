# OpenCode Setup - Superpowers + Pencil MCP

Scripts de instalação automática para configurar [Superpowers](https://github.com/obra/superpowers) e [Pencil MCP](https://github.com/aspect-build/aspect-cli) no [OpenCode](https://opencode.ai).

## O que é instalado

### Superpowers
Framework de skills para coding agents que transforma seu agente em um verdadeiro desenvolvedor sênior. Inclui:
- Brainstorming socrático
- Test-Driven Development (TDD)
- Desenvolvimento orientado a subagentes
- Code review sistemático

### Pencil MCP
Servidor MCP para design de interfaces que permite:
- Criar e editar designs .pen
- Exportar designs para HTML/CSS
- Gerenciar variáveis e temas

## Pré-requisitos

- [OpenCode.ai](https://opencode.ai) instalado
- [Git](https://git-scm.com) instalado
- [Node.js](https://nodejs.org) e npm (recomendado)

## Instalação Rápida

### Windows (PowerShell)

```powershell
# Opção 1: Baixar e executar
iex (irm https://raw.githubusercontent.com/SEU_USER/opencode-setup/main/install-opencode-tools.ps1)

# Opção 2: Clonar repositório
git clone https://github.com/SEU_USER/opencode-setup.git
cd opencode-setup
.\install-opencode-tools.ps1
```

### Linux/macOS (Bash)

```bash
# Clonar repositório
git clone https://github.com/SEU_USER/opencode-setup.git
cd opencode-setup
chmod +x install-opencode-tools.sh
./install-opencode-tools.sh
```

## Uso

### Instalação padrão
```powershell
.\install-opencode-tools.ps1
```

### Reinstalação (forçar)
```powershell
.\install-opencode-tools.ps1 -Force
```

### Caminho personalizado do config
```powershell
.\install-opencode-tools.ps1 -OpenCodeConfigPath "C:\caminho\personalizado\opencode.json"
```

## O que o script faz

1. **Verifica pré-requisitos** - OpenCode, Git, npm
2. **Cria backup** da configuração existente
3. **Configura Superpowers** - Adiciona plugin ao opencode.json
4. **Configura Pencil MCP** - Adiciona servidor MCP ao opencode.json
5. **Salva configuração** - Atualiza o arquivo opencode.json

## Verificação

Após a instalação, reinicie o OpenCode e teste:

### Superpowers
```
Tell me about your superpowers
```

### Pencil MCP
Use comandos de design ou:
```
use skill tool to list skills
```

## Estrutura do Repositório

```
opencode-setup/
├── install-opencode-tools.ps1    # Script PowerShell (Windows)
├── install-opencode-tools.sh     # Script Bash (Linux/macOS)
├── opencode.template.json        # Template de configuração
└── README.md                     # Este arquivo
```

## Solução de Problemas

### Plugin não carrega
1. Verifique os logs: `opencode run --print-logs "hello" 2>&1 | grep -i superpowers`
2. Verifique se o plugin está no opencode.json
3. Reinicie o OpenCode

### Erro de permissão (Windows)
Execute o PowerShell como administrador:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Pencil MCP não conecta
1. Verifique se o caminho do executável está correto
2. Teste o executável manualmente
3. Verifique se o OpenCode tem permissão de acesso

## Atualização

Para atualizar as ferramentas, execute novamente o script com `-Force`:
```powershell
.\install-opencode-tools.ps1 -Force
```

## Contribuindo

1. Fork o repositório
2. Crie uma branch para sua feature
3. Faça commit suas alterações
4. Envie um Pull Request

## Licença

MIT License - veja o arquivo [LICENSE](LICENSE) para detalhes.

## Links Úteis

- [OpenCode Documentation](https://opencode.ai/docs)
- [Superpowers Repository](https://github.com/obra/superpowers)
- [Pencil MCP Documentation](https://github.com/aspect-build/aspect-cli)
- [OpenCode Discord](https://discord.gg/opencode)