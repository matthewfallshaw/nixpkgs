local utils = require 'malo.utils'
local bufkeymaps = utils.bufkeymaps
local _ = require 'moses'

---@type fun(s:string)
local function with_crs(s)
  return string.gsub(s, '[\n\r]', '<CR>')
end

vim.opt_local.makeprg = "openscad %:S -o %:r:S.amf"

vim.api.nvim_exec(
  [[
command! -nargs=? -bang Make      lua require 'openscad'.Make(<f-args>)
command! -nargs=* -bang ReMake    lua require 'openscad'.ReMake(<f-args>)
command! -nargs=? -bang MakeModes lua require 'openscad'.MakeModes(<f-args>)
command! -nargs=1 -bang New       lua require 'openscad'.New(<f-args>)
command! -nargs=1 -bang TNew      lua require 'openscad'.TNew(<f-args>)
  ]]
  , false
)

bufkeymaps{ mode = 'i', opts = { 'noremap' }, maps = {
  { ';;b', with_crs [[
include <BOSL2/std.scad>
MODE="assy"; // [ "assy", "help" ]

]] },
  { ';;a', with_crs [[
include <BOSL/constants.scad>
use <BOSL/transforms.scad>
use <BOSL/shapes.scad>
use <BOSL/masks.scad>
use <BOSL/math.scad>


]] },
  { ';;n', with_crs [[
include <NopSCADlib/lib.scad>
// include <NopSCADlib/vitamins/stepper_motors.scad>
<ESC>cc
]] },
  { ';;s', [[
include <stdlib.scad>

$fn=0;
$fa=12;
$fs=2;

// $fn=16;
$fn=32;
$fn=64;
<ESC>cc
// BIGNUM=100;
<ESC>cc

MODE = "help"; // [ "assy", "help" ]
MODES = [ "assy", str("help") ];
if (MODE=="assy") assy();
else if(MODE=="help") echo(MODES=MODES);


]] },
} }

vim.bo.commentstring = '// %s '

vim.api.nvim_exec('autocmd BufRead,BufNewFile *.escad set filetype=openscad', false)
