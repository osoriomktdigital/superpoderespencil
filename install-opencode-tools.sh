#!/bin/bash

# =============================================================================
# OpenCode Setup - Superpowers + Pencil MCP
# 
# Script de instalação automática para configurar Superpowers e Pencil MCP
# no OpenCode.
# =============================================================================

set -e  # Sair imediatamente se um comando falhar

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funções de output
print_step() {
    echo -e "${BLUE}→ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Verificar pré-requisitos
check_prerequisites() {
    print_step "Verificando pré-requisitos..."
    
    # Verificar se OpenCode está instalado
    if ! command -v opencode &> /dev/null; then
        print_error "OpenCode não encontrado. Instale em https://opencode.ai"
        exit 1
    fi
    print_success "OpenCode encontrado"
    
    # Verificar se git está instalado
    if ! command -v git &> /dev/null; then
        print_error "Git não encontrado. Instale em https://git-scm.com"
        exit 1
    fi
    print_success "Git encontrado"
    
    # Verificar se npm está instalado
    if ! command -v npm &> /dev/null; then
        print_warning "npm não encontrado. Algumas funcionalidades podem não funcionar."
    else
        print_success "npm encontrado"
    fi
}

# Criar backup do arquivo de configuração
backup_config() {
    local config_path="$1"
    
    if [ -f "$config_path" ]; then
        local backup_path="${config_path}.backup.$(date +%Y%m%d-%H%M%S)"
        print_step "Criando backup: $backup_path"
        cp "$config_path" "$backup_path"
        print_success "Backup criado"
    fi
}

# Ler configuração existente
get_opencode_config() {
    local config_path="$1"
    
    if [ -f "$config_path" ]; then
        print_step "Lendo configuração existente..."
        cat "$config_path"
    else
        print_step "Criando nova configuração..."
        cat <<EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "plugin": [],
  "mcp": {}
}
EOF
    fi
}

# Adicionar Superpowers plugin
add_superpowers() {
    local config_content="$1"
    
    print_step "Configurando Superpowers..."
    
    # Verificar se já está instalado
    if echo "$config_content" | grep -q "superpowers"; then
        print_warning "Superpowers já está configurado"
        echo "$config_content"
        return
    fi
    
    # Adicionar plugin usando jq se disponível, senão usar python
    if command -v jq &> /dev/null; then
        echo "$config_content" | jq '.plugin += ["superpowers@git+https://github.com/obra/superpowers.git"]'
    elif command -v python3 &> /dev/null; then
        echo "$config_content" | python3 -c "
import json, sys
config = json.load(sys.stdin)
if 'plugin' not in config:
    config['plugin'] = []
config['plugin'].append('superpowers@git+https://github.com/obra/superpowers.git')
print(json.dumps(config, indent=2))
"
    else
        # Fallback: inserção manual via sed
        print_warning "jq e python3 não encontrados. Configurando manualmente..."
        echo "$config_content" | sed 's/"plugin": \[/&"superpowers@git+https:\/\/github.com\/obra\/superpowers.git", /'
    fi
    
    print_success "Superpowers configurado"
}

# Configurar Pencil MCP
add_pencil_mcp() {
    local config_content="$1"
    
    print_step "Configurando Pencil MCP..."
    
    # Verificar se já está configurado
    if echo "$config_content" | grep -q '"pencil"'; then
        print_warning "Pencil MCP já está configurado"
        echo "$config_content"
        return
    fi
    
    # Configuração do Pencil MCP
    local pencil_config='{
      "command": [
        "D:\\programas ssd\\IA\\Pencil\\resources\\app.asar.unpacked\\out\\mcp-server-windows-x64.exe",
        "--app",
        "desktop",
        "--agent",
        "openCodeCLI"
      ],
      "enabled": true,
      "type": "local"
    }'
    
    # Adicionar configuração usando jq se disponível
    if command -v jq &> /dev/null; then
        echo "$config_content" | jq --argjson pencil "$pencil_config" '.mcp.pencil = $pencil'
    elif command -v python3 &> /dev/null; then
        echo "$config_content" | python3 -c "
import json, sys
config = json.load(sys.stdin)
if 'mcp' not in config:
    config['mcp'] = {}
config['mcp']['pencil'] = {
    'command': [
        'D:\\programas ssd\\IA\\Pencil\\resources\\app.asar.unpacked\\out\\mcp-server-windows-x64.exe',
        '--app',
        'desktop',
        '--agent',
        'openCodeCLI'
    ],
    'enabled': True,
    'type': 'local'
}
print(json.dumps(config, indent=2))
"
    else
        print_warning "Configuração do Pencil MCP requer jq ou python3"
    fi
    
    print_success "Pencil MCP configurado"
}

# Salvar configuração
save_config() {
    local config_content="$1"
    local config_path="$2"
    
    print_step "Salvando configuração..."
    
    # Garantir que o diretório existe
    local config_dir=$(dirname "$config_path")
    mkdir -p "$config_dir"
    
    # Salvar JSON
    echo "$config_content" > "$config_path"
    
    print_success "Configuração salva em: $config_path"
}

# Função principal
main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     Instalador de Tools para OpenCode                    ║${NC}"
    echo -e "${BLUE}║     Superpowers + Pencil MCP                              ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Configurações
    local config_path="${HOME}/.config/opencode/opencode.json"
    
    # Verificar pré-requisitos
    check_prerequisites
    
    # Criar backup
    backup_config "$config_path"
    
    # Ler configuração
    local config_content=$(get_opencode_config "$config_path")
    
    # Configurar Superpowers
    config_content=$(add_superpowers "$config_content")
    
    # Configurar Pencil MCP
    config_content=$(add_pencil_mcp "$config_content")
    
    # Salvar configuração
    save_config "$config_content" "$config_path"
    
    # Instruções finais
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     Instalação Concluída!                                 ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Próximos passos:${NC}"
    echo -e "  1. Reinicie o OpenCode"
    echo -e "  2. Para testar Superpowers, pergunte: 'Tell me about your superpowers'"
    echo -e "  3. Para testar Pencil, use comandos de design"
    echo ""
}

# Executar
main "$@"