local storage = core.get_mod_storage()
local receivedFirstMessage = false


minetest.register_chatcommand("chatmode", {
    params = "<1/2/3/4/5>",
    description = "1 = default, 2 = highlight your name, 3 = allow messages from your team, 4 = allow messages with your name, 5 = block all messages.",
    func = function(message)
        storage:set_string("chatmodesetting", message)
    end,
})


local function CheckContains(message, search)
    if message:find(search) ~= nil then
        return true
    else
        return false
    end
end

--from prev version
-- there''s probably a better way to do the below two functions using the fact that onreceivingchatmessage has the name param of who sent the message
function find(str, search)
    local index = {1}
    local final = {}
    while str:find(search,index[#index]+search:len()) ~= nil do
        index[#index+1] = str:find(search,index[#index]+search:len())
    end
    for i = 1, #index do
        if i>1 and not (index[i] == nil) then
            final[#final+1] = index[i]
        end
    end
    return final
end
--from prev version'
local function HighlightName(message, player_name)
    local index = find(message, player_name)
    if index[1] ~= nil then
        if "<"..player_name..">" == "<"..message:sub(index[1],index[1]+player_name:len()) then
            table.remove(index,1)
        end
    end
    if index[1] ~= nil then
        temp_msg = message:sub(1,index[1]-1)
        for i = 1, #index do
            if index[i] ~= nil then
                temp_msg = temp_msg .. minetest.colorize("yellow",message:sub(index[i],index[i]+player_name:len()-1))
                last_int = i
                if index[i+1] ~= nil then
                     temp_msg = temp_msg .. message:sub(index[i]-1+player_name:len()+1,index[i+1]-1)
                end
            end
        end
        if index[last_int] ~= nil then
            temp_msg = temp_msg .. message:sub(index[last_int]-1+player_name:len()+1,-1)
        end
        return temp_msg
    end
    return message --something went wrong
end


local function ModifyMessage(message, setting, name)
    -- return altered message to be displayed, assume default message blocked
    local fromTeam = false
    local hasName = false

    if CheckContains(setting,"1") then --default behavior
        return message
    end
    if CheckContains(setting,"5") then --return empty string to be caught by check
        return ""
    end

    if CheckContains(setting,"3") then --if contains team
        fromTeam = CheckContains(message, "[TEAM]")
    end
    if CheckContains(setting,"4") then --if contains playername
        hasName = CheckContains(message, name)
    end
    if CheckContains(setting,"2") then
        if CheckContains(message, name) == true then
            hasName = true
            message = HighlightName(message, name)
        end
    end
    

    if fromTeam == true or hasName == true then
        return message
    else
        return ""
    end
end


minetest.register_on_receiving_chat_message(function(message, name)
    if receivedFirstMessage == true then
        if minetest.localplayer then
            local player_name = minetest.localplayer:get_name()
            setting = storage:get_string("chatmodesetting")
            local modifiedMsg = ModifyMessage(message, setting, player_name)
            if modifiedMsg ~= "" then print(modifiedMsg) end
            return true
        else
            print("Error: localplayer not found")
        end
    else 
        receivedFirstMessage = true
    end
end)
