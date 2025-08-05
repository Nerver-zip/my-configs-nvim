--No momento só tenho alguns overrides do telescope
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
      "--no-ignore",  -- força ignorar o .gitignore
    },
    file_ignore_patterns = { "^%.git$", "^node_modules$", "%.pyc$", "%.o$" },
  },
  pickers = {
    find_files = {
      hidden = true,
      no_ignore = true, -- não respeita .gitignore
      find_command = { "fd", "--type", "f", "--no-ignore", "--hidden" },
    },
  },
}
