#Requires -Version 5.1
<#
.SYNOPSIS
    Instala Superpowers e Pencil MCP para OpenCode

.DESCRIPTION
    Este script configura automaticamente:
    - Superpowers (obra/superpowers) - Framework de skills para coding agents
    - Pencil MCP - Servidor MCP para design de interfaces
    - Instrucoes personalizadas em portugues

.EXAMPLE
    .\install-opencode-tools.ps1
#>

param(
    [string]$OpenCodeConfigPath = "$env:USERPROFILE\.config\opencode\opencode.json",
    [switch]$Force
)

# Cores para output
function Write-Step { param([string]$Message) Write-Host "-> $Message" -ForegroundColor Cyan }
function Write-Success { param([string]$Message) Write-Host "OK: $Message" -ForegroundColor Green }
function Write-Warning { param([string]$Message) Write-Host "AVISO: $Message" -ForegroundColor Yellow }
function Write-Error { param([string]$Message) Write-Host "ERRO: $Message" -ForegroundColor Red }

# Verificar pre-requisitos
function Test-Prerequisites {
    Write-Step "Verificando pre-requisitos..."
    
    # Verificar se OpenCode esta instalado
    if (-not (Get-Command opencode -ErrorAction SilentlyContinue)) {
        Write-Error "OpenCode nao encontrado. Instale em https://opencode.ai"
        exit 1
    }
    Write-Success "OpenCode encontrado"
    
    # Verificar se git esta instalado
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error "Git nao encontrado. Instale em https://git-scm.com"
        exit 1
    }
    Write-Success "Git encontrado"
    
    # Verificar se npm esta instalado
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Warning "npm nao encontrado. Algumas funcionalidades podem nao funcionar."
    } else {
        Write-Success "npm encontrado"
    }
}

# Criar instrucoes personalizadas em portugues
function Create-Instructions {
    Write-Step "Criando instrucoes personalizadas em portugues..."
    
    $instructionsPath = "$env:USERPROFILE\.config\opencode\instructions.md"
    $instructionsDir = Split-Path -Path $instructionsPath -Parent
    
    # Criar diretorio se nao existir
    if (-not (Test-Path $instructionsDir)) {
        New-Item -ItemType Directory -Path $instructionsDir -Force | Out-Null
    }
    
    # Conteudo das instrucoes
    $instructionsContent = @"
# Instruções Personalizadas

## Idioma
- **SEMPRE** responda em Português do Brasil
- Todas as explicações, instruções e documentação devem ser em português
- Código e comandos podem permanecer em inglês

## Estilo de Comunicação
- Seja claro e direto
- Use linguagem acessível
- Forneça exemplos práticos quando possível

## Formato
- Use Markdown para formatação
- Organize informações em listas e tabelas quando apropriado
- Inclua exemplos de código quando útil
"@
    
    # Salvar instrucoes
    $instructionsContent | Set-Content -Path $instructionsPath -Encoding UTF8
    Write-Success "Instrucoes criadas em: $instructionsPath"
}

# Criar backup do arquivo de configuracao
function Backup-Config {
    param([string]$ConfigPath)
    
    if (Test-Path $ConfigPath) {
        $backupPath = "$ConfigPath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Write-Step "Criando backup: $backupPath"
        Copy-Item -Path $ConfigPath -Destination $backupPath -Force
        Write-Success "Backup criado"
    }
}

