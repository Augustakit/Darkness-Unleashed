-- Requires
---@type UI
local m_UI = require("Systems/UI")
---@type MapVEManager
local m_MapVEManager = require("Systems/MapVEManager")
---@type VehicleManager
local m_VehicleManager = require("Systems/VehicleManager")
local m_ClientVehicleController = require("Systems/ClientVehicleController")

---@type NVG
local m_NVG = require("Systems/NVG")

require("Systems/Patches")

-- Logger
local m_Logger = DULogger("DarknessClient", true)

---@class DarknessClient
---@overload fun(): DarknessClient
DarknessClient = class("DarknessClient")

function DarknessClient:__init()
    self:RegisterVars()
    self:RegisterEvents()
end

--改变游戏环境必备文件
function DarknessClient:RegisterVars()
    self.m_Presets = {
        ["Night"] = require("Presets/Night"),
        ["NVG"] = require("Presets/Special/NVG"),
        ["FLIR"] = require("Presets/Special/FLIR"),
        ["Vehicle_NVG"] = require("Presets/Special/Vehicle_NVG"),
        ["Vehicle_Thermal"] = require("Presets/Special/Vehicle_Thermal"),

        ["MP_001_Night"] = require("Presets/Vanilla/MP_001/Night"),
        ["MP_003_Night"] = require("Presets/Vanilla/MP_003/Night"),
        ["MP_007_Night"] = require("Presets/Vanilla/MP_007/Night"),
        ["MP_007_Morning"] = require("Presets/Vanilla/MP_007/Morning"),
        ["MP_011_Night"] = require("Presets/Vanilla/MP_011/Night"),
        ["MP_012_Night"] = require("Presets/Vanilla/MP_012/Night"),
        ["MP_013_Night"] = require("Presets/Vanilla/MP_013/Night"),
        ["MP_017_Night"] = require("Presets/Vanilla/MP_017/Night"),
        ["MP_018_Night"] = require("Presets/Vanilla/MP_018/Night"),
        ["MP_Subway_Night"] = require("Presets/Vanilla/MP_Subway/Night"),
        ["XP1_001_Night"] = require("Presets/Vanilla/XP1_001/Night"),
        ["XP1_002_Night"] = require("Presets/Vanilla/XP1_002/Night"),
        ["XP1_003_Night"] = require("Presets/Vanilla/XP1_003/Night"),

        ["MP_001_NVG"] = require("Presets/Vanilla/MP_001/NVG"),
        ["MP_003_NVG"] = require("Presets/Vanilla/MP_003/NVG"),
        ["MP_007_NVG"] = require("Presets/Vanilla/MP_007/NVG"),
        ["MP_011_NVG"] = require("Presets/Vanilla/MP_011/NVG"),
        ["MP_012_NVG"] = require("Presets/Vanilla/MP_012/NVG"),
        ["MP_013_NVG"] = require("Presets/Vanilla/MP_013/NVG"),
        ["MP_017_NVG"] = require("Presets/Vanilla/MP_017/NVG"),
        ["MP_018_NVG"] = require("Presets/Vanilla/MP_018/NVG"),
        ["MP_Subway_NVG"] = require("Presets/Vanilla/MP_Subway/NVG"),
    }

    self.m_Prefix = "DU_" --意味着你如果添加新的预设地图，名字开头必须用DU_，否则识别不到
end

function DarknessClient:RegisterEvents()
    Events:Subscribe("Level:Loaded", self, self.OnLevelLoaded)
    Events:Subscribe("Level:LoadResources", self, self.OnLoadResources)
    Events:Subscribe("Level:Destroy", self, self.OnLevelDestroyed)
    Events:Subscribe('Level:RegisterEntityResources', self, self.OnEntityRegister)
    Events:Subscribe("Engine:Update", self, self.OnEngineUpdate)
    Events:Subscribe("Player:UpdateInput", self, self.OnUpdateInput)
    Events:Subscribe('Player:Killed', self, self.OnPlayerKilled)
    Events:Subscribe("VEManager:PresetsLoaded", self, self.OnPresetsLoaded)
    Events:Subscribe("Player:Respawn", self, self.OnPlayerRespawn)
    NetEvents:Subscribe("Darkness:YellPreset", self, self.OnYellPreset)
end



---@param p_LevelName string
---@param p_GameMode string
---@param p_IsDedicatedServer boolean
function DarknessClient:RegisterPresets(p_LevelName, p_GameMode, p_IsDedicatedServer)
    m_Logger:Write("Registering Presets")
    local s_LevelName = p_LevelName:match('/[^/]+'):sub(2)
    local s_Prefix = self.m_Prefix

    for l_Name, l_Preset in pairs(self.m_Presets) do
        local s_Name = s_Prefix .. l_Name

        if string.find(s_Name, s_LevelName) 
           or l_Name == "Night"
           or l_Name == "NVG"
           or l_Name == "Morning"
           or l_Name == "Evening"
           or l_Name == "Noon"
           or l_Name == "FLIR"
           or l_Name == "Vehicle_NVG"
           or l_Name == "Vehicle_Thermal" then

            m_Logger:Write("Registering Preset: " .. s_Name)
            Events:Dispatch("VEManager:RegisterPreset", s_Name, l_Preset)
        end
    end

  --通用模式 保险：如果 m_Presets 表里没有 Night / NVG，也强制注册通用路径
  --[[if not self.m_Presets["Night"] then
         self:RegisterPreset(s_Prefix .. "Night", "Night")  -- 根目录 Presets/Night.lua
     end
      if not self.m_Presets["NVG"] then
         self:RegisterPreset(s_Prefix .. "NVG", "Special/NVG") -- Special/NVG.lua
    end]]
