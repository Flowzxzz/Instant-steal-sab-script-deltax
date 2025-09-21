-- bu5àlddscrípts - DeltaX Enhanced with Real Teleportation & Pathfinding
-- Anti-Cheat Protected Position Saver & Teleporter

-- Show loading message immediately
BeginTextCommandThefeedPost("STRING")
AddTextComponentSubstringPlayerName("🔄 bu5àlddscrípts - Loading Advanced Teleport System...")
EndTextCommandThefeedPostTicker(false, true)

Citizen.Wait(1000)

-- Initialize script variables
local Positions = {}
local currentSlot = 1
local uiVisible = true
local lastTouchTime = 0
local toggleCooldown = 500
local antiCheatEnabled = false
local pathfindingEnabled = false
local screenWidth, screenHeight = GetScreenResolution()
local teleportMode = "instant" -- "instant", "gradual", "pathfind"

-- Show script loaded notification
BeginTextCommandThefeedPost("STRING")
AddTextComponentSubstringPlayerName("✅ bu5àlddscrípts loaded with Real Teleportation!")
EndTextCommandThefeedPostTicker(false, true)

-- Anti-Cheat Bypass with enhanced protection
function EnableAntiCheatBypass()
    local success, result = pcall(function()
        -- Multiple anti-cheat bypass techniques
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" then
                local fn = rawget(v, "observeTag")
                if type(fn) == "function" then
                    hookfunction(fn, function()
                        return {
                            Disconnect = function() end,
                            disconnect = function() end
                        }
                    end)
                end
                
                -- Additional anti-cheat hooks
                local checkFn = rawget(v, "checkPlayer")
                if type(checkFn) == "function" then
                    hookfunction(checkFn, function() return true end)
                end
            end
        end
        
        -- Disable common anti-cheat checks
        if _G.AC_Check then
            _G.AC_Check = function() return true end
        end
        
        return true
    end)
    
    antiCheatEnabled = success
    return success
end

-- Enhanced teleportation system with multiple modes
function RealTeleportToPosition(slot)
    if not Positions[slot] then
        ShowNotification("No position saved in slot " .. slot)
        return false
    end
    
    if not antiCheatEnabled then
        ShowNotification("Enable Anti-Cheat First!")
        return false
    end
    
    local pos = Positions[slot]
    local ped = PlayerPedId()
    
    -- Preload collision at destination
    RequestCollisionAtCoord(pos.x, pos.y, pos.z)
    NewLoadSceneStart(pos.x, pos.y, pos.z, pos.x, pos.y, pos.z, 50.0, 0)
    
    -- Choose teleport method based on mode
    if teleportMode == "instant" then
        -- Instant teleport (most risky but fastest)
        SetEntityCoordsNoOffset(ped, pos.x, pos.y, pos.z, false, false, false)
        SetEntityHeading(ped, pos.heading)
        
    elseif teleportMode == "gradual" then
        -- Gradual teleport (safer)
        local startPos = GetEntityCoords(ped)
        local steps = 8
        
        for i = 1, steps do
            local progress = i / steps
            local currentX = startPos.x + (pos.x - startPos.x) * progress
            local currentY = startPos.y + (pos.y - startPos.y) * progress
            local currentZ = startPos.z + (pos.z - startPos.z) * progress
            
            SetEntityCoordsNoOffset(ped, currentX, currentY, currentZ, false, false, false)
            Citizen.Wait(30)
        end
        
        SetEntityHeading(ped, pos.heading)
        
    elseif teleportMode == "pathfind" and pathfindingEnabled then
        -- Pathfinding-based teleport (safest)
        StartPathfindTeleport(ped, pos)
    end
    
    -- Ensure proper collision loading
    local timeout = 0
    while not HasCollisionLoadedAroundEntity(ped) and timeout < 50 do
        Citizen.Wait(10)
        timeout = timeout + 1
    end
    
    ShowNotification(string.format("Teleported to slot %d (%s)", slot, teleportMode))
    return true
end

-- Basic pathfinding implementation for teleportation
function StartPathfindTeleport(ped, targetPos)
    local currentPos = GetEntityCoords(ped)
    local maxAttempts = 3
    
    for attempt = 1, maxAttempts do
        -- Calculate intermediate points for pathfinding
        local intermediatePoints = CalculatePathPoints(currentPos, targetPos)
        
        if intermediatePoints and #intermediatePoints > 0 then
            -- Follow the calculated path
            for i, point in ipairs(intermediatePoints) do
                SetEntityCoordsNoOffset(ped, point.x, point.y, point.z, false, false, false)
                Citizen.Wait(15) -- Short delay between points
            end
            break
        else
            -- Fallback to direct teleport if pathfinding fails
            if attempt == maxAttempts then
                SetEntityCoordsNoOffset(ped, targetPos.x, targetPos.y, targetPos.z, false, false, false)
            end
            Citizen.Wait(100)
        end
    end
    
    SetEntityHeading(ped, targetPos.heading or GetEntityHeading(ped))
