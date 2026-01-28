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

-- 图片资源配置

-- https://youke.xn--y7xa690gmna.cn/s1/2026/01/28/69797247a03ff.webp
-- https://youke.xn--y7xa690gmna.cn/s1/2026/01/28/697972490f343.webp
-- https://youke.xn--y7xa690gmna.cn/s1/2026/01/28/69797249dbbc5.webp

config.images = {
    A = 'https://youke.xn--y7xa690gmna.cn/s1/2026/01/28/69797247a03ff.webp',  -- 默认显示图像A（距离大于15米）
    B = 'https://youke.xn--y7xa690gmna.cn/s1/2026/01/28/697972490f343.webp',  -- 距离5-15米显示图像B
    C = 'https://youke.xn--y7xa690gmna.cn/s1/2026/01/28/69797249dbbc5.webp',  -- 距离5米以内显示图像C
    AMD = 'Images/amd.gif'  -- AMD图标
}

return config