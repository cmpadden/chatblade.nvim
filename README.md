<div align="center">
    <img alt="chatblade.nvim banner" src=".github/chatblade.nvim.png">
    <br>
    <p>
        <i>Leverage <a href="https://github.com/npiv/chatblade">Chatblade</a>, the Swiss Army Knife for ChatGPT, from your Neovim editor.</i>
    </p>
</div>


## Usage

```lua
chatblade = require('chatblade')

vim.api.nvim_create_user_command("Chatblade", _chatblade.run, { range = true })

vim.keymap.set("v", "<leader>x", ":Chatblade<CR>", { silent = true })

vim.api.nvim_create_user_command("ChatbladeStartSession", function(input)
    _chatblade.start_session(input['args'])
end, { nargs = 1, desc = "Activate Chatblade Session" })

vim.api.nvim_create_user_command("ChatbladeStopSession", function()
    _chatblade.stop_session()
end, { nargs = 0, desc = "Deactivate Chatblade Session" })

vim.api.nvim_create_user_command("ChatbladeDeleteSession", function(input)
    _chatblade.delete_session(input['args'])
end, { nargs = 1, desc = "Deactivate Chatblade Session" })
```

## Motivation

If all you seek is to pass text to `chatblade` from your Neovim session, then there is no need to introduce yet another plugin. Simply add a binding like so:

```lua
vim.keymap.set("v", "<leader>x", ':!chatblade -e -r<CR>')
```

However, _chatblade.nvim_ offers some quality of life improvements over such a bindings.

- Editor based sessions
- Flexible configuration and prompt management
- **[todo]** Metadata and file information injection 
