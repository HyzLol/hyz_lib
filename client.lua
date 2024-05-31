setText = function(text)
    return SendNUIMessage({
        type = "textUi",
        toggle = true,
        text = text 
    })
end 

removeText = function()
    return SendNUIMessage({
        type = "textUi",
        toggle = false
    })
end 

local areas = {}
addArea = function(area,coords,distance,functions)
    if areas[area] then return end 

    areas[area] = {
        coords = coords,
        distance = distance,
        functions = functions
    }
end 

removeArea = function(area)
    if not areas[area] then return end 

    areas[area] = nil 
end 

doesAreaExist = function(area)
    return areas[area] ~= nil
end 

isNearArea = function()
    local isNear,areaName = false,""

    for k,v in pairs(areas) do 
        if #(GetEntityCoords(PlayerPedId()) - v.coords.xyz) > v.distance then goto skip end 

        isNear = true 
        areaName = k 
        break 
        ::skip::
    end 
    return isNear,areaName 
end 


CreateThread(function()
    local ticks = 500 
    local lastArea = nil 
    local inside = false 
    while 1 do 
        Wait(ticks)
        ticks = 500 

        local isNear,areaName = isNearArea()
        if not isNear then 
            if lastArea ~= nil then 
                if areas[lastArea] then 
                    areas[lastArea].functions.exit()
                    lastArea = nil 
                end 
            end 
            goto skip 
        end 

        if areaName == lastArea then goto skip end 
        
        lastArea = areaName
        areas[areaName].functions.enter()
        ::skip::
    end 
end)

exports("setText",setText)
exports("removeText",removeText)

exports("addArea",addArea)
exports("removeArea",removeArea)
exports("doesAreaExist",doesAreaExist)


notify = function(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    return DrawNotification(true, false)
end 

exports("notify",notify)

