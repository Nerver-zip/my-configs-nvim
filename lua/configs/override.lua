return {
  defaults = {
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--no-ignore",      -- ignora o .gitignore
      "--hidden",         -- inclui arquivos escondidos
    },
    file_ignore_patterns = {}, -- nenhum padrão de ignore
  },
  pickers = {
    find_files = {
      hidden = true,       -- inclui dotfiles
      no_ignore = true,    -- ignora o .gitignore
      find_command = { "fd", "--type", "f", "--hidden", "--no-ignore" },
    },
  },
}

