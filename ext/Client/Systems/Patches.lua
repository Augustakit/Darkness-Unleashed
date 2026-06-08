Events:Subscribe('Level:Loaded', function(levelName, gameMode)
    --Patch https://github.com/EmulatorNexus/Venice-EBX/blob/f06c290fa43c80e07985eda65ba74c59f4c01aa0/Weapons/Accessories/flashlight/Flashlight_1p.txt
    PatchFlashLight(ResourceManager:FindInstanceByGuid(Guid('83E2B938-E678-11DF-A7B3-CBA49C34928F'),
        Guid('995E49EE-8914-4AFD-8EF5-59125CA8F9CD')))
    --Patch https://github.com/EmulatorNexus/Venice-EBX/blob/f06c290fa43c80e07985eda65ba74c59f4c01aa0/Weapons/Accessories/flashlight/Flashlight_3p.txt
    PatchFlashLight(ResourceManager:FindInstanceByGuid(Guid('65A5BFD9-028A-4D4F-8B89-3A60B2E06F83'),
        Guid('5FBA51D6-059F-4284-B5BB-6E20F145C064')))

    AllowMoreSpotlights()
end)

Events:Subscribe('Partition:Loaded', function(partition)
    PatchEmitters(partition)
end)

--作用：专门针对手电筒光源实例（1P/3P 模型上的 SpotLight）修改光学参数。
function PatchFlashLight(instance)
    if instance == nil then
        return
    end

    instance = SpotLightEntityData(instance)
    instance:MakeWritable()
    instance.radius = 75  --30 照射半径
    instance.intensity = 9 -- 20 亮度
    instance.coneOuterAngle = 50  -- 32.37200164794922 聚光灯的外锥角（度数） 控制光束的扩散范围，越大范围越广但是亮度会衰减快。
    instance.orthoWidth = 40  --5.0 正交投影模式下光源照射的宽 在手电筒上用到相对少，但改大会让照亮范围更大
    instance.orthoHeight = 40  --5.0 正交投影模式下光源照射的高 在手电筒上用到相对少，但改大会让照亮范围更大
    instance.frustumFov = 40 --20 光锥的视觉角度（Field of View），改大会让手电范围更开阔。
    instance.castShadowsEnable = true  --是否投射阴影 
    instance.castShadowsMinLevel = 0  --3 MinLevel 控制最小阴影质量等级（0=最低）从0到3从低往高排 
    instance.shape = 1 --1 0为圆锥体 1为平顶锥体 2为长方体

    instance = LocalLightEntityData(instance)
    instance:MakeWritable()
    instance.attenuationOffset = 250 --250 衰减偏移量，控制光强衰减的起始位置。增大后，手电光可以更远距离保持高亮
end

function PatchComponents(partition)
    for _, instance in pairs(partition.instances) do
        if instance:Is('LocalLightEntityData') then
            PatchHDLights(instance)
        end
    end
end

--作用：针对地图中多数静态 / 动态 点光源（LocalLightEntityData），扩大范围、调整亮度、开启全局光照。
function PatchHDLights(instance)
    instance = LocalLightEntityData(instance)
    instance:MakeWritable()
    --instance.visible = true -- true 取消注释会强制光源可见
    instance.specularEnable = true --true 启用镜面反射（让物体表面有高光反射）。
    instance.radius = instance.radius * 1.5 --半径扩大 1.5 倍，光照范围更大
    instance.intensity = instance.intensity * 0.65 --光强下降为原来的 65%（因为范围加大，亮度适当降低以避免过曝）
    instance.enlightenColorMode = 0 --全局光照的颜色模式 0=默认 0是保留物体原有颜色/纹理，但通过光照颜色进行调制 1是完全覆盖原始颜色，忽略物体表面的原有颜色或纹理
    instance.enlightenEnable = true --启用 Enlighten 动态全局光照（可以影响全局反射与间接照明）
    instance.attenuationOffset = instance.attenuationOffset * 17.5 --把衰减偏移放大 17.5 倍 → 光线保持较高亮度的距离大幅增加。

    if instance.typeInfo.name == 'SpotLightEntityData' then
        PatchSpotlights(instance)
    end
end
--针对 SpotLight 光源做二次修改，调阴影和角度。
function PatchSpotlights(instance)
    instance = SpotLightEntityData(instance)
    instance:MakeWritable()

    instance.castShadowsEnable = true
    instance.castShadowsMinLevel = 3 --开阴影，只有高等级阴影质量才会渲染
    instance.coneInnerAngle = instance.coneInnerAngle * 1 
    instance.coneOuterAngle = instance.coneOuterAngle * 2
end

--WorldRenderSettings‌ 是一个全局配置类或数据结构，用于定义 ‌整个场景的渲染参数‌，通常包含光照、环境、后期处理等核心视觉效果的设置。
--DebrisSystemSettings‌ 是一组用于控制 ‌碎片/粒子系统行为‌ 的参数集合，通常用于模拟物体破碎、爆炸、环境互动（如子弹击中墙壁溅射的碎石）等动态效果。
function AllowMoreSpotlights()
    local worldRender = ResourceManager:GetSettings('WorldRenderSettings')

    if worldRender ~= nil then
        worldRender = WorldRenderSettings(worldRender)
        worldRender.maxSpotLightShadowCount = 9 --同屏允许的聚光灯投影数量
        worldRender.maxSpotLightCount = 1024 --同屏允许渲染的聚光灯总数（包括不投影的）
        worldRender.shadowmapViewDistance = 75 --投影阴影贴图的最大显示距离
        worldRender.lightOverdrawMaxLayerCount = 256 --强行堆叠的光照层数上限
        print("Patched World Renderer spotlights!")
    end

    local debris = ResourceManager:GetSettings('DebrisSystemSettings')

    if debris ~= nil then
        debris = DebrisSystemSettings(debris)
        debris.meshShadowEnable = false --禁用碎片的网格阴影渲染
        print("Patched debris shadows!")
    end
end

--Configure Smoke, Muzzle & Emmiters
function PatchEmitters(partition)
    for _, instance in pairs(partition.instances) do
        if instance:Is("EmitterTemplateData") then
            local emitterTemplate = EmitterTemplateData(instance)
            emitterTemplate:MakeWritable()
            emitterTemplate.maxCount = emitterTemplate.maxCount * 2 --maxCount → 最多同时存在的粒子数，原来的基础上翻倍
            emitterTemplate.maxSpawnDistance = emitterTemplate.maxSpawnDistance * 2 --MaxSpawnDistance → 粒子生成的最大距离（通常影响你能多远看到这些效果），也翻倍

            -- 调整烟雾和灰尘，使其持续更长时间
            if string.find(emitterTemplate.name:lower(), "smoke" or string.find(emitterTemplate.name:lower(), "dust")) then
                emitterTemplate:MakeWritable()

                if not (emitterTemplate.emissive or emitterTemplate.actAsPointLight or emitterTemplate.repeatParticleSpawning or emitterTemplate.opaque) then
                    if emitterTemplate.rootProcessor:Is("UpdateAgeData") then
                        local rootProcessor = UpdateAgeData(emitterTemplate.rootProcessor)
                    
                        rootProcessor:MakeWritable()
                        rootProcessor.lifetime = rootProcessor.lifetime * 1.2  --粒子存在时长是原来的1.2倍
                        emitterTemplate.lifetime = emitterTemplate.lifetime * 1.2 --粒子发射器存在的时长是原来的1.2倍
                        emitterTemplate.maxCount = emitterTemplate.maxCount * 1.5  --最多同时存在的粒子数，原来的基础上1.5倍
                    end
                end

                -- 使枪口焰火亮起
            elseif string.find(emitterTemplate.name:lower(), "muzz") then
                emitterTemplate:MakeWritable()
                emitterTemplate.actAsPointLight = true  --actAsPointLight = true → 粒子会成为一个点光源（让枪口照亮附近环境）
                emitterTemplate.maxCount = emitterTemplate.maxCount * 2

                if emitterTemplate.pointLightColor == Vec3(1, 1, 1) then --如果默认点光颜色是白色 (1,1,1)，就改为橙色 (1, 0.25, 0) 并调整半径和距离：
                    emitterTemplate.pointLightColor = Vec3(1, 0.25, 0)
                    emitterTemplate.pointLightRadius = emitterTemplate.pointLightRadius * 0.65
                    emitterTemplate.maxSpawnDistance = 3000 --枪口焰能打亮周围，但距离设得特别远（3km）
                end

                -- Make bullets light up 同样给曳光弹增加光源，有橙色光，亮度稍提升，半径多 10%
            elseif string.find(emitterTemplate.name:lower(), "tracer") then
                emitterTemplate:MakeWritable()
                emitterTemplate.actAsPointLight = true
                emitterTemplate.maxCount = emitterTemplate.maxCount * 2

                if emitterTemplate.pointLightColor == Vec3(1, 1, 1) then
                    emitterTemplate.pointLightColor = Vec3(1, 0.25, 0)
                    emitterTemplate.pointLightRadius = emitterTemplate.pointLightRadius * 1.10
                    emitterTemplate.maxSpawnDistance = 3000
                end

                -- Make sparks light up  火花效果
            elseif string.find(emitterTemplate.name:lower(), "spark") then
                emitterTemplate:MakeWritable()
                emitterTemplate.actAsPointLight = true
                emitterTemplate.maxCount = emitterTemplate.maxCount * 1.5 -- --最多同时存在的粒子数，原来的基础上1.5倍

                if emitterTemplate.pointLightColor == Vec3(1, 1, 1) then
                    emitterTemplate.pointLightColor = Vec3(1, 0.25, 0)
                    emitterTemplate.pointLightRadius = emitterTemplate.pointLightRadius * 1.15
                    emitterTemplate.maxSpawnDistance = 3000
                end
            --坦克残骸火
            elseif string.find(emitterTemplate.name:lower(), "wreck/tank/emitters") then
                emitterTemplate:MakeWritable()

                emitterTemplate.maxSpawnDistance = 3000
                emitterTemplate.actAsPointLight = true
                emitterTemplate.repeatParticleSpawning = true  --设置 repeatParticleSpawning = true 让火不断重复生成
                emitterTemplate.maxCount = emitterTemplate.maxCount * 3   --最多同时存在的粒子数，原来的基础上3倍
                emitterTemplate.pointLightRadius = emitterTemplate.pointLightRadius * 1.5
                emitterTemplate.pointLightIntensity = emitterTemplate.pointLightIntensity * 1.5
                emitterTemplate.lifetime = emitterTemplate.lifetime * 3 
                emitterTemplate.forceFullRes = true  --控制这个粒子发射器的渲染是否始终使用全分辨率
                emitterTemplate.repeatParticleSpawning = true

                if emitterTemplate.pointLightColor == Vec3(1, 1, 1) then
                    emitterTemplate.pointLightColor = Vec3(1, 0.25, 0)
                end
                --直升机/汽车残骸火
            elseif string.find(emitterTemplate.name:lower(), "wreck/heli/emitters") or string.find(emitterTemplate.name:lower(), "wreck/car/emitters") then
                emitterTemplate:MakeWritable()

                emitterTemplate.maxSpawnDistance = 3000
                emitterTemplate.actAsPointLight = true
                emitterTemplate.maxCount = emitterTemplate.maxCount * 3  --最多同时存在的粒子数，原来的基础上3倍
                emitterTemplate.pointLightRadius = emitterTemplate.pointLightRadius * 1.75
                emitterTemplate.pointLightIntensity = emitterTemplate.pointLightIntensity * 1.75
                emitterTemplate.forceFullRes = true --控制这个粒子发射器的渲染是否始终使用全分辨率
                emitterTemplate.lifetime = emitterTemplate.lifetime * 3

                if emitterTemplate.pointLightColor == Vec3(1, 1, 1) then
                    emitterTemplate.pointLightColor = Vec3(1, 0.25, 0)
                end
            end
        end
    end
end
