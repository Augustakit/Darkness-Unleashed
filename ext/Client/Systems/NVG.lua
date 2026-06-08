-- --@type MapVEManager
-- local m_MapVEManager = require("Systems/MapVEManager")

local m_Logger = DULogger("NVG", false)

---@class NVG
---@overload fun(): NVG
local NVG = class("NVG")

function NVG:__init()
    self:RegisterVars()
    -- Set value on the UI
    UI:Batteries(self.m_BatteryLifeMin, self.m_BatteryLifeMax)
    self:RegisterEvents()
end

-- Systems/NVG.lua

function NVG:RegisterVars()
    -- 从 DU_CONFIG 读取 NVG 配置，如果不存在则使用默认值（保持原硬编码值）
    local nvgConfig = DU_CONFIG.NVG or {}
    self.m_Activated = false
    self.m_Transitioning = false
    self.m_BatteryLifeMax = nvgConfig.BATTERY_MAX or 120        -- 电池满格数值（最大电量），直接决定夜视镜最长可用时间，通常为秒
    self.m_BatteryLifeMin = nvgConfig.BATTERY_MIN or 10         -- 激活 NVG 需要的最低电量，一般单位也为秒
    self.m_BatteryEmptyTime = 0
    self.m_BatteryLifeCooldown = nvgConfig.BATTERY_COOLDOWN or 10  -- 电池完全耗尽后，要等待的冷却时间（单位是和 p_ElapsedTime 一致，一般是秒）
    self.m_BatteryLifeCurrent = self.m_BatteryLifeMax           -- 当前电量值，初始为满电
    self.m_FadeLengthMS = nvgConfig.FADE_LENGTH_MS or 2000      -- 开关 NVG 特效淡入淡出时长（毫秒），改快则 NVG 开/关切换时更迅速，改慢=更顺滑过渡
    self.m_AnimationValue = 0
    self.m_AnimationT = 0
    self.m_CurrentNVGVE = nil
    self.m_Depleted = false  --标记是否电量耗尽
    self.m_NVGVES = nil
end

-- DarknessClient 会在选好模式后调用这个方法
function NVG:SetCurrentMode(mode)
    self.m_ModeFromClient = mode

    -- 从 DU_CONFIG 中读取模式预设映射表，如果配置不存在或模式缺失，则使用原硬编码的默认映射
    local nvgConfig = DU_CONFIG.NVG
    local ModePresets = nil
    if nvgConfig and nvgConfig.MODE_PRESETS then
        ModePresets = nvgConfig.MODE_PRESETS
    else
        -- 默认映射（与原硬编码一致）
        ModePresets = {
            Night = {
                Soldier = "DU_FLIR",
                Vehicle = "DU_Vehicle_NVG",
                Vehicle_Thermal = "DU_Vehicle_Thermal"
            },
            NVG = {
                Soldier = "DU_FLIR",
                Vehicle = "DU_Vehicle_NVG",
                Vehicle_Thermal = "DU_Vehicle_Thermal"
            },
            Morning = {
                Soldier = "DU_FLIR",
                Vehicle = "DU_Vehicle_NVG",
                Vehicle_Thermal = "DU_Vehicle_Thermal"
            }
        }
    end

    self.m_NVGVES = ModePresets[mode] -- 不在表中则直接是 nil
    m_Logger:Write('NVG 当前模式设置为: '..tostring(mode))
end



function NVG:RegisterEvents()
    Events:Subscribe('Level:Destroy', self, self._OnLevelDestroy)
    NetEvents:Subscribe('DarknessServer:VehicleInteract', self, self._OnVehicleInteract)
    -- Events:Subscribe('TimeServer:TimeInform', self, self._OnTimeInform)
end

function NVG:_OnLevelDestroy()
    self:RegisterVars()
end

-- ---@param p_Hour number
-- function NVG:_OnTimeInform(p_Hour)
--     local player = PlayerManager:GetLocalPlayer()

--     if player.inVehicle and self.m_Activated then
--         if p_Hour > 5 and p_Hour < 20 then
--             Events:Dispatch("VEManager:DisablePreset", self.m_CurrentNVGVE)
--             self.m_CurrentNVGVE = self.m_NVGVES["Vehicle_Thermal"]
--             Events:Dispatch("VEManager:EnablePreset", self.m_CurrentNVGVE)
--         else
--             Events:Dispatch("VEManager:DisablePreset", self.m_CurrentNVGVE)
--             self.m_CurrentNVGVE = self.m_NVGVES["Vehicle"]
--             Events:Dispatch("VEManager:EnablePreset", self.m_CurrentNVGVE)
--         end
--     end
-- end

---@param p_RecievedPlayerName string
function NVG:_OnVehicleInteract(p_RecievedPlayerName)
    -- What to do when a player (local) enters a vehicle, switch the preset being used.
    if not self.m_NVGVES then
        self:RegisterVars()
    end
    local player = PlayerManager:GetLocalPlayer()
    if self.m_Activated and p_RecievedPlayerName == player.name then
        if not player.inVehicle then
            m_Logger:Write('The player entered a Vehicle! Swtiching to NVG')

            Events:Dispatch("VEManager:DisablePreset", self.m_CurrentNVGVE)
            self.m_CurrentNVGVE = self.m_NVGVES["Vehicle"]
            Events:Dispatch("VEManager:EnablePreset", self.m_CurrentNVGVE)
        else
            m_Logger:Write('The player exited a Vehicle! Switching to Vehicle NVG')

            Events:Dispatch("VEManager:DisablePreset", self.m_CurrentNVGVE)
            self.m_CurrentNVGVE = self.m_NVGVES["Soldier"]
            Events:Dispatch("VEManager:EnablePreset", self.m_CurrentNVGVE)
        end
    end
end

function NVG:Activate(p_LevelName)
    if not self.m_NVGVES then
        self:RegisterVars()
    end
    m_Logger:Write('NVG Activate called!')
    m_Logger:Write(self.m_BatteryLifeCurrent)
    if self.m_BatteryLifeCurrent >= self.m_BatteryLifeMin then

         -- 电量充足提示
        NetEvents:SendLocal("BatteryStatus", "充足")
        if not self.m_Activated and self.m_CurrentNVGVE == nil then
            self.m_Activated = true
            local localPlayer = PlayerManager:GetLocalPlayer()
            if not localPlayer.inVehicle then
                self.m_CurrentNVGVE = self.m_NVGVES["Soldier"]
            else
                self.m_CurrentNVGVE = self.m_NVGVES["Vehicle_Thermal"]
                --self.m_CurrentNVGVE = self.m_NVGVES["Vehicle"]
            end
            Events:Dispatch("VEManager:FadeIn", self.m_CurrentNVGVE, self.m_FadeLengthMS)

            WebUI:ExecuteJS('playSound("sounds/Switch_ON.webm", 1.0, false);')
            m_Logger:Write('NVG Activate ...')
            UI:EnableGoggleIcon(true) -- Update UI battery icon
            self.m_Transitioning = true
        else
            if self.m_Activated then
                m_Logger:Write('NVG Already active | NVG:Activate()')
            else
                m_Logger:Write('Animation Running | NVG:Activate()')
            end
        end
    else
        m_Logger:Write('Not enough battery to activate | ' ..
            tostring(self.m_BatteryLifeCurrent) .. '/' .. tostring(self.m_BatteryLifeMax))
        m_Logger:Write('Needs more than ' .. tostring(self.m_BatteryLifeMin) .. ' to activate!')
        WebUI:ExecuteJS('window.showNVGAlert();')
        WebUI:ExecuteJS('playSound("sounds/Switch_EMPTY.webm", 1.0, false);')
    end
end

