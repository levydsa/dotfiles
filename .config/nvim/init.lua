
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
vim.opt.signcolumn = 'yes:1'          -- automatic signs
vim.opt.colorcolumn = {81}            -- color column
vim.opt.encoding = 'utf-8'            -- utf-8 encoding
vim.opt.spelllang = {'en_us','pt_br'} -- spell check English and Brazilian Portuguese
vim.opt.showtabline = 2               -- always show the tab line

-- Show tabs and trailing spaces
vim.opt.listchars:append({ trail = "~", tab = "┃ ", space = "·" })
vim.opt.list = true

vim.opt.mouse = ""
autocmd("FileType", { pattern = { "*" }, command = [[setlocal fo-=cro]] })

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
vim.opt.shiftwidth = 0    -- default to tabstop
vim.opt.tabstop = 4       -- 4 spaces indent

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

vim.keymap.set('t', '<esc>', '<c-\\><c-n>')
vim.keymap.set('t', '<leader>gb', function()
  vim.cmd.pop();
end)

vim.fn.sign_define({
  { name = "DiagnosticSignError", texthl = "DiagnosticSignError", text = "" },
  { name = "DiagnosticSignHint",  texthl = "DiagnosticSignHint",  text = "" },
  { name = "DiagnosticSignWarn",  texthl = "DiagnosticSignWarn",  text = "" },
  { name = "DiagnosticSignInfo",  texthl = "DiagnosticSignInfo",  text = "" },
})

-- custom indentation per filetype
local typecmd = {
  html = [[ setlocal ts=2 et ]],
  tex  = [[ setlocal ts=2 et ]],
  css  = [[ setlocal ts=2 et ]],
  xml  = [[ setlocal ts=2 et ]],
  sh   = [[ setlocal ts=2 et ]],
  asm  = [[ setlocal ts=2 et ]],
  lua  = [[ setlocal ts=2 et ]],
  elm  = [[ setlocal ts=2 et ]],
}

for filetype, cmd in pairs(typecmd) do
  autocmd("FileType", { pattern = { filetype }, command = cmd })
end

-- auto-save
autocmd({"TextChanged", "InsertLeave"}, {
  pattern = { '*' },
  callback = function()
    if fn.expand('%') ~= "" and not vim.bo.readonly and vim.bo then
      vim.cmd([[silent! update]])
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
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
      vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
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
        ensure_installed = { "zig", "c", "cpp", "lua", "python" },
        sync_install = false,
        auto_install = false,
        highlight = { enable = true },
      }
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")

      lspconfig.zls.setup{}
      lspconfig.clangd.setup{}
      lspconfig.rust_analyzer.setup{}

      autocmd("LspAttach", {
        callback = function(event)
          local opts = { buffer = event.buf }
          vim.print(vim.inspect(event.buf))

          vim.keymap.set("n", "<leader>gd", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, opts)
        end
      })
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("ibl").setup{
				indent = { char = "┃" },
				scope = {
					show_start = false,
					show_end = false,
				}
			}
    end,
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      vim.keymap.set("n", "<leader>a", function() harpoon:list():append() end);
      vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end);
      vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end);
      vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end);
      vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end);
    end,
  },
  {
    "echasnovski/mini.move",
    version = false,
    config = function()
      require('mini.move').setup({
        mappings = {
          left = '<C-h>',
          right = '<C-l>',
          down = '<C-j>',
          up = '<C-k>',

          line_left = '<C-h>',
          line_right = '<C-l>',
          line_down = '<C-j>',
          line_up = '<C-k>',
        },
      })
    end
  },
})
