A simple pluign for starting an input window when `vim.ui.input` is called.

![Apr28::182842](https://github.com/user-attachments/assets/d69daced-5135-4260-8d98-d68c085ba252)

## Installation

Install the plugin with your favourite plugin manager and then place the following in your config:

```lua
vim.ui.input = function(opts, on_confirm)
	require('util-input-window').input(opts, on_confirm, {
		-- border = "single",
		-- row    = -4
	})
end
```
(You can experiment with some windows settings if you don't like the default ones.)