function NVG:Deactivate()
    m_Logger:Write('NVG Deactivate called!')
    if self.m_Activated and self.m_CurrentNVGVE ~= nil then
        self.m_Activated = false

        --Beep boop sound
        if self.m_Depleted then
            Events:Dispatch("VEManager:FadeOut", self.m_CurrentNVGVE, self.m_FadeLengthMS)
            WebUI:ExecuteJS('playSound("sounds/Switch_EMPTY.webm", 1.0, false);')
        else
            Events:Dispatch("VEManager:FadeOut", self.m_CurrentNVGVE, self.m_FadeLengthMS)
            WebUI:ExecuteJS('playSound("sounds/Switch_OFF.webm", 1.0, false);')
        end

        self.m_CurrentNVGVE = nil

        m_Logger:Write('Deactivate')
        UI:DisableGoggleIcon(true) -- Update UI battery icon
    else
        if not self.m_Activated then
            m_Logger:Write('NVG not active | NVG:Deactivate()')
        else
            m_Logger:Write('Animation Running | NVG:Deactivate()')
        end
    end
end




--[[玩家步行时 → 电量每次 -1
玩家在载具中 → 电量每次 +1 （载具内自动充电？）
当 <= 0 时 → 触发耗尽逻辑 + 禁用图标
 电量递减的速率和游戏调用 Depleting() 的频率相关，一般是每秒调用一次（如果你的 loop 是 1Hz），那么 m_BatteryLifeMax = 200 → 200秒耗尽]]
function NVG:Depleting(p_ElapsedTime)
    local s_LocalPlayer = PlayerManager:GetLocalPlayer()

    if s_LocalPlayer == nil then
        return
    end

    if s_LocalPlayer.inVehicle then
        if self.m_BatteryLifeCurrent + 1 < self.m_BatteryLifeMax then
            self.m_BatteryLifeCurrent = self.m_BatteryLifeCurrent + 1
        end
    elseif self.m_BatteryLifeCurrent > 0 then
        self.m_BatteryLifeCurrent = self.m_BatteryLifeCurrent - 1
    end

    UI:Battery(self.m_BatteryLifeCurrent) -- Update UI battery
    m_Logger:Write("Battery Life: " .. self.m_BatteryLifeCurrent)


   -- 电量不足提示，当电量低于10%时只提醒一次
    if not self.m_LowBatteryWarned and self.m_BatteryLifeCurrent <= (self.m_BatteryLifeMax * 0.1) then
          NetEvents:SendLocal("BatteryStatus", "不足")
        self.m_LowBatteryWarned = true
    end

    if self.m_BatteryLifeCurrent <= 0 then
        m_Logger:Write('Battery has depleted!')

        if self.m_Activated then
            UI:DisableGoggleIcon(true) -- Update UI battery icon
            self.m_BatteryEmptyTime = p_ElapsedTime
            m_Logger:Write('Battery Depletion Animation Started')
            self.m_Depleted = true
            self:Deactivate()
        end
    end
end

--[[耗尽后等 m_BatteryLifeCooldown 秒才能重新开始充电
充电以每次 +1 速度增加，即 跟耗电速率相同
在载具中似乎也是即时充（见 Depleting）]]
function NVG:Recharging(p_ElapsedTime)
    if self.m_BatteryEmptyTime + self.m_BatteryLifeCooldown > p_ElapsedTime then
        return
    end

    -- Show Enabled/Disabled Goggles icon
    if self.m_BatteryLifeCurrent >= self.m_BatteryLifeMin then
        UI:DisableGoggleIcon(false) -- Update UI battery icon
        self.m_Depleted = false
    end

    if self.m_BatteryLifeCurrent < self.m_BatteryLifeMax then
        self.m_BatteryLifeCurrent = self.m_BatteryLifeCurrent + 1
        UI:Battery(self.m_BatteryLifeCurrent) -- Update UI battery
        m_Logger:Write("Battery Charged To: " .. self.m_BatteryLifeCurrent)
    end
end

return NVG()