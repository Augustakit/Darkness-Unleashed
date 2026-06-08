# Darkness Unleashed

> **真正的黑夜模组，远不止黑夜**  
> 现已支持全自定义配置、随机模式切换、夜视仪完整系统。新功能和配置系统的设计灵感来源于《叛乱：沙漠风暴》。

## 这是什么模组？

**Darkness Unleashed** 让《战地3》的世界彻底改变：  
原本白天的地图现在可以变成真实的黑夜、黄昏、清晨，甚至任意切换。  
你不再只能看到千篇一律的光照，而是能体验到：

- 🌙 **真正的黑暗** – 需要手电筒、夜视仪来作战
- 🌅 **晨昏变化** – 清晨的薄雾、黄昏的暖光
- 🔦 **增强光源** – 载具大灯、探照灯、手电筒全部新增并正常工作
- 🥽 **完整夜视仪系统** – 电池、充电、冷却，像《叛乱：沙漠风暴》一样真实
- 🎲 **随机模式** – 每局地图自动在多种光照预设中随机切换

模组的核心功能最初由 **Lesley 与 IllustrisJack** 实现，  
此后由 **AugustaKit** 扩展了 **完整可配置系统**、**随机模式**、**夜视仪电池系统** 等新特性。

> 💡 **灵感来源**：Night Vision 的设计与电池机制借鉴了 **《叛乱：沙漠风暴》（Insurgency: Sandstorm）** 的 Nightfall 更新。NV 不再是简单的绿色滤镜，而是一个需要管理的战术装备。

## ✨ 核心功能

### 🌓 全新的视觉体验

- **4 种基础预设**：Night（夜晚）、NVG（夜视风格）、Morning（清晨）、Evening（黄昏）
- **可任意扩展**：你可以自己添加 Noon、Sunset 等新预设
- **全局 + 每地图独立**：亮度、雾效、对比度、色调均可单独控制
- **增强高光反射**（Specular Reflections）与动态光照

### 🚗 载具灯光系统

- 所有载具（坦克、直升机、悍马等）的 **大灯 / 探照灯** 已新增并正常工作
- 支持 **车灯光束 + 泛光 + 镜头光晕**
- 驾驶员可按 **`T`** 键开关灯光

### 🔦 武器手电筒增强

- 手电筒 **半径 / 强度 / 锥角 / 阴影** 全面重调
- 真实光束模型 + 投射阴影 + 镜头光晕
- 枪口火焰、曳光弹、火花等粒子效果增强并附加点光源

### 🥽 完整夜视仪系统（NVG）

- 按 **`7`** 键开关
- **电池系统**：步行时消耗，载具内充电（空中载具内同样可用）
- 低电量警告（<10%）+ 耗尽后冷却
- **三种视觉模式**：步兵 / 载具内 / 载具热成像，可独立配置
- 开关时有淡入淡出效果 + 音效

### 🎲 灵活的模式选择

| 模式类型 | 行为 | 适用场景 |
|---|---|---|
| **地图固定模式**（`fixed_map`） | 每个地图使用自己的专用预设，支持从配置列表中随机选择 | 想要每个地图有独立光照风格，且带随机变化 |
| **通用模式**（`generic`） | 所有地图共用一套预设，同样支持随机选择 | 服务器统一风格（例如全黑夜） |
| **MAPS 备选方案** | 逐个地图手动指定一个固定预设，无随机 | 喜欢绝对可控的老玩家 |

> 随机列表和开关全部可在 `Settings.lua` 中一行配置。

### 🛠 其他视觉增强

- **曳光弹可见度提升** + 附加点光源
- **减少太阳眩光 / 无镜头光晕**（仅手电筒保留）
- **烟雾、灰尘、爆炸残骸等粒子效果增强**
- **修复 VU 20079+ 版本的 UI 失效问题**

## 📁 安装与文件结构

### 1️⃣ 下载与放置

| 步骤 | 操作 |
|---|---|
| 1 | 下载本模组（`Darkness-Unleashed` 文件夹） |
| 2 | 放入你的 VU 服务端 `Mods` 目录 |
| 3 | 在 `ModList.txt` 中添加一行 `Darkness-Unleashed` |
| 4 | （可选）根据下方说明修改 `Settings.lua` 配置 |
| 5 | 启动服务器，享受黑暗！ |

### 2️⃣ 关键文件结构（你需要知道的路径）

```
Darkness-Unleashed/
├── ext/
│   ├── Shared/
│   │   ├── Settings.lua          ← ★ 所有配置都在这里（核心！）
│   │   └── SettingsDev.lua       ← MAPS 备用配置模板
│   ├── Client/
│   │   ├── __init__.lua          ← 主逻辑（一般不需改动）
│   │   ├── Presets/              ← 预设文件目录
│   │   │   ├── Vanilla/          ← 地图固定预设（按地图名分文件夹）
│   │   │   │   ├── MP_001/
│   │   │   │   ├── MP_003/
│   │   │   │   └── ...
│   │   │   ├── Special/          ← NVG 视觉效果预设
│   │   │   ├── Night.lua
│   │   │   ├── NVG.lua
│   │   │   └── Morning.lua
│   │   └── Systems/              ← NVG、车辆灯光、UI 等子系统
│   └── Server/
│       └── __init__.lua          ← 服务端同步逻辑
└── ModList.txt                   ← 你的模组列表
```

