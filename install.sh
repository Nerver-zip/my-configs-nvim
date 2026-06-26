#!/bin/bash

# Cores para o terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sem cor

echo -e "${BLUE}===================================================${NC}"
echo -e "${BLUE}   Instalador de Configuração Personalizada Neovim  ${NC}"
echo -e "${BLUE}===================================================${NC}"

NVIM_DIR="$HOME/.config/nvim"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IN_DEST_DIR=false

# Verifica se o script está rodando de dentro da pasta destino final
if [ "$SCRIPT_DIR" = "$NVIM_DIR" ]; then
    IN_DEST_DIR=true
fi

# =========================================================
# 1. Opção de Instalar o Neovim a partir da Fonte
# =========================================================
read -p "Deseja instalar o Neovim compilando a partir da fonte? [y/N]: " build_from_source < /dev/tty

if [[ "$build_from_source" =~ ^[yY]$ ]]; then
    # IMPORTANTE: Não sobrescrevemos a variável 'PREFIX', pois no Termux ela é exportada
    # e aponta para o diretório de pacotes (/data/data/com.termux/files/usr).
    # Alterá-la quebra o CMake/compilador que não conseguem achar os headers do sistema.
    NVIM_INSTALL_PREFIX="$HOME/.local"
    BUILD_DIR="$HOME/.cache/neovim-build"

    echo -e "${BLUE}Clonando o repositório do Neovim (branch stable)...${NC}"
    rm -rf "$BUILD_DIR"
    git clone --depth 1 --branch stable https://github.com/neovim/neovim.git "$BUILD_DIR"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}[✗] Falha ao clonar o Neovim.${NC}"
        exit 1
    fi
    
    cd "$BUILD_DIR"
    echo -e "${BLUE}Compilando o Neovim... (isso pode levar alguns minutos)${NC}"
    make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX="$NVIM_INSTALL_PREFIX"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}[✗] Erro durante a compilação do Neovim.${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}Instalando o Neovim em $NVIM_INSTALL_PREFIX...${NC}"
    make install CMAKE_INSTALL_PREFIX="$NVIM_INSTALL_PREFIX"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}[✗] Erro durante a instalação do Neovim.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}[✓] Neovim compilado e instalado com sucesso!${NC}"
    
    # Limpeza
    cd - >/dev/null
    rm -rf "$BUILD_DIR"
    
    # Ajuste de PATH caso tenha sido instalado localmente
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo -e "${YELLOW}[!] ATENÇÃO: Adicione $HOME/.local/bin ao seu PATH para rodar o Neovim.${NC}"
        echo -e "    Adicione a seguinte linha ao seu ~/.bashrc ou ~/.zshrc e reinicie o terminal:"
        echo -e "    ${BLUE}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
    fi
fi

# =========================================================
# 2. Instalação dos Arquivos de Configuração
# =========================================================

# Limpeza de caches e dados antigos do Neovim
echo -e "${YELLOW}[!] Limpando caches e dados antigos do Neovim...${NC}"
rm -rf "$HOME/.local/share/nvim"
rm -rf "$HOME/.local/state/nvim"
rm -rf "$HOME/.cache/nvim"
echo -e "${GREEN}[✓] Limpeza de dados antigos concluída.${NC}"

if [ "$IN_DEST_DIR" = true ]; then
    echo -e "${GREEN}[✓] O instalador está rodando de dentro da pasta de destino ($NVIM_DIR).${NC}"
    echo -e "${GREEN}[✓] Pulando etapa de download/clonagem da configuração.${NC}"
else
    # Backup da configuração atual se ela existir
    if [ -d "$NVIM_DIR" ]; then
        BACKUP_DIR="$HOME/.config/nvim.bak.$(date +%Y%m%d_%H%M%S)"
        echo -e "${YELLOW}[!] Encontrada configuração existente em $NVIM_DIR${NC}"
        echo -e "${YELLOW}[!] Criando backup em $BACKUP_DIR...${NC}"
        mv "$NVIM_DIR" "$BACKUP_DIR"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[✓] Backup concluído com sucesso.${NC}"
        else
            echo -e "${RED}[✗] Falha ao criar o backup. Abortando por segurança.${NC}"
            exit 1
        fi
    fi

    # Como o repositório é privado, usamos clone via Git (SSH/HTTPS) que lida com autenticação do usuário
    REPO_URL="git@github.com:Nerver-zip/nvim.git"
    echo -e "${BLUE}[!] Clonando a nova configuração a partir de $REPO_URL...${NC}"
    
    # Tenta clonar via SSH
    git clone --depth 1 "$REPO_URL" "$NVIM_DIR"
    if [ $? -ne 0 ]; then
        # Se falhar (por exemplo, sem chaves SSH cadastradas na máquina nova), tenta HTTPS
        REPO_URL_HTTPS="https://github.com/Nerver-zip/nvim.git"
        echo -e "${YELLOW}[!] Falha ao clonar via SSH. Tentando via HTTPS ($REPO_URL_HTTPS)...${NC}"
        git clone --depth 1 "$REPO_URL_HTTPS" "$NVIM_DIR"
    fi

    if [ $? -ne 0 ]; then
        echo -e "${RED}[✗] Falha ao clonar o repositório de configuração.${NC}"
        echo -e "${RED}[!] Certifique-se de possuir acesso de leitura ao repositório privado.${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}===================================================${NC}"
echo -e "${GREEN}[✓] Instalação concluída com sucesso!${NC}"
echo -e "${GREEN}===================================================${NC}"
echo -e "${YELLOW}Para finalizar a instalação:${NC}"
echo -e "1. Abra o Neovim digitando: ${BLUE}nvim${NC}"
echo -e "2. O lazy.nvim irá baixar e instalar todos os plugins automaticamente."
echo -e "3. Depois que a instalação terminar, feche e abra o Neovim novamente."
