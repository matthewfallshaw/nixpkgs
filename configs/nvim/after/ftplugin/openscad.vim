setlocal makeprg=openscad\ %:S\ -o\ %:r:S.amf

command! -nargs=0 -bang Make      lua require 'openscad'.Make()
command! -nargs=1 -bang ReMake    lua require 'openscad'.ReMake(<f-args>)
command! -nargs=0 -bang MakeModes lua require 'openscad'.MakeModes()
command! -nargs=1 -bang New       lua require 'openscad'.New(<f-args>)
command! -nargs=1 -bang TNew      lua require 'openscad'.TNew(<f-args>)

setlocal commentstring=//\ %s

inoremap <buffer> ;;b include <BOSL2/std.scad>
inoremap <buffer> ;;a include <BOSL/constants.scad><CR>use <BOSL/transforms.scad><CR>
  \use <BOSL/shapes.scad><CR>use <BOSL/masks.scad><CR>use <BOSL/math.scad>
inoremap <buffer> ;;n include <NopSCADlib/lib.scad><CR>
  \// include <NopSCADlib/vitamins/stepper_motors.scad><CR><ESC>cc
inoremap <buffer> ;;s include <stdlib.scad><CR><CR>$fn=0;<CR>$fa=12;<CR>$fs=2;<CR>// $fn=64;<CR><ESC>cc<CR>