end

-- Calculate path points for teleportation (simplified pathfinding)
function CalculatePathPoints(startPos, endPos)
    local points = {}
    local steps = 10
    
    -- Simple linear interpolation (can be enhanced with proper pathfinding)
    for i = 1, steps do
        local progress = i / steps
        local point = {
            x = startPos.x + (endPos.x - startPos.x) * progress,
            y = startPos.y + (endPos.y - startPos.y) * progress,
            z = startPos.z + (endPos.z - startPos.z) * progress
        }
        
        -- Add slight height variation to simulate pathfinding
        if i < steps then
            point.z = point.z + math.sin(progress * math.pi) * 2.0
        end
        
        table.insert(points, point)
    end
    
    return points
end

-- Save position with enhanced safety
function SavePosition(slot)
    if not antiCheatEnabled then
        ShowNotification("Enable Anti-Cheat First!")
        return false
    end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    Positions[slot] = {
        x = coords.x,
        y = coords.y,
        z = coords.z,
        heading = heading,
        timestamp = os.date("%H:%M:%S")
    }
    
    ShowNotification(string.format("Position saved to slot %d", slot))
    return true
end

-- Check if touch is within a rectangle
function IsTouchInBounds(touchX, touchY, rectX, rectY, width, height)
    return touchX >= rectX - width/2 and 
           touchX <= rectX + width/2 and 
           touchY >= rectY - height/2 and 
           touchY <= rectY + height/2
end

-- Create enhanced mobile UI with teleport mode selection
function DrawEnhancedUI()
    if not uiVisible then return end
    
    local uiWidth = screenWidth * 0.8
    local uiHeight = screenHeight * 0.3
    local uiX = (screenWidth - uiWidth) / 2
    local uiY = screenHeight - uiHeight - 20
    
    -- Background
    DrawRect(uiX, uiY, uiWidth, uiHeight, 0, 0, 0, 150)
    
    -- Title with watermark
    SetTextFont(4)
    SetTextScale(0.5, 0.5)
    SetTextColour(255, 255, 255, 255)
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName("bu5àlddscrípts - Real Teleport")
    EndTextCommandDisplayText(uiX + uiWidth/2, uiY + 10)
    
    -- Status info
    SetTextFont(4)
    SetTextScale(0.3, 0.3)
    SetTextColour(255, 255, 255, 200)
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName("Mode: " .. teleportMode:upper() .. " | Anti-Cheat: " .. (antiCheatEnabled and "ON" or "OFF"))
    EndTextCommandDisplayText(uiX + uiWidth/2, uiY + 30)
    
    -- Slot buttons
    local buttonWidth = uiWidth / 5
    for i = 1, 5 do
        local btnX = uiX + (i-1) * buttonWidth + buttonWidth/2
        local btnY = uiY + uiHeight/3
        
        -- Button background
        if currentSlot == i then
            DrawRect(btnX, btnY, buttonWidth - 10, 40, 50, 150, 50, 200)
        else
            DrawRect(btnX, btnY, buttonWidth - 10, 40, 50, 50, 50, 200)
        end
        
        -- Button text
        SetTextFont(4)
        SetTextScale(0.4, 0.4)
        SetTextColour(255, 255, 255, 255)
        SetTextCentre(true)
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(tostring(i))
        EndTextCommandDisplayText(btnX, btnY - 10)
        
        -- Saved indicator
        if Positions[i] then
            SetTextFont(4)
            SetTextScale(0.3, 0.3)
            SetTextColour(200, 200, 200, 255)
            SetTextCentre(true)
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName("SAVED")
            EndTextCommandDisplayText(btnX, btnY + 10)
        end
    end
    
    -- Action buttons
    local saveBtnX = uiX + uiWidth * 0.2
    local teleportBtnX = uiX + uiWidth * 0.8
    local antiCheatBtnX = uiX + uiWidth * 0.5
    local modeBtnX = uiX + uiWidth * 0.35
    local pathfindBtnX = uiX + uiWidth * 0.65
    local btnY = uiY + uiHeight * 0.7
    
    -- Save button
    DrawRect(saveBtnX, btnY, uiWidth * 0.25, 30, 0, 100, 200, 200)
    SetTextFont(4)
    SetTextScale(0.4, 0.4)
    SetTextColour(255, 255, 255, 255)
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName("SAVE")
    EndTextCommandDisplayText(saveBtnX, btnY - 8)
    
    -- Teleport button
    DrawRect(teleportBtnX, btnY, uiWidth * 0.25, 30, 200, 100, 0, 200)
    SetTextFont(4)
    SetTextScale(0.4, 0.4)
    SetTextColour(255, 255, 255, 255)
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName("TELEPORT")
    EndTextCommandDisplayText(teleportBtnX, btnY - 8)
    
    -- Anti-Cheat toggle button
    DrawRect(antiCheatBtnX, btnY, uiWidth * 0.2, 30, antiCheatEnabled and 0 or 150, antiCheatEnabled and 150 or 0, 0, 200)
    SetTextFont(4)
    SetTextScale(0.3, 0.3)
    SetTextColour(255, 255, 255, 255)
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName("ANTI-CHEAT")
    EndTextCommandDisplayText(antiCheatBtnX, btnY - 8)
    
    -- Teleport mode button
    DrawRect(modeBtnX, btnY, uiWidth * 0.2, 30, 150, 0, 150, 200)
    SetTextFont(4)
    SetTextScale(0.3, 0.3)
    SetTextColour(255, 255, 255, 255)
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName("MODE: " .. teleportMode:sub(1, 1):upper())
    EndTextCommandDisplayText(modeBtnX, btnY - 8)
    
    -- Pathfind toggle button
    DrawRect(pathfindBtnX, btnY, uiWidth * 0.2, 30, pathfindingEnabled and 0 or 150, 150, pathfindingEnabled and 150 : 0, 200)
    SetTextFont(4)
    SetTextScale(0.3, 0.3)
    SetTextColour(255, 255, 255, 255)
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName("PATHFIND")
    EndTextCommandDisplayText(pathfindBtnX, btnY - 8)
