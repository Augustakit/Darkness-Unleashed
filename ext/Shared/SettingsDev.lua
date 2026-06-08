-- 这是 SettingsDev.lua，备份了含有 MAPS 功能的配置
-- 如果你想使用 MAPS 逐个地图指定模式，请将此文件内容复制到 Settings.lua 中
-- 并且注释掉 client/__init.lua 中的“两种模式”代码块，取消注释“MAPS 模式”代码块

DU_CONFIG = {
    VEHICLES = {
        USE_VEHICLE_LIGHTS = true
    },
    GENERAL = {
        USE_NIGHTVISION_GADGET = true
    },
    LOGGER_ENABLED = true,
    LOGGER_PRINT_ALL = false,

    -- MAPS 表：为每个地图指定一个固定的模式（模式名必须对应 Presets 中存在的预设）
    MAPS = {
        MP_001 = "Night",      -- Grand Bazaar
        MP_003 = "Night",      -- Teheran Highway
        MP_007 = "Night",      -- Caspian Border
        MP_011 = "Night",      -- Seine Crossing
        MP_012 = "Night",      -- Operation Firestorm
        MP_013 = "Night",      -- Damavand Peak
        MP_017 = "Night",      -- Noshahr Canals
        MP_018 = "Night",      -- Kharg Island
        MP_Subway = "Night",   -- Operation Metro
        XP1_001 = "Night",     -- Strike at Karkand
        XP1_002 = "Night",     -- Gulf of Oman
        XP1_003 = "Night",     -- Sharqi Peninsula
        XP1_004 = "Night",     -- Wake Island
        XP2_Palace = "Night",  -- Donya Fortress
        XP2_Office = "Night",  -- Operation 925
        XP2_Factory = "Night", -- Scrapmetal
        XP2_Skybar = "Night",  -- Ziba Tower
        XP3_Alborz = "Night",  -- Alborz Mountains
        XP3_Shield = "Night",  -- Armored Shield
        XP3_Desert = "Night",  -- Bandar Desert
        XP3_Valley = "Night",  -- Death Valley
        XP4_Parl = "Night",    -- Azadi Palace
        XP4_Quake = "Night",   -- Epicenter
        XP4_FD = "Night",      -- Markaz Monolith
        XP4_Rubble = "Night",  -- Talah Market
        XP5_001 = "Night",     -- Operation Riverside
        XP5_002 = "Night",     -- Nebandan Flats
        XP5_003 = "Night",     -- Kiasar Railroad
        XP5_004 = "Night"      -- Sabalan Pipeline
    },

    NVG = {
        -- 电池参数（单位：秒，与游戏内时间对应）
        BATTERY_MAX = 120,           -- 最大电量（满电）
        BATTERY_MIN = 10,            -- 激活 NVG 所需的最低电量
        BATTERY_COOLDOWN = 10,       -- 电池完全耗尽后等待冷却的秒数
        FADE_LENGTH_MS = 2000,       -- 开关 NVG 特效的淡入淡出时长（毫秒）

        -- 不同模式下 NVG 视觉效果对应的 VEManager 预设名
        -- 注意：这些预设名必须在你的 Presets 文件夹中存在（例如 DU_FLIR, DU_Vehicle_NVG, DU_Vehicle_Thermal）
        MODE_PRESETS = {
            Night = {
                Soldier = "DU_FLIR",
                Vehicle = "DU_Vehicle_NVG",
                Vehicle_Thermal = "DU_Vehicle_Thermal",
            },
            NVG = {
                Soldier = "DU_FLIR",
                Vehicle = "DU_Vehicle_NVG",
                Vehicle_Thermal = "DU_Vehicle_Thermal",
            },
            Morning = {
                Soldier = "DU_FLIR",
                Vehicle = "DU_Vehicle_NVG",
                Vehicle_Thermal = "DU_Vehicle_Thermal",
            },
            -- 如果你有其他模式（如 Evening, Noon），也可以在这里添加
        },
    },

}