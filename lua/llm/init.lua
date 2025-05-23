local M = {
    active_session = nil,
}

-- Lua 5.1 backwards compatibility
-- https://github.com/hrsh7th/nvim-cmp/issues/1017#issuecomment-1141440976
unpack = unpack or table.unpack

----------------------------------------------------------------------------------------
--                                       Utils                                        --
----------------------------------------------------------------------------------------

-- Gets text in current buffer given selection indexes.
--
-- Note: column based selection was removed, see Git history for this functionality.
--
-- @param srow line number of selection start
-- @param erow line number of selection end
local function get_lines(srow, erow)
    local lines = vim.api.nvim_buf_get_lines(0, srow - 1, erow, false)
    if #lines == 0 then
        return nil
    end
    return lines
end

-- Puts array of lines below specified `line_number`.
-- @param line_number line to place text below
-- @param lines array of strings to place into buffer
local function put_lines_below_line(line_number, lines)
    vim.api.nvim_buf_set_lines(0, line_number, line_number, true, lines)
end

----------------------------------------------------------------------------------------
--                                     Entrypoint                                     --
----------------------------------------------------------------------------------------

-- stylua: ignore
M.default_config = {
    model        = "claude-3.5-haiku",  -- -m, --model TEXT             Model to use
    system       = nil,                 -- -s, --system TEXT
    continue     = nil,                 -- -c, --continue               Continue the most recent conversation.
    conversation = nil,                 -- --cid, --conversation TEXT   Continue the conversation with the given ID.
    template     = nil,                 -- -t, --template TEXT          Template to use
    param        = nil,                 -- -p, --param <TEXT TEXT>...   Parameters for template
    option       = nil,                 -- -o, --option <TEXT TEXT>...  key/value options for the model
}

-- function M.start_session(session_name)
--     M.active_session = session_name
--     print(string.format("Activated session %s!", session_name))
-- end
--
-- function M.stop_session(session_name)
--     M.active_session = nil
--     print(string.format("Deactivated session %s!", session_name))
-- end
--
-- function M.delete_session(session_name)
--     M.active_session = nil
--     local stdout =
--         vim.fn.system({ "chatblade", "--session-delete", "--session", session_name })
--     print(stdout)
-- end

M.setup = function(opts)
    opts = opts or {}

    -- merge user options w/ default configuration, overwriting defaults
    M.config = vim.tbl_deep_extend("force", M.default_config, opts)

    -- Use `input.range` to determine if a visual selection is present.
    --
    -- When performing a visual selection, use the line number of the end of the
    -- selection (`input.line2`) as the `response_line_number` so that the response
    -- will be placed below the selected text.
    vim.api.nvim_create_user_command("LLM", function(input)
        if input.range == 0 then
            -- No visual selection
            M.run(input.args, nil, input.line2)
        else
            -- Include visual selection as supplement text
            local visual_selection = get_lines(input.line1, input.line2)
            M.run(input.args, visual_selection, input.line2)
        end
    end, { nargs = "*", range = true })

    -- vim.api.nvim_create_user_command("ChatbladeSessionStart", function(input)
    --     M.start_session(input["args"])
    -- end, { nargs = 1, desc = "Activate Chatblade Session" })

    -- vim.api.nvim_create_user_command("ChatbladeSessionStop", function()
    --     M.stop_session()
    -- end, { nargs = 0, desc = "Deactivate Chatblade Session" })

    -- vim.api.nvim_create_user_command("ChatbladeSessionDelete", function(input)
    --     M.delete_session(input["args"])
    -- end, { nargs = 1, desc = "Deactivate Chatblade Session" })
end

function M.run(optional_query, optional_visual_selection, response_line_number)
    if optional_query == nil and optional_visual_selection == nil then
        print("Either a query or visual selection must be provided...")
        return
    end

    local query = {}

    if M.config.include_filetype then
        table.insert(query, "current filetype = " .. vim.bo.filetype)
    end

    if optional_query then
        table.insert(query, optional_query)
    end

    if optional_visual_selection then
        for _, v in ipairs(optional_visual_selection) do
            table.insert(query, v)
        end
    end

    -- TODO(feature) - make `uvx` and `--with` configureable
    local command = { "uvx", "--with", "llm-anthropic", "llm", "--no-stream" }

    if M.config.model then
        table.insert(command, "--model")
        table.insert(command, tostring(M.config.model))
    end

    if M.config.system then
        table.insert(command, "--system")
        table.insert(command, tostring(M.config.system))
    end

    if M.config.continue then
        table.insert(command, "--continue")
    end

    if M.config.conversation then
        table.insert(command, "--conversation")
        table.insert(command, tostring(M.config.conversation))
    end

    if M.config.template then
        table.insert(command, "--template")
        table.insert(command, tostring(M.config.template))
    end

    if M.config.param then
        table.insert(command, "--param")
        table.insert(command, tostring(M.config.param))
    end

    if M.config.option then
        table.insert(command, "--option")
        table.insert(command, tostring(M.config.option))
    end

    print("Awaiting response...")

    local stdout = vim.fn.systemlist(command, query)

    if M.config.insert_as_comment then
        local comment_string = vim.api.nvim_buf_get_option(0, "commentstring")
        for i, _ in ipairs(stdout) do
            stdout[i] = comment_string:gsub("%%s", stdout[i])        end
    end

    put_lines_below_line(response_line_number, stdout)
end

return M
