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
      "--no-ignore",      -- ignore .gitignore
      "--hidden",         -- include hidden files
    },
    file_ignore_patterns = {}, -- no ignore patterns
  },
  pickers = {
    find_files = {
      hidden = true,       -- include dotfiles
      no_ignore = true,    -- ignore .gitignore
      find_command = { "fd", "--type", "f", "--hidden", "--no-ignore" },
    },
  },
}
