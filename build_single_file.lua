--- 构建脚本：将 src 目录中的模块合并成一个文件
--- 使用虚拟模块系统实现，无需修改源码中的 require/return

local function read_file(filepath)
    local file = io.open(filepath, "r")
    if not file then
        error("无法打开文件: " .. filepath)
    end
    
    local content = file:read("*all")
    file:close()
    
    return content
end

local function write_file(filepath, content)
    local file = io.open(filepath, "w")
    if not file then
        error("无法写入文件: " .. filepath)
    end
    
    file:write(content)
    file:close()
end

local function build()
    print("开始构建单文件版本...")

    -- 定义模块列表 (文件名 -> 模块名)
    -- 注意：顺序不重要，因为我们使用的是模块预加载机制
    local modules = {
        { path = "./src/config.lua", name = "config" },
        { path = "./src/utils.lua", name = "utils" },
        { path = "./src/driverTable.lua", name = "driverTable" },
        { path = "./src/render.lua", name = "render" }
        -- main.lua 单独处理，作为入口
    }
    
    local output_content = {}
    table.insert(output_content, "-- Auto-generated single file build")
    table.insert(output_content, "-- Generated at " .. os.date("%Y-%m-%d %H:%M:%S"))
    table.insert(output_content, "")
    
    -- 1. 添加微型模块加载器
    table.insert(output_content, [[
-- Virtual Module System
local __modules__ = {}
local __module_cache__ = {}

local function __require__(name)
    if __module_cache__[name] then
        return unpack(__module_cache__[name])
    end
    if __modules__[name] then
        local ret = { __modules__[name]() }
        __module_cache__[name] = ret
        return unpack(ret)
    end
    -- Fallback to system require if not found in bundle (optional, ac lua usually doesn't need this for internal files)
    return require(name)
end

-- Override global require (or just use local replacement if preferred, but global is easier for existing code)
local _original_require = require
require = __require__
]])

    -- 2. 包装并写入每个模块
    for _, mod in ipairs(modules) do
        print("Processing module: " .. mod.name)
        local content = read_file(mod.path)
        
        table.insert(output_content, string.format("-- Module: %s", mod.name))
        table.insert(output_content, string.format("__modules__['%s'] = function()", mod.name))
        table.insert(output_content, content)
        table.insert(output_content, "end\n")
    end

    -- 3. 写入入口文件 main.lua
    print("Processing entry: main.lua")
    local main_content = read_file("./src/main.lua")
    table.insert(output_content, "-- Entry Point: main.lua")
    table.insert(output_content, "(function()")
    table.insert(output_content, main_content)
    table.insert(output_content, "end)()")

    -- 连接所有内容
    local final_content = table.concat(output_content, "\n")
    
    -- 写入输出文件
    local output_file = "./AcSmallBubble.lua"
    print("正在写入合并后的文件: " .. output_file)
    write_file(output_file, final_content)
    
    print("构建完成! 输出文件: " .. output_file)
end

-- 执行构建
build()