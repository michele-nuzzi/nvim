local o = vim.o

local indent_len = 4;

o.expandtab = true --# expand tab input with spaces characters
o.smartindent = true --# syntax aware indentations for newline inserts
o.tabstop = indent_len --# num of space characters per tab
o.shiftwidth = indent_len --# spaces per indentation level

---- about this neovim-configuration

-- - features: completion, lsp, tree-sitter, formatter, automatic configuration of indendation.
-- - goals: web development with typescript and tsx.
-- - themes: on mac, one-light; otherwise, gruvbox.

---- external setup

-- - install git and neovim. e.g., with guix as package-manager, run:
--   guix install git neovim
-- - install "lazy" as neovim-specific package-manager:
--   git clone --filter=blob:none --branch=stable https://github.com/folke/lazy.nvim.git ~/.local/share/nvim/lazy/lazy.nvim
-- - install code-formatter and language servers using npm:
--   npm i -g prettier typescript typescript-language-server vscode-langservers-extracted

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"


require('lazy').setup(
  {

    ---- themes
    -- should have a high priority

    {
      'ellisonleao/gruvbox.nvim',
      priority = 1000,
    },

    {
      'navarasu/onedark.nvim',
      priority = 1000,
    },

    ---- autocompletion

    {
      -- package recommended by https://github.com/neovim/nvim-lspconfig/wiki/Autocompletion/217feffc675a17d8ab95259ed9d4c6d62e1cd2e1#autocompletion-not-built-in-vs-completion-built-in
      'hrsh7th/nvim-cmp',
      config = function(cmp)
        local cmp = require('cmp')
        cmp.setup({
          completion = { completeopt = 'menu,menuone,noinsert' },
          -- if desired, choose another keymap-preset:
          mapping = cmp.mapping.preset.insert(),
          -- optionally, add more completion-sources:
          sources = cmp.config.sources({{ name = 'nvim_lsp' }}),
        })
      end,
    },

    ---- code formatting

    {
      'mhartington/formatter.nvim',
      config = function()
        local formatter_prettier = { require('formatter.defaults.prettier') }
        require("formatter").setup({
          filetype = {
            javascript      = formatter_prettier,
            javascriptreact = formatter_prettier,
            typescript      = formatter_prettier,
            typescriptreact = formatter_prettier,
          }
        })
        -- automatically format buffer before writing to disk:
        vim.api.nvim_create_augroup('BufWritePreFormatter', {})
        vim.api.nvim_create_autocmd('BufWritePre', {
          command = 'FormatWrite',
          group = 'BufWritePreFormatter',
          pattern = { '*.js', '*.jsx', '*.ts', '*.tsx' },
        })
      end,
      ft = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    },

    ---- language server protocol (lsp)

    {
      -- use official lspconfig package (and enable completion):
      'neovim/nvim-lspconfig', dependencies = { 'hrsh7th/cmp-nvim-lsp' },
      config = function()
        local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
        local lsp_on_attach = function(client, bufnr)
          local bufopts = { noremap=true, silent=true, buffer=bufnr }
          -- following keymap is based on both lspconfig and lsp-zero.nvim:
          -- - https://github.com/neovim/nvim-lspconfig/blob/fd8f18fe819f1049d00de74817523f4823ba259a/README.md?plain=1#L79-L93
          -- - https://github.com/VonHeikemen/lsp-zero.nvim/blob/18a5887631187f3f7c408ce545fd12b8aeceba06/lua/lsp-zero/server.lua#L285-L298
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help                        , bufopts)
          vim.keymap.set('n', 'K'    , vim.lsp.buf.hover                                 , bufopts)
          vim.keymap.set('n', 'gD'   , vim.lsp.buf.declaration                           , bufopts)
          vim.keymap.set('n', 'gd'   , vim.lsp.buf.definition                            , bufopts)
          vim.keymap.set('n', 'gi'   , vim.lsp.buf.implementation                        , bufopts)
          vim.keymap.set('n', 'go'   , vim.lsp.buf.type_definition                       , bufopts)
          vim.keymap.set('n', 'gr'   , vim.lsp.buf.references                            , bufopts)
          --m.keymap.set('n', TODO   , vim.lsp.buf.code_action                           , bufopts) -- lspconfig: <space>ca; lsp-zero: <F4>
          --m.keymap.set('n', TODO   , function() vim.lsp.buf.format { async = true } end, bufopts) -- lspconfig: <space>f
          --m.keymap.set('n', TODO   , vim.lsp.buf.rename                                , bufopts) -- lspconfig: <space>rn; lsp-zero: <F2>
        end
        local lspconfig = require('lspconfig')
        -- enable both language-servers for both eslint and typescript:
        for _, server in pairs({ 'eslint', 'ts_ls' }) do
          lspconfig[server].setup({
            capabilities = lsp_capabilities,
            on_attach = lsp_on_attach,
          })
        end
      end,
      ft = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    },

    ---- indendation detection
    -- automatically configure indentation when a file is opened.

    { 'nmac427/guess-indent.nvim' },

    ---- file navigation and more

    { 'nvim-telescope/telescope.nvim', dependencies = { 'nvim-lua/plenary.nvim' },
      cmd = "Telescope",
      -- TODO: map keys.
    },

    ---- tree-sitter

    {
      'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
      config = function()
        require('nvim-treesitter.configs').setup({
          -- for syntax-highlight, instead of regular expressions, use tree-sitter:
          highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
          },
        })
      end,
    },
  },

  ---- lazy (package manager)

  {
    ui = {
      -- instead of emoji-icons, use ascii-strings:
      icons = {
        cmd = 'CMD',
        config = 'CONFIG',
        event = 'EVENT',
        ft = 'FT',
        init = 'INIT',
        keys = 'KEYS',
        plugin = 'PLUGIN',
        runtime = 'RUNTIME',
        source = 'SOURCE',
        start = 'START',
        task = 'TASK',
        lazy = 'LAZY',
      },
    },
  }
)

---- theme (2): on mac, use one-light; otherwise, use gruvbox:

if vim.fn.has('mac') == 1 then
  vim.opt.background = 'light'
  vim.cmd('colorscheme onedark')
else
  vim.opt.background = 'dark'
  vim.cmd('colorscheme gruvbox')
end

---- miscellaneous

vim.opt.cursorline = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = indent_len
vim.opt.signcolumn = 'number'
vim.opt.smartindent = true
vim.opt.softtabstop = indent_len
vim.opt.tabstop = indent_len;
