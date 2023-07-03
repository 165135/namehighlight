storage = core.get_mod_storage()

minetest.register_chatcommand("chatmode", {
        params = "<1/2/3/4>",
        description = "1 = no change, 2 = your name is highlighted, 3 = messages not containing your name are blocked, 4 = all messages blocked.",
        func = function(message)
            if message == "1" or message == "2" or message == "3" or message == "4" then
                storage:set_string("setting", message) -- 1 = no change, 2 = your name is highlighted, 3 = messages not containing your name are blocked, 4 = all messages blocked.
            else
                print(minetest.colorize("orange", "Please input a number 1-4 corresponding to mode. 1 = no change, 2 = your name is highlighted, 3 = messages not containing your name are blocked, 4 = all messages blocked."))
            end
        end,
    })

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

function block(message)
    if message:len()>0 then
        return true
    else
        return false
    end
end

minetest.register_on_receiving_chat_message(function(message)
    if minetest.localplayer then
        local player_name = minetest.localplayer:get_name()
        if storage:get_string("setting") == "2" then
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
                print(temp_msg)
                return block(message)
            end
        end
        if storage:get_string("setting") == "3" then
            if message:find(player_name) == nil then
                return block(message)
            end
        end
        if storage:get_string("setting") == "4" then
            return block(message)
        end
    end
end)
