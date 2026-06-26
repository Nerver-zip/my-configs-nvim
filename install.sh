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

# =========================================================
# 1. Opção de Instalar o Neovim a partir da Fonte
# =========================================================
read -p "Deseja instalar o Neovim compilando a partir da fonte? [y/N]: " build_from_source < /dev/tty

if [[ "$build_from_source" =~ ^[yY]$ ]]; then
    echo -e "${BLUE}Onde deseja instalar o Neovim?${NC}"
    echo -e "1) Globalmente (/usr/local) - requer privilégios de superusuário (sudo)"
    echo -e "2) Localmente ($HOME/.local) - recomendado para Termux, sem acesso root ou computadores compartilhados"
    read -p "Escolha [1/2, padrão 2]: " prefix_choice < /dev/tty
    
    PREFIX="$HOME/.local"
    USE_SUDO=false
    if [ "$prefix_choice" = "1" ]; then
        PREFIX="/usr/local"
        USE_SUDO=true
    fi

    # Detecção do gerenciador de pacotes para instalar as dependências de compilação
    if [ -f /etc/debian_version ]; then
        PKG_MAN="apt"
    elif [ -f /etc/arch-release ]; then
        PKG_MAN="pacman"
    elif [ -f /etc/fedora-release ] || [ -f /etc/redhat-release ]; then
        PKG_MAN="dnf"
    elif [ -n "$TERMUX_VERSION" ] || [ -x "$(command -v termux-setup-storage)" ]; then
        PKG_MAN="termux"
    elif [ -x "$(command -v brew)" ]; then
        PKG_MAN="brew"
    else
        PKG_MAN="unknown"
    fi

    case "$PKG_MAN" in
        apt)
            echo -e "${BLUE}Instalando dependências de compilação via apt...${NC}"
            sudo apt-get update && sudo apt-get install -y ninja-build gettext cmake unzip curl build-essential git
            ;;
        pacman)
            echo -e "${BLUE}Instalando dependências de compilação via pacman...${NC}"
            sudo pacman -S --needed --noconfirm base-devel cmake unzip ninja gettext curl git
            ;;
        dnf)
            echo -e "${BLUE}Instalando dependências de compilação via dnf...${NC}"
            sudo dnf install -y cmake gcc-c++ make unzip gettext ninja-build curl git
            ;;
        termux)
            echo -e "${BLUE}Instalando dependências de compilação no Termux...${NC}"
            pkg update && pkg install -y clang cmake make ninja pkg-config gettext libuv libgcrypt libtool curl unzip git
            ;;
        brew)
            echo -e "${BLUE}Instalando dependências de compilação via Homebrew...${NC}"
            brew install cmake ninja gettext curl unzip git
            ;;
        *)
            echo -e "${YELLOW}Não foi possível detectar o gerenciador de pacotes automaticamente.${NC}"
            echo -e "${YELLOW}Certifique-se de ter instalado os pacotes: cmake, ninja, gettext, make, compilador C (gcc/clang), git, curl e unzip.${NC}"
            ;;
    esac

    # Clone e compilação do Neovim
    BUILD_DIR="/tmp/neovim-build"
    echo -e "${BLUE}Clonando o repositório do Neovim (branch stable)...${NC}"
    rm -rf "$BUILD_DIR"
    git clone --depth 1 --branch stable https://github.com/neovim/neovim.git "$BUILD_DIR"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}[✗] Falha ao clonar o Neovim.${NC}"
        exit 1
    fi
    
    cd "$BUILD_DIR"
    echo -e "${BLUE}Compilando o Neovim... (isso pode levar alguns minutos)${NC}"
    make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX="$PREFIX"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}[✗] Erro durante a compilação do Neovim.${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}Instalando o Neovim em $PREFIX...${NC}"
    if [ "$USE_SUDO" = true ]; then
        sudo make install
    else
        make install
    fi
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}[✗] Erro durante a instalação do Neovim.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}[✓] Neovim compilado e instalado com sucesso!${NC}"
    
    # Limpeza
    cd - >/dev/null
    rm -rf "$BUILD_DIR"
    
    # Ajuste de PATH caso tenha sido instalado localmente
    if [ "$USE_SUDO" = false ]; then
        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            echo -e "${YELLOW}[!] ATENÇÃO: Adicione $HOME/.local/bin ao seu PATH para rodar o Neovim.${NC}"
            echo -e "    Adicione a seguinte linha ao seu ~/.bashrc ou ~/.zshrc e reinicie o terminal:"
            echo -e "    ${BLUE}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
        fi
    fi
fi

# =========================================================
# 2. Instalação dos Arquivos de Configuração
# =========================================================
NVIM_DIR="$HOME/.config/nvim"

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

# Limpeza de caches e dados antigos do Neovim
echo -e "${YELLOW}[!] Limpando caches e dados antigos do Neovim...${NC}"
rm -rf "$HOME/.local/share/nvim"
rm -rf "$HOME/.local/state/nvim"
rm -rf "$HOME/.cache/nvim"
echo -e "${GREEN}[✓] Limpeza de dados antigos concluída.${NC}"

# Download e extração da release
VERSION="v1.0.0"
RELEASE_URL="https://github.com/Nerver-zip/nvim/archive/refs/tags/${VERSION}.tar.gz"

echo -e "${BLUE}[!] Baixando e extraindo a configuração (${VERSION}) a partir de $RELEASE_URL...${NC}"
mkdir -p "$NVIM_DIR"

curl -L "$RELEASE_URL" | tar -xzf - -C "$NVIM_DIR" --strip-components=1
if [ ${PIPESTATUS[0]} -eq 0 ] && [ ${PIPESTATUS[1]} -eq 0 ]; then
    echo -e "${GREEN}===================================================${NC}"
    echo -e "${GREEN}[✓] Configuração instalada com sucesso!${NC}"
    echo -e "${GREEN}===================================================${NC}"
    echo -e "${YELLOW}Para finalizar a instalação:${NC}"
    echo -e "1. Abra o Neovim digitando: ${BLUE}nvim${NC}"
    echo -e "2. O lazy.nvim irá baixar e instalar todos os plugins automaticamente."
    echo -e "3. Depois que a instalação terminar, feche e abra o Neovim novamente."
else
    echo -e "${RED}[✗] Falha ao baixar ou extrair a configuração.${NC}"
    echo -e "${RED}[!] Certifique-se de que a versão ${VERSION} existe no GitHub e que você possui conexão com a internet.${NC}"
    exit 1
fi
