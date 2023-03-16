local builtin = require('telescope.builtin')

-- All File Finder
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})

-- Git File Finder 
vim.keymap.set('n', '<leader>gf', builtin.git_files, {})

-- Search Files that have the given input word (not working right now)
vim.keymap.set('n', '<leader>sf', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)