### 3️⃣ 预设文件命名规则（非常重要！）

预设文件（如 `Night.lua`）内部有一个 **`"Name"` 字段**，这个字段才是 VEManager 真正识别的标识符，**不是文件名**。

| 预设类型 | 路径 | 文件内 `"Name"` 示例 |
|---|---|---|
| 通用模式预设 | `Presets/Night.lua` | `"DU_Night"` |
| 地图固定预设 | `Presets/Vanilla/MP_007/Night.lua` | `"DU_MP_007_Night"` |
| NVG 步兵预设 | `Presets/Special/FLIR.lua` | `"DU_FLIR"` |
| NVG 载具预设 | `Presets/Special/Vehicle_NVG.lua` | `"DU_Vehicle_NVG"` |

> 💡 简单来说：**文件名只是 require 用，`"Name"` 才是游戏内真正的名字。**

## ⚙️ 配置说明（`Settings.lua`）

所有可配置项都在 `DU_CONFIG` 表中。

### 🔧 基础模式选择

```lua
DU_CONFIG = {
    MODE_TYPE = "fixed_map",   -- "fixed_map" 或 "generic"
    MODE_LIST = { "Night", "NVG", "Morning" },  -- 随机池
}
```

**解释**：
- `MODE_TYPE = "fixed_map"` 启用地图固定模式（每个地图独立预设）。系统会根据当前地图名（如 `MP_007`）从 `MODE_LIST` 中随机选一个模式（例如 `"Night"`），然后尝试启用预设 `DU_MP_007_Night`。如果该预设不存在，则不启用任何视觉效果。
- `MODE_TYPE = "generic"` 启用通用模式。所有地图共用同一套预设，系统会从 `MODE_LIST` 中随机选一个模式（例如 `"Night"`），然后启用预设 `DU_Night`。
- 如果 `MODE_LIST` 只有一个元素（如 `{ "Night" }`），则不会随机，永远使用该模式。

### 🥽 夜视仪配置

```lua
NVG = {
    BATTERY_MAX = 120,          -- 最大电量（秒）
    BATTERY_MIN = 10,           -- 激活所需最低电量
    BATTERY_COOLDOWN = 10,      -- 耗尽后冷却时间（秒）
    FADE_LENGTH_MS = 2000,      -- 淡入淡出时长（毫秒）
    MODE_PRESETS = {
        Night = {
            Soldier = "DU_FLIR",
            Vehicle = "DU_Vehicle_NVG",
            Vehicle_Thermal = "DU_Vehicle_Thermal",
        },
        NVG = { ... },
        Morning = { ... },
    },
}
```

**解释**：
- `BATTERY_MAX`：满电时夜视仪最长可用时间（秒）。
- `BATTERY_MIN`：按下 `7` 键时，当前电量必须大于等于此值才能开启夜视仪。
- `BATTERY_COOLDOWN`：电量耗尽后，需要等待多少秒才能开始重新充电。
- `FADE_LENGTH_MS`：开启/关闭夜视仪时视觉效果淡入淡出的时长（毫秒）。
- `MODE_PRESETS`：每种游戏模式（如 `Night`）下，夜视仪开启后调用的 VEManager 预设名。`Soldier` 用于步兵，`Vehicle` 用于载具内，`Vehicle_Thermal` 用于在载具内重生时（通常更亮）。这些预设名必须对应 `Presets/Special/` 目录下文件内的 `"Name"` 字段。

### 🌍 MAPS 逐个地图指定（备选方案）

如果你更喜欢手动指定每个地图用哪种预设（无随机），可以使用 **MAPS 方案**。

**步骤**：
1. 将 `SettingsDev.lua` 的内容**覆盖**到 `Settings.lua`。
2. 在 `Client/__init.lua` 中找到 `OnPresetsLoaded` 函数区域，你会看到两个代码块：
   - 版本 A（两种模式）：当前默认激活。
   - 版本 B（MAPS 模式）：被注释掉。
3. **注释掉版本 A**，**取消注释版本 B**（删除 `--[[` 和 `--]]`）。
4. 保存文件。

**配置示例**（在 `Settings.lua` 中）：
```lua
MAPS = {
    MP_001 = "Night",
    MP_007 = "NVG",
    MP_017 = "Morning",
    -- 未列出的地图无预设
}
```

**行为**：系统查找当前地图（如 `MP_007`）对应的模式（`"NVG"`），然后启用预设 `DU_MP_007_NVG`。如果预设不存在，则不启用任何视觉效果。

> ✅ 两种方案完全独立，可以随时切换。

## 🖼️ 预设效果预览（原帖截图）

以下为原版预设的实机截图，展示了不同光照下的视觉差异：

### 🌙 Preset Night

