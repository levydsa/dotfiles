
--
--   minimalist neovim configuration
--   by Levy A.
--

autocmd = vim.api.nvim_create_autocmd
fn = vim.fn

vim.opt.nu = true                     -- line numbers
vim.opt.rnu = true                    -- show line number relative to cursor line
vim.opt.redrawtime = 10000            -- more time to redraw (better for larger files)
vim.opt.cmdheight = 2                 -- larger command line
vim.opt.wrap = false                  -- no warping
vim.opt.wildmenu = true               -- better completion menu
vim.opt.ignorecase = true             -- ignore case sensitive search
vim.opt.smartcase = true              -- overwrite 'ignorecase' if search has upper case chars
vim.opt.hlsearch = true               -- highlight search
vim.opt.updatetime = 300              -- swap write to disk delay
vim.opt.signcolumn = 'auto'           -- automatic signs
vim.opt.colorcolumn = {81}            -- color column
vim.opt.encoding = 'utf-8'            -- utf-8 encoding
vim.opt.spelllang = {'en_us','pt_br'} -- spell check English and Brazilian Portuguese
vim.opt.showtabline = 2               -- always show the tab line

-- Show tabs and trailing spaces
vim.opt.list = true
vim.opt.listchars = { tab = '│ ' , trail = '~' }

-- disable mouse
vim.opt.mouse = ""

-- disable auto-comment
vim.opt.formatoptions:remove('c')
vim.opt.formatoptions:remove('r')
vim.opt.formatoptions:remove('o')

-- who needs airline?
function status()
  local spell = vim.opt.spell
  local langs = vim.opt.spelllang
  return ' %f %m%r%y '
  .. (spell:get() and '[' .. table.concat(langs:get(), ', ') .. ']' or '')
  .. '%=(%l, %c) (0x%B) (%P) [%L] '
end
vim.opt.statusline = '%!v:lua.status()'

-- don't keep or make backup
vim.opt.writebackup = false
vim.opt.backup      = false

-- indentation
vim.opt.smartindent = true
vim.opt.expandtab = false  -- don't expand tabs by default
vim.opt.shiftwidth = 0     -- default to tabstop

vim.g.mapleader = ' ' -- leader is space
vim.g.c_syntax_for_h = true -- don't know why the default is cpp :/

-- (s)et s(p)ell
vim.keymap.set('n', '<leader>sp', function()
  vim.opt.spell = not(vim.opt.spell:get())
end)

-- (t)o(g)gle search
vim.keymap.set('n', '<leader>tg', function()
  fn.setreg('/', (fn.getreg('/') == '') and fn.expand("<cword>") or '')
end)

-- custom indentation per filetype
local typecmd = {
  html = [[ setlocal ts=2 ]],
  tex  = [[ setlocal ts=2 ]],
  css  = [[ setlocal ts=2 ]],
  xml  = [[ setlocal ts=2 ]],
  vim  = [[ setlocal ts=2 ]],
  sh   = [[ setlocal ts=2 ]],
  asm  = [[ setlocal ts=2 ]],
  go   = [[ setlocal ts=4 ]],
  cpp  = [[ setlocal ts=4 ]],
  lua  = [[ setlocal ts=2 et ]],
  elm  = [[ setlocal ts=2 et ]],
  javascript = [[ setlocal ts=4 et ]],
  markdown = [[ setlocal ts=4 et ]],
  haskell = [[ setlocal ts=4 et ]],
}

for filetype, cmd in pairs(typecmd) do
  autocmd("FileType", { pattern = { filetype }, command = cmd })
end

-- auto-save
autocmd({"TextChanged", "InsertLeave"}, {
  pattern = { '*' },
  callback = function()
    if fn.expand('%') ~= "" and not vim.bo.readonly then
      vim.cmd.update()
    end
  end,
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local lazyurl = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({
    "git", "clone", "--filter=blob:none", lazyurl, "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "nvim-telescope/telescope.nvim", -- fuzzy OwO
    branch = '0.1.x',
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
    end
  },
  {
    "bluz71/vim-moonfly-colors",
    name = "moonfly",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("moonfly")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { "zig", "c", "cpp", "lua", "vim", "python" },
        sync_install = false,
        auto_install = false,
        highlight = { enable = true },
      }
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("indent_blankline").setup{}
    end,
  }
})
