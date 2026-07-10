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
function Write-Step { param([string]$Message) Write-Host "→ $Message" -ForegroundColor Cyan }
function Write-Success { param([string]$Message) Write-Host "✓ $Message" -ForegroundColor Green }
function Write-Warning { param([string]$Message) Write-Host "⚠ $Message" -ForegroundColor Yellow }
function Write-Error { param([string]$Message) Write-Host "✗ $Message" -ForegroundColor Red }

# Verificar pré-requisitos
function Test-Prerequisites {
    Write-Step "Verificando pré-requisitos..."
    
    # Verificar se OpenCode está instalado
    if (-not (Get-Command opencode -ErrorAction SilentlyContinue)) {
        Write-Error "OpenCode não encontrado. Instale em https://opencode.ai"
        exit 1
    }
    Write-Success "OpenCode encontrado"
    
    # Verificar se git está instalado
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error "Git não encontrado. Instale em https://git-scm.com"
        exit 1
    }
    Write-Success "Git encontrado"
    
    # Verificar se npm está instalado
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Warning "npm não encontrado. Algumas funcionalidades podem não funcionar."
    } else {
        Write-Success "npm encontrado"
    }
}

# Criar backup do arquivo de configuração
function Backup-Config {
    param([string]$ConfigPath)
    
    if (Test-Path $ConfigPath) {
        $backupPath = "$ConfigPath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Write-Step "Criando backup: $backupPath"
        Copy-Item -Path $ConfigPath -Destination $backupPath -Force
        Write-Success "Backup criado"
    }
}

# Ler configuração existente
function Get-OpenCodeConfig {
    param([string]$ConfigPath)
    
    if (Test-Path $ConfigPath) {
        Write-Step "Lendo configuração existente..."
        $config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
        Write-Success "Configuração carregada"
    } else {
        Write-Step "Criando nova configuração..."
        $config = @{
            '$schema' = 'https://opencode.ai/config.json'
            'plugin' = @()
            'mcp' = @{}
        }
    }
    
    return $config
}

# Adicionar Superpowers plugin
function Add-Superpowers {
    param([ref]$Config)
    
    Write-Step "Configurando Superpowers..."
    
    # Verificar se já está instalado
    $superpowersInstalled = $Config.Value.plugin | Where-Object { $_ -match "superpowers" }
    
    if ($superpowersInstalled -and -not $Force) {
        Write-Warning "Superpowers já está instalado. Use -Force para reinstalar."
        return
    }
    
    # Adicionar plugin
    $pluginSpec = "superpowers@git+https://github.com/obra/superpowers.git"
    
    if (-not $Config.Value.plugin) {
        $Config.Value.plugin = @()
    }
    
    # Remover se já existir (para reinstalação)
    $Config.Value.plugin = @($Config.Value.plugin | Where-Object { $_ -notmatch "superpowers" })
    
    # Adicionar nova especificação
    $Config.Value.plugin += $pluginSpec
    
    Write-Success "Superpowers configurado: $pluginSpec"
}

# Configurar Pencil MCP
function Add-PencilMCP {
    param([ref]$Config)
    
    Write-Step "Configurando Pencil MCP..."
    
    # Verificar se já está configurado
    if ($Config.Value.mcp -and $Config.Value.mcp.pencil -and -not $Force) {
        Write-Warning "Pencil MCP já está configurado. Use -Force para reconfigurar."
        return
    }
    
    # Configuração do Pencil MCP
    $pencilConfig = @{
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
    
    # Inicializar MCP se necessário
    if (-not $Config.Value.mcp) {
        $Config.Value.mcp = @{}
    }
    
    # Adicionar configuração
    $Config.Value.mcp.pencil = $pencilConfig
    
    Write-Success "Pencil MCP configurado"
}

# Salvar configuração
function Save-Config {
    param([ref]$Config, [string]$ConfigPath)
    
    Write-Step "Salvando configuração..."
    
    # Garantir que o diretório existe
    $configDir = Split-Path -Path $ConfigPath -Parent
    if (-not (Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    }
    
    # Salvar JSON
    $Config.Value | ConvertTo-Json -Depth 10 | Set-Content -Path $ConfigPath -Encoding UTF8
    
    Write-Success "Configuração salva em: $ConfigPath"
}

# Instalar Superpowers via npm (método alternativo para Windows)
function Install-SuperpowersNpm {
    Write-Step "Tentando instalar Superpowers via npm..."
    
    try {
        $npmPath = "$env:USERPROFILE\.config\opencode"
        npm install "superpowers@git+https://github.com/obra/superpowers.git" --prefix $npmPath 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Superpowers instalado via npm"
            return $true
        }
    } catch {
        Write-Warning "Instalação via npm falhou: $_"
    }
    
    return $false
}

# Função principal
function Main {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║     Instalador de Tools para OpenCode                    ║" -ForegroundColor Magenta
    Write-Host "║     Superpowers + Pencil MCP                              ║" -ForegroundColor Magenta
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""
    
    # Verificar pré-requisitos
    Test-Prerequisites
    
    # Criar backup
    Backup-Config -ConfigPath $OpenCodeConfigPath
    
    # Ler configuração
    $config = Get-OpenCodeConfig -ConfigPath $OpenCodeConfigPath
    
    # Configurar Superpowers
    Add-Superpowers -Config ([ref]$config)
    
    # Tentar instalação via npm no Windows
    if (-not (Test-Path "$env:USERPROFILE\.config\opencode\node_modules\superpowers")) {
        $npmInstalled = Install-SuperpowersNpm
        if ($npmInstalled) {
            # Atualizar caminho do plugin para uso local
            $config.plugin = @($config.plugin | Where-Object { $_ -notmatch "superpowers" })
            $config.plugin += "~/.config/opencode/node_modules/superpowers"
        }
    }
    
    # Configurar Pencil MCP
    Add-PencilMCP -Config ([ref]$config)
    
    # Salvar configuração
    Save-Config -Config ([ref]$config) -ConfigPath $OpenCodeConfigPath
    
    # Instruções finais
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║     Instalação Concluída!                                 ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "Próximos passos:" -ForegroundColor Yellow
    Write-Host "  1. Reinicie o OpenCode" -ForegroundColor White
    Write-Host "  2. Para testar Superpowers, pergunte: 'Tell me about your superpowers'" -ForegroundColor White
    Write-Host "  3. Para testar Pencil, use comandos de design" -ForegroundColor White
    Write-Host ""
    Write-Host "Para reinstalar, execute novamente com -Force" -ForegroundColor Gray
    Write-Host ""
}

# Executar
Main