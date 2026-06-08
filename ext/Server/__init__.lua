-- Your server side code here

-- Logger
local m_Logger = DULogger("DarknessServer", false)

---@class DarknessServer
---@overload fun(): DarknessServer
DarknessServer = class("DarknessServer")
-- local m_ServiceVehicleController = require("ServerVehicleController")

function DarknessServer:__init()
    self:RegisterEvents()
    self.m_CurrentPreset = nil
end

function DarknessServer:RegisterEvents()
    --NetEvents:Subscribe("VEManager:PresetsLoaded", self, self._OnPresetsLoaded) --昼夜循环图必备，但不推荐用

    Events:Subscribe('Vehicle:Enter', self, self._OnVehicleInteract)
    Events:Subscribe('Vehicle:Exit', self, self._OnVehicleInteract)
    -- Events:Subscribe('Vehicle:Destroy', self, self._OnVehicleDestroy)

    -- 监听客户端发来的电池状态
    NetEvents:Subscribe("BatteryStatus", self, self.OnBatteryStatus)
    -- 监听客户端发来的“当前预设名”
    NetEvents:Subscribe("Darkness:SyncPresetName", self, self.OnSyncPresetName)
    -- 玩家重生时发Yell
    Events:Subscribe("Player:Respawn", self, self.OnPlayerRespawn)

end

---@param vehicle string
---@param player Player
function DarknessServer:_OnVehicleInteract(vehicle, player)
    NetEvents:BroadcastLocal('DarknessServer:VehicleInteract', player.name, vehicle)
end

-- function DarknessServer:_OnVehicleDestroy(vehicle, player)
--     NetEvents:BroadcastLocal('DarknessServer:VehicleInteract', player.name)
-- end

--昼夜循环图必备，但不推荐用
--[[function DarknessServer:setDayNightCycle(p_StartingTime, p_LengthOfCycle)
    -- Is time static?
    if p_LengthOfCycle <= 0 then
        ---@diagnostic disable-next-line: cast-local-type
        p_LengthOfCycle = nil
    end

    -- Fix incorrect time
    if p_StartingTime < 0 or p_StartingTime >= 24 then
        p_StartingTime = 0
    end

    local l_OnlyDynamicPresets = DU_CONFIG.TIME.ONLY_DYNAMIC_PRESETS

    Events:Dispatch('TimeServer:Enable', p_StartingTime, p_LengthOfCycle, l_OnlyDynamicPresets)
end

function DarknessServer:_OnPresetsLoaded()
    -- This causes crashes when some maps start loading and spawning bots. Delegating this responsability to VEManager directly.
    if DU_CONFIG.TIME.ENABLED then
        self:setDayNightCycle(DU_CONFIG.TIME.START_HOUR, DU_CONFIG.TIME.DAY_DURATION)
    end
end]]

-- 客户端发来预设名字
function DarknessServer:OnSyncPresetName(p_Player, p_PresetName)
    self.m_CurrentPreset = p_PresetName
    m_Logger:Write("收到客戶端"..p_Player.name.."的當前預設："..tostring(p_PresetName))
end

-- 玩家重生时告诉他
function DarknessServer:OnPlayerRespawn(p_Player)
    if self.m_CurrentPreset ~= nil then
        ChatManager:Yell("當前視覺預設: " .. tostring(self.m_CurrentPreset), 5.0, p_Player)
    end
end

-- 接收客户端电量状态并发 Yell
function DarknessServer:OnBatteryStatus(p_Player, status)
    if status == "充足" then
        ChatManager:Yell("電量充足，可以使用夜視鏡", 5, p_Player)
    elseif status == "不足" then
        ChatManager:Yell("電量不足 10%，請節約使用", 5, p_Player)
    end
    m_Logger:Write("电量状态 Yell 给玩家: "..p_Player.name.." 状态: "..status)
end

DarknessServer = DarknessServer()

return DarknessServer
