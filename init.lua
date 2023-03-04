--              AstroNvim Configuration Table
-- All configuration changes should go inside of the table below
-- You can think of a Lua "table" as a dictionary like data structure the
-- normal format is "key = value". These also handle array like data structures
-- where a value with no key simply has an implicit numeric key

local M = {}
local null_sources = {}
local cmd = vim.api.nvim_create_autocmd
local keymap = vim.api.nvim_set_keymap
local map = vim.keymap.set
local opts = { noremap = true, silent = true }
local actions = require "telescope.actions"
local action_set = require "telescope.actions.set"
local formatting = require("null-ls").builtins.formatting
local _, dashboard = pcall(require, "alpha.themes.dashboard")
local _, terminal = pcall(require, "toggleterm.terminal")

------------------------------------------------------------------------------------------------------------------------

local function stylua_config()
  for _, package in ipairs(require("mason-registry").get_installed_packages()) do
    if package.name == "stylua" then
      table.insert(
        null_sources,
        formatting[package.name].with {
          extra_args = {
            "--indent-width=2",
            "--indent-type=Spaces",
            "--call-parentheses=None",
            "--collapse-simple-statement=Always",
          },
        }
      )
    end
  end
end

stylua_config()

------------------------------------------------------------------------------------------------------------------------

local function fb_actions(action, prompt_bufnr)
  return require "telescope._extensions.file_browser.actions"[action](prompt_bufnr)
end

local function edit_register(prompt_bufnr)
  local selection = require("telescope.actions.state").get_selected_entry()
  local updated_value = vim.fn.input("Edit [" .. selection.value .. "] ❯ ", selection.content)

  vim.fn.setreg(selection.value:lower(), updated_value)
  selection.content = updated_value

  require("telescope.actions").close(prompt_bufnr)
  require("telescope.builtin").resume()
end

------------------------------------------------------------------------------------------------------------------------

local temp_path = "/tmp/lfpickerpath"
function _LF_TOGGLE(dir, openmode)
  terminal.Terminal:new({
    cmd = "lf -selection-path " .. temp_path .. " " .. dir,
    on_close = function()
      local file = io.open(temp_path, "r")
      if file ~= nil then
        vim.opt.number = true
        if openmode == 'tabreplace' then
          vim.cmd("tabnew " .. file:read("*a") .. " | tabclose #")
        else
          vim.cmd(openmode .. file:read("*a"))
        end
        file:close()
        os.remove(temp_path)
      end
    end
  }):toggle()
end

------------------------------------------------------------------------------------------------------------------------

M.EnableAutoNoHighlightSearch = function()
  vim.on_key(function(char)
    if vim.fn.mode() == "n" then
      local new_hlsearch = vim.tbl_contains({ "<Up>", "<Down>", "<CR>", "n", "N", "*", "#", "?", "/" },
        vim.fn.keytrans(char))
      if vim.opt.hlsearch:get() ~= new_hlsearch then vim.cmd [[ noh ]] end
    end
  end, vim.api.nvim_create_namespace "auto_hlsearch")
end

M.DisableAutoNoHighlightSearch = function()
  vim.on_key(nil, vim.api.nvim_get_namespaces()["auto_hlsearch"])
  vim.cmd [[ set hlsearch ]]
end

------------------------------------------------------------------------------------------------------------------------

_G.FeedKeysCorrectly = function(keys)
  local feedableKeys = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.api.nvim_feedkeys(feedableKeys, "n", true)
end

------------------------------------------------------------------------------------------------------------------------

_G.GoToParentIndent = function()
  local ok, start = require("indent_blankline.utils").get_current_context(
    vim.g.indent_blankline_context_patterns,
    vim.g.indent_blankline_use_treesitter_scope
  )
  if ok then
    vim.api.nvim_win_set_cursor(vim.api.nvim_get_current_win(), { start, 0 })
    vim.cmd [[normal! _]]
  end
end

------------------------------------------------------------------------------------------------------------------------

function GotoTextObj_Callback()
  FeedKeysCorrectly(vim.g.dotargs)
end

_G.GotoTextObj = function(action)
  vim.g.dotargs = action
  vim.o.operatorfunc = 'v:lua.GotoTextObj_Callback'
  return "g@"
end

------------------------------------------------------------------------------------------------------------------------

function WhichKeyRepeat_Callback()
  if vim.g.dotfirstcmd ~= nil then vim.cmd(vim.g.dotfirstcmd) end
  if vim.g.dotsecondcmd ~= nil then vim.cmd(vim.g.dotsecondcmd) end
  if vim.g.dotthirdcmd ~= nil then vim.cmd(vim.g.dotthirdcmd) end
end

_G.WhichkeyRepeat = function(firstcmd, secondcmd, thirdcmd)
  vim.g.dotfirstcmd = firstcmd
  vim.g.dotsecondcmd = secondcmd
  vim.g.dotthirdcmd = thirdcmd
  vim.o.operatorfunc = 'v:lua.WhichKeyRepeat_Callback'
  vim.cmd.normal { "g@l", bang = true }
end

------------------------------------------------------------------------------------------------------------------------

local config = {

  -- Configure AstroNvim updates
  updater = {
    remote = "origin", -- remote to use
    channel = "stable", -- "stable" or "nightly"
    version = "v2.*", -- "latest", tag name, or regex search like "v1.*" to only do updates before v2 (STABLE ONLY)
    branch = "main", -- branch name (NIGHTLY ONLY)
    commit = nil, -- commit hash (NIGHTLY ONLY)
    pin_plugins = nil, -- nil, true, false (nil will pin plugins on stable only)
    skip_prompts = false, -- skip prompts about breaking changes
    show_changelog = true, -- show the changelog after performing an update
    auto_reload = false, -- automatically reload and sync packer after a successful update
    auto_quit = false -- automatically quit the current session after a successful update
    -- remotes = { -- easily add new remotes to track
    --   ["remote_name"] = "https://remote_url.come/repo.git", -- full remote url
    --   ["remote2"] = "github_user/repo", -- GitHub user/repo shortcut,
    --   ["remote3"] = "github_user", -- GitHub user assume AstroNvim fork
    -- },
  },

  -- Set colorscheme to use
  -- colorscheme = "default_theme",
  colorscheme = "tokyonight-night",
  -- colorscheme = "poimandres",

  -- Add highlight groups in any theme
  highlights = {
    init = { -- this table overrides highlights in all themes
      EndOfBuffer            = { bg = "NONE" },
      MsgArea                = { bg = "NONE" },
      NeoTreeNormal          = { bg = "NONE" },
      NeoTreeNormalNC        = { bg = "NONE" },
      Normal                 = { fg = "NONE", bg = "NONE" },
      NormalNC               = { fg = "NONE", bg = "NONE" },
      NormalSB               = { fg = "NONE", bg = "NONE" },
      SignColumn             = { bg = "NONE" },
      SignColumnSB           = { bg = "NONE" },
      TerminalBorder         = { bg = "NONE" },
      TerminalNormal         = { fg = "NONE", bg = "NONE" },
      TelescopeNormal        = { bg = "NONE" },
      WhichKeyFloat          = { bg = "NONE" },
      TermCursor             = { fg = "#1a1b26", bg = "#c0caf5" },
      TermCursorNC           = { fg = "#c0caf5", bg = "#3c3c3c" },
      CursorLine             = { bg = "#0c0c0c" },
      NeoTreeCursorLine      = { bg = "#16161e" },
      NeoTreeGitAdded        = { fg = "#495466" },
      NeoTreeGitConflict     = { fg = "#495466" },
      NeoTreeGitDeleted      = { fg = "#495466" },
      NeoTreeGitIgnored      = { fg = "#495466" },
      NeoTreeGitModified     = { fg = "#495466" },
      NeoTreeGitUnstaged     = { fg = "#495466" },
      NeoTreeGitUntracked    = { fg = "#495466" },
      NeoTreeGitStaged       = { fg = "#495466" },
      NeoTreeRootName        = { fg = "#7aa2f7" },
      NeoTreeTabActive       = { fg = "#c0caf5" },
      TelescopeResultsNormal = { fg = "#9c9c9c" },
      NormalFloat            = { fg = "#888888", bg = "NONE" },
      FloatBorder            = { fg = "#444444", bg = "NONE" },
      CmpItemAbbr            = { fg = "#888888", bg = "NONE" },
      Pmenu                  = { fg = "#444444", bg = "NONE" },
      TelescopeBorder        = { fg = "#171922", bg = "NONE" },
      TelescopeTitle         = { fg = "#303340", bg = "NONE" },
      WhichKeyBorder         = { fg = "#171922", bg = "NONE" },
      Winbar                 = { fg = "#495466" },
      WinbarNC               = { fg = "#495466" },
    },
    ["tokyonight"] = { -- a table of overrides/changes to the tokyonight theme

      ["Comment"]                = { fg = "#565f89", italic = false },
      ["Keyword"]                = { fg = "#7dcfff", italic = false },
      ["@keyword"]               = { fg = "#9d7cd8", italic = false },
      ["@keyword.function"]      = { fg = "#6e51a2" },
      ["@field"]                 = { fg = "#7aa2f7" },
      ["@string"]                = { fg = "#73daca" },
      ["@boolean"]               = { fg = "#1cff1c" },
      ["@number"]                = { fg = "#1cff1c" },
      ["@punctuation"]           = { fg = "#e8e8e8" },
      ["@punctuation.bracket"]   = { fg = "#515171" },
      ["@punctuation.delimiter"] = { fg = "#e8e8e8" },
      ["@punctuation.special"]   = { fg = "#515171" },
      ["@parameter"]             = { fg = "#e4f0fb" },
      ["@variable"]              = { fg = "#e4f0fb" },
      ["@tag"]                   = { fg = "#515171" },
      ["@tag.attribute"]         = { fg = "#91b4d5" },
      ["@tag.delimiter"]         = { fg = "#515171" },
      ["@constructor"]           = { fg = "#6e51a2" },
      ["Constant"]               = { fg = "#1cff1c" },
      ["String"]                 = { fg = "#73daca" },
      GitSignsAdd                = { fg = "#1abc9c" },
      GitSignsChange             = { fg = "#3c3cff" },
      GitSignsDelete             = { fg = "#880000" },
      IndentBlanklineChar        = { fg = "#3b4261" },
      IndentBlanklineContextChar = { fg = "#7aa2f7" },
      IlluminatedWordText        = { bg = "#080811" },
      IlluminatedWordRead        = { bg = "#080811" },
      IlluminatedWordWrite       = { bg = "#080811" },
      LspReferenceRead           = { bg = "#080811" },
      LspReferenceText           = { bg = "#080811" },
      LspReferenceWrite          = { bg = "#080811" },
      NotifyBackground           = { bg = "#000000" },
      NotifyDEBUGBody            = { fg = "#c0caf5" },
      NotifyDEBUGBorder          = { fg = "#2c2f44" },
      NotifyERRORBody            = { fg = "#c0caf5" },
      NotifyERRORBorder          = { fg = "#542931" },
      NotifyINFOBody             = { fg = "#c0caf5" },
      NotifyINFOBorder           = { fg = "#164a5b" },
      NotifyTRACEBody            = { fg = "#c0caf5" },
      NotifyTRACEBorder          = { fg = "#41385b" },
      NotifyWARNBody             = { fg = "#c0caf5" },
      NotifyWARNBorder           = { fg = "#55473a" },
      TelescopeSelection         = { bg = "#080811" },
      TelescopeSelectionCaret    = { bg = "#080811" },
      WinSeparator               = { fg = "#565f89" },
      rainbowcol1                = { fg = "#89ddff" },
      rainbowcol2                = { fg = "#2ac3de" },
      rainbowcol3                = { fg = "#7dcfff" },
      rainbowcol4                = { fg = "#1abc9c" },
      rainbowcol5                = { fg = "#7aa2f7" },
      rainbowcol6                = { fg = "#bb9af7" },
      rainbowcol7                = { fg = "#9d7cd8" },

    },
    ["poimandres"] = { -- a table of overrides/changes to the poimandres theme
      ["@punctuation"]           = { fg = "#e8e8e8" },
      ["@punctuation.bracket"]   = { fg = "#515171" },
      ["@punctuation.delimiter"] = { fg = "#e8e8e8" },
      ["@punctuation.special"]   = { fg = "#515171" },
      ["@tag"]                   = { fg = "#515171" },
      ["@tag.attribute"]         = { fg = "#91b4d5" },
      ["@tag.delimiter"]         = { fg = "#515171" },
      ["@constructor"]           = { fg = "#5de4c7" },
      ["@comment"]               = { fg = "#3e4041" },
      ["Comment"]                = { fg = "#a6accd" },
      ["Visual"]                 = { bg = "#1c1c1c" },
      GitSignsAdd                = { fg = "#1abc9c" },
      GitSignsChange             = { fg = "#3c3cff" },
      GitSignsDelete             = { fg = "#880000" },
      IndentBlanklineChar        = { fg = "#3b4261" },
      IndentBlanklineContextChar = { fg = "#7aa2f7" },
      IlluminatedWordText        = { bg = "#080811" },
      IlluminatedWordRead        = { bg = "#080811" },
      IlluminatedWordWrite       = { bg = "#080811" },
      NotifyBackground           = { bg = "#000000" },
      LspReferenceRead           = { bg = "#080811" },
      LspReferenceText           = { bg = "#080811" },
      LspReferenceWrite          = { bg = "#080811" },
      PmenuSel                   = { bg = "#1c1c1c" },
      TelescopeSelection         = { bg = "#080811" },
      TelescopeSelectionCaret    = { bg = "#080811" },
      WinSeparator               = { fg = "#565f89" },
      rainbowcol1                = { fg = "#89ddff" },
      rainbowcol2                = { fg = "#2ac3de" },
      rainbowcol3                = { fg = "#7dcfff" },
      rainbowcol4                = { fg = "#1abc9c" },
      rainbowcol5                = { fg = "#7aa2f7" },
      rainbowcol6                = { fg = "#bb9af7" },
      rainbowcol7                = { fg = "#9d7cd8" },
    }
  },

  -- set vim options here (vim.<first_key>.<second_key> = value)
  options = {
    opt = {
      -- set to true or false etc.
      completeopt = { "menu", "menuone", "noinsert" }, -- mostly just for cmp
      cursorline = false, -- sets vim.opt.cursorline
      number = true, -- sets vim.opt.number
      relativenumber = true, -- sets vim.opt.relativenumber
      scrolloff = 8, -- vertical scrolloff
      sidescrolloff = 8, -- horizontal scrolloff
      signcolumn = "auto", -- sets vim.opt.signcolumn to auto
      showtabline = 0, -- 0) never show; 1) show tabs if more than 2; 2) always show
      spell = false, -- sets vim.opt.spell
      undofile = false, -- disable persistent undo
      virtualedit = "all", -- allow cursor bypass end of line
      wrap = false, -- sets vim.opt.wrap

      -- Indentation
      expandtab = true, -- convert tabs to spaces
      tabstop = 2, -- length of an actual \t character (eg. formmatters)
      softtabstop = 2, -- length to use when editing text (eg. pressing TAB and BS keys)
      shiftwidth = 2, -- length to use when shifting text (eg. <<, >> and == commands)
      smartindent = true, -- autoindenting when starting a new line

    },
    g = {
      autoformat_enabled = true, -- enable or disable auto formatting at start (lsp.formatting.format_on_save must be enabled)
      autopairs_enabled = true, -- enable autopairs at start
      cmp_enabled = true, -- enable completion at start
      codeium_no_map_tab = true, -- disable <tab> codeium completion
      diagnostics_enabled = true, -- enable diagnostics at start
      heirline_bufferline = true, -- enable new heirline based bufferline (requires :PackerSync after changing)
      icons_enabled = true, -- disable icons in the UI (disable if no nerd font is available, requires :PackerSync after changing)
      mapleader = " ", -- sets vim.g.mapleader
      status_diagnostics_enabled = true, -- enable diagnostics in statusline
      ui_notifications_enabled = true, -- disable notifications when toggling UI elements
    }
  },
  -- If you need more control, you can use the function()...end notation
  -- options = function(local_vim)
  --   local_vim.opt.relativenumber = true
  --   local_vim.g.mapleader = " "
  --   local_vim.opt.whichwrap = vim.opt.whichwrap - { 'b', 's' } -- removing option from list
  --   local_vim.opt.shortmess = vim.opt.shortmess + { I = true } -- add to option list
  --
  --   return local_vim
  -- end,

  -- Default theme configuration
  default_theme = {
    -- Modify the color palette for the default theme
    colors = {
      fg = "#abb2bf",
      bg = "#1e222a",
    },
    highlights = function(hl) -- or a function that returns a new table of colors to set
      local C = require "default_theme.colors"

      hl.Normal = { fg = C.fg, bg = C.bg }

      -- New approach instead of diagnostic_style
      hl.DiagnosticError.italic = true
      hl.DiagnosticHint.italic = true
      hl.DiagnosticInfo.italic = true
      hl.DiagnosticWarn.italic = true

      return hl
    end,
    -- enable or disable highlighting for extra plugins
    plugins = {
      aerial = true,
      beacon = false,
      bufferline = true,
      cmp = true,
      dashboard = true,
      highlighturl = true,
      hop = false,
      indent_blankline = true,
      lightspeed = false,
      ["neo-tree"] = true,
      notify = true,
      ["nvim-tree"] = false,
      ["nvim-web-devicons"] = true,
      rainbow = true,
      symbols_outline = false,
      telescope = true,
      treesitter = true,
      vimwiki = false,
      ["which-key"] = true
    }
  },

  -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
  diagnostics = { virtual_text = true, underline = true },

  -- Extend LSP configuration
  lsp = {
    -- enable servers that you already have installed without mason
    servers = {
      -- "pyright"
    },
    formatting = {
      -- control auto formatting on save
      format_on_save = {
        enabled = false, -- enable or disable format on save globally
        allow_filetypes = { -- enable format on save for specified filetypes only
          -- "go",
        },
        ignore_filetypes = { -- disable format on save for specified filetypes
          -- "python",
        }
      },
      disabled = { -- disable formatting capabilities for the listed language servers
        -- "sumneko_lua",
      },
      timeout_ms = 1000 -- default format timeout
      -- filter = function(client) -- fully override the default formatting function
      --   return true
      -- end
    },
    -- easily add or disable built in mappings added during LSP attaching
    mappings = {
      n = {
        ["<leader>lF"] = { function() vim.lsp.buf.format(astronvim.lsp.format_opts) end, desc = "Format buffer" },
        -- ["H"] = false, -- disable prev buffer
        -- ["L"] = false, -- disable next buffer
        ["K"] = false, -- disable Hover symbol
        ["gh"] = { "<cmd>lua vim.lsp.buf.hover()<CR>", desc = "Hover Symbol" },
        ["go"] = { "<cmd>lua vim.diagnostic.open_float()<cr>", desc = "Hover Diagnostics" },
        ["gl"] = { "`.", desc = "Jump to Last change" }, -- Overwrites Hover Diagnostics
      }
    },
    -- add to the global LSP on_attach function
    -- on_attach = function(client, bufnr)
    -- end,

    -- override the mason server-registration function
    -- server_registration = function(server, opts)
    --   require("lspconfig")[server].setup(opts)
    -- end,

    -- Add overrides for LSP server settings, the keys are the name of the server
    ["server-settings"] = {
      -- example for addings schemas to yamlls
      -- yamlls = { -- override table for require("lspconfig").yamlls.setup({...})
      --   settings = {
      --     yaml = {
      --       schemas = {
      --         ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*.{yml,yaml}",
      --         ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
      --         ["http://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/*.{yml,yaml}",
      --       },
      --     },
      --   },
      -- },
      jsonls = {
        settings = {
          json = {
            schemas = function() require("schemastore").json.schemas() end,
            validate = { enable = true },
            keepLines = { enable = true },
          },
        },
      },
    },
  },

  -- Mapping data with "desc" stored directly by vim.keymap.set().
  --
  -- Please use this mappings table to set keyboard mapping since this is the
  -- lower level configuration and more robust one. (which-key will
  -- automatically pick-up stored data by this setting.)
  mappings = {
    -- first key is the mode
    n = {
      -- second key is the lefthand side of the map
      -- mappings seen under group name "Buffer"
      ["Q"] = { "<cmd>quit<cr>", desc = "Quit" },
      ["R"] = { "<cmd>lua vim.lsp.buf.format()<cr><cmd>write<cr>", desc = "Save" },
      ["Y"] = { "yg_", desc = "Forward yank" },
      ["<leader>v"] = { "<Cmd>ToggleTerm direction=vertical   size=70<CR>", desc = "ToggleTerm vertical" },
      ["<leader>V"] = { "<Cmd>ToggleTerm direction=horizontal size=10<CR>", desc = "ToggleTerm horizontal" },
      ["<leader>gh"] = false, -- disable Reset Git hunk
    },
    t = {
      -- setting a mapping to false will disable it
      -- ["<esc>"] = false,
      ["<esc><esc>"] = { [[<C-\><C-n>]], desc = "Normal Mode" },
    },
    v = {
      ["p"] = { '"_c<c-r>+<esc>', desc = "Paste unaltered" },
      ["P"] = { 'g_P', desc = "Forward Paste" },
      ["<leader>p"] = { '"*p', desc = "Paste unaltered (second_clip)" },
      ["<leader>P"] = { 'g_"*P', desc = "Forward Paste (second_clip)" },
      ["<leader>y"] = { '"*y', desc = "Copy (second_clip)" },
      ["<leader>Y"] = { 'y:let @* .= @0<cr>', desc = "Copy Append (second_clip)" },
      ["<leader>z"] = { ":'<,'>fold<CR>", desc = "fold" },
      ["<leader>Z"] = { ":'<,'>!column -t<CR>", desc = "Format Column" },
      ["<leader>gw"] = { "gw", desc = "Format Comment" },
      ["<leader>gi"] = { "g<C-a>", desc = "Increment numbers" },
      ["<leader>gd"] = { "g<C-x>", desc = "Decrement numbers" },
    },
    c = {
      ["w!!"] = { "w !sudo tee %", desc = "save as sudo" },
    }
  },

  -- Configure plugins
  plugins = {
    init = {
      -- You can disable default plugins as follows:
      -- ["goolord/alpha-nvim"] = { disable = true },

      -- You can also add new plugins here as well:
      -- Add plugins, the packer syntax without the "use"
      -- { "andweeb/presence.nvim" },
      -- {
      --   "ray-x/lsp_signature.nvim",
      --   event = "BufRead",
      --   config = function()
      --     require("lsp_signature").setup()
      --   end,
      -- },

      -- We also support a key value style plugin definition similar to NvChad:
      -- ["ray-x/lsp_signature.nvim"] = {
      --   event = "BufRead",
      --   config = function()
      --     require("lsp_signature").setup()
      --   end,
      -- },

      -- UI
      ["folke/tokyonight.nvim"] = {},
      ["olivercederborg/poimandres.nvim"] = {},
      ["mrjones2014/legendary.nvim"] = {
        commit = "3008ed68c8f309ced07587684c8af53884791d35",
        config = function() require('legendary').setup({ which_key = { auto_register = true } }) end
      },
      ["nvim-telescope/telescope-file-browser.nvim"] = {
        commit = "304508fb7bea78e3c0eeddd88c4837501e403ae8",
        config = function() require("telescope").load_extension("file_browser") end
      },
      ["AckslD/nvim-neoclip.lua"] = {
        commit = "5b9286a40ea2020352280caeb713515badb03d99",
        config = function()
          require('neoclip').setup({
            on_select = { move_to_front = true },
            on_paste = { move_to_front = false, },
            keys = {
              telescope = {
                i = {
                  select = '<cr>',
                  paste = '<c-p>',
                  paste_behind = '<c-k>',
                  replay = '<c-q>', -- replay a macro
                  delete = '<c-d>', -- delete an entry
                  edit = '<c-e>', -- edit an entry
                  custom = {},
                },
                n = {
                  select = '<cr>',
                  paste = 'p',
                  paste_behind = 'P',
                  replay = 'Q',
                  delete = 'd',
                  edit = 'e',
                  custom = {},
                },
              },
            },
          })
          require("telescope").load_extension("neoclip")
        end
      },
      ["DaikyXendo/nvim-material-icon"] = {
        config = function()
          require("nvim-web-devicons").setup({ override = require("nvim-material-icon").get_icons() })
        end
      },

      -- Automation
      ['tpope/vim-commentary'] = { commit = "e87cd90dc09c2a203e13af9704bd0ef79303d755" },
      ["tzachar/cmp-tabnine"] = {
        commit = "851fbcc8ee54bdb93f9482e13b5fc31b50012422",
        run = "./install.sh",
        config = function()
          require("cmp_tabnine.config"):setup()
          astronvim.add_cmp_source({ name = "cmp_tabnine", priority = 1000, max_item_count = 7 })
        end
      },
      ["Exafunction/codeium.vim"] = {},
      ["ahmedkhalf/project.nvim"] = {
        commit = "685bc8e3890d2feb07ccf919522c97f7d33b94e4",
        config = function()
          require("project_nvim").setup()
          require("telescope").load_extension('projects')
        end
      },
      ["hrsh7th/nvim-cmp"] = { keys = { ":", "/", "?" } },
      ["hrsh7th/cmp-cmdline"] = { commit = "23c51b2a3c00f6abc4e922dbd7c3b9aca6992063", after = "nvim-cmp" },
      {
        "hrsh7th/cmp-emoji",
        commit = "19075c36d5820253d32e2478b6aaf3734aeaafa0",
        after = "nvim-cmp",
        config = function() astronvim.add_user_cmp_source "emoji" end,
      },

      -- Motions
      ["machakann/vim-columnmove"] = { commit = "21a43d809a03ff9bf9946d983d17b3a316bf7a64" },
      ["tpope/vim-repeat"] = { commit = "24afe922e6a05891756ecf331f39a1f6743d3d5a" },
      ["justinmk/vim-sneak"] = { commit = "93395f5b56eb203e4c8346766f258ac94ea81702", },
      ["numToStr/Comment.nvim"] = { disable = true },

      -- Text-Objects
      ["paraduxos/vim-indent-object"] = { branch = "new_branch", commit = "2408bf0d2d54f70e6cd9cfcb558bd43283bf5003" },
      ["kana/vim-textobj-user"] = { commit = "41a675ddbeefd6a93664a4dc52f302fe3086a933" },
      ["saihoooooooo/vim-textobj-space"] = { commit = "d4dc141aad3ad973a0509956ce753dfd0fc87114" },
      ["nvim-treesitter/nvim-treesitter-textobjects"] = { commit = "4b30081d2736e09f90c890a8a7adfe4df36f5b36" },
      ["RRethy/nvim-treesitter-textsubjects"] = { commit = "bc047b20768845fd54340eb76272b2cf2f6fa3f3" },
      ["coderifous/textobj-word-column.vim"] = { commit = "cb40e1459817a7fa23741ff6df05e4481bde5a33" },
      ["mg979/vim-visual-multi"] = { commit = "724bd53adfbaf32e129b001658b45d4c5c29ca1a" },
      ["svermeulen/vim-easyclip"] = { commit = "f1a3b95463402b30dd1e22dae7d0b6ea858db2df" },
      ["vim-easyclip"] = { commit = "f1a3b95463402b30dd1e22dae7d0b6ea858db2df" },
      ["chrisgrieser/nvim-various-textobjs"] = {
        commit = "2fddc521bd8172dc157c89d2c182983caa898164",
        config = function() require("various-textobjs").setup { useDefaultKeymaps = false, lookForwardLines = 30 } end,
      },
      ["RRethy/vim-illuminate"] = {
        commit = "a6d0b28ea7d6b9d139374be1f94a16bd120fcda3",
        config = function() require("illuminate").configure({ filetypes_denylist = { 'neo-tree', } }) end
      },
      ["echasnovski/mini.nvim"] = {
        commit = "c65901227e5a3671dbcb054745566a1c78f9f0c8",
        config = function()

          local spec_treesitter = require('mini.ai').gen_spec.treesitter
          require('mini.ai').setup({
            custom_textobjects = {
              q = spec_treesitter({ a = '@call.outer', i = '@call.inner', }),
              Q = spec_treesitter({ a = '@class.outer', i = '@class.inner', }),
              g = spec_treesitter({ a = '@comment.outer', i = '@comment.inner', }),
              G = spec_treesitter({ a = '@conditional.outer', i = '@conditional.inner', }),
              B = spec_treesitter({ a = '@block.outer', i = '@block.inner', }),
              F = spec_treesitter({ a = '@function.outer', i = '@function.inner', }),
              L = spec_treesitter({ a = '@loop.outer', i = '@loop.inner', }),
              P = spec_treesitter({ a = '@parameter.outer', i = '@parameter.inner', }),
              R = spec_treesitter({ a = '@return.outer', i = '@return.inner', }),
              ["="] = spec_treesitter({ a = '@assignment.rhs', i = '@assignment.lhs', }),
              ["+"] = spec_treesitter({ a = '@assignment.outer', i = '@assignment.inner', }),
              ["z"] = spec_treesitter({ a = '@number.outer', i = '@number.inner', }),
              a = require('mini.ai').gen_spec.argument({ brackets = { '%b()' } }),
              k = { { '\n.-[=:]', '^.-[=:]' }, '^%s*()().-()%s-()=?[!=<>\\+-\\*]?[=:]' }, -- .- -> don't be greedy let %s- to exist
              v = { { '[=:]()%s*().-%s*()[;,]()', '[=:]=?()%s*().*()().$' } }, -- Pattern in double curly bracket equals fallback
              u = { { "%b''", '%b""', '%b``' }, '^.().*().$' },
              n = { '[-+]?()%f[%d]%d+()%.?%d*' }, -- %f[%d] to make jumping to next group of number instead of next digit
              x = { '#()%x%x%x%x%x%x()' },
            },
            mappings = {
              around = 'a',
              inside = 'i',
              around_next = 'aN',
              inside_next = 'iN',
              around_last = 'al',
              inside_last = 'il',
              goto_left = 'g[',
              goto_right = 'g]',
            },
          })

          require('mini.align').setup({
            mappings = {
              start = 'ga',
              start_with_preview = 'gA',
            },
          })

          require('mini.bracketed').setup({
            buffer     = { suffix = 'b', options = {} },
            comment    = { suffix = 'c', options = {} },
            conflict   = { suffix = 'x', options = {} },
            diagnostic = { suffix = 'd', options = {} },
            file       = { suffix = 'f', options = {} },
            indent     = { suffix = 'n', options = {} },
            jump       = { suffix = 'j', options = {} },
            location   = { suffix = 'l', options = {} },
            oldfile    = { suffix = 'o', options = {} },
            quickfix   = { suffix = 'q', options = {} },
            treesitter = { suffix = 't', options = {} },
            undo       = { suffix = 'u', options = {} },
            window     = { suffix = 'w', options = {} },
            yank       = { suffix = 'y', options = {} },
          })

          require('mini.comment').setup({
            mappings = {
              comment = '',
              comment_line = '',
              textobject = '',
            },
            hooks = {
              pre = function() require('ts_context_commentstring.internal').update_commentstring() end,
              post = function() end,
            },
          })

          require('mini.indentscope').setup({
            draw = {
              delay = 100,
              animation = nil
            },
            mappings = {
              object_scope = 'iI', -- empty to disable
              object_scope_with_border = 'aI', -- empty to disable
              goto_top = '[ii',
              goto_bottom = ']ii',
            },
            options = {
              border = 'both',
              indent_at_cursor = false,
              try_as_border = false,
            },
            symbol = '',
          })

          require('mini.surround').setup({
            custom_surroundings = nil,
            highlight_duration = 500,
            mappings = {
              add = 'ys', -- Add surrounding in Normal and Visual modes
              delete = 'ds', -- Delete surrounding
              find = 'zf', -- Find surrounding (to the right)
              find_left = 'zF', -- Find surrounding (to the left)
              highlight = 'zh', -- Highlight surrounding
              replace = 'cs', -- Replace surrounding
              update_n_lines = 'zn', -- Update `n_lines`
              suffix_last = 'l', -- Suffix to search with "prev" method
              suffix_next = 'N', -- Suffix to search with "next" method
            },
          })

        end
      },
      ["folke/which-key.nvim"] = {
        config = function()
          require("which-key").setup({
            plugins = {
              spelling = { enabled = true },
              presets = { operators = true },
            },
            window = {
              border = "rounded",
              padding = { 2, 2, 2, 2 },
            },
            disable = { filetypes = { "TelescopePrompt" } },
          })
        end
      },
    },

    ["telescope"] = {
      mappings = {
        i = {
          ["<A-R>"] = edit_register,

          ["<Tab>"] = function(prompt_bufnr) actions.toggle_selection(prompt_bufnr) actions.move_selection_next(prompt_bufnr) end,
          ["<S-Tab>"] = function(prompt_bufnr) actions.toggle_selection(prompt_bufnr) actions.move_selection_previous(prompt_bufnr) end,

          ["<C-a>"] = function(prompt_bufnr) actions.add_selected_to_qflist(prompt_bufnr) actions.open_qflist(prompt_bufnr) end,
          ["<A-A>"] = function(prompt_bufnr) actions.add_selected_to_loclist(prompt_bufnr) actions.open_loclist(prompt_bufnr) end,

          ["<C-d>"] = actions.preview_scrolling_down,
          ["<C-u>"] = actions.preview_scrolling_up,

          ["<Down>"] = actions.move_selection_next,
          ["<Up>"] = actions.move_selection_previous,
          ["<CR>"] = actions.select_default,
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<C-l>"] = actions.select_default,
          ["<A-J>"] = function(prompt_bufnr) action_set.shift_selection(prompt_bufnr, 10) end,
          ["<A-K>"] = function(prompt_bufnr) action_set.shift_selection(prompt_bufnr, -10) end,

          ["<C-n>"] = actions.cycle_history_next,
          ["<C-p>"] = actions.cycle_history_prev,

          ["<C-g>"] = actions.move_to_top,
          ["<A-G>"] = actions.move_to_bottom,
          ["<C-;>"] = actions.move_to_middle,

          ["<C-c>"] = actions.close,

          ["<C-s>"] = function(prompt_bufnr) actions.send_selected_to_qflist(prompt_bufnr) actions.open_qflist(prompt_bufnr) end,
          ["<A-S>"] = function(prompt_bufnr) actions.send_selected_to_loclist(prompt_bufnr) actions.open_loclist(prompt_bufnr) end,

          ["<C-v>"] = actions.select_vertical,
          ["<A-V>"] = actions.select_horizontal,
          ["<A-T>"] = actions.select_tab,

          ["<A-P>"] = require("telescope.actions.layout").toggle_preview,
          ["<A-Z>"] = require("telescope.actions.layout").cycle_layout_next,
          ["<C-z>"] = actions.toggle_all,

          ["<C-_>"] = actions.complete_tag, -- keys from pressing <C-/>
          ["<C-?>"] = actions.which_key,

          ["<PageUp>"] = actions.results_scrolling_up,
          ["<PageDown>"] = actions.results_scrolling_down,
        },
        n = {
          ["R"] = edit_register,

          ["<Tab>"] = function(prompt_bufnr) actions.toggle_selection(prompt_bufnr) actions.move_selection_next(prompt_bufnr) end,
          ["<S-Tab>"] = function(prompt_bufnr) actions.toggle_selection(prompt_bufnr) actions.move_selection_previous(prompt_bufnr) end,

          ["a"] = function(prompt_bufnr) actions.add_selected_to_qflist(prompt_bufnr) actions.open_qflist(prompt_bufnr) end,
          ["A"] = function(prompt_bufnr) actions.add_selected_to_loclist(prompt_bufnr) actions.open_loclist(prompt_bufnr) end,

          ["d"] = actions.preview_scrolling_down,
          ["u"] = actions.preview_scrolling_up,

          ["<Down>"] = actions.move_selection_next,
          ["<Up>"] = actions.move_selection_previous,
          ["<CR>"] = actions.select_default,
          ["j"] = actions.move_selection_next,
          ["k"] = actions.move_selection_previous,
          ["l"] = actions.select_default,
          ["J"] = function(prompt_bufnr) action_set.shift_selection(prompt_bufnr, 10) end,
          ["K"] = function(prompt_bufnr) action_set.shift_selection(prompt_bufnr, -10) end,

          ["n"] = actions.cycle_history_next,
          ["p"] = actions.cycle_history_prev,

          ["g"] = actions.move_to_top,
          ["G"] = actions.move_to_bottom,
          [";"] = actions.move_to_middle,

          ["q"] = actions.close,
          ["<esc>"] = actions.close,

          ["s"] = function(prompt_bufnr) actions.send_selected_to_qflist(prompt_bufnr) actions.open_qflist(prompt_bufnr) end,
          ["S"] = function(prompt_bufnr) actions.send_selected_to_loclist(prompt_bufnr) actions.open_loclist(prompt_bufnr) end,

          ["t"] = actions.select_tab,
          ["v"] = actions.select_vertical,
          ["V"] = actions.select_horizontal,

          ["P"] = require("telescope.actions.layout").toggle_preview,
          ["Z"] = require("telescope.actions.layout").cycle_layout_next,
          ["z"] = actions.toggle_all,

          ["/"] = actions.complete_tag,
          ["?"] = actions.which_key,

          ["<PageUp>"] = actions.results_scrolling_up,
          ["<PageDown>"] = actions.results_scrolling_down,
        },
      },
      extensions = {
        file_browser = {
          auto_depth = true,
          display_stat = {},
          grouped = true,
          hidden = true,
          hide_parent_dir = true,
          path = "%:p:h",
          respect_gitignore = false,
          mappings = {
            ["i"] = {
              ["<A-B>"] = function(prompt_bufnr) fb_actions("toggle_browser", prompt_bufnr) end,
              ["<A-C>"] = function(prompt_bufnr) fb_actions("create", prompt_bufnr) end,
              ["<A-D>"] = function(prompt_bufnr) fb_actions("remove", prompt_bufnr) end,
              ["<A-E>"] = function(prompt_bufnr) fb_actions("goto_home_dir", prompt_bufnr) end,
              ["<c-h>"] = function(prompt_bufnr) fb_actions("toggle_hidden", prompt_bufnr) end,
              ["<A-H>"] = function(prompt_bufnr) fb_actions("goto_parent_dir", prompt_bufnr) end,
              ["<A-M>"] = function(prompt_bufnr) fb_actions("move", prompt_bufnr) end,
              ["<A-O>"] = function(prompt_bufnr) fb_actions("open", prompt_bufnr) end,
              ["<A-R>"] = function(prompt_bufnr) fb_actions("rename", prompt_bufnr) end,
              ["<A-W>"] = function(prompt_bufnr) fb_actions("goto_cwd", prompt_bufnr) end,
              ["<A-Y>"] = function(prompt_bufnr) fb_actions("copy", prompt_bufnr) end,
              ["<A-Z>"] = function(prompt_bufnr) fb_actions("toggle_all", prompt_bufnr) end,
              ["<A-.>"] = function(prompt_bufnr) fb_actions("change_cwd", prompt_bufnr) end,
              ["<S-CR>"] = function(prompt_bufnr) fb_actions("create_from_prompt", prompt_bufnr) end,
            },
            ["n"] = {
              ["B"] = function(prompt_bufnr) fb_actions("toggle_browser", prompt_bufnr) end,
              ["c"] = function(prompt_bufnr) fb_actions("create", prompt_bufnr) end,
              ["D"] = function(prompt_bufnr) fb_actions("remove", prompt_bufnr) end,
              ["e"] = function(prompt_bufnr) fb_actions("goto_home_dir", prompt_bufnr) end,
              ["h"] = function(prompt_bufnr) fb_actions("goto_parent_dir", prompt_bufnr) end,
              ["H"] = function(prompt_bufnr) fb_actions("toggle_hidden", prompt_bufnr) end,
              ["m"] = function(prompt_bufnr) fb_actions("move", prompt_bufnr) end,
              ["o"] = function(prompt_bufnr) fb_actions("open", prompt_bufnr) end,
              ["r"] = function(prompt_bufnr) fb_actions("rename", prompt_bufnr) end,
              ["w"] = function(prompt_bufnr) fb_actions("goto_cwd", prompt_bufnr) end,
              ["y"] = function(prompt_bufnr) fb_actions("copy", prompt_bufnr) end,
              ["z"] = function(prompt_bufnr) fb_actions("toggle_all", prompt_bufnr) end,
              ["."] = function(prompt_bufnr) fb_actions("change_cwd", prompt_bufnr) end,
            },
          },
        }
      },
    },

    ["treesitter"] = {
      ensure_installed = { "python", "bash", "javascript", "json", "html", "css", "c", "lua" },
      incremental_selection = {
        enable = true,
        disable = { "yaml" },
        keymaps = {
          init_selection = '<c-space>', -- maps in normal mode to init the node/scope selection
          node_incremental = '<c-space>', -- increment to the upper named parent
          scope_incremental = '<c-]>', -- increment to the upper scope (as defined in locals.scm)
          node_decremental = '<c-[>', -- decrement to the previous node
        }
      },
      textobjects = {
        move = {
          enable = true,
          set_jumps = true,
          goto_previous_start = {
            ['[aq'] = '@call.outer',
            ['[aQ'] = '@class.outer',
            ['[ag'] = '@comment.outer',
            ['[aG'] = '@conditional.outer',
            ['[aB'] = '@block.outer',
            ['[aF'] = '@function.outer',
            ['[aL'] = '@loop.outer',
            ['[aP'] = '@parameter.outer',
            ['[aR'] = '@return.outer',
            ['[a='] = '@assignment.outer',
            ['[a+'] = '@assignment.lhs',
            ['[iq'] = '@call.inner',
            ['[iQ'] = '@class.inner',
            ['[ig'] = '@comment.inner',
            ['[iG'] = '@conditional.inner',
            ['[iB'] = '@block.inner',
            ['[iF'] = '@function.inner',
            ['[iL'] = '@loop.inner',
            ['[iP'] = '@parameter.inner',
            ['[iR'] = '@return.inner',
            ['[['] = '@parameter.inner',
            ['[i='] = '@assignment.inner',
            ['[i+'] = '@assignment.rhs',
          },
          goto_next_start = {
            [']aq'] = '@call.outer',
            [']aQ'] = '@class.outer',
            [']ag'] = '@comment.outer',
            [']aG'] = '@conditional.outer',
            [']aB'] = '@block.outer',
            [']aF'] = '@function.outer',
            [']aL'] = '@loop.outer',
            [']aP'] = '@parameter.outer',
            [']aR'] = '@return.outer',
            [']a='] = '@assignment.outer',
            [']a+'] = '@assignment.lhs',
            [']iq'] = '@call.inner',
            [']iQ'] = '@class.inner',
            [']ig'] = '@comment.inner',
            [']iG'] = '@conditional.inner',
            [']iB'] = '@block.inner',
            [']iF'] = '@function.inner',
            [']iL'] = '@loop.inner',
            [']iP'] = '@parameter.inner',
            [']iR'] = '@return.inner',
            [']]'] = '@parameter.inner',
            [']i='] = '@assignment.inner',
            [']i+'] = '@assignment.rhs',
          },
          goto_previous_end = {
            ['[eaq'] = '@call.outer',
            ['[eaQ'] = '@class.outer',
            ['[eag'] = '@comment.outer',
            ['[eaG'] = '@conditional.outer',
            ['[eaB'] = '@block.outer',
            ['[eaF'] = '@function.outer',
            ['[eaL'] = '@loop.outer',
            ['[eaP'] = '@parameter.outer',
            ['[eaR'] = '@return.outer',
            ['[ea='] = '@assignment.outer',
            ['[ea+'] = '@assignment.lhs',
            ['[eiq'] = '@call.inner',
            ['[eiQ'] = '@class.inner',
            ['[eig'] = '@comment.inner',
            ['[eiG'] = '@conditional.inner',
            ['[eiB'] = '@block.inner',
            ['[eiF'] = '@function.inner',
            ['[eiL'] = '@loop.inner',
            ['[eiP'] = '@parameter.inner',
            ['[eiR'] = '@return.inner',
            ['[ei='] = '@assignment.inner',
            ['[ei+'] = '@assignment.rhs',
          },
          goto_next_end = {
            [']eaq'] = '@call.outer',
            [']eaQ'] = '@class.outer',
            [']eag'] = '@comment.outer',
            [']eaG'] = '@conditional.outer',
            [']eaB'] = '@block.outer',
            [']eaF'] = '@function.outer',
            [']eaL'] = '@loop.outer',
            [']eaP'] = '@parameter.outer',
            [']eaR'] = '@return.outer',
            [']ea='] = '@assignment.outer',
            [']ea+'] = '@assignment.lhs',
            [']eiq'] = '@call.inner',
            [']eiQ'] = '@class.inner',
            [']eig'] = '@comment.inner',
            [']eiG'] = '@conditional.inner',
            [']eiB'] = '@block.inner',
            [']eiF'] = '@function.inner',
            [']eiL'] = '@loop.inner',
            [']eiP'] = '@parameter.inner',
            [']eiR'] = '@return.inner',
            [']ei='] = '@assignment.inner',
            [']ei+'] = '@assignment.rhs',
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ['>,'] = '@parameter.inner',
          },
          swap_previous = {
            ['<,'] = '@parameter.inner',
          },
        },
        lsp_interop = {
          enable = true,
          border = 'rounded', --'none', 'single', 'double', 'rounded', 'solid', 'shadow'.
          peek_definition_code = {
            ['<leader>lf'] = '@function.outer',
            ['<leader>lc'] = '@class.outer',
          },
        },
      },
      textsubjects = {
        enable = true,
        prev_selection = 'Q', -- (Optional) keymap to select the previous selection
        keymaps = {
          ['K'] = 'textsubjects-smart', -- useful for block of comments
          ['aK'] = 'textsubjects-container-outer',
          ['iK'] = 'textsubjects-container-inner',
        },
      },
    },

    ["gitsigns"] = {
      signs = {
        add          = { text = '│' },
        change       = { text = '│' },
        delete       = { text = '│' },
        topdelete    = { text = '契' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
      },
    },

    ["indent_blankline"] = {
      show_first_indent_level = false,
      show_current_context = true,
      show_current_context_start = false,
    },

    ["neo-tree"] = {
      window = {
        mappings = {
          ["F"] = "filter_on_submit",
          ["v"] = function(state) state.commands["open_vsplit"](state) vim.cmd("Neotree close") end,
          ["V"] = function(state) state.commands["open_split"](state) vim.cmd("Neotree close") end,
          ["s"] = false,
          ["S"] = false,
          ["f"] = false,
          ["fa"] = function() vim.cmd [[normal 0]] vim.cmd [[/ a]] vim.cmd [[normal n]] end,
          ["fb"] = function() vim.cmd [[normal 0]] vim.cmd [[/ b]] vim.cmd [[normal n]] end,
          ["fc"] = function() vim.cmd [[normal 0]] vim.cmd [[/ c]] vim.cmd [[normal n]] end,
          ["fd"] = function() vim.cmd [[normal 0]] vim.cmd [[/ d]] vim.cmd [[normal n]] end,
          ["fe"] = function() vim.cmd [[normal 0]] vim.cmd [[/ e]] vim.cmd [[normal n]] end,
          ["ff"] = function() vim.cmd [[normal 0]] vim.cmd [[/ f]] vim.cmd [[normal n]] end,
          ["fg"] = function() vim.cmd [[normal 0]] vim.cmd [[/ g]] vim.cmd [[normal n]] end,
          ["fh"] = function() vim.cmd [[normal 0]] vim.cmd [[/ h]] vim.cmd [[normal n]] end,
          ["fi"] = function() vim.cmd [[normal 0]] vim.cmd [[/ i]] vim.cmd [[normal n]] end,
          ["fj"] = function() vim.cmd [[normal 0]] vim.cmd [[/ j]] vim.cmd [[normal n]] end,
          ["fk"] = function() vim.cmd [[normal 0]] vim.cmd [[/ k]] vim.cmd [[normal n]] end,
          ["fl"] = function() vim.cmd [[normal 0]] vim.cmd [[/ l]] vim.cmd [[normal n]] end,
          ["fm"] = function() vim.cmd [[normal 0]] vim.cmd [[/ m]] vim.cmd [[normal n]] end,
          ["fn"] = function() vim.cmd [[normal 0]] vim.cmd [[/ n]] vim.cmd [[normal n]] end,
          ["fo"] = function() vim.cmd [[normal 0]] vim.cmd [[/ o]] vim.cmd [[normal n]] end,
          ["fp"] = function() vim.cmd [[normal 0]] vim.cmd [[/ p]] vim.cmd [[normal n]] end,
          ["fq"] = function() vim.cmd [[normal 0]] vim.cmd [[/ q]] vim.cmd [[normal n]] end,
          ["fr"] = function() vim.cmd [[normal 0]] vim.cmd [[/ r]] vim.cmd [[normal n]] end,
          ["fs"] = function() vim.cmd [[normal 0]] vim.cmd [[/ s]] vim.cmd [[normal n]] end,
          ["ft"] = function() vim.cmd [[normal 0]] vim.cmd [[/ t]] vim.cmd [[normal n]] end,
          ["fu"] = function() vim.cmd [[normal 0]] vim.cmd [[/ u]] vim.cmd [[normal n]] end,
          ["fv"] = function() vim.cmd [[normal 0]] vim.cmd [[/ v]] vim.cmd [[normal n]] end,
          ["fw"] = function() vim.cmd [[normal 0]] vim.cmd [[/ w]] vim.cmd [[normal n]] end,
          ["fx"] = function() vim.cmd [[normal 0]] vim.cmd [[/ x]] vim.cmd [[normal n]] end,
          ["fy"] = function() vim.cmd [[normal 0]] vim.cmd [[/ y]] vim.cmd [[normal n]] end,
          ["fz"] = function() vim.cmd [[normal 0]] vim.cmd [[/ z]] vim.cmd [[normal n]] end,
          ["f/"] = function() vim.cmd [[normal 0]] vim.cmd [[/\v( | )]] vim.cmd [[normal n]] end,
        },
      },
      filesystem = {
        commands = {

          getparent_closenode = function(state)
            local node = state.tree:get_node()
            if node.type == 'directory' and node:is_expanded() then
              require 'neo-tree.sources.filesystem'.toggle_directory(state, node)
            else
              require 'neo-tree.ui.renderer'.focus_node(state, node:get_parent_id())
            end
          end,

          open_unfocus = function(state)
            state.commands["open"](state)
            vim.cmd("Neotree reveal")
          end,

          quit_on_open = function(state)
            local node = state.tree:get_node()
            if node.type == 'directory' then
              if not node:is_expanded() then
                require 'neo-tree.sources.filesystem'.toggle_directory(state, node)
              elseif node:has_children() then
                require 'neo-tree.ui.renderer'.focus_node(state, node:get_child_ids()[1])
              end
            else
              state.commands['open'](state)
              state.commands["close_window"](state)
              vim.cmd('normal! M')
            end
          end,

        },
        window = {
          mappings = {
            ["h"] = "getparent_closenode",
            ["H"] = "toggle_hidden",
            ["l"] = "quit_on_open",
            ["L"] = "open_unfocus",
          },
        },
      },
    },

    ["alpha"] = {
      layout = {
        { type = "padding", val = vim.fn.max { 2, vim.fn.floor(vim.fn.winheight(0) * 0.08) } },
        {
          type = "text",
          val = {
            "██████  ███████ ████████ ██████   ██████",
            "██   ██ ██         ██    ██   ██ ██    ██",
            "██████  ███████    ██    ██████  ██    ██",
            "██   ██ ██         ██    ██   ██ ██    ██",
            "██   ██ ███████    ██    ██   ██  ██████",
            " ",
            "    ███    ██ ██    ██ ██ ███    ███",
            "    ████   ██ ██    ██ ██ ████  ████",
            "    ██ ██  ██ ██    ██ ██ ██ ████ ██",
            "    ██  ██ ██  ██  ██  ██ ██  ██  ██",
            "    ██   ████   ████   ██ ██      ██",
          },
          opts = { position = "center", hl = "DashboardHeader" },
        },
        { type = "padding", val = 3 },
        {
          type = "group",
          val = {
            dashboard.button("p", " " .. " Find Project", ":Telescope projects initial_mode=normal<cr>"),
            dashboard.button("f", " " .. " Find File", ":Telescope find_files initial_mode=normal<cr>"),
            dashboard.button("o", " " .. " Recents", ":Telescope oldfiles initial_mode=normal<cr>"),
            dashboard.button("w", " " .. " Find Word", ":Telescope live_grep  initial_mode=normal<cr>"),
            dashboard.button("n", " " .. " New File", ":enew<cr>"),
            dashboard.button("m", " " .. " Bookmarks", ":Telescope marks initial_mode=normal<cr>"),
            dashboard.button("b", " " .. " File Browser", ":Telescope file_browser initial_mode=normal<cr>"),
            dashboard.button("l", " " .. " Explorer", ":lua _LF_TOGGLE(vim.api.nvim_buf_get_name(0),'tabreplace')<cr>"),
            dashboard.button("t", " " .. " Terminal",
              ":lua vim.cmd[[ tabedit | terminal ]] vim.cmd[[ tabclose # ]] vim.cmd[[ set ft=tab-terminal nonumber norelativenumber laststatus=0 | startinsert ]]<cr>"),
            dashboard.button("T", " " .. " Tmux",
              ":lua vim.cmd[[ tabnew | terminal tmux ]] vim.cmd[[ tabclose # ]] vim.cmd[[ set ft=tab-terminal nonumber norelativenumber laststatus=0 | startinsert ]]<cr>"),
            dashboard.button("s", " " .. " Last Session", ":SessionManager load_last_session<cr>"),
          },
          opts = { spacing = 1 },
        },
      },
    },

    ["cmp"] = function(config)
      -- options parameter is the default options table
      -- the function is lazy loaded so cmp is able to be required
      local cmp = require "cmp"
      local luasnip = require "luasnip"

      -- modify the mapping part of the table
      config.mapping = {
        ["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
        ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
        ["<A-j>"] = cmp.mapping.select_next_item(),
        ["<A-k>"] = cmp.mapping.select_prev_item(),
        ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
        ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
        ["<C-Space>"] = cmp.mapping({
          i = function()
            if cmp.visible() then
              cmp.abort()
            else
              cmp.complete()
            end
          end,
          c = function()
            if cmp.visible() then
              cmp.close()
            else
              cmp.complete()
            end
          end,
        }),
        ["<CR>"] = cmp.mapping.confirm { select = true },
        ["<A-l>"] = cmp.mapping(cmp.mapping.confirm { select = true }, { "i", "c" }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expandable() then
            luasnip.expand()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, {
          "i",
          "s",
        }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, {
          "i",
          "s",
        }),
      }

      -- modify the formatting part of the table
      config.formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
          vim_item.kind = require("lspkind").symbolic(vim_item.kind, { mode = "symbol" })
          vim_item.menu = ({
            cmp_tabnine = "[TN]",
            nvim_lsp = "[LSP]",
            luasnip = "[Snippet]",
            buffer = "[Buffer]",
            path = "[Path]",
            emoji = "[Emoji]",
          })[entry.source.name]
          return vim_item
        end,
      }

      config.completion = {
        completeopt = 'menu,menuone,noinsert' -- autoselect to show the completion preview
      }

      -- return the new table to be used
      return config
    end,

    -- All other entries override the require("<key>").setup({...}) call for default plugins
    ["null-ls"] = function(config) -- overrides `require("null-ls").setup(config)`
      -- config variable is the default configuration table for the setup function call
      -- local null_ls = require "null-ls"

      -- Check supported formatters and linters
      -- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
      -- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
      -- config.sources = {
      --   -- Set a formatter
      --   -- null_ls.builtins.formatting.stylua,
      --   -- null_ls.builtins.formatting.prettier,
      -- }
      config.sources = null_sources
      return config -- return final config table
    end,
    -- use mason-lspconfig to configure LSP installations
    ["mason-lspconfig"] = { -- overrides `require("mason-lspconfig").setup(...)`
      ensure_installed = { "tsserver" },
    },
    -- use mason-null-ls to configure Formatters/Linter installation for null-ls sources
    ["mason-null-ls"] = { -- overrides `require("mason-null-ls").setup(...)`
      -- ensure_installed = { "prettier" },
    },
    ["mason-nvim-dap"] = { -- overrides `require("mason-nvim-dap").setup(...)`
      -- ensure_installed = { "chrome" },
    },
  },

  -- LuaSnip Options
  luasnip = {
    -- Extend filetypes
    filetype_extend = {
      -- javascript = { "javascriptreact" },
    },
    -- Configure luasnip loaders (vscode, lua, and/or snipmate)
    vscode = {
      -- Add paths for including more VS Code style snippets in luasnip
      paths = {}
    }
  },

  -- CMP Source Priorities
  -- modify here the priorities of default cmp sources
  -- higher value == higher priority
  -- The value can also be set to a boolean for disabling default sources:
  -- false == disabled
  -- true == 1000

  cmp = {
    source_priority = {
      cmp_tabnine = 1000,
      nvim_lsp = 900,
      luasnip = 750,
      buffer = 500,
      path = 250,
      emoji = 200,
    },

    setup = function()
      -- load cmp to access it's internal functions
      local cmp = require "cmp"

      -- configure mappings for cmdline
      local fallback_func = function(func)
        return function(fallback)
          if cmp.visible() then
            cmp[func]()
          else
            fallback()
          end
        end
      end
      local mappings = cmp.mapping.preset.cmdline {
        ["<C-n>"] = function(fallback) fallback() end,
        ["<C-p>"] = function(fallback) fallback() end,
        ["<C-j>"] = { c = fallback_func "select_next_item" },
        ["<C-k>"] = { c = fallback_func "select_prev_item" },
        ["<M-j>"] = { c = fallback_func "select_next_item" },
        ["<M-k>"] = { c = fallback_func "select_prev_item" },
      }

      local config = {
        -- configure cmp.setup.cmdline(source, options)
        cmdline = {
          [":"] = {
            mapping = mappings,
            -- configure sources normally without getting priority from cmp.source_priority
            sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } })
          },
          ["/"] = { mapping = mappings, sources = { { name = "buffer" } } },
          ["?"] = { mapping = mappings, sources = { { name = "buffer" } } },
        },
      }
      return config
    end,
  },

  -- Customize Heirline options
  heirline = {
    -- Customize different separators between sections
    -- separators = { tab = { "", "" } },
    separators = { tab = { "▎", " " } },
    -- Customize colors for each element each element has a `_fg` and a `_bg`
    colors = function(colors)
      -- colors.bg                      = astronvim.get_hlgroup("Normal").bg
      colors.bg = "NONE" -- Status line
      colors.section_bg = "NONE" -- Status icons
      colors.buffer_bg = "#000000" -- Inactive buffer
      colors.buffer_fg = "#3b4261" -- Inactive buffer
      colors.buffer_path_fg = "#3b4261" -- Inactive buffer
      colors.buffer_close_fg = "#3b4261" -- Inactive buffer
      colors.buffer_active_fg = "#ffffff" -- Active buffer
      colors.buffer_active_path_fg = "#ffffff" -- Active buffer path
      colors.buffer_active_close_fg = "#ffffff" -- Active buffer close button
      colors.buffer_visible_fg = "NONE" -- Unfocus buffer
      colors.buffer_visible_path_fg = "NONE" -- Unfocus buffer path
      colors.buffer_visible_close_fg = "NONE" -- Unfocus buffer close button
      colors.tab_close_fg = "#5c5c5c" -- Tab close button
      colors.tabline_bg = "NONE" -- buffer line
      return colors
    end,
    -- Customize attributes of highlighting in Heirline components
    attributes = {
      -- styling choices for each heirline element, check possible attributes with `:h attr-list`
      -- git_branch = { bold = true }, -- bold the git branch statusline component
      -- buffer_active = { bold = false },
    }
    -- -- Customize if icons should be highlighted
    -- icon_highlights = {
    --   breadcrumbs = false, -- LSP symbols in the breadcrumbs
    --   file_icon = {
    --     winbar = false, -- Filetype icon in the winbar inactive windows
    --     statusline = true, -- Filetype icon in the statusline
    --   },
    -- },
  },

  -- Modify which-key registration (Use this with mappings table in the above.)
  ["which-key"] = {
    -- Add bindings which show up as group name
    register = {
      -- first key is the mode, n == normal mode
      n = {
        ["H"] = { "10h", "Jump 10h" },
        ["J"] = { "10j", "Jump 10j" },
        ["K"] = { "10k", "Jump 10k" },
        ["L"] = { "10l", "Jump 10l" },
        -- second key is the prefix, <leader> prefixes
        ["<leader>"] = {
          -- third key is the key to bring up next level and its displayed
          -- group name in which-key top level menu
          ["."] = { "<cmd>Telescope resume<cr>", "Telescope resume" },
          [";"] = {
            name = "Tabs",
            C = { "<cmd>tabonly<cr>", "Close others Tabs" },
            n = { "<cmd>tabnext<cr>", "Next Tab" },
            p = { "<cmd>tabprevious<cr>", "Previous Tab" },
            N = { "<cmd>+tabmove<cr>", "move tab to next tab" },
            P = { "<cmd>-tabmove<cr>", "move tab to previous tab" },
            t = { "<cmd>tabnew<cr>", "New Tab" },
            x = { "<cmd>tabclose<cr>", "Close Tab" },
            [";"] = { "<cmd>tabnext #<cr>", "Recent Tab" },
            ["<Tab>"] = { "<cmd>tabprevious<cr>", "Previous Tab" },
            ["<S-Tab>"] = { "<cmd>tabnext<cr>", "Next Tab" },
          },
          ["b"] = {
            name = "Buffers",
            b = {
              function()
                require('telescope.builtin').buffers(
                  require('telescope.themes').get_cursor {
                    previewer = false,
                    initial_mode = 'normal'
                  })
              end,
              "Telescope Buffer cursor-theme"
            },
            C = { "<cmd>%bd|e#|bd#<cr>", "Close others Buffers" },
            s = { "<cmd>bprev<cr>", "Previous Buffer" },
            f = { "<cmd>bnext<cr>", "Next Buffer" },
            t = { function() vim.cmd [[ enew ]] end, "New buffer" },
            ["<TAB>"] = {
              function()
                vim.cmd [[ setlocal nobuflisted ]]
                vim.cdm [[ bprevious ]]
                vim.cmd [[ tabe # ]]
              end,
              "buffer to Tab"
            },
            v = { "<cmd>vertical ball<cr>", "Buffers to vertical windows" },
            V = { "<cmd>belowright ball<cr>", "Buffers to horizontal windows" },
            x = { "<cmd>:bp | bd #<cr>", "Close Buffer" },
            [";"] = { "<cmd>buffer #<cr>", "Recent buffer" },
          },
          ["D"] = {
            name = "Debugger",
            b = { function() WhichkeyRepeat("lua require'dap'.toggle_breakpoint()") end, "Toggle Breakpoint" },
            B = { function() WhichkeyRepeat("lua require'dap'.clear_breakpoints()") end, "Clear Breakpoints" },
            c = { function() WhichkeyRepeat("lua require'dap'.continue()") end, "Start/Continue" },
            h = { function() WhichkeyRepeat("lua require'dap.ui.widgets'.hover()") end, "Debugger Hover" },
            i = { function() WhichkeyRepeat("lua require'dap'.step_into()") end, "Step Into" },
            l = { function() WhichkeyRepeat("lua require'dap'.run_last()") end, "Run last" },
            o = { function() WhichkeyRepeat("lua require'dap'.step_over()") end, "Step Over" },
            O = { function() WhichkeyRepeat("lua require'dap'.step_out()") end, "Step Out" },
            q = { function() require 'dap'.close() end, "Close Session" },
            Q = { function() require 'dap'.terminate() end, "Terminate Session" },
            p = { function() WhichkeyRepeat("lua require'dap'.pause()") end, "Pause" },
            r = { function() WhichkeyRepeat("lua require'dap'.restart_frame()") end, "Restart" },
            R = { function() WhichkeyRepeat("lua require'dap'.repl.toggle()") end, "Toggle REPL" },
            u = { function() WhichkeyRepeat("lua require'dapui'.toggle()") end, "Toggle Debugger UI" },
          },
          ["g"] = {
            name = "Git",
            g = { "<cmd>lua require 'toggleterm.terminal'.Terminal:new({ cmd='lazygit', direction='tab', hidden=true }):toggle()<cr>",
              "Tab Lazygit" },
            G = { function() astronvim.toggle_term_cmd "lazygit" end, "Float Lazygit" },
            L = { "<cmd>terminal lazygit<cr><cmd>set ft=tab-terminal<cr>", "Buffer Lazygit" },
            j = { function() WhichkeyRepeat("lua require 'gitsigns'.next_hunk()") end, "Next Hunk" },
            k = { function() WhichkeyRepeat("lua require 'gitsigns'.prev_hunk()") end, "Prev Hunk" },
            l = { function() WhichkeyRepeat("lua require 'gitsigns'.blame_line()") end, "Blame" },
            p = { function() WhichkeyRepeat("lua require 'gitsigns'.preview_hunk()") end, "Preview Hunk" },
            r = { function() WhichkeyRepeat("lua require 'gitsigns'.reset_hunk()") end, "Reset Hunk" },
            R = { function() WhichkeyRepeat("lua require 'gitsigns'.reset_buffer()") end, "Reset Buffer" },
            s = { function() WhichkeyRepeat("lua require 'gitsigns'.stage_hunk()") end, "Stage Hunk" },
            u = { function() WhichkeyRepeat("lua require 'gitsigns'.undo_stage_hunk()") end, "Undo Stage Hunk" },
            d = { function() WhichkeyRepeat("Gitsigns diffthis HEAD") end, "Diff", },
            o = { "<cmd>Telescope git_status initial_mode=normal<cr>", "Open Changed File" },
            b = { "<cmd>Telescope git_branches initial_mode=normal<cr>", "Checkout Branch" },
            c = { "<cmd>Telescope git_commits initial_mode=normal<cr>", "Checkout Commit" },
            ["t"] = { "which_key_ignore" },
          },
          ["p"] = {
            name = "Packages",
            C = { "<cmd>PackerClean<cr>", "Packer Clean" },
            L = { "<cmd>LspInfo<cr>", "Lsp Info" },
            N = { "<cmd>NullLsInfo<cr>", "NullLs Info" },
          },
          ["s"] = {
            name = "Search",
            b = { "<cmd>Telescope buffers initial_mode=normal<cr>", "Buffers" },
            B = { "<cmd>Telescope current_buffer_fuzzy_find theme=ivy<cr>", "Ripgrep" },
            c = {
              function()
                require('telescope.builtin').colorscheme({ enable_preview = true, initial_mode = 'normal' })
              end,
              "Colorscheme"
            },
            C = { "<cmd>Telescope commands<cr>", "Commands" },
            k = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
            f = { "<cmd>Telescope grep_string search= theme=ivy<cr>", "Grep string" },
            F = { "<cmd>Telescope live_grep theme=ivy<cr>", "Live Grep" },
            g = { "<cmd>Telescope git_files theme=ivy<cr>", "Git Files (hidden included)" },
            h = { "<cmd>Telescope help_tags<cr>", "Find Help" },
            H = { "<cmd>Telescope highlights<cr>", "Find Highlights" },
            m = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
            n = { "<cmd>Telescope neoclip initial_mode=normal<cr>", "NeoClip" },
            N = { "<cmd>Telescope notify initial_mode=normal<cr>", "Search notifications" },
            O = { "<cmd>lua require('notify').history()<cr>", "History notifications" },
            o = { "<cmd>Telescope file_browser initial_mode=normal<cr>", "Open File Browser" },
            p = { "<cmd>Telescope projects<cr>", "Projects" },
            q = { "<cmd>Telescope quickfixhistory initial_mode=normal<cr>", "Telescope QuickFix History" },
            Q = { "<cmd>Telescope quickfix initial_mode=normal<cr>", "Telescope QuickFix" },
            r = { "<cmd>Telescope oldfiles initial_mode=normal<cr>", "Open Recent File" },
            R = { "<cmd>Telescope registers initial_mode=normal<cr>", "Registers" },
            s = { "<cmd>Telescope grep_string<cr>", "Grep string under cursor" },
            z = {
              function()
                local aerial_avail, _ = pcall(require, "aerial")
                if aerial_avail then
                  require("telescope").extensions.aerial.aerial()
                else
                  require("telescope.builtin").lsp_document_symbols()
                end
              end,
              "Search symbols",
            },
            ["+"] = { "<cmd>Telescope builtin previewer=false initial_mode=normal<cr>", "More" },
            ["/"] = { "<cmd>Telescope find_files theme=ivy hidden=true<cr>", "Find files" },
            [";"] = { "<cmd>Telescope jumplist theme=ivy initial_mode=normal<cr>", "Jump List" },
            ["'"] = { "<cmd>Telescope marks theme=ivy initial_mode=normal<cr>", "Marks" },
          },
          t = {
            name = "Terminal",
            ["<TAB>"] = { function() vim.cmd [[ wincmd T ]] end, "Terminal to Tab" },
            b = {
              function()
                vim.cmd [[ terminal ]]
                vim.cmd [[ startinsert | set ft=buf-terminal nonumber ]]
              end,
              "Buffer terminal"
            },
            B = {
              function()
                vim.cmd [[ tabnew|terminal ]]
                vim.cmd [[ startinsert | set ft=tab-terminal nonumber ]]
              end,
              "Buffer Terminal (Tab)"
            },
            f = { "<cmd>ToggleTerm direction=float<cr>", "Float ToggleTerm" },
            l = {
              function()
                _LF_TOGGLE(vim.api.nvim_buf_get_name(0), 'vsplit')
              end,
              "lf (TabSame)"
            },
            L = {
              function()
                _LF_TOGGLE(vim.api.nvim_buf_get_name(0), 'tabnew')
              end,
              "lf (TabNew)"
            },
            r = {
              function()
                _LF_TOGGLE(vim.api.nvim_buf_get_name(0), 'tabreplace')
              end,
              "lf (TabReplace)"
            },
            t = { "<cmd>ToggleTerm <cr>", "Toggle ToggleTerm" },
            T = { "<cmd>ToggleTerm direction=tab <cr>", "Tab ToggleTerm" },
            H = { "<cmd>split +te | resize 10 | setlocal ft=sp-terminal<cr>", "Horizontal terminal" },
            V = { "<cmd>vsplit +te | vertical resize 80 | setlocal ft=vs-terminal<cr>", "Vertical terminal" },
            h = { "<cmd>ToggleTerm direction=horizontal size=10<cr>", "Horizontal ToggleTerm" },
            v = { "<cmd>ToggleTerm direction=vertical   size=80<cr>", "Vertical ToggleTerm" },
            ["2h"] = { "<cmd>2ToggleTerm direction=vertical   <cr>", "Toggle second horizontal ToggleTerm" },
            ["2v"] = { "<cmd>2ToggleTerm direction=horizontal <cr>", "Toggle second vertical ToggleTerm" },
            ["3h"] = { "<cmd>3ToggleTerm direction=vertical   <cr>", "Toggle third horizontal ToggleTerm" },
            ["3v"] = { "<cmd>3ToggleTerm direction=horizontal <cr>", "Toggle third vertical ToggleTerm" },
            ["4h"] = { "<cmd>4ToggleTerm direction=vertical   <cr>", "Toggle fourth horizontal ToggleTerm" },
            ["4v"] = { "<cmd>4ToggleTerm direction=horizontal <cr>", "Toggle fourth vertical ToggleTerm" },
          },
          ["u"] = {
            name = "UI",
            u = { function() WhichkeyRepeat("normal! 0", "lua GoToParentIndent()") end, "Jump to current_context", },
            U = { function() astronvim.ui.toggle_url_match() end, "Toggle URL highlight" },
            [";"] = { ":clearjumps<cr>:normal m'<cr>", "Clear and Add jump" }, -- Reset JumpList
          },
          ["U"] = {
            name = "TUI",
            ["0"] = { "<cmd>set showtabline=0<cr>", "Hide Buffer" },
            ["1"] = { "<cmd>set showtabline=2<cr>", "Show Buffer" },
            a = { "<cmd>Alpha<cr>", "Alpha (TabSame)" },
            A = { "<cmd>tabnew | Alpha<cr>", "Alpha (TabNew)" },
            c = {
              function()
                local cmdheight = vim.opt.cmdheight:get()
                if cmdheight == 0 then
                  vim.opt.cmdheight = 1
                else
                  vim.opt.cmdheight = 0
                end
              end
              , "Toggle cmdheight"
            },
            G = {
              function()
                if vim.g.ToggleNormal == nil then
                  vim.api.nvim_set_hl(0, "Normal", { bg = "#0b0b0b" })
                  vim.g.ToggleNormal = true
                else
                  vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
                  vim.g.ToggleNormal = nil
                end
              end
              , "Toggle Background"
            },
            h = { function() M.EnableAutoNoHighlightSearch() end, "Disable AutoNoHighlightSearch" },
            H = { function() M.DisableAutoNoHighlightSearch() end, "Enable AutoNoHighlightSearch" },
            I = { "<cmd>IndentBlanklineToggle<cr>", "Toggle IndentBlankline" },
            l = { "<cmd>set cursorline!<cr>", "Toggle Cursorline" },
            L = { "<cmd>setlocal cursorline!<cr>", "Toggle Local Cursorline" },
            o = { "<cmd>Legendary<cr>", "Open Legendary" },
            r = {
              function()
                require("toggleterm.terminal").Terminal:new({ cmd = "resto", direction = "tab", hidden = true }):toggle()
              end,
              "Rest Client"
            },
          },
          w = {
            name = "Window",
            B = { "<cmd>all<cr>", "Windows to buffers" },
            C = { "<C-w>o", "Close Other windows" },
            h = { "<C-w>H", "Move window to Leftmost" },
            j = { "<C-w>J", "Move window to Downmost" },
            k = { "<C-w>K", "Move window to Upmost" },
            l = { "<C-w>L", "Move window to Rightmost" },
            m = { "<C-w>_ | <c-w>|", "Maximize window" },
            n = { "<C-w>w", "Switch to next window CW " },
            p = { "<C-w>W", "Switch to previous window CCW" },
            q = { "<cmd>qa<cr>", "Quit all" },
            s = { "<cmd>wincmd x<cr>", "window Swap CW (same parent node)" },
            S = { "<cmd>-wincmd x<cr>", "window Swap CCW (same parent node)" },
            r = { "<C-w>r", "Rotate CW (same parent node)" },
            R = { "<C-w>R", "Rotate CCW (same parent node)" },
            ["<TAB>"] = {
              function()
                vim.cmd [[ setlocal nobuflisted ]]
                vim.cmd [[ wincmd T ]]
              end,
              "window to Tab"
            },
            v = { "<cmd>vsplit<cr>", "split vertical" },
            V = { "<cmd>split<cr>", "split horizontal" },
            w = { "<cmd>new<cr>", "New horizontal window" },
            W = { "<cmd>vnew<cr>", "New vertical window" },
            x = { "<cmd>wincmd q<cr>", "Close window" },
            [";"] = { "<C-w>p", "recent window" },
            ["="] = { "<C-w>=", "Reset windows sizes" },
          },

          ["1"] = "which_key_ignore",
          ["2"] = "which_key_ignore",
          ["3"] = "which_key_ignore",
          ["4"] = "which_key_ignore",
          ["5"] = "which_key_ignore",
          ["6"] = "which_key_ignore",
          ["7"] = "which_key_ignore",
          ["8"] = "which_key_ignore",
          ["9"] = "which_key_ignore",
          ["d"] = "which_key_ignore",
          ["v"] = "which_key_ignore",
          ["V"] = "which_key_ignore",
          ["q"] = "which_key_ignore",
          ["<Tab>"] = { "which_key_ignore" },
          ["<S-Tab>"] = { "which_key_ignore" },
          ["'"] = { "<Cmd>Telescope marks initial_mode=normal<CR>", "Marks" },
        }
      }
    }
  },

  -- This function is run last and is a good place to configuring
  -- augroups/autocommands and custom filetypes also this just pure lua so
  -- anything that doesn't fit in the normal config locations above can go here
  polish = function()
    -- Set up custom filetypes
    -- vim.filetype.add {
    --   extension = {
    --     foo = "fooscript",
    --   },
    --   filename = {
    --     ["Foofile"] = "fooscript",
    --   },
    -- pattern = {
    --     ["~/%.config/foo/.*"] = "fooscript",
    --   },
    -- }

    -- ╭─────────╮
    -- │ Autocmd │
    -- ╰─────────╯

    -- _autostart_EnableAutoNoHighlightSearch
    M.EnableAutoNoHighlightSearch()

    -- _jump_to_last_position_on_reopen
    vim.cmd [[ au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif ]]

    -- _disable_autocommented_new_lines
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      callback = function()
        vim.opt.formatoptions:remove { "c", "r", "o" }
      end,
    })

    -- _show_bufferline_if_more_than_two
    cmd({ "BufAdd" }, { command = "set showtabline=2" })

    -- _hide_bufferline_if_last_buffer
    cmd({ "BufDelete" }, {
      callback = function()
        if #vim.fn.getbufinfo({ buflisted = true }) == 2 then
          vim.o.showtabline = 0
        end
      end,
    })

    -- _show_tabs_if_more_than_two
    cmd({ "TabNew" }, { command = "set showtabline=2" })

    -- _show_alpha_if_close_last_tab-terminal
    cmd({ "TermClose" }, {
      callback = function()
        local type = vim.bo.filetype
        if type == "sp-terminal" or type == "vs-terminal" or type == "buf-terminal" or type == "tab-terminal" then
          if #vim.api.nvim_list_tabpages() == 1 then
            vim.cmd [[ Alpha ]]
            vim.cmd [[ bd # ]]
          else
            if #vim.fn.getbufinfo({ buflisted = 1 }) == 1 then
              vim.cmd [[ call feedkeys("\<Esc>\<Esc>:close\<CR>") ]]
            end
          end
          vim.cmd [[ call feedkeys("") ]]
        end
      end,
    })

    -- _custom_terminal_colors
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = function()
        local custom_themes = {
          tokyonight = {
            custom_terminal_colors = {
              terminal_color_0  = '#222222',
              terminal_color_1  = '#990000',
              terminal_color_2  = '#009900',
              terminal_color_3  = '#999900',
              terminal_color_4  = '#5555cc',
              terminal_color_5  = '#8855ff',
              terminal_color_6  = '#5FB3A1',
              terminal_color_7  = '#a0a0a0',
              terminal_color_8  = '#6c6c6c',
              terminal_color_9  = '#ff0000',
              terminal_color_10 = '#00ff00',
              terminal_color_11 = '#ffff00',
              terminal_color_12 = '#1c1cff',
              terminal_color_13 = '#8844bb',
              terminal_color_14 = '#5DE4C7',
              terminal_color_15 = '#ffffff',
            }
          },
          poimandres = {
            custom_terminal_colors = {
              terminal_color_0  = '#222222',
              terminal_color_1  = '#990000',
              terminal_color_2  = '#009900',
              terminal_color_3  = '#999900',
              terminal_color_4  = '#5555cc',
              terminal_color_5  = '#8855ff',
              terminal_color_6  = '#5FB3A1',
              terminal_color_7  = '#a0a0a0',
              terminal_color_8  = '#6c6c6c',
              terminal_color_9  = '#ff0000',
              terminal_color_10 = '#00ff00',
              terminal_color_11 = '#ffff00',
              terminal_color_12 = '#1c1cff',
              terminal_color_13 = '#8844bb',
              terminal_color_14 = '#5DE4C7',
              terminal_color_15 = '#ffffff',
            }
          },
        }
        local selected_colorscheme = custom_themes[vim.g.colors_name]
        if selected_colorscheme then
          for k, v in pairs(selected_colorscheme.custom_terminal_colors) do
            vim.g[k] = v
          end
        end
      end
    })
    local status_ok, _ = pcall(vim.cmd, "colorscheme " .. vim.g.colors_name)
    if not status_ok then
      return
    end

    -- ╭────────────╮
    -- │ Automation │
    -- ╰────────────╯

    -- Resize with arrows
    map({ 'n', 't' }, '<M-Left>', require('smart-splits').resize_left)
    map({ 'n', 't' }, '<M-Down>', require('smart-splits').resize_down)
    map({ 'n', 't' }, '<M-Up>', require('smart-splits').resize_up)
    map({ 'n', 't' }, '<M-Right>', require('smart-splits').resize_right)

    -- Navigate buffers
    keymap("n", "<right>", ":bnext<CR>", opts)
    keymap("n", "<left>", ":bprevious<CR>", opts)
    keymap("n", "<Home>", ":tabprevious<CR>", opts)
    keymap("n", "<End>", ":tabnext<CR>", opts)
    keymap("n", "<Insert>", ":tabnext #<CR>", opts)
    keymap("t", "<Home>", "<C-\\><C-n>:tabprevious<CR>", opts)
    keymap("t", "<End>", "<C-\\><C-n>:tabnext<CR>", opts)
    keymap("t", "<Insert>", "<C-\\><C-n>:tabnext #<CR>", opts)
    keymap("n", "<Tab>", ":bnext<CR>", opts)
    keymap("n", "<S-Tab>", ":bprevious<CR>", opts)
    keymap("n", "<leader>x", ":bp | bd #<CR>", { desc = "Close Buffer" })
    keymap("n", "<leader><Tab>", ":tabnext<CR>", opts)
    keymap("n", "<leader><S-Tab>", ":tabprevious<CR>", opts)
    keymap("n", "<leader>X", ":tabclose<CR>", { desc = "Close Tab" })
    keymap("n", "gb;", "<C-6>", { noremap = true, silent = true, desc = "go to last buffer" })

    -- _codeium_completion
    map('i', '<c-h>', function() return vim.fn['codeium#Clear']() end, { expr = true })
    map('i', '<c-j>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true })
    map('i', '<c-k>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true })
    map('i', '<c-l>', function() return vim.fn['codeium#Accept']() end, { expr = true })

    -- Replace all/visual_selected
    map({ "n" }, "<C-s>", ":%s//g<Left><Left>", { desc = "Replace in Buffer" })
    map({ "x" }, "<C-s>", ":s//g<Left><Left>", { desc = "Replace in Visual_selected" })

    -- ╭──────────────╮
    -- │ Text Objects │
    -- ╰──────────────╯

    -- _goto_textobj_(dotrepeat)
    map('n', "g.", function() return GotoTextObj("") end, { expr = true, desc = "StartOf TextObj" })
    map('n', "g:", function() return GotoTextObj(":normal `[v`]<cr><esc>") end, { expr = true, desc = "EndOf TextObj" })

    -- _last_change_text_object
    map("o", 'gm', "<cmd>normal! `[v`]<Left><cr>", { desc = "Last change textobj" })
    map("x", 'gm', "`[o`]<Left>", { desc = "Last change textobj" })

    -- _git_hunk_(next/prev_autojump_unsupported)
    map({ 'o', 'x' }, 'gh', ':<C-U>Gitsigns select_hunk<CR>', { desc = "Git hunk textobj" })

    -- _jump_to_last_change
    map({ "n", "o", "x" }, "gl", "`.", { desc = "Jump to last change" })

    -- _mini_comment_(not_showing_desc)_(next/prev_autojump_unsupported)
    map({ "o" }, 'gk', '<Cmd>lua MiniComment.textobject()<CR>', { desc = "BlockComment textobj" })
    map({ "x" }, 'gk', ':<C-u>normal "zygkgv<cr>', { desc = "BlockComment textobj" })
    map({ "x" }, 'gK', '<Cmd>lua MiniComment.textobject()<cr>', { desc = "RestOfComment textobj" })
    map({ "x" }, 'gC', ':<C-u>normal "zygcgv<cr>', { desc = "WholeComment textobj" })

    -- _search_textobj_(dot-repeat_supported)
    map({ "o", "x" }, "gs", "gn", { noremap = true, desc = "Next search textobj" })
    map({ "o", "x" }, "gS", "gN", { noremap = true, desc = "Prev search textobj" })

    -- _replace_textobj_(repeable_with_cgs_+_dotrepeat_supported)
    map({ 'x' }, 'g/', '"zy:s/<C-r>z//g<Left><Left>', { desc = "Replace textobj" })

    -- _nvim_various_textobjs
    map({ "o", "x" }, "gd", function() require("various-textobjs").diagnostic() vim.call("repeat#set", "vgd") end,
      { desc = "Diagnostic textobj" })
    map({ "o", "x" }, "gL", function() require("various-textobjs").nearEoL() vim.call("repeat#set", "vgL") end,
      { desc = "nearEoL textobj" })
    map({ "o", "x" }, "g|", function() require("various-textobjs").column() vim.call("repeat#set", "vg|") end,
      { desc = "ColumnDown textobj" })
    map({ "o", "x" }, "gr", function() require("various-textobjs").restOfParagraph() vim.call("repeat#set", "vgr") end,
      { desc = "RestOfParagraph textobj" })
    map({ "o", "x" }, "gR", function() require("various-textobjs").restOfIndentation() vim.call("repeat#set", "vgR") end
      , { desc = "restOfIndentation textobj" })
    map({ "o", "x" }, "gG", function() require("various-textobjs").entireBuffer() end,
      { desc = "EntireBuffer textobj" })
    map({ "o", "x" }, "gu", function() require("various-textobjs").url() vim.call("repeat#set", "vgu") end,
      { desc = "Url textobj" })

    -- _nvim_various_textobjs: inner-outer
    map({ "o", "x" }, "aS", function() require("various-textobjs").subword(false) vim.call("repeat#set", "vaS") end,
      { desc = "outer Subword textobj" })
    map({ "o", "x" }, "iS", function() require("various-textobjs").subword(true) vim.call("repeat#set", "vaS") end,
      { desc = "inner Subword textobj" })

    -- _vim_indent_object_(visualrepeatable_+_vimrepeat)
    vim.api.nvim_create_autocmd({ "FileType" }, {
      pattern = "*",
      callback = function()
        map({ "o", "x" }, "iI", "<Cmd>lua MiniIndentscope.textobject(false)<CR>", { desc = "MiniIndentscope_iI" })
        map({ "o", "x" }, "aI", "<Cmd>lua MiniIndentscope.textobject(true)<CR>", { desc = "MiniIndentscope_aI" })
      end
    })

    -- _vim-textobj-space
    vim.g.textobj_space_no_default_key_mappings = true
    map({ "o", "x" }, "ir", "<Plug>(textobj-space-i)", { desc = "Space textobj" })
    map({ "o", "x" }, "ar", "<Plug>(textobj-space-a)", { desc = "Space textobj" })

    -- _illuminate_text_objects
    map({ 'n', 'x', 'o' }, '<a-n>', '<cmd>lua require"illuminate".goto_next_reference(wrap)<cr>')
    map({ 'n', 'x', 'o' }, '<a-p>', '<cmd>lua require"illuminate".goto_prev_reference(wrap)<cr>')
    map({ 'n', 'x', 'o' }, '<a-i>', '<cmd>lua require"illuminate".textobj_select()<cr>')

    -- _clipboard_textobj
    vim.cmd [[
      let g:EasyClipUseCutDefaults = 0
      let g:EasyClipEnableBlackHoleRedirect = 0
      nmap gx "_d
      nmap gxx "_dd
      xmap gx "_d

      let g:EasyClipUseYankDefaults = 0
      nmap <silent> gy <plug>SubstituteOverMotionMap
      nmap gyy <plug>SubstituteLine
      xmap gy <plug>XEasyClipPaste

      let g:EasyClipUsePasteDefaults = 0
      nmap gY <plug>G_EasyClipPasteBefore
      xmap gY <Plug>XG_EasyClipPaste

      let g:EasyClipUsePasteToggleDefaults = 0
      nmap gz <plug>EasyClipSwapPasteForward
      nmap gZ <plug>EasyClipSwapPasteBackwards

    ]]

    -- ╭─────────╮
    -- │ Motions │
    -- ╰─────────╯

    -- _sneak_keymaps
    vim.cmd [[
      let g:sneak#prompt = ''
      map f <Plug>Sneak_f
      map F <Plug>Sneak_F
      map t <Plug>Sneak_t
      map T <Plug>Sneak_T
      map <space><space>s <Plug>SneakLabel_s
      map <space><space>S <Plug>SneakLabel_S
      nmap <silent><expr> <Tab> sneak#is_sneaking() ? '<Plug>SneakLabel_s<cr>' : ':bnext<cr>'
      nmap <silent><expr> <S-Tab> sneak#is_sneaking() ? '<Plug>SneakLabel_S<cr>' : ':bprevious<cr>'
      omap <Tab> <Plug>SneakLabel_s<cr>
      omap <S-Tab> <Plug>SneakLabel_S<cr>
      vmap <Tab> <Plug>SneakLabel_s<cr>
      vmap <S-Tab> <Plug>SneakLabel_S<cr>
      xmap <Tab> <Plug>SneakLabel_s<cr>
      xmap <S-Tab> <Plug>SneakLabel_S<cr>
    ]]

    -- _bufpos.vim
    vim.cmd [[
      function! BufPos_ActivateBuffer(num)
        let l:count = 1
        for i in range(1, bufnr("$"))
          if buflisted(i) && getbufvar(i, "&modifiable")
            if l:count == a:num
              exe "buffer " . i
              return
            endif
            let l:count = l:count + 1
          endif
        endfor
      endfunction

      function! BufPos_Initialize()
        for i in range(1, 9)
          exe "map <Space>" . i . " :call BufPos_ActivateBuffer(" . i . ")<CR>"
        endfor
      endfunction

      autocmd VimEnter * call BufPos_Initialize()
    ]]

    -- ╭────────────╮
    -- │ Repeatable │
    -- ╰────────────╯

    -- _nvim-treesitter-textobjs_repeatable
    -- ensure ; goes forward and , goes backward regardless of the last direction
    local ts_repeat_move_status_ok, ts_repeat_move = pcall(require, "nvim-treesitter.textobjects.repeatable_move")
    if ts_repeat_move_status_ok then
      map({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next, { desc = "Next TS textobj" })
      map({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous, { desc = "Prev TS textobj" })

      -- _sneak_repeatable
      vim.cmd [[ command SneakForward execute "normal \<Plug>Sneak_;" ]]
      vim.cmd [[ command SneakBackward execute "normal \<Plug>Sneak_," ]]
      local next_sneak, prev_sneak = ts_repeat_move.make_repeatable_move_pair(
        function() vim.cmd [[ SneakForward ]] end,
        function() vim.cmd [[ SneakBackward ]] end
      )
      map({ "n", "x", "o" }, "<BS>", next_sneak, { desc = "Next SneakForward" })
      map({ "n", "x", "o" }, "<S-BS>", prev_sneak, { desc = "Prev SneakForward" })

      -- _goto_diagnostic_repeatable
      local next_diagnostic, prev_diagnostic = ts_repeat_move.make_repeatable_move_pair(
        function() vim.diagnostic.goto_next({ border = "rounded" }) end,
        function() vim.diagnostic.goto_prev({ border = "rounded" }) end
      )
      map({ "n", "x", "o" }, "gnd", next_diagnostic, { desc = "Next Diagnostic" })
      map({ "n", "x", "o" }, "gpd", prev_diagnostic, { desc = "Prev Diagnostic" })

      -- _goto_function_definition_repeatable
      local next_funcdefinition, prev_funcdefinition = ts_repeat_move.make_repeatable_move_pair(
        function() vim.cmd [[ normal vaNf ]] vim.cmd [[ call feedkeys("") ]] end,
        function() vim.cmd [[ normal valf ]] vim.cmd [[ call feedkeys("") ]] end
      )
      map({ "n", "x", "o" }, "gnf", next_funcdefinition, { desc = "Next FuncDefinition" })
      map({ "n", "x", "o" }, "gpf", prev_funcdefinition, { desc = "Prev FuncDefinition" })

      -- _gitsigns_chunck_repeatable
      local gs = require("gitsigns")
      local next_hunk_repeat, prev_hunk_repeat = ts_repeat_move.make_repeatable_move_pair(gs.next_hunk, gs.prev_hunk)
      map({ "n", "x", "o" }, "gnh", next_hunk_repeat, { desc = "Next GitHunk" })
      map({ "n", "x", "o" }, "gph", prev_hunk_repeat, { desc = "Prev GitHunk" })

      -- _goto_quotes_repeatable
      local next_quote, prev_quote = ts_repeat_move.make_repeatable_move_pair(
        function() vim.cmd [[ normal viNu ]] vim.cmd [[ call feedkeys("") ]] end,
        function() vim.cmd [[ normal vilu ]] vim.cmd [[ call feedkeys("") ]] end
      )
      map({ "n", "x", "o" }, "gnu", next_quote, { desc = "Next Quote" })
      map({ "n", "x", "o" }, "gpu", prev_quote, { desc = "Prev Quote" })

      -- _columnmove_repeatable
      vim.g.columnmove_strict_wbege = 0 -- skips inner-paragraph whitespaces for wbege
      vim.g.columnmove_no_default_key_mappings = true
      map({ "n", "o", "x" }, "<leader><leader>f", "<Plug>(columnmove-f)", { silent = true })
      map({ "n", "o", "x" }, "<leader><leader>t", "<Plug>(columnmove-t)", { silent = true })
      map({ "n", "o", "x" }, "<leader><leader>F", "<Plug>(columnmove-F)", { silent = true })
      map({ "n", "o", "x" }, "<leader><leader>T", "<Plug>(columnmove-T)", { silent = true })

      local next_columnmove, prev_columnmove = ts_repeat_move.make_repeatable_move_pair(
        function() vim.cmd [[ execute "normal \<Plug>(columnmove-;)" ]] end,
        function() vim.cmd [[ execute "normal \<Plug>(columnmove-,)" ]] end
      )
      map({ "n", "x", "o" }, "<leader><leader>;", next_columnmove, { desc = "Next ColumnMove_;" })
      map({ "n", "x", "o" }, "<leader><leader>,", prev_columnmove, { desc = "Prev ColumnMove_," })

      local next_columnmove_w, prev_columnmove_b = ts_repeat_move.make_repeatable_move_pair(
        function() vim.cmd [[ execute "normal \<Plug>(columnmove-w)" ]] end,
        function() vim.cmd [[ execute "normal \<Plug>(columnmove-b)" ]] end
      )
      map({ "n", "x", "o" }, "<leader><leader>w", next_columnmove_w, { desc = "Next ColumnMove_w" })
      map({ "n", "x", "o" }, "<leader><leader>b", prev_columnmove_b, { desc = "Prev ColumnMove_b" })

      local next_columnmove_e, prev_columnmove_ge = ts_repeat_move.make_repeatable_move_pair(
        function() vim.cmd [[ execute "normal \<Plug>(columnmove-e)" ]] end,
        function() vim.cmd [[ execute "normal \<Plug>(columnmove-ge)" ]] end
      )
      map({ "n", "x", "o" }, "<leader><leader>e", next_columnmove_e, { desc = "Next ColumnMove_e" })
      map({ "n", "x", "o" }, "<leader><leader>ge", prev_columnmove_ge, { desc = "Prev ColumnMove_ge" })

      local next_columnmove_W, prev_columnmove_B = ts_repeat_move.make_repeatable_move_pair(
        function() vim.cmd [[ execute "normal \<Plug>(columnmove-W)" ]] end,
        function() vim.cmd [[ execute "normal \<Plug>(columnmove-B)" ]] end
      )
      map({ "n", "x", "o" }, "<leader><leader>W", next_columnmove_W, { desc = "Next ColumnMove_W" })
      map({ "n", "x", "o" }, "<leader><leader>B", prev_columnmove_B, { desc = "Prev ColumnMove_B" })

      local next_columnmove_E, prev_columnmove_gE = ts_repeat_move.make_repeatable_move_pair(
        function() vim.cmd [[ execute "normal \<Plug>(columnmove-E)" ]] end,
        function() vim.cmd [[ execute "normal \<Plug>(columnmove-gE)" ]] end
      )
      map({ "n", "x", "o" }, "<leader><leader>E", next_columnmove_E, { desc = "Next ColumnMove_E" })
      map({ "n", "x", "o" }, "<leader><leader>gE", prev_columnmove_gE, { desc = "Prev ColumnMove_gE" })

      -- _jump_blankline_repeatable
      local next_blankline, prev_blankline = ts_repeat_move.make_repeatable_move_pair(
        function() vim.cmd [[ normal } ]] end,
        function() vim.cmd [[ normal { ]] end
      )
      map({ "n", "x", "o" }, "<leader><leader>}", next_blankline, { desc = "Next Blankline" })
      map({ "n", "x", "o" }, "<leader><leader>{", prev_blankline, { desc = "Prev Blankline" })

      -- _jump_indent_repeatable
      local next_indent, prev_indent = ts_repeat_move.make_repeatable_move_pair(
        function() vim.cmd [[ normal vii_ ]] vim.cmd [[ call feedkeys("") ]] end,
        function() vim.cmd [[ normal viio_ ]] vim.cmd [[ call feedkeys("") ]] end
      )
      map({ "n", "x", "o" }, "<leader><leader>]", next_indent, { desc = "Next Indent" })
      map({ "n", "x", "o" }, "<leader><leader>[", prev_indent, { desc = "Prev Indent" })

      -- _jump_paragraph_repeatable
      local next_paragraph, prev_paragraph = ts_repeat_move.make_repeatable_move_pair(
        function() vim.cmd [[ normal ) ]] end,
        function() vim.cmd [[ normal ( ]] end
      )
      map({ "n", "x", "o" }, "<leader><leader>)", next_paragraph, { desc = "Next Paragraph" })
      map({ "n", "x", "o" }, "<leader><leader>(", prev_paragraph, { desc = "Prev Paragraph" })

      -- _jump_startofline_repeatable
      local next_startline, prev_startline = ts_repeat_move.make_repeatable_move_pair(
        function() vim.cmd [[ normal + ]] end,
        function() vim.cmd [[ normal - ]] end
      )
      map({ "n", "x", "o" }, "<leader><leader>+", next_startline, { desc = "Next StartLine" })
      map({ "n", "x", "o" }, "<leader><leader>-", prev_startline, { desc = "Prev StartLine" })

      -- _number_textobj_(goto_repeatable)
      local next_inner_hex, prev_inner_hex = ts_repeat_move.make_repeatable_move_pair(
        function() require("mini.ai").move_cursor('left', 'i', 'x', { search_method = 'next' }) end,
        function() require("mini.ai").move_cursor('left', 'i', 'x', { search_method = 'prev' }) end
      )
      map({ "n", "x", "o" }, "gnx", next_inner_hex, { desc = "Next Inner Hex" })
      map({ "n", "x", "o" }, "gpx", prev_inner_hex, { desc = "Prev Inner Hex" })

      local next_around_hex, prev_around_hex = ts_repeat_move.make_repeatable_move_pair(
        function() require("mini.ai").move_cursor('left', 'a', 'x', { search_method = 'next' }) end,
        function() require("mini.ai").move_cursor('left', 'a', 'x', { search_method = 'prev' }) end
      )
      map({ "n", "x", "o" }, "gNx", next_around_hex, { desc = "Next Around Hex" })
      map({ "n", "x", "o" }, "gPx", prev_around_hex, { desc = "Prev Around Hex" })

      -- hexadecimalcolor_textobj_(goto_repeatable)
      local next_inner_numeral, prev_inner_numeral = ts_repeat_move.make_repeatable_move_pair(
        function() require("mini.ai").move_cursor('left', 'i', 'n', { search_method = 'next' }) end,
        function() require("mini.ai").move_cursor('left', 'i', 'n', { search_method = 'prev' }) end
      )
      map({ "n", "x", "o" }, "gnn", next_inner_numeral, { desc = "Next Inner Number" })
      map({ "n", "x", "o" }, "gpn", prev_inner_numeral, { desc = "Prev Inner Number" })

      local next_around_numeral, prev_around_numeral = ts_repeat_move.make_repeatable_move_pair(
        function() require("mini.ai").move_cursor('left', 'a', 'n', { search_method = 'next' }) end,
        function() require("mini.ai").move_cursor('left', 'a', 'n', { search_method = 'prev' }) end
      )
      map({ "n", "x", "o" }, "gNn", next_around_numeral, { desc = "Next Around Number" })
      map({ "n", "x", "o" }, "gPn", prev_around_numeral, { desc = "Prev Around Number" })

      -- _vert_horz_incremental_(goto_repeatable)
      local vert_increment, vert_decrement = ts_repeat_move.make_repeatable_move_pair(
        function() vim.cmd [[ normal "zyanjvan"zp ]] FeedKeysCorrectly('<C-a>') end,
        function() vim.cmd [[ normal "zyanjvan"zp ]] FeedKeysCorrectly('<C-x>') end
      )
      map({ "n" }, "g+", vert_increment, { desc = "Vert Increment" })
      map({ "n" }, "g-", vert_decrement, { desc = "Vert Decrement" })

      local horz_increment, horz_decrement = ts_repeat_move.make_repeatable_move_pair(
        function() vim.cmd [[ normal "zyanvaNn"zp ]] FeedKeysCorrectly('<C-a>') end,
        function() vim.cmd [[ normal "zyanvaNn"zp ]] FeedKeysCorrectly('<C-x>') end
      )
      map({ "n" }, "gn+", horz_increment, { desc = "Horz increment" })
      map({ "n" }, "gn-", horz_decrement, { desc = "Horz Decrement" })

      -- _key_textobj_(goto_repeatable)
      local next_inner_key, prev_inner_key = ts_repeat_move.make_repeatable_move_pair(
        function() require("mini.ai").move_cursor('left', 'i', 'k', { search_method = 'next' }) end,
        function() require("mini.ai").move_cursor('left', 'i', 'k', { search_method = 'prev' }) end
      )
      map({ "n", "x", "o" }, "gnk", next_inner_key, { desc = "Next Inner Key" })
      map({ "n", "x", "o" }, "gpk", prev_inner_key, { desc = "Prev Inner Key" })

      local next_around_key, prev_around_key = ts_repeat_move.make_repeatable_move_pair(
        function() require("mini.ai").move_cursor('left', 'a', 'k', { search_method = 'next' }) end,
        function() require("mini.ai").move_cursor('left', 'a', 'k', { search_method = 'prev' }) end
      )
      map({ "n", "x", "o" }, "gNk", next_around_key, { desc = "Next Around Key" })
      map({ "n", "x", "o" }, "gNk", prev_around_key, { desc = "Prev Around Key" })

      -- _value_textobj_(goto_repeatable)
      local next_inner_value, prev_inner_value = ts_repeat_move.make_repeatable_move_pair(
        function() require("mini.ai").move_cursor('left', 'i', 'v', { search_method = 'next' }) end,
        function() require("mini.ai").move_cursor('left', 'i', 'v', { search_method = 'prev' }) end
      )
      map({ "n", "x", "o" }, "gnv", next_inner_value, { desc = "Next Inner Value" })
      map({ "n", "x", "o" }, "gpv", prev_inner_value, { desc = "Prev Inner Value" })

      local next_around_value, prev_around_value = ts_repeat_move.make_repeatable_move_pair(
        function() require("mini.ai").move_cursor('left', 'a', 'v', { search_method = 'next' }) end,
        function() require("mini.ai").move_cursor('left', 'a', 'v', { search_method = 'prev' }) end
      )
      map({ "n", "x", "o" }, "gNv", next_around_value, { desc = "Next Around Value" })
      map({ "n", "x", "o" }, "gNv", prev_around_value, { desc = "Prev Around Value" })

      -- _comment_(goto_repeatable)
      local next_comment, prev_comment = ts_repeat_move.make_repeatable_move_pair(
        function() require('mini.bracketed').comment('forward') end,
        function() require('mini.bracketed').comment('backward') end
      )
      map({ "n", "x", "o" }, "gnc", next_comment, { desc = "Next Comment" })
      map({ "n", "x", "o" }, "gpc", prev_comment, { desc = "Prev Comment" })

    end

    -- ╭───────────╮
    -- │ Lspconfig │
    -- ╰───────────╯

    -- _manually_lspconfig_setup_using_nix/system_package_manager
    local handle = io.popen("lua-language-server --version 2>/dev/null")
    if handle then --handles "Need check nil" warning
      local output = handle:read("*a")
      if output:match("^3.*") then
        require('lspconfig')['sumneko_lua'].setup {
          on_attach = astronvim.lsp.on_attach,
          capabilities = astronvim.lsp.capabilities,
          settings = {
            Lua = {
              telemetry = { enable = false },
              runtime = { version = "LuaJIT" },
              diagnostics = { globals = { "vim" } },
              format = { enable = true, }
            }
          }
        }
      end
      handle:close()
    end

    -- ╭──────────╮
    -- │ WhichKey │
    -- ╰──────────╯

    local mini_textobj = {
      q = '@call',
      Q = '@class',
      g = '@comment',
      G = '@conditional',
      B = '@block',
      F = '@function',
      L = '@loop',
      P = '@parameter',
      R = '@return',
      ["="] = '@assignment.side',
      ["+"] = '@assignment.whole',
      ['a'] = 'Function Parameters',
      ['A'] = 'Whole Buffer',
      ['b'] = 'Alias )]}',
      ['f'] = 'Function Definition',
      ['k'] = 'Key',
      ['n'] = 'Number',
      ['p'] = 'Paragraph',
      ['s'] = 'Sentence',
      ['t'] = 'Tag',
      ['u'] = 'Alias "\'`',
      ['v'] = 'Value',
      ['w'] = 'Word',
      ['x'] = 'Hex',
      ['?'] = 'Prompt',
      ['('] = 'Same as )',
      ['['] = 'Same as ]',
      ['{'] = 'Same as }',
      ['<'] = 'Same as >',
      ['"'] = 'punctuations...',
      ["'"] = 'punctuations...',
      ["`"] = 'punctuations...',
      ['.'] = 'punctuations...',
      [','] = 'punctuations...',
      [';'] = 'punctuations...',
      ['-'] = 'punctuations...',
      ['_'] = 'punctuations...',
      ['/'] = 'punctuations...',
      ['|'] = 'punctuations...',
      ['&'] = 'punctuations...',
      -- `!@#$%^&*()_+-=[]{};'\:"|,./<>?
    }

    require("which-key").register({
      mode = { "o", "x" },
      ["i"] = mini_textobj,
      ["il"] = { name = "+Last", mini_textobj },
      ["iN"] = { name = "+Next", mini_textobj },
      ["a"] = mini_textobj,
      ["al"] = { name = "+Last", mini_textobj },
      ["aN"] = { name = "+Next", mini_textobj },
    })

    require("which-key").register({
      mode = { "n" },
      ["g["] = vim.tbl_extend("force", { name = "+Cursor to Left Around" }, mini_textobj),
      ["g]"] = vim.tbl_extend("force", { name = "+Cursor to Rigth Around" }, mini_textobj),
    })

  end
}

return config
