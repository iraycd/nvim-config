return function(filename, line_number)
  line_number = tonumber(line_number) or 1
  -- Close the lazygit floating window
  vim.api.nvim_win_close(0, true)
  -- Open the file in the main buffer
  vim.cmd("edit +" .. line_number .. " " .. filename)
end
