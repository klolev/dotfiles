require("config.lazy")

require('neotest').setup {
    adapters = {
      require('rustaceanvim.neotest')
    }
}

vim.cmd('source ~/.vimrc')

if vim.g.neovide then
    vim.g.neovide_window_blurred = true
    vim.g.neovide_floating_blur_amount_x = 4.0
    vim.g.neovide_floating_blur_amount_y = 4.0
    vim.g.neovide_opacity = 0.8
    vim.g.neovide_theme = 'auto'
    vim.g.neovide_cursor_vfx_mode = 'pixiedust'
    vim.opt.clipboard = "unnamedplus"
    vim.cmd 'colorscheme tokyonight-night'
end
