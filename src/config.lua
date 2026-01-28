--- 配置模块
local config = {}

--- 渲染配置
config.render = {
    --- 最大显示距离（超过此距离将不再显示）
    maxDistance = 100,

    --- 最小缩放比例（最远距离时的缩放）
    minScale = 0.3,

    --- 最大缩放比例（最近距离时的缩放）
    maxScale = 1.5,

    --- 基础画布宽度
    baseWidth = 1200,

    --- 基础画布高度
    baseHeight = 240,

    --- 中心X坐标
    centerX = 1000,

    --- 中心Y坐标
    centerY = 100
}

return config
