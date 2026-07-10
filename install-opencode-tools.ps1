#Requires -Version 5.1
<#
.SYNOPSIS
    Instala Superpowers e Pencil MCP para OpenCode

.DESCRIPTION
    Este script configura automaticamente:
    - Superpowers (obra/superpowers) - Framework de skills para coding agents
    - Pencil MCP - Servidor MCP para design de interfaces

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

# Configurar Superpowers e Pencil MCP
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
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host ""
    
    # Verificar pre-requisitos
    Test-Prerequisites
    
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
    Write-Host ""
    Write-Host "Para reinstalar, execute novamente com -Force"
    Write-Host ""
}

# Executar
Main