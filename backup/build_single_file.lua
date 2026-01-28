-- 构建脚本：将项目的所有模块合并到一个文件中
local function read_file(path)
    local file = io.open(path, "r")
    if not file then
        error("无法打开文件: " .. path)
    end
    local content = file:read("*all")
    file:close()
    return content
end

local function file_exists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

local function clean_and_write(content, output_path)
    -- 如果文件存在，先删除它
    if file_exists(output_path) then
        os.remove(output_path)
        print("已清理旧的目标文件: " .. output_path)
    end
    
    -- 创建新文件并写入内容
    local file = io.open(output_path, "w")
    if not file then
        error("无法创建输出文件: " .. output_path)
    end
    file:write(content)
    file:close()
end

-- 读取所有模块
local header_comment = "-- 合并后的 AcSmallBubble 项目\n-- 此文件由 build_single_file.lua 自动生成\n\n"
local config_module = read_file("config.lua")
local vehicle_data_module = read_file("vehicle_data.lua")
local chat_bubble_renderer_module = read_file("chat_bubble_renderer.lua")
local collision_detector_module = read_file("collision_detector.lua")
local audio_manager_module = read_file("audio_manager.lua")
local main_module = read_file("AcSmallBubble.lua")

-- 替换 require 调用为模块内容
local combined = header_comment .. 
    config_module:gsub("^.-\n", ""):gsub("return config", "") .. "\n\n" ..
    vehicle_data_module:gsub("^.-\n", ""):gsub("local config = require%('config'%)", ""):gsub("return vehicle_data", "") .. "\n\n" ..
    chat_bubble_renderer_module:gsub("^.-\n", ""):gsub("local config = require%('config'%)", ""):gsub("local vehicle_data = require%('vehicle_data'%)", ""):gsub("return chat_bubble_renderer", "") .. "\n\n" ..
    collision_detector_module:gsub("^.-\n", ""):gsub("local config = require%('config'%)", ""):gsub("local audio_manager = require%('audio_manager'%)", ""):gsub("return collision_detector", "") .. "\n\n" ..
    audio_manager_module:gsub("^.-\n", ""):gsub("local config = require%('config'%)", ""):gsub("return audio_manager", "") .. "\n\n" ..
    main_module:gsub("local config = require%('config'%)", ""):gsub("local vehicle_data = require%('vehicle_data'%)", ""):gsub("local chat_bubble_renderer = require%('chat_bubble_renderer'%)", ""):gsub("local collision_detector = require%('collision_detector'%)", ""):gsub("local audio_manager = require%('audio_manager'%)", "")

-- 清理并写入合并后的文件
clean_and_write(combined, "AcSmallBubble_combined.lua")

print("项目已成功合并到 AcSmallBubble_combined.lua")