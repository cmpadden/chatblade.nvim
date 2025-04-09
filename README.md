<div align="center">
    <img alt="chatblade.nvim banner" src=".github/chatblade.nvim.png">
    <br>
    <p>
      <i>Leverage <a href="https://github.com/simonw/llm"><code>llm</code></a>, a CLI utility and Python library for interacting with Large Language Models, from your Neovim editor.</i>
    </p>
</div>

## Setup

### Prerequisites

1. Install the [llm](https://github.com/simonw/llm) CLI
2. Set the API key for the LLM provider of your choice

### Installation & Configuration

```lua
-- lazy.nvim
{
  "cmpadden/llm.nvim",
  keys = {
    { "<leader>x", ":LLM<cr>", mode = "v" },
  },
  cmd = {
    "LLM",
  },
  opts = {
    model        = "claude-3.5-haiku",  -- TEXT            Model to use
    system       = nil,                 -- TEXT            System prompt to use
    continue     = nil,                 --                 Continue the most recent conversation.
    conversation = nil,                 -- TEXT            Continue the conversation with the given ID.
    template     = nil,                 -- TEXT            Template to use
    param        = nil,                 -- <TEXT TEXT>...  Parameters for template
    option       = nil,                 -- <TEXT TEXT>...  key/value options for the model
  }
}
```

## Usage

### Bindings

Select text, and send it to LLM with your key binding of choice. For the example
of `<leader>x`, you can visually select a line or paragraph, send it to LLM, and
the response will be inserted below your cursor.

```
vip<leader>x
```

### Commands

The following user commands have been made available. This allows you to handle sessions
so that you can send snippets to LLM, and ask follow-up questions with persisted
context.

| Command                | Parameters | Description                                                      |
| ---------------------- | --------- | ----------------------------------------------------------------- |
| LLM                    | `string?` | Prompt LLM with visual selection and/or an additional query |

## Motivation

If all you wish to do is to pass text to `llm` from your Neovim session, then you may be better off defining a key binding like so:

```lua
vim.keymap.set("v", "<leader>x", ':!LLM -e -r<CR>')
```

However, _llm.nvim_ intends to offer some quality of life improvements over such a bindings.

<div align="center">
    <img src=".github/fire.svg" height="25" width="25">
</div>
