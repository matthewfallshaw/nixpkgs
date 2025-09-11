-- Setup Environment -------------------------------------------------------------------------------

-- Create locals for all needed globals so we have access to them
local unpack = unpack
local vim = vim
local func = require 'pl.func'
local seq = require 'pl.seq'

-- Clear environment
local _ENV = {}

-- Init module
local M = {}

-- Main functions ----------------------------------------------------------------------------------

function M.spread(f) return function(t) f(unpack(t)) end end

function M.const(f) return function() return f end end

function M.keymaps(t)
  seq(t.maps):foreach(M.spread(func.bind(vim.keymap.set, t.modes, func._1, func._2, t.opts)))
end

function M.augroup(t)
  vim.api.nvim_create_augroup(t.name, {})
  seq(t.cmds):foreach(function(cmd)
    cmd[2].group = t.name
    vim.api.nvim_create_autocmd(cmd[1], cmd[2])
  end)
end

-- Other handy stuff -------------------------------------------------------------------------------

M.symbols = {
  close = '',
  error = '',
  errorShape = '',
  gitBranch = '',
  ibar = '',
  info = '',
  infoShape = '',
  list = '',
  lock = '',
  pencil = '',
  question = '',
  questionShape = '',
  sepRoundLeft = '',
  sepRoundRight = '',
  spinner = '',
  term = '',
  vim = '',
  wand = '',
  warning = '',
  warningShape = '',
}

return M