end

-- Handle touch input
function HandleTouchInput()
    if not IsControlJustReleased(0, 237) then return end
    
    local touchX, touchY = GetControlNormal(0, 239), GetControlNormal(0, 240)
    touchX = touchX * screenWidth
    touchY = touchY * screenHeight
    
    local uiWidth = screenWidth * 0.8
    local uiHeight = screenHeight * 0.3
    local uiX = (screenWidth - uiWidth) / 2
    local uiY = screenHeight - uiHeight - 20
    
    -- Toggle UI with center screen tap
    if IsTouchInBounds(touchX, touchY, screenWidth/2, screenHeight/2, 100, 100) then
        if GetGameTimer() - lastTouchTime > toggleCooldown then
            uiVisible = not uiVisible
            lastTouchTime = GetGameTimer()
        end
        return
    end
    
    if not uiVisible then return end
    
    -- Check slot buttons
    local buttonWidth = uiWidth / 5
    for i = 1, 5 do
        local btnX = uiX + (i-1) * buttonWidth + buttonWidth/2
        local btnY = uiY + uiHeight/3
        
        if IsTouchInBounds(touchX, touchY, btnX, btnY, buttonWidth - 10, 40) then
            currentSlot = i
            return
        end
    end
    
    -- Check action buttons
    local saveBtnX = uiX + uiWidth * 0.2
    local teleportBtnX = uiX + uiWidth * 0.8
    local antiCheatBtnX = uiX + uiWidth * 0.5
    local modeBtnX = uiX + uiWidth * 0.35
    local pathfindBtnX = uiX + uiWidth * 0.65
    local btnY = uiY + uiHeight * 0.7
    
    -- Save button
    if IsTouchInBounds(touchX, touchY, saveBtnX, btnY, uiWidth * 0.25, 30) then
        SavePosition(currentSlot)
        return
    end
    
    -- Teleport button
    if IsTouchInBounds(touchX, touchY, teleportBtnX, btnY, uiWidth * 0.25, 30) then
        RealTeleportToPosition(currentSlot)
        return
    end
    
    -- Anti-Cheat button
    if IsTouchInBounds(touchX, touchY, antiCheatBtnX, btnY, uiWidth * 0.2, 30) then
        if antiCheatEnabled then
            antiCheatEnabled = false
            ShowNotification("Anti-Cheat Disabled")
        else
            if EnableAntiCheatBypass() then
                ShowNotification("Anti-Cheat Enabled")
            else
                ShowNotification("Anti-Cheat Failed to Enable")
            end
        end
        return
    end
    
    -- Mode button
    if IsTouchInBounds(touchX, touchY, modeBtnX, btnY, uiWidth * 0.2, 30) then
        -- Cycle through teleport modes
        if teleportMode == "instant" then
            teleportMode = "gradual"
        elseif teleportMode == "gradual" then
            teleportMode = "pathfind"
        else
            teleportMode = "instant"
        end
        ShowNotification("Teleport Mode: " .. teleportMode:upper())
        return
    end
    
    -- Pathfind button
    if IsTouchInBounds(touchX, touchY, pathfindBtnX, btnY, uiWidth * 0.2, 30) then
        pathfindingEnabled = not pathfindingEnabled
        ShowNotification("Pathfinding " .. (pathfindingEnabled and "Enabled" : "Disabled"))
        return
    end
end

-- Main loop
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        HandleTouchInput()
        DrawEnhancedUI()
    end
end)

-- Show usage instructions
Citizen.CreateThread(function()
    Citizen.Wait(3000)
    ShowNotification("Tap center screen to toggle UI")
    ShowNotification("Enable Anti-Cheat for safety first!")
    ShowNotification("Switch modes for different teleport types")
end)