![Night 1](https://cdn.discordapp.com/attachments/799963847842070568/799987928565678120/unknown.png)
![Night 2](https://cdn.discordapp.com/attachments/799963847842070568/800000645703794688/unknown.png)
![Night 3](https://cdn.discordapp.com/attachments/799963847842070568/800001895249739786/unknown.png)
![Night 4](https://cdn.discordapp.com/attachments/799963847842070568/800075716334845952/unknown.png)
![Night 5](https://cdn.discordapp.com/attachments/799963847842070568/800075843278995496/unknown.png)

### ☀️ Preset Bright Night

![Bright Night 1](https://cdn.discordapp.com/attachments/799963847842070568/800027108066983986/unknown.png)
![Bright Night 2](https://cdn.discordapp.com/attachments/799963847842070568/800027233296187392/unknown.png)

### 🌅 Preset Morning

![Morning 1](https://cdn.discordapp.com/attachments/799963847842070568/800083453579231292/Client_Screenshot_2021.01.16_-_20.23.56.55.png)
![Morning 2](https://cdn.discordapp.com/attachments/799963847842070568/800092188288876554/Client_Screenshot_2021.01.16_-_20.58.05.46.png)
![Morning 3](https://cdn.discordapp.com/attachments/799963847842070568/800094068323123210/Client_Screenshot_2021.01.16_-_21.07.41.64.png)
![Morning 4](https://cdn.discordapp.com/attachments/799963847842070568/800094333159997470/Client_Screenshot_2021.01.16_-_21.09.03.09.png)

### 🌆 Preset Evening

![Evening 1](https://cdn.discordapp.com/attachments/799963847842070568/799963940088053760/unknown.png)
![Evening 2](https://cdn.discordapp.com/attachments/799963847842070568/799977404390965278/unknown.png)
![Evening 3](https://cdn.discordapp.com/attachments/799963847842070568/799972039539949598/unknown.png)
![Evening 4](https://cdn.discordapp.com/attachments/799963847842070568/799971215510601728/unknown.png)

## 🧪 兼容性与依赖

| 项目 | 说明 |
|---|---|
| **VEManager** | 需要 `0.5.7` 或更高版本 |
| **fun-bots** | ✅ 完全兼容 |
| **VU 版本** | 推荐使用最新稳定版；如需使用 VEEditor，请降级至 `20079` |
| **UI** | 已修复 20079+ 版本的 UI 失效问题 |

## 🛠 进阶：使用 VEEditor 编辑预设

如果你想**自己微调或创建新的视觉预设**（比如修改亮度、雾效、色调等），可以使用 **VEEditor**。

### 🔗 VEEditor 是什么？

> VEEditor 是一个可视化编辑器，用于创建和修改 VEManager 可加载的 VE 预设文件。  
> GitHub 地址：[https://github.com/BF3RM/VEEditor](https://github.com/BF3RM/VEEditor)

它可以让你在游戏内**实时调整**光照、雾、色彩校正等参数，然后直接保存为 `.lua` 预设文件。

### ⚠️ 重要兼容性提醒

由于 VU 版本更新，**VEEditor 在最新版 VU 上可能无法正常工作**。  
如果你需要编辑预设，**建议将 VU 服务端/客户端降级到 `20079` 版本**，在该版本下 VEEditor 可以正常使用。  
降级方法请参考 VU 社区的相关教程。

> 📌 本模组自带的预设文件（Night、NVG、Morning 等）已经配置完善，多数用户**无需使用 VEEditor**。

## 📝 版本历史

- **v1.2.0（当前版本）** – 完整配置系统重构：支持两种模式 + 随机池、NVG 全参数可配置、MAPS 备选方案、载具灯光新增、Yell 提示增强、预设命名规范澄清
- **v1.1.0** – 上一版本（配置系统初步迁移）
- **v1.0.0** – 原版（Lesley & IllustrisJack）

## 🙏 致谢 & 链接

- **原始作者**：Lesley 与 IllustrisJack
- **配置系统扩展 & 夜视仪重构**：AugustaKit
- **灵感来源**：《叛乱：沙漠风暴》（Insurgency: Sandstorm）Nightfall 更新

### 🔗 相关链接

- GitHub 仓库：[https://github.com/VU-PINK/Darkness-Unleashed](https://github.com/VU-PINK/Darkness-Unleashed)
- VU 社区讨论帖：[https://community.veniceunleashed.net/t/darkness-unleashed-...](https://community.veniceunleashed.net/t/darkness-unleashed-a-true-dark-night-mod-and-more-v1-0-0-v1-0-9-in-testing/2298)
- VEEditor（预设编辑器）：[https://github.com/BF3RM/VEEditor](https://github.com/BF3RM/VEEditor)
- 原模组仓库（IllustrisJack）：[https://github.com/IllustrisJack/Darkness-Unleashed](https://github.com/IllustrisJack/Darkness-Unleashed)

---

> 🖤 **Enjoy the darkness.**
> 
> 如果有任何问题、建议或想要参与开发，请在 GitHub 提交 Issue，或通过社区帖子 / Discord 联系我们。