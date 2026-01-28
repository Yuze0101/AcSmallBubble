--- 构建脚本：将 src 目录中的模块合并成一个文件
--- 根据 Lua 项目构建与文件合并规范，实现源码合并功能

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
    
    -- 读取各个模块的内容
    local utils_content = read_file("./src/utils.lua")
    local driver_table_content = read_file("./src/driverTable.lua")
    local render_content = read_file("./src/render.lua")
    local main_content = read_file("./src/main.lua")
    
    -- 构建最终输出内容
    local output_content = "-- Auto-generated single file build\n"
    output_content = output_content .. "-- Generated at " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
    output_content = output_content .. "-- Original modules combined: utils, driverTable, render, main\n\n"
    
    -- 定义全局变量
    output_content = output_content .. "-- Define globals\n"
    output_content = output_content .. "Sim = nil\n\n"
    
    -- 添加 driverTable 模块内容（移除 return 语句）
    output_content = output_content .. "-- Module: driverTable\n"
    -- 移除 return 语句（根据实际的return语句格式）
    driver_table_content = driver_table_content:gsub("\nreturn driverTable, updateDriverTableData", "")
    output_content = output_content .. driver_table_content .. "\n\n"
    
    -- 添加 utils 模块内容（移除 require 语句）
    output_content = output_content .. "-- Module: utils\n"
    -- 移除 require 语句
    utils_content = utils_content:gsub('local%s+driverTable%s*=%s*require%s+"driverTable"%s*\n?', '')
    -- 移除 return 语句
    utils_content = utils_content:gsub('\nreturn calculateDistance', '')
    -- 修改utils中的函数，使用pairs而不是ipairs，因为driverTable是用索引作为key的
    utils_content = utils_content:gsub('for index, driverData in ipairs%(driverTable%) do', 'for index, driverData in pairs(driverTable) do')
    output_content = output_content .. utils_content .. "\n\n"
    
    -- 添加 render 模块内容（移除 require 语句）
    output_content = output_content .. "-- Module: render\n"
    -- 移除 require 语句
    render_content = render_content:gsub('local%s+driverTable,%s+updateDriverTableData,%s+deleteDriverTableData%s*=%s*require%s+"driverTable"%s*\n?', '')
    render_content = render_content:gsub('local%s+driverTable%s*=%s*require%s+"driverTable"%s*\n?', '')
    -- 移除 return 语句
    render_content = render_content:gsub('\nreturn renderCustom', '')
    output_content = output_content .. render_content .. "\n\n"
    
    -- 添加 main 模块内容，移除 require 语句
    output_content = output_content .. "-- Main module:\n"
    -- 移除 main 模块中的所有 require 语句及相关类型注解
    main_content = main_content:gsub('local%s+renderCustom%s*=%s*require%s+"render"%s*\n?', '')
    main_content = main_content:gsub('local%s+calculateDistance%s*=%s*require%s+"utils"%s*\n?', '')
    main_content = main_content:gsub('local%s+driverTable,%s+updateDriverTableData,%s+deleteDriverTableData%s*=%s*require%s+"driverTable"[^\n]*\n', '')
    main_content = main_content:gsub('@.-require "driverTable"[^\n]*\n', '')
    output_content = output_content .. main_content
    
    -- 写入输出文件
    local output_file = "./AcSmallBubble_combined.lua"
    print("正在写入合并后的文件: " .. output_file)
    write_file(output_file, output_content)
    
    print("构建完成! 输出文件: " .. output_file)
end

-- 执行构建
build()