local _ = require 'moses'

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

vim.bo.commentstring = '//%s'
