-- Setup Environment -------------------------------------------------------------------------------

_ = require 'moses'

-- Create locals for all needed globals so we have access to them
local vim = vim
local expand = vim.fn.expand
local shellescape = vim.fn.shellescape
local expand_escape = function(...) return shellescape(expand(...)) end

-- Clear environment
local _ENV = {}

-- Init module
local M = { default_format = 'amf' }
M.lines = {}

-- require 'luapad'.attach({
--   context = { M = M }
-- })

-- Helper functions -----------------------------------------------------------------------------

local function populate_quickfix(job_id)
  vim.fn.setqflist(
    {},
    " ",
    {
      title = M.lines.job_id.title,
      lines = M.lines.job_id.lines,
    }
  )
end

local function add_data(job_id, data)
  if data then
    if type(data)=='table' then
      M.lines.job_id.lines = _.append(M.lines.job_id.lines, data)
    else
      print('add_data: '..vim.inspect(data))
    end
  end
end

local function open_quickfix_and_return()
  vim.api.nvim_command('copen')
  vim.cmd('wincmd p')
end

local function on_exit(job_id, data, event)
  add_data(job_id, data)
end

local function on_out(job_id, data, event)
  add_data(job_id, data)
  populate_quickfix(job_id)
end

local function on_err(job_id, data, event)
  add_data(job_id, data)
  populate_quickfix(job_id)
end

-- Keymaps -----------------------------------------------------------------------------------------

local utils = require 'malo.utils'
local bufkeymaps = utils.bufkeymaps

---@type fun(s:string)
local function with_crs(s)
  return string.gsub(s, '[\n\r]', '<CR>')
end

bufkeymaps{ mode = 'i', opts = { 'noremap' }, maps = {

  { ';;b', with_crs [[
include <BOSL2/std.scad>
MODE="assy"; // [ "assy", "help" ]

]] },

  { ';;n', with_crs [[
include <NopSCADlib/lib.scad>
// include <NopSCADlib/vitamins/stepper_motors.scad>
<ESC>cc
]] },

  { ';;s', with_crs [[
include <stdlib.scad>

// Fragment arc count: Circles have $fa segments; arcs have 360/$fa angles
<ESC>cc$fa=12;  // [16, 32, 64, 128, 256]

// Fragment size: Maximum size for line fragments
<ESC>cc$fs=2;   // [0.1, 0.25, 0.5, 1, 2, 5, 10]

// Override $fs, use $fn for $fa
<ESC>cc$fn=0;  // [0, 16, 32, 64, 128, 256]

// BIGNUM=100;
<ESC>cc

MODE = "assy"; // [ part, assy, help ]
MODES = [ "part", "assy", str("help") ];
if(MODE=="assy") assy();
else if(MODE=="part") part();
else assert(false, str("Unrecognised MODE: ", MODE, "; Available modes: ", MODES));


module part() {
}

module assy() {
  part();
}<ESC><<4k<<O
]] },

  { ';;A', with_crs [[anchor=CENTER, spin=0, orient=UP]] },

  { ';;a', with_crs [[anchor=anchor, spin=spin, orient=orient]] },

} }


-- Make functions -------------------------------------------------------------------------------

function M.Make(format)
  local fmt = format or M.default_format
  local infile = expand_escape('%')
  local outfile = expand_escape('%:r')..'.'..fmt

  local cmd = 'openscad '..infile..' -o '..outfile

  local winnr = vim.fn.win_getid()
  local bufnr = vim.api.nvim_win_get_buf(winnr)

  local job_id = vim.fn.jobstart(
    cmd,
    {
      on_stderr = on_err,
      on_stdout = on_out,
      on_exit = on_exit,
      stdout_buffered = true,
      stderr_buffered = true,
    }
  )

  M.lines.job_id = {
    title = cmd,
    lines = { 'Make: ', cmd, '' },
    winnr = winnr,
    bufnr = bufnr,
  }
  populate_quickfix(job_id)
  open_quickfix_and_return()
end

function M.ReMake(name, format)
  local fmt = format or M.default_format
  local infile = expand_escape('%')
  local outfile = expand_escape('%:p:h/')..name..'.'..fmt

  local cmd = 'openscad '..infile..' -o '..outfile

  local winnr = vim.fn.win_getid()
  local bufnr = vim.api.nvim_win_get_buf(winnr)

  local job_id = vim.fn.jobstart(
    cmd,
    {
      on_stderr = on_err,
      on_stdout = on_out,
      on_exit = on_exit,
      stdout_buffered = true,
      stderr_buffered = true,
    }
  )

  M.lines.job_id = {
    title = cmd,
    lines = { 'ReMake: ', cmd, '' },
    winnr = winnr,
    bufnr = bufnr,
  }
  populate_quickfix(job_id)
  open_quickfix_and_return()
end

function M.MakeModes(format)
  local fmt = format or M.default_format
  local infile = expand_escape('%')
  local outfile_fragment = expand_escape('%:r')

  local cmd =
    [[rg "^\s*(?:else )?if ?\(MODE==\"?([^\"\)]+)\"?\).*" ]]..infile..[[ -r '$1' | rg -v '^assy|^nil|^_' ]]..
    [[| parallel ]]..
    [[openscad -D MODE='\"{}\"' ]]..infile..[[ -o ]]..outfile_fragment..[[_{}.]]..fmt

  local winnr = vim.fn.win_getid()
  local bufnr = vim.api.nvim_win_get_buf(winnr)

  local job_id = vim.fn.jobstart(
    cmd,
    {
      on_stderr = on_err,
      on_stdout = on_out,
      on_exit = on_exit,
      stdout_buffered = true,
      stderr_buffered = true,
    }
  )

  M.lines.job_id = {
    title = cmd,
    lines = { 'MakeModes: ', cmd, '' },
    winnr = winnr,
    bufnr = bufnr,
  }
  populate_quickfix(job_id)
  open_quickfix_and_return()
end

function M.New(name)
  local n = shellescape(name)

  vim.cmd('Mkdir(..n..)')
  vim.cmd('edit("'..n..'/'..n..'.scad")')
end

function M.TNew(name)
  local n = shellescape(name)

  vim.cmd('Mkdir(..n..)')
  vim.cmd('tabedit("'..n..'/'..n..'.scad")')
end

return M