# Configurar Superpowers, Pencil MCP e Instrucoes
function Configure-Tools {
    param([string]$ConfigPath)
    
    # Ler o conteudo do arquivo JSON
    $jsonContent = Get-Content -Path $ConfigPath -Raw
    
    # Converter para hashtable para manipulacao mais facil
    $config = $jsonContent | ConvertFrom-Json
    
    # Criar nova hashtable para a configuracao final
    $newConfig = @{}
    $newConfig.'$schema' = 'https://opencode.ai/config.json'
    
    # Adicionar plugin Superpowers se nao existir
    $hasSuperpowers = $false
    if ($config.plugin) {
        foreach ($p in $config.plugin) {
            if ($p -match "superpowers") {
                $hasSuperpowers = $true
                break
            }
        }
    }
    
    if (-not $hasSuperpowers -or $Force) {
        $pluginArray = @()
        if ($config.plugin) {
            $pluginArray = @($config.plugin | Where-Object { $_ -notmatch "superpowers" })
        }
        $pluginArray += "superpowers@git+https://github.com/obra/superpowers.git"
        $newConfig.plugin = $pluginArray
        Write-Success "Superpowers adicionado"
    } else {
        $newConfig.plugin = @($config.plugin)
        Write-Warning "Superpowers ja configurado"
    }
    
    # Adicionar instrucoes personalizadas
    $instructionsPath = "~/.config/opencode/instructions.md"
    $hasInstructions = $false
    if ($config.instructions) {
        foreach ($i in $config.instructions) {
            if ($i -match "instructions.md") {
                $hasInstructions = $true
                break
            }
        }
    }
    
    if (-not $hasInstructions -or $Force) {
        $instructionsArray = @()
        if ($config.instructions) {
            $instructionsArray = @($config.instructions)
        }
        $instructionsArray += $instructionsPath
        $newConfig.instructions = $instructionsArray
        Write-Success "Instrucoes personalizadas adicionadas"
    } else {
        $newConfig.instructions = @($config.instructions)
        Write-Warning "Instrucoes personalizadas ja configuradas"
    }
    
    # Manter configuracao MCP existente ou criar nova
    if ($config.mcp) {
        $newConfig.mcp = $config.mcp
    } else {
        $newConfig.mcp = @{}
    }
    
    # Verificar se Pencil MCP ja esta configurado
    $hasPencil = $false
    if ($newConfig.mcp.pencil) {
        $hasPencil = $true
    }
    
    if (-not $hasPencil -or $Force) {
        # Configuracao do Pencil MCP
        $newConfig.mcp.pencil = @{
            'command' = @(
                "D:\programas ssd\IA\Pencil\resources\app.asar.unpacked\out\mcp-server-windows-x64.exe"
                "--app"
                "desktop"
                "--agent"
                "openCodeCLI"
            )
            'enabled' = $true
            'type' = 'local'
        }
        Write-Success "Pencil MCP configurado"
    } else {
        Write-Warning "Pencil MCP ja configurado"
    }
    
    # Salvar a nova configuracao
    $newConfig | ConvertTo-Json -Depth 10 | Set-Content -Path $ConfigPath -Encoding UTF8
    Write-Success "Configuracao salva"
}

# Funcao principal
function Main {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host "  Instalador de Tools para OpenCode     " -ForegroundColor Magenta
    Write-Host "  Superpowers + Pencil MCP               " -ForegroundColor Magenta
    Write-Host "  + Instrucoes em Portugues              " -ForegroundColor Magenta
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host ""
    
    # Verificar pre-requisitos
    Test-Prerequisites
    
    # Criar instrucoes personalizadas
    Create-Instructions
    
    # Criar backup
    Backup-Config -ConfigPath $OpenCodeConfigPath
    
    # Configurar ferramentas
    Configure-Tools -ConfigPath $OpenCodeConfigPath
    
    # Instrucoes finais
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  Instalacao Concluida!                 " -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Proximos passos:" -ForegroundColor Yellow
    Write-Host "  1. Reinicie o OpenCode"
    Write-Host "  2. Para testar Superpowers, pergunte: Tell me about your superpowers"
    Write-Host "  3. Para testar Pencil, use comandos de design"
    Write-Host "  4. Todas as respostas serao em Portugues!"
    Write-Host ""
    Write-Host "Para reinstalar, execute novamente com -Force"
    Write-Host ""
}

# Executar
Main