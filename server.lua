logToDiscord = function(webhook,username,title,text)
    if not webhook then return end 

    local embed = {
        {
            ["color"] = 1234521,
            ["title"] = title,
            ["description"] = text,
            ["footer"] = {
                ["text"] = "© Hyz's Cove",
            },
        }
    }

    PerformHttpRequest(webhook,function(err, text, header) end, 'POST',json.encode({username = username, embeds = embed, avatar_url = "https://cdn-icons-png.flaticon.com/512/2125/2125009.png"}), {['Content-Type'] = 'application/json'})   
end

exports("logToDiscord",logToDiscord)

