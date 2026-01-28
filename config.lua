-- 配置模块
local config = {}

-- 聊天气泡配置
config.bubble = {
    distance = 300,  -- 米
    nearRange = 0.8, -- 显示完整气泡
    midRange = 0.55, -- 显示部分气泡
    farRange = 0.3,  -- 完全隐藏气泡
    duration = 5,    -- 消息显示持续时间（秒）
}

-- 渲染配置
config.render = {
    fpsTarget = 30,  -- 目标渲染帧率
}

-- 碰撞检测配置
config.collision = {
    cooldown = 0.5,  -- 碰撞响应冷却时间（秒）
}

-- 车辆距离阈值配置
config.distance_thresholds = {
    close = 5,       -- ≤ 5m
    medium = 10,     -- 5m ~ 10m
    far = 15,        -- > 10m
}

-- 撞击动画配置
config.animation = {
    duration = 0.3,  -- 撞击动画持续时间（秒）
}

return config