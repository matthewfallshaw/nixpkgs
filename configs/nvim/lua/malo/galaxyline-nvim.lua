local s = require 'malo.utils'.symbols
local _ = require 'moses'

-- galaxyline.nvim
-- https://github.com/glepnir/galaxyline.nvim
vim.cmd 'packadd galaxyline.nvim'

local gl = require 'galaxyline'
local condition = require 'galaxyline.condition'

local file_path_provider = function(modified_icon, readonly_icon)
  local function file_readonly()
    if vim.bo.filetype == 'help' then
      return ''
    end
    local icon = readonly_icon or ''
    if vim.bo.readonly == true then
      return " " .. icon .. " "
    end
    return ''
  end

  local file = vim.fn.expand('%:.')
  if vim.fn.empty(file) == 1 then return '' end
  if string.len(file_readonly()) ~= 0 then
    return file .. file_readonly()
  end
  local icon = modified_icon or ''
  if vim.bo.modifiable then
    if vim.bo.modified then
      return file .. ' ' .. icon .. '  '
    end
  end
  return file .. ' '
end

gl.short_line_list = { 'floaterm' }

gl.section.left = {
  {
    Mode = {
      provider = function()
        local alias = {
          c = s.term,
          i = s.pencil,
          n = s.vim,
          t = s.term,
          v = s.ibar,
          V = s.ibar,
          [''] = s.ibar,
        }
        if(not alias[vim.fn.mode()]) then print('ERROR: galaxyline-nvim: missing vim.fn.mode() or symbol: ' .. vim.fn.mode()) end
        local ret = '  ' .. (alias[vim.fn.mode()] or vim.fn.mode() or '') .. ' '
        return ret
      end,
      highlight = 'StatusLineMode',
      separator = s.sepRoundRight .. ' ',
      separator_highlight = 'StatusLineModeSep',
    }
  },
  {
    FileIcon = {
      condition = condition.buffer_not_empty,
      provider = function ()
        vim.cmd('hi GalaxyFileIcon guifg='..require'galaxyline.provider_fileinfo'.get_file_icon_color()..' guibg='..require'lush_theme.malo'.StatusLine.bg.hex)
        return require'galaxyline.provider_fileinfo'.get_file_icon() .. ' '
      end,
      highlight = {},
    }
  },
  {
    FileName = {
      condition = condition.buffer_not_empty,
      -- provider = 'FileName',
      provider = file_path_provider,
      highlight = 'StatusLineFileName',
    }
  },
  {
    GitBranch = {
      condition = condition.buffer_not_empty,
      icon = '  ' .. s.gitBranch .. ' ',
      provider = 'GitBranch',
      highlight = 'StatusLineGitBranch',
    }
  },
  {
    DiffAdd = {
      condition = condition.hide_in_width,
      icon = ' ',
      provider = 'DiffAdd',
      highlight = 'StatusLineDiffAdd',
    }
  },
  {
    DiffModified = {
      condition = condition.hide_in_width,
      icon = ' ',
      provider = 'DiffModified',
      highlight = 'StatusLineDiffModified',
    }
  },
  {
    DiffRemove = {
      condition = condition.hide_in_width,
      icon = ' ',
      provider = 'DiffRemove',
      highlight = 'StatusLineDiffRemove',
    }
  },
}

gl.section.right = {
  {
    LspClient = {
      condition = condition.check_active_lsp,
      provider = { 'GetLspClient', _.constant(' ') },
      highlight = 'StatusLineLspClient',
    }
  },
  {
    DiagnosticError = {
      condition = condition.check_active_lsp,
      icon = ' ' .. s.errorShape .. ' ',
      provider = 'DiagnosticError',
      highlight = 'StatusLineDiagnosticError',
    }
  },
  {
    DiagnosticWarn = {
      condition = condition.check_active_lsp,
      icon = '  ' .. s.warningShape .. ' ',
      provider = 'DiagnosticWarn',
      highlight = 'StatusLineDiagnosticWarn',
    }
  },
  {
    DiagnosticInfo = {
      condition = condition.check_active_lsp,
      icon = '  ' .. s.infoShape .. ' ',
      provider = 'DiagnosticInfo',
      highlight = 'StatusLineDiagnosticInfo',
    }
  },
  {
    DiagnosticHint = {
      condition = condition.check_active_lsp,
      icon = '  ' .. s.questionShape .. ' ',
      provider = 'DiagnosticHint',
      highlight = 'StatusLineDiagnosticHint',
    }
  },
  {
    LineInfo = {
      separator = ' ' .. s.sepRoundLeft,
      separator_highlight = 'StatusLineModeSep',
      icon = ' ',
      provider = 'LineColumn',
      highlight = 'StatusLineLineInfo',
    }
  },
  {
    FilePosition = {
      separator = ' ',
      separator_highlight = 'StatusLineFilePositionSep',
      provider = { 'LinePercent', 'ScrollBar' },
      highlight = 'StatusLineFilePosition',
    }
  },
}

gl.section.short_line_left = {
  {
    ShortStatusLine = {
      -- provider = { _.constant('  '), 'FileIcon', _.constant(' '), 'FileName' },
      provider = { _.constant('  '), 'FileIcon', _.constant(' '), file_path_provider },
      highlight = 'StatusLineSortStatusLine',
    }
  },
}
