-- simple neovim config
--  completely self contained
--

local autocmd = vim.api.nvim_create_autocmd

vim.opt.nu = true                        -- line numbers
vim.opt.rnu = true                       -- show line number relative to cursor line
vim.opt.redrawtime = 10000               -- more time to redraw (better for larger files)
vim.opt.cmdheight = 2                    -- larger command line
vim.opt.wrap = false                     -- no warping
vim.opt.wildmenu = true                  -- better completion menu
vim.opt.ignorecase = true                -- ignore case sensitive search
vim.opt.smartcase = true                 -- overwrite 'ignorecase' if search has upper case chars
vim.opt.hlsearch = true                  -- highlight search
vim.opt.updatetime = 300                 -- swap write to disk delay
vim.opt.signcolumn = 'yes:1'             -- automatic signs
vim.opt.colorcolumn = { 81 }             -- color column
vim.opt.encoding = 'utf-8'               -- utf-8 encoding
vim.opt.spelllang = { 'en_us', 'pt_br' } -- spell check English and Brazilian Portuguese
vim.opt.showtabline = 2                  -- always show the tab line

vim.g.netrw_keepdir = 0
vim.g.netrw_banner = 0

-- Show tabs and trailing spaces
vim.opt.listchars:append({ trail = "~", tab = "┃ ", space = "·" })
vim.opt.list = true

vim.opt.mouse = ""
autocmd("FileType", { pattern = { "*" }, command = [[setlocal fo-=cro]] })

-- who needs airline?
function Status()
    local spell = vim.opt.spell
    local langs = vim.opt.spelllang
    return ' %f %m%r%y '
        .. (spell:get() and '[' .. table.concat(langs:get(), ', ') .. ']' or '')
        .. '%=(%l, %c) (0x%B) (%P) [%L] '
end

vim.opt.statusline   = '%!v:lua.Status()'

-- don't keep or make backup
vim.opt.writebackup  = false
vim.opt.backup       = false

-- indentation
vim.opt.smartindent  = true
vim.opt.expandtab    = false -- don't expand tabs by default
vim.opt.shiftwidth   = 0     -- default to tabstop
vim.opt.tabstop      = 4     -- 4 spaces indent

vim.g.mapleader      = ' '   -- leader is space
vim.g.c_syntax_for_h = true  -- don't know why the default is cpp :/

vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y')
vim.keymap.set({ 'n', 'v' }, '<leader>p', '"+p')

-- (s)et s(p)ell
vim.keymap.set('n', '<leader>sp', function()
    vim.opt.spell = not (vim.opt.spell:get())
end)

-- (t)o(g)gle search
vim.keymap.set('n', '<leader>tg', function()
    vim.fn.setreg('/', (vim.fn.getreg('/') == '') and vim.fn.expand("<cword>") or '')
end)

vim.keymap.set('t', '<esc>', '<c-\\><c-n>')
vim.keymap.set('t', '<leader>gb', function()
    vim.cmd.pop();
end)
vim.keymap.set('t', '<leader>h', function()
    vim.lsp.inlay_hint.enable(0, not vim.lsp.inlay_hint.is_enabled())
end)

vim.diagnostic.config {
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.HINT] = "",
            [vim.diagnostic.severity.INFO] = "",
        },
    },
}

-- custom indentation per filetype
local typecmd = {
    lean = [[ setlocal ts=2 et ]],
    sql  = [[ setlocal ts=2 et ]],
    html = [[ setlocal ts=2 et ]],
    tex  = [[ setlocal ts=2 et ]],
    css  = [[ setlocal ts=2 et ]],
    xml  = [[ setlocal ts=2 et ]],
    sh   = [[ setlocal ts=2 et ]],
    asm  = [[ setlocal ts=2 et ]],
    elm  = [[ setlocal ts=2 et ]],
    lua  = [[ setlocal ts=4 et ]],
}

for filetype, cmd in pairs(typecmd) do
    autocmd("FileType", { pattern = { filetype }, command = cmd })
end

-- auto-save
autocmd({ "TextChanged", "InsertLeave" }, {
    pattern = { '*' },
    callback = function()
        if vim.fn.expand('%') ~= "" and not vim.bo.readonly and vim.bo then
            vim.cmd([[silent! update]])
        end
    end,
})