end

---@param p_LevelName string
---@param p_GameMode string
---@param p_IsDedicatedServer boolean
function DarknessClient:OnLoadResources(p_LevelName, p_GameMode, p_IsDedicatedServer)
    -- Self

    self:RegisterPresets(p_LevelName, p_GameMode, p_IsDedicatedServer)
    -- Distribute
    -- m_MapVEManager:OnLoadResources(p_LevelName, p_GameMode, p_IsDedicatedServer)
end

---@param p_LevelName string
---@param p_GameMode string
function DarknessClient:OnLevelLoaded(p_LevelName, p_GameMode)

end

---@param p_LevelName string
---@param p_GameMode string
function DarknessClient:OnLevelDestroyed(p_LevelName, p_GameMode)

end

---@param p_Player Player
function DarknessClient:OnPlayerRespawn(p_Player)
    -- Distribute
    local s_localPlayer = PlayerManager:GetLocalPlayer()
    if s_localPlayer == p_Player then
        m_UI:OnPlayerRespawn()
    end
end

---@param p_Player Player
function DarknessClient:OnPlayerKilled(p_Player)
    -- Distribute
    local s_localPlayer = PlayerManager:GetLocalPlayer()
    if s_localPlayer == p_Player then
        m_NVG:Deactivate()
    end
end

---@param p_LevelData LevelData
function DarknessClient:OnEntityRegister(p_LevelData)
    -- Distribute
    m_VehicleManager:OnEntityRegister(p_LevelData)
end

---@param p_DeltaTime integer
function DarknessClient:OnUpdateInput(p_DeltaTime)
    -- Self
    local s_localPlayer = PlayerManager:GetLocalPlayer()
    if s_localPlayer ~= nil and s_localPlayer.soldier ~= nil and s_localPlayer.alive then
        self:NVGPlayerInput(p_DeltaTime)
    end
end

-- ===================== 以下代码块二选一，请手动注释/取消注释 =====================

