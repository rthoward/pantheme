local ok, err = pcall(function()
    local plugin = vim.env.PLUGIN or error("PLUGIN environment variable must be set")
    local colorscheme = vim.env.COLORSCHEME or error("COLORSCHEME environment variable must be set")
    local appearance = vim.env.APPEARANCE or error("APPEARANCE environment variable must be set")

    -- Create a data directory in ./runtime
    local script_dir = vim.fn.fnamemodify(vim.fn.expand("<sfile>"), ":p:h")
    local data_dir = script_dir .. "/runtime"
    vim.fn.mkdir(data_dir, "p")

    local lazypath = data_dir .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable",
            lazypath,
        })
    end
    vim.opt.rtp:prepend(lazypath)

    require("lazy").setup({ plugin, dependencies = "rktjmp/lush.nvim" })
    require("lazy").sync()

    vim.cmd.colorscheme(colorscheme)
    vim.o.background = appearance

    for i = 0, 15 do
        local color = vim.g['terminal_color_' .. i]
        print(string.format('terminal_color_%d=%s', i, color))
      end

    vim.cmd("highlight")
end)

if ok then
    vim.cmd("qa!")
else
    print("ERROR: " .. tostring(err))
    vim.cmd("cq!")
end
