
--
--   minimalist neovim configuration
--   by Levy A.
--

autocmd = vim.api.nvim_create_autocmd
fn = vim.fn

local ensure_packer = function()
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()
local packer = require('packer')

packer.startup(function(use)
  -- packer
  use 'wbthomason/packer.nvim'

  -- fuzzy OwO
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.x',
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- general language support
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use 'simplosophy/vim-io'

  -- color scheme
  use { "bluz71/vim-moonfly-colors", as = "moonfly" }

  if packer_bootstrap then
    packer.sync()
    packer.install()
  end
end)

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
vim.opt.formatoptions:remove({'c', 'r', 'o'}) 

-- who needs airline?
function status()
  return ' %f %m%r%y '
  .. (vim.opt.spell:get() and '[Spell ('
  .. vim.inspect(vim.opt.spelllang:get())
  .. ')]' or '')
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

-- leader is space
vim.g.mapleader = ' '

-- don't know why the default is cpp
vim.g.c_syntax_for_h = true

vim.cmd.colorscheme('moonfly')

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

-- toggle search
vim.keymap.set('n', '<F3>', function()
  fn.setreg('/', (fn.getreg('/') == '') and fn.expand("<cword>") or '')
end)

-- telescope config
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- treesitter config
require('nvim-treesitter.configs').setup {
  -- install others as you go
  ensure_installed = { "c", "cpp", "lua", "vim", "python" },
  sync_install = false,
  auto_install = false,
  highlight = {
    enable = true,
    disable = function(lang, buf)
      local max_filesize = 100 * 1024 -- 100 KiB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
  },
}