-- ========== 版本 A：两种模式（fixed_map / generic + 随机列表） ==========
function DarknessClient:OnPresetsLoaded()
    -- 初始化随机数种子
    local now = os.time()
    local micro = math.floor((SharedUtils:GetTimeMS() or 0) % 1000)
    math.randomseed(now + micro)

    -- 获取地图短名，例如 MP_007
    local currentMap = SharedUtils:GetLevelName():match('/[^/]+'):sub(2)

    -- 读取配置（如果 DU_CONFIG 不存在或字段缺失，使用默认值）
    local modeType = DU_CONFIG.MODE_TYPE or "fixed_map"
    local modeList = DU_CONFIG.MODE_LIST or { "Night", "NVG", "Morning" }

    -- 确保模式列表不为空
    if #modeList == 0 then
        m_Logger:Write("错误：MODE_LIST 为空，无法选择模式")
        return
    end

    -- 从模式列表中随机选择一个
    local selected = modeList[math.random(#modeList)]

    -- 保存当前模式，通知 NVG 模块
    self.m_CurrentMode = selected
    m_NVG:SetCurrentMode(selected)

    local presetName = nil

    if modeType == "generic" then
        -- 通用模式：直接使用前缀+模式名，例如 DU_Night
        presetName = self.m_Prefix .. selected
        m_Logger:Write("通用模式，选择预设: " .. presetName)
    else
        -- 地图固定模式：尝试使用地图名+模式名，例如 DU_MP_007_Night
        local presetKey = currentMap .. "_" .. selected
        if self.m_Presets[presetKey] then
            presetName = self.m_Prefix .. presetKey
            m_Logger:Write("地图固定模式，地图 " .. currentMap .. " 有专用预设: " .. presetName)
        else
            -- 没有对应的地图固定预设，则什么都不做（不启用任何预设）
            m_Logger:Write("地图固定模式，地图 " .. currentMap .. " 没有专用预设: " .. presetKey .. "，放弃启用")
            return
        end
    end

    -- 启用预设并同步给服务器
    if presetName then
        Events:Dispatch("VEManager:EnablePreset", presetName)
        NetEvents:Send("Darkness:SyncPresetName", presetName)
    end
end
-- ========== 版本 A 结束 ==========



-- ========== 版本 B：MAPS 逐个地图指定模式（使用 DU_CONFIG.MAPS 表） ==========
--[[function DarknessClient:OnPresetsLoaded()
    -- 获取地图短名
    local currentMap = SharedUtils:GetLevelName():match('/[^/]+'):sub(2)

    -- 读取 MAPS 配置表
    local maps = DU_CONFIG.MAPS
    if not maps then
        m_Logger:Write("错误：DU_CONFIG.MAPS 不存在，无法使用 MAPS 模式")
        return
    end

    -- 查找当前地图对应的模式（例如 maps["MP_007"] 返回 "Night"）
    local selected = maps[currentMap]
    if not selected then
        m_Logger:Write("MAPS 模式：地图 " .. currentMap .. " 没有指定模式，放弃启用任何预设")
        return
    end

    -- 保存当前模式，通知 NVG 模块
    self.m_CurrentMode = selected
    m_NVG:SetCurrentMode(selected)

    -- 构建地图固定预设名：DU_MP_007_Night
    local presetKey = currentMap .. "_" .. selected
    local presetName = nil

    if self.m_Presets[presetKey] then
        presetName = self.m_Prefix .. presetKey
        m_Logger:Write("MAPS 模式：地图 " .. currentMap .. " 启用预设: " .. presetName)
    else
        m_Logger:Write("MAPS 模式：地图 " .. currentMap .. " 指定的模式 " .. selected .. " 对应的预设 " .. presetKey .. " 不存在，放弃启用")
        return
    end

    -- 启用预设并同步给服务器
    Events:Dispatch("VEManager:EnablePreset", presetName)
    NetEvents:Send("Darkness:SyncPresetName", presetName)
end]]
-- ========== 版本 B 结束 ==========


-- 获取当前模式的方法
function DarknessClient:GetCurrentMode()
    return self.m_CurrentMode -- 不做默认值假设，必须先在 OnPresetsLoaded() 里赋值
end


-- Night Vision Gadget
---@param p_DeltaTime integer
function DarknessClient:NVGPlayerInput(p_DeltaTime)
    -- Night Vision Goggles
    if InputManager:WentKeyDown(InputDeviceKeys.IDK_7) then
        m_Logger:Write('NVG Key detected!')

        if DU_CONFIG.GENERAL.USE_NIGHTVISION_GADGET and m_UI.m_HudActive then
            if not m_NVG.m_Activated then
                m_Logger:Write('Calling NVG:Activate()')
                m_NVG:Activate()
            else
                m_Logger:Write('Calling NVG:Deactivate()')
                m_NVG:Deactivate()
            end
        else
            m_Logger:Write('Failed to enable NVG. useNightVisionGadget = ' ..
                tostring(DU_CONFIG.GENERAL.USE_NIGHTVISION_GADGET) ..
                ' | isHud = ' .. tostring(m_UI.m_HudActive) .. ' | isKilled = ' .. tostring(m_UI.m_PlayerDead))
        end
    end

    --[[m_NVG.m_AnimationValue = MathUtils:Lerp(0, 2, m_NVG.m_AnimationT)
    if m_NVG.m_Transitioning then
        m_NVG.m_AnimationT = m_NVG.m_AnimationT + (p_DeltaTime / 1)
        Events:Dispatch("VEManager:SetSingleValue", "DU_" .. m_MapVEManager.m_LoadedPreset[1] .. "_NVG", "vignette", "exponent", m_NVG.m_AnimationValue)

        if m_NVG.m_AnimationValue >= 2 then
            m_NVG.m_Transitioning = false
            m_NVG.m_AnimationT = 0
        end
    end]]
end




--[[s_LastSecond 本质上是一个“上次执行的秒数记录”
当条件满足（总时间 >= 上次执行时间 + 1秒）时，才会执行耗电或充电逻辑

p_DeltaTime = 本帧与上一帧的真实时间间隔（秒）
s_ElapsedTime = 总经过时间（秒）
if s_ElapsedTime >= s_LastSecond + 1 then
→ 这里的 +1 就是说明 耗电/充电逻辑每隔 1 秒执行一次
→ 也就是我们说的 loop 频率 = 1Hz
每次满足条件：
如果 NVG 开启 → m_NVG:Depleting(s_ElapsedTime)（耗电 1 点）
如果 NVG 关闭且未满电 → m_NVG:Recharging(s_ElapsedTime)（回电 1 点）]]

local s_ElapsedTime = 0
local s_LastSecond = 0
---@param p_DeltaTime integer
---@param p_SimulationDeltaTime integer
function DarknessClient:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
    s_ElapsedTime = s_ElapsedTime + p_DeltaTime

    if s_ElapsedTime >= s_LastSecond + 1 then
        s_LastSecond = s_LastSecond + 1
        if DU_CONFIG.GENERAL.USE_NIGHTVISION_GADGET then
            if m_NVG.m_Activated then
                m_NVG:Depleting(s_ElapsedTime)
            elseif not m_NVG.m_Activated and m_NVG.m_BatteryLifeCurrent ~= m_NVG.m_BatteryLifeMax then
                m_NVG:Recharging(s_ElapsedTime)
            end
        end
    end
end

-- 收到服务器发来的预设名并显示
function DarknessClient:OnYellPreset(p_PresetName)
    m_Logger:Write("收到预设消息: " .. tostring(p_PresetName))
    ChatManager:Yell("当前预设: " .. tostring(p_PresetName), 5.0)
end

DarknessClient = DarknessClient()

return DarknessClient