vim.filetype.add {
    extension = { templ = "templ" },
    pattern = {
        ["*.zig.zon"] = "zig",
    },
}

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
        "bluz71/vim-moonfly-colors",
        name = "moonfly",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("moonfly")
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        main = "nvim-treesitter.configs",
        build = ":TSUpdate",
        opts = {
            ensure_installed = { "vimdoc", "lua", "markdown" },
            highlight = { enable = true },

            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-space>",
                    node_incremental = "<C-space>",
                    scope_incremental = false,
                    node_decremental = "<bs>",
                },
            },
        }
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            {
                "williamboman/mason.nvim",
                opts = {},
            },
            {
                "williamboman/mason-lspconfig.nvim",
                opts = { automatic_installation = true },
            },
        },
        opts = {
            servers = {
                rust_analyzer = {
                    imports = {
                        granularity = {
                            group = "module",
                        },
                        prefix = "self",
                    },
                    cargo = {
                        buildScripts = {
                            enable = true,
                        },
                    },
                    procMacro = {
                        enable = true
                    },
                },
                lua_ls = {
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = { 'vim', 'require' },
                            },
                            workspace = {
                                library = vim.api.nvim_get_runtime_file("", true),
                            },
                            telemetry = { enable = false },
                        },
                    },
                },
                clangd = {},
                jdtls = {},
                templ = {},
                tsserver = {},
                gopls = {},
                html = {
                    filetypes = { "html", "templ" },
                },
                htmx = {
                    filetypes = { "html", "templ" },
                },
                tailwindcss = {
                    filetypes = { "js", "rust", "html" },
                    init_options = {
                        userLanguages = {
                            rust = "html",
                        },
                    },
                },
            }
        },
        config = function(_, opts)
            local lspconfig = require('lspconfig')


            local capabilities = vim.tbl_deep_extend(
                "force",
                vim.lsp.protocol.make_client_capabilities(),
                require('cmp_nvim_lsp').default_capabilities()
            )

            for server, config in pairs(opts.servers) do
                lspconfig[server].setup(vim.tbl_deep_extend("keep", vim.deepcopy(capabilities), config))
            end

            autocmd("LspAttach", {
                callback = function(event)
                    -- vim.lsp.inlay_hint.enable(event.buf, true)

                    local opts = { buffer = event.buf }

                    vim.bo[event.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

                    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
                    vim.keymap.set("n", "<leader>gd", vim.lsp.buf.declaration, opts)
                    vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, opts)
                    vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, opts)
                    vim.keymap.set("n", "<leader>ga", vim.lsp.buf.code_action, opts)
                end
            })
        end,
    },
    {
        'laytan/tailwind-sorter.nvim',
        ft = { "templ", "html", "rust" },
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'nvim-lua/plenary.nvim',
        },
        build = 'cd formatter && npm i && npm run build',
        config = true,
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",

            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
        },
        config = function()
            local cmp = require('cmp')

            cmp.setup({
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-d>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<Tab>'] = cmp.mapping.confirm({ select = true }),
                }),
                sources = cmp.config.sources({
                    { name = 'path' },
                    { name = 'nvim_lsp' },
                }, {
                    { name = 'buffer' },
                })
            })

            cmp.setup.cmdline({ '/', '?' }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' }
                }
            })

            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = 'path' }
                }, {
                    { name = 'cmdline' }
                })
            })
        end
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {
            indent = { char = "┃" },
            scope = {
                show_start = false,
                show_end = false,
            },
        }
    },
    {
        "nvim-telescope/telescope.nvim", -- fuzzy OwO
        branch = "0.1.x",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
            vim.keymap.set("n", "<leader>fw", builtin.spell_suggest, {})
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
            vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
            vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
        end,
    },
    {
        'Julian/lean.nvim',
        ft = { "lean" },
        dependencies = {
            'neovim/nvim-lspconfig',
            'nvim-lua/plenary.nvim',
        },
        opts = { mappings = true }
    },
    {
        'vxpm/ferris.nvim',
        opts = {}
    }
})
