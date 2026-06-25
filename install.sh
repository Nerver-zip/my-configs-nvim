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
REPO_URL="https://github.com/Nerver-zip/nvim.git"

# 1. Backup da configuração atual se ela existir
if [ -d "$NVIM_DIR" ]; then
    BACKUP_DIR="$HOME/.config/nvim.bak.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}[!] Encontrada configuração existente em $NVIM_DIR${NC}"
    echo -e "${YELLOW}[!] Criando backup em $BACKUP_DIR...${NC}"
    mv "$NVIM_DIR" "$BACKUP_DIR"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[✓] Backup concluído com sucesso.${NC}"
    else
        echo -e "${RED}[✗] Falha ao criar o backup. Abortando instalação por segurança.${NC}"
        exit 1
    fi
fi

# 2. Remoção de dados antigos e caches para evitar conflitos de plugins
echo -e "${YELLOW}[!] Limpando caches e dados antigos do Neovim...${NC}"
rm -rf "$HOME/.local/share/nvim"
rm -rf "$HOME/.local/state/nvim"
rm -rf "$HOME/.cache/nvim"
echo -e "${GREEN}[✓] Limpeza de dados antigos concluída.${NC}"

VERSION="v1.0.0"
RELEASE_URL="https://github.com/Nerver-zip/nvim/archive/refs/tags/${VERSION}.tar.gz"

# 3. Download e extração da release
echo -e "${BLUE}[!] Baixando e extraindo a configuração (${VERSION}) a partir de $RELEASE_URL...${NC}"
mkdir -p "$NVIM_DIR"

curl -L "$RELEASE_URL" | tar -xzf - -C "$NVIM_DIR" --strip-components=1
if [ ${PIPESTATUS[0]} -eq 0 ] && [ ${PIPESTATUS[1]} -eq 0 ]; then
    echo -e "${GREEN}===================================================${NC}"
    echo -e "${GREEN}[✓] Instalação concluída com sucesso!${NC}"
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
