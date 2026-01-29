--- 配置模块
local config = {}

--- 渲染配置
config.render = {
    --- 最大显示距离（超过此距离将不再显示）
    maxDistance = 100,

    --- 最小缩放比例（最远距离时的缩放）
    minScale = 0.3,

    --- 最大缩放比例（最近距离时的缩放）
    maxScale = 1,

    --- 基础画布宽度
    baseWidth = 1200,

    --- 基础画布高度
    baseHeight = 500,

    --- 驾驶员名字字体大小
    driverNameFontSize = 52,

    --- 距离字体大小
    distanceFontSize = 42,

    --- 驾驶员名字显示区域大小
    driverNameArea = vec2(1000, 60),

    --- 距离显示区域大小
    distanceArea = vec2(1000, 40)
}

--- UI标签配置
config.ui = {
    --- 驾驶员标签大小
    driverTagSize = vec2(1000, 500)
}

config.images = {
    A = 'http://youke.xn--y7xa690gmna.cn/s1/2026/01/28/69797247a03ff.webp', -- 默认显示图像A（距离大于15米）
    B = 'http://youke.xn--y7xa690gmna.cn/s1/2026/01/28/697972490f343.webp', -- 距离5-15米显示图像B
    C = 'http://youke.xn--y7xa690gmna.cn/s1/2026/01/28/69797249dbbc5.webp', -- 距离5米以内显示图像C
}

config.localImageAssets = {
    A = "",
    B = "",
    C = ""
}

--- 车辆的距离
config.carDistance = {
    near = 5,
    mid = 10,
    far = 15,
}

for k, v in pairs(config.images) do
    web.loadRemoteAssets(v, function(error, folder)
        ac.debug("loadRemoteAssets folder", folder)
        config.localImageAssets[k] = folder
    end)
end



return config
