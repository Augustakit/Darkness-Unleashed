-- Default MapVE Configuration
DU_CONFIG = {
    VEHICLES = {
        USE_VEHICLE_LIGHTS = true
    },
    GENERAL = {
        USE_NIGHTVISION_GADGET = true
    },
    LOGGER_ENABLED = true,
    LOGGER_PRINT_ALL = false,

    -- ========== 模式选择（两种模式） ==========
    MODE_TYPE = "fixed_map",   -- "fixed_map" 或 "generic"
    MODE_LIST = { "Night", "NVG", "Morning" },

    -- ========== NVG 配置 ==========
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