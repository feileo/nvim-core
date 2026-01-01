local M = {}
local map = vim.keymap.set

-- export on_attach & capabilities
M.on_attach = function(_, bufnr)
  local function opts(desc)
    return { buffer = bufnr, desc = "LSP " .. desc }
  end

  -- map("n", "gD", vim.lsp.buf.declaration, opts "Go to declaration")
  -- map("n", "gd", vim.lsp.buf.definition, opts "Go to definition")
  -- map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts "Add workspace folder")
  -- map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts "Remove workspace folder")

  -- map("n", "<leader>wl", function()
  --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  -- end, opts "List workspace folders")

  -- map("n", "<leader>D", vim.lsp.buf.type_definition, opts "Go to type definition")
  -- map("n", "<leader>ra", require "nvchad.lsp.renamer", opts "NvRenamer")
  map("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts "LSP hover doc")
  map("n", "<2-LeftMouse>", "<cmd>Lspsaga goto_definition<CR>", opts "LSP goto definition")
  map("n", "<A-LeftMouse>", "<cmd>Lspsaga goto_definition<CR>", opts "LSP goto definition")
  map("n", "gd", "<cmd>Lspsaga goto_definition<CR>", opts "LSP goto definition")
  map("n", "gD", "<cmd>Lspsaga goto_type_definition<CR>", opts "LSP goto type definition")
  map("n", "gp", "<cmd>Lspsaga peek_definition<CR>", opts "LSP peek definition")
  map("n", "gP", "<cmd>Lspsaga peek_type_definition<CR>", opts "LSP peek type definition")
  map("n", "gf", "<cmd>Lspsaga finder<CR>", opts "LSP finder")
  map("n", "gi", "<cmd>Lspsaga finder imp<CR>", opts "LSP implementation")
  map("n", "gr", "<cmd>Lspsaga finder ref<CR>", opts "LSP references")
  map("n", "gn", require "nvchad.lsp.renamer", opts "NvRenamer")
  -- map("n", "gn", "<cmd>Lspsaga rename<CR>", opts "LSP rename")
  map("n", "gN", "<cmd>Lspsaga rename ++project<CR>", opts "LSP rename project")

  map("n", "gca", "<cmd>Lspsaga code_action<CR>", opts "LSP code action")
  map("n", "gco", "<cmd>Lspsaga outgoing_calls<CR>", opts "LSP outgoing_calls")
  map("n", "gci", "<cmd>Lspsaga incoming_calls<CR>", opts "LSP incoming_calls")

  map("n", "<leader>d", "<cmd>Lspsaga goto_definition<CR>", opts "LSP goto definition")
  map("n", "<leader>D", "<cmd>Lspsaga goto_type_definition<CR>", opts "LSP goto type definition")
  map("n", "<leader>p", "<cmd>Lspsaga peek_definition<CR>", opts "LSP peek definition")
  map("n", "<leader>e", "<cmd>Lspsaga show_buf_diagnostics<CR>", opts "LSP show buf diagnostics")
  map("n", "<leader>E", "<cmd>Lspsaga show_workspace_diagnostics<CR>", opts "LSP show work diagnostics")
  map("n", "<leader>0", "<cmd>Lspsaga outline<CR>", opts "LSP symbols outline")
end

-- disable semanticTokens
M.on_init = function(client, _)
  if vim.fn.has "nvim-0.11" ~= 1 then
    if client.supports_method "textDocument/semanticTokens" then
      client.server_capabilities.semanticTokensProvider = nil
    end
  else
    if client:supports_method "textDocument/semanticTokens" then
      client.server_capabilities.semanticTokensProvider = nil
    end
  end
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()

M.capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

M.defaults = function()
  dofile(vim.g.base46_cache .. "lsp")
  require("nvchad.lsp").diagnostic_config()

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      M.on_attach(_, args.buf)
    end,
  })

  local lua_lsp_settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = {
        library = {
          vim.fn.expand "$VIMRUNTIME/lua",
          vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types",
          vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy",
          "${3rd}/luv/library",
        },
      },
    },
  }

  -- Use new vim.lsp.config API for Neovim 0.11+
  vim.lsp.config("*", { capabilities = M.capabilities, on_init = M.on_init })
  vim.lsp.config("lua_ls", { settings = lua_lsp_settings })
  vim.lsp.enable "lua_ls"
end

return M
