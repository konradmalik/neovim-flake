{ pkgs }:
pkgs.writeTextDir "lua/konrad/cmp/copilot.lua" ''
  require("copilot").setup({
      suggestion = { enabled = false },
      panel = { enabled = false },
      copilot_node_command = '${pkgs.nodejs-slim}/bin/node',
  })
  local fmt = require('copilot_cmp.format')
  require("copilot_cmp").setup({
      formatters = {
          label = fmt.format_label_text,
          -- insert_text = fmt.format_insert_text,
          insert_text = fmt.remove_existing,
          preview = fmt.deindent,
      },
  })
''
