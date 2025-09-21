-- bu5àlddscrípts - Steal A Brainrot with Movable T-Button UI
-- Anti-Cheat Protected Position Saver & Teleporter

-- Show loading message immediately
BeginTextCommandThefeedPost("STRING")
AddTextComponentSubstringPlayerName("🔄 bu5àlddscrípts - Loading...")
EndTextCommandThefeedPostTicker(false, true)

Citizen.Wait(1000)

-- Initialize script variables
local Positions = {}
local currentSlot = 1
local uiVisible = false
local mainUIvisible = false
local lastTouchTime = 0
local toggleCooldown = 500
local antiCheatEnabled = false
local screenWidth, screenHeight = GetScreenResolution()

-- Movable T-button settings
local tButtonX = screenWidth * 0.1  -- Default position (10% from left)
local tButtonY = screenHeight * 0.2 -- Default position (20% from top)
local tButtonSize = 40
local isDragging = false

-- Show script loaded notification
BeginTextCommandThefeedPost("STRING")
AddTextComponentSubstringPlayerName("✅ bu5àlddscrípts loaded! Tap T-button to open UI")
EndTextCommandThefeedPostTicker(false, true)

-- Anti-Cheat Bypass
function EnableAntiCheatBypass()
    local success, result = pcall(function()
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
                    break
                end
            end
        end
        return true
    end)
    
    antiCheatEnabled = success
    return success
end

-- Save position with safety checks
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

-- Teleport with safety checks
function TeleportToPosition(slot)
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
    
    -- Preload collision
    RequestCollisionAtCoord(pos.x, pos.y, pos.z)
    
    -- Gradual teleportation to avoid detection
    local startPos = GetEntityCoords(ped)
    local steps = 5
    
    for i = 1, steps do
        local progress = i / steps
        local currentX = startPos.x + (pos.x - startPos.x) * progress
        local currentY = startPos.y + (pos.y - startPos.y) * progress
        local currentZ = startPos.z + (pos.z - startPos.z) * progress
        
        SetEntityCoordsNoOffset(ped, currentX, currentY, currentZ, false, false, false)
        Citizen.Wait(50)
    end
    
    SetEntityHeading(ped, pos.heading)
    
    ShowNotification(string.format("Teleported to slot %d", slot))
    return true
end

-- Check if touch is within a rectangle
function IsTouchInBounds(touchX, touchY, rectX, rectY, width, height)
    return touchX >= rectX - width/2 and 
           touchX <= rectX + width/2 and 
           touchY >= rectY - height/2 and 
           touchY <= rectY + height/2
end

-- Draw movable T-button
function DrawTButton()
    -- Draw T-button background
    DrawRect(tButtonX, tButtonY, tButtonSize, tButtonSize, 50, 150, 50, 200)
    
    -- Draw T symbol
    SetTextFont(4)
    SetTextScale(0.8, 0.8)
    SetTextColour(255, 255, 255, 255)
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName("T")
    EndTextCommandDisplayText(tButtonX, tButtonY - 12)
    
    -- Draw small indicator when UI is open
    if mainUIvisible then
        DrawRect(tButtonX, tButtonY - tButtonSize/2 - 5, 10, 5, 0, 255, 0, 200)
    end
end

-- Draw main UI
function DrawMainUI()
    if not mainUIvisible then return end
    
    local uiWidth = screenWidth * 0.8
    local uiHeight = screenHeight * 0.25
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
    AddTextComponentSubstringPlayerName("bu5àlddscrípts - Slot " .. currentSlot)
    EndTextCommandDisplayText(uiX + uiWidth/2, uiY + 10)
    
    -- Anti-cheat status
    SetTextFont(4)
    SetTextScale(0.3, 0.3)
    SetTextColour(antiCheatEnabled and 0 or 255, antiCheatEnabled and 255 or 0, 0, 255)
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName("Anti-Cheat: " .. (antiCheatEnabled and "ON" or "OFF"))
    EndTextCommandDisplayText(uiX + uiWidth/2, uiY + 30)
    
    -- Slot buttons
    local buttonWidth = uiWidth / 5
    for i = 1, 5 do
        local btnX = uiX + (i-1) * buttonWidth + buttonWidth/2
        local btnY = uiY + uiHeight/2
        
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
    local btnY = uiY + uiHeight * 0.8
    
    -- Save button
    DrawRect(saveBtnX, btnY, uiWidth * 0.3, 30, 0, 100, 200, 200)
    SetTextFont(4)
    SetTextScale(0.4, 0.4)
    SetTextColour(255, 255, 255, 255)
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName("SAVE")
    EndTextCommandDisplayText(saveBtnX, btnY - 8)
    
    -- Teleport button
    DrawRect(teleportBtnX, btnY, uiWidth * 0.3, 30, 200, 100, 0, 200)
    SetTextFont(4)
    SetTextScale(0.4, 0.4)
    SetTextColour(255, 255, 255, 255)
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName("TELEPORT")
    EndTextCommandDisplayText(teleportBtnX, btnY - 8)
    
    -- Anti-cheat toggle button
    DrawRect(antiCheatBtnX, btnY, uiWidth * 0.3, 30, antiCheatEnabled and 0 or 150, antiCheatEnabled and 150 or 0, 0, 200)
    SetTextFont(4)
    SetTextScale(0.4, 0.4)
    SetTextColour(255, 255, 255, 255)
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(antiCheatEnabled and "ANTI-CHEAT ON" or "ANTI-CHEAT OFF")
    EndTextCommandDisplayText(antiCheatBtnX, btnY - 8)
end

-- Handle touch input
function HandleTouchInput()
    if not IsControlJustReleased(0, 237) then return end
    
    local touchX, touchY = GetControlNormal(0, 239), GetControlNormal(0, 240)
    touchX = touchX * screenWidth
    touchY = touchY * screenHeight
    
    -- Check T-button for drag/click
    if IsTouchInBounds(touchX, touchY, tButtonX, tButtonY, tButtonSize, tButtonSize) then
        if isDragging then
            isDragging = false
        else
            -- Toggle main UI
            mainUIvisible = not mainUIvisible
            ShowNotification(mainUIvisible and "UI Opened" or "UI Closed")
        end
        return
    end
    
    -- Start dragging if touching T-button area
    if IsTouchInBounds(touchX, touchY, tButtonX, tButtonY, tButtonSize * 2, tButtonSize * 2) then
        isDragging = true
        return
    end
    
    -- Handle dragging
    if isDragging then
        tButtonX = touchX
        tButtonY = touchY
        -- Constrain to screen boundaries
        tButtonX = math.max(tButtonSize/2, math.min(screenWidth - tButtonSize/2, tButtonX))
        tButtonY = math.max(tButtonSize/2, math.min(screenHeight - tButtonSize/2, tButtonY))
        return
    end
    
    if not mainUIvisible then return end
    
    -- Handle main UI interactions
    local uiWidth = screenWidth * 0.8
    local uiHeight = screenHeight * 0.25
    local uiX = (screenWidth - uiWidth) / 2
    local uiY = screenHeight - uiHeight - 20
    
    -- Check slot buttons
    local buttonWidth = uiWidth / 5
    for i = 1, 5 do
        local btnX = uiX + (i-1) * buttonWidth + buttonWidth/2
        local btnY = uiY + uiHeight/2
        
        if IsTouchInBounds(touchX, touchY, btnX, btnY, buttonWidth - 10, 40) then
            currentSlot = i
            return
        end
    end
    
    -- Check action buttons
    local saveBtnX = uiX + uiWidth * 0.2
    local teleportBtnX = uiX + uiWidth * 0.8
    local antiCheatBtnX = uiX + uiWidth * 0.5
    local btnY = uiY + uiHeight * 0.8
    
    -- Save button
    if IsTouchInBounds(touchX, touchY, saveBtnX, btnY, uiWidth * 0.3, 30) then
        SavePosition(currentSlot)
        return
    end
    
    -- Teleport button
    if IsTouchInBounds(touchX, touchY, teleportBtnX, btnY, uiWidth * 0.3, 30) then
        TeleportToPosition(currentSlot)
        return
    end
    
    -- Anti-cheat button
    if IsTouchInBounds(touchX, touchY, antiCheatBtnX, btnY, uiWidth * 0.3, 30) then
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
end

-- Main loop
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        HandleTouchInput()
        DrawTButton()
        DrawMainUI()
    end
end)

-- Show usage instructions
Citizen.CreateThread(function()
    Citizen.Wait(3000)
    ShowNotification("Drag the T-button to move it")
    ShowNotification("Tap T-button to open/close UI")
    ShowNotification("Enable Anti-Cheat for safety first!")
end)

-- Cleanup on script restart
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        -- Reset dragging if touch is released
        if isDragging and not IsControlPressed(0, 237) then
            isDragging = false
        end
    end
end)
