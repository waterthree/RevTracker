-- Initialize SavedVariables
RevTrackerDB = RevTrackerDB or {}

-- Main frame for events
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_DEAD")
f:RegisterEvent("PLAYER_TARGET_CHANGED")

-- Slash commands
SLASH_REVTRACKER1 = "/rev"
SlashCmdList["REVTRACKER"] = function(msg)
    if msg == "show" then
        RevTrackerFrame:Show()
    elseif msg == "hide" then
        RevTrackerFrame:Hide()
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00RevTracker|r: use /rev show or /rev hide")
    end
end

-- Function to add/update an enemy entry
local function AddEnemy(name, class, level, reason)
    if not name then return end
    RevTrackerDB[name] = RevTrackerDB[name] or {}
    RevTrackerDB[name].class = class or RevTrackerDB[name].class or "Unknown"
    RevTrackerDB[name].level = level or RevTrackerDB[name].level or 0
    RevTrackerDB[name].lastKill = date("%Y-%m-%d %H:%M:%S")
    RevTrackerDB[name].nasty = RevTrackerDB[name].nasty or 0
    RevTrackerDB[name].reason = reason or RevTrackerDB[name].reason or ""
end

-- Event handling
f:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_DEAD" then
        local killerName = UnitName("target") -- Simplified; proper tracking requires combat log parsing
        if killerName then
            AddEnemy(killerName, UnitClass("target"), UnitLevel("target"), "Killed me")
            DEFAULT_CHAT_FRAME:AddMessage("|cffff0000RevTracker:|r Logged "..killerName.." as your killer.")
        end
    elseif event == "PLAYER_TARGET_CHANGED" then
        local tName = UnitName("target")
        if tName and RevTrackerDB[tName] then
            local info = RevTrackerDB[tName]
            local msg = string.format("⚠️ Revenge Target! %s (Nasty %d) Last seen: %s",
                tName, info.nasty or 0, info.lastKill or "unknown")
            UIErrorsFrame:AddMessage(msg, 1, 0, 0, 3)
            PlaySoundFile("Sound\\Interface\\RaidWarning.wav")
        end
    end
end)

-- Button handler for manual add
function RevTracker_AddTarget()
    local tName = UnitName("target")
    if tName and UnitIsPlayer("target") and not UnitIsFriend("player", "target") then
        AddEnemy(tName, UnitClass("target"), UnitLevel("target"), "Manually added")
        DEFAULT_CHAT_FRAME:AddMessage("|cffff8800RevTracker:|r Added "..tName.." manually.")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffff8800RevTracker:|r No valid enemy target.")
    end
end