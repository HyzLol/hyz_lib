local CT = CreateThread

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


CT(function()
    local ticks = 500 
    local lastArea = nil 
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

local blips = {}

addBlip = function(coords,id,color,scale,name)
    if not coords then coords = vec3(0,0,0) end 
    if not id then id = 0 end 
    if not color then color = 0 end 
    if not scale then scale = 1.0 end 
    if not name then name = "Undefined Blip" end 

    coords = vec3(coords.x, coords.y,coords.z + 0.01)

    local blip = AddBlipForCoord(coords)
    
    SetBlipSprite(blip,id)
    SetBlipColour(blip,color)
    SetBlipAsShortRange(blip,true)
    SetBlipRoute(blip,false)
    SetBlipScale(blip,scale)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blip)
    blips[blip] = true 
    return blip 
end 

removeBlip = function(blip)
    if not blips[blip] then return end 

    RemoveBlip(blip)
    blips[blip] = nil 
end

exports("addBlip",addBlip)
exports("removeBlip",removeBlip)


local npcs = {}

addNPC = function(coords,hash,name,anim)
    if not coords then coords = vec3(0,0,0) end 
    if not hash then hash = "mp_m_freemode_01" end 
    if not name then name = "" end 
    if not anim then anim = {"missbigscore2aig_3", "guard_idle_a"} end 

    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(0)
    end

    local npc = CreatePed(4, hash, coords.x, coords.y, coords.z - 1.0, coords.w, false, true)

    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    TaskSetBlockingOfNonTemporaryEvents(npc, true)
    SetPedFleeAttributes(npc, 0, false)
    SetPedCombatAttributes(npc, 46, true) 
    SetPedCanRagdoll(npc, false)
    FreezeEntityPosition(npc, true)

    RequestAnimDict(anim[1])
    while not HasAnimDictLoaded(anim[1]) do
        Wait(0)
    end

    TaskPlayAnim(npc, anim[1], anim[2], 8.0, -8.0, -1, 1, 0, false, false, false)

    npcs[npc] = name 
    return npc 
end 

removeNPC = function (npc)
    if not DoesEntityExist(npc) then return end 
    if not npcs[npc] then return end 

    DeleteEntity(npc)    
    npcs[npc] = nil
end

local DrawText3D = function(coords,text)
    local x,y,z in coords 

    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if not onScreen then return end 

    SetTextScale(0.5, 0.5)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215) 
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
end

local isNearNPC = function()
    local id = -1 
    for k,v in pairs(npcs) do 
        if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(k)) < 3.0 then 
            id = k 
            break 
        end 
    end 
    return id
end 

CT(function()
    local ticks = 512 
    while 1 do 
        Wait(ticks)
        ticks = 512 
        local npc = isNearNPC() 
        if npc == -1 then goto skip end 

        ticks = 1 
        local name = npcs[npc] 
        local npcCoords = GetEntityCoords(npc) 
        npcCoords = vec3(npcCoords.x,npcCoords.y,npcCoords.z + 1.0) 

        DrawText3D(npcCoords, name) 
        ::skip:: 
    end 
end)


exports("addNPC",addNPC)
exports("removeNPC",removeNPC)

AddEventHandler("onResourceStop",function(name)
    if name ~= "hyz_lib" then return end 
        
    -- BLIPS 
    for k in pairs(blips) do 
        removeBlip(k)
    end 

    -- NPCS
    for k in pairs(npcs) do 
        removeNPC(k) 
    end 
end)