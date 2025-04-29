-- -----------------------------------------------------------------------------
-- Copyright (c) Nikola Vukićević 2025.
-- -----------------------------------------------------------------------------
local M = { }
-- -----------------------------------------------------------------------------
local Config = {
	defer_timer_1 = 10,
	defer_timer_2 = 5,
	right_margin  = 5,
	max_width     = 54,
	quit_key      = "q",

	def_opts = {
		-- title     = 'Rename: ',
		relative  = 'cursor',
		row       = -3,
		col       = -1,
		width     = 0,
		height    = 1,
		focusable = true,
		style     = 'minimal',
		border    = 'rounded',
	},

	aux_buffer = nil,
}
-- -----------------------------------------------------------------------------
local function map_keys(win, on_confirm, prompt)
	-- vim.keymap.set({ "i", "n" }, "<CR>", "<CR><Esc>:close!<CR>:stopinsert<CR>", {
	-- 	silent = true, buffer = Config.aux_buffer })
	vim.keymap.set({ "n", "i", "v" }, "<cr>", function()
		local lines = vim.api.nvim_buf_get_lines(Config.aux_buffer, 0, 1, false)
		vim.cmd("stopinsert")
		vim.api.nvim_win_close(win, true)
		vim.cmd("normal l")
		on_confirm(string.sub(lines[1], #prompt + 1))
	end, { buffer = Config.aux_buffer })

	vim.keymap.set("n", Config.quit_key, function()
		on_confirm(nil)
		vim.cmd("stopinsert")
		vim.api.nvim_win_close(win, true)
	end, { buffer = Config.aux_buffer })
end
-- -----------------------------------------------------------------------------
local function create_aux_buffer(prompt, on_confirm)
	Config.aux_buffer = vim.api.nvim_create_buf(false, false)

	vim.bo[Config.aux_buffer].buftype   = 'prompt'
	vim.bo[Config.aux_buffer].bufhidden = 'wipe'

	local main_callback = function(input)
		vim.defer_fn(function()
			on_confirm(input)
			-- print(input)
		end, Config.defer_timer_1)
	end

	vim.fn.prompt_setprompt(Config.aux_buffer, prompt)
	vim.fn.prompt_setcallback(Config.aux_buffer, main_callback)
end
-- -----------------------------------------------------------------------------
M.input = function(opts, on_confirm, win_opts)
	local prompt       = (" " .. opts.prompt) or ""
	local default_text = opts.default or ""

	create_aux_buffer(prompt, on_confirm)

	win_opts = vim.tbl_deep_extend('force', Config.def_opts, win_opts)

	local proposed_width = #default_text + #prompt + Config.right_margin

    win_opts.width = proposed_width > Config.max_width and Config.max_width or proposed_width

	local win = vim.api.nvim_open_win(Config.aux_buffer, true, win_opts)
	vim.api.nvim_win_set_option(win, "winhighlight", "Search:None")

	map_keys(win, on_confirm, prompt)

	vim.cmd("startinsert")

	vim.defer_fn(function()
		vim.api.nvim_buf_set_text(Config.aux_buffer, 0, #prompt, 0, #prompt, {
			default_text
		})
		vim.cmd("startinsert!")
	end, Config.defer_timer_2)
end
-- -----------------------------------------------------------------------------
return M
-- -----------------------------------------------------------------------------
