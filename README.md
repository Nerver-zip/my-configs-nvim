# ⚡ Neovim Config (NvChad Custom)

Minha configuração personalizada do Neovim baseada no **NvChad v2.5**, otimizada para desenvolvimento rápido, estética moderna e portabilidade total.

## 💡 Motivação

Esta configuração foi reformulada para ser **100% portátil** e livre de dependências de caminhos absolutos hardcoded ou de privilégios de superusuário (`sudo`). 

O objetivo principal é carregar instantaneamente o mesmo ambiente de desenvolvimento completo em:
- Qualquer distribuição Linux (Desktop/Servidores).
- **Termux** (Android).
- Servidores e computadores compartilhados onde não há acesso root.

## 🚀 Como Instalar

Você pode instalar a configuração de duas formas:

### Método 1: Instalação Direta (Um único comando)
Execute o comando abaixo no seu terminal para baixar e rodar o instalador interativo:
```bash
curl -fsSL https://raw.githubusercontent.com/Nerver-zip/nvim/main/install.sh | bash
```

### Método 2: Instalação Manual (Git Clone)
Se preferir clonar o repositório manualmente:
```bash
# 1. Clone o repositório
git clone https://github.com/Nerver-zip/nvim.git ~/.config/nvim

# 2. Acesse a pasta e execute o instalador
cd ~/.config/nvim && ./install.sh
```

---

### O que o `install.sh` faz?
- **Compilação do Neovim da Fonte (Opcional):** Permite compilar a última versão estável do Neovim e instalá-la em seu diretório de usuário (`~/.local`) sem necessitar de privilégios root.
- **Backup automático:** Protege sua configuração anterior movendo-a para `~/.config/nvim.bak`.
- **Limpeza profunda:** Remove caches e dados antigos do Neovim (`~/.local/share/nvim`, etc.) evitando que plugins legados incompatíveis quebrem a nova instalação.

---
*Baseado no [NvChad v2.5](https://github.com/NvChad/NvChad).*
