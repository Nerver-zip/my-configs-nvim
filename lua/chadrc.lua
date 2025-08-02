-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 
---@type ChadrcConfig
local M = {}

M.base46 = {
    theme = "dark_horizon",
    hl_override = {
        -- Fundo geral
        Normal = { bg = "#000000" },
        NormalNC = { bg = "#000000" },

        -- Barra lateral (NvimTree)
        NvimTreeNormal = { bg = "#000000" },
        NvimTreeNormalNC = { bg = "#000000" },

        -- Divisórias e linhas de status
        WinSeparator = { fg = "#000000", bg = "#000000" },
        VertSplit = { fg = "#000000", bg = "#000000" },
        StatusLine = { bg = "#000000" },
        StatusLineNC = { bg = "#000000" },

        -- Telescope (se você usar)
        TelescopeNormal = { bg = "#000000" },
        TelescopeBorder = { bg = "#000000", fg = "#000000" },
    },

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}
-- M.nvdash = { load_on_startup = true }
-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
--}

return M
