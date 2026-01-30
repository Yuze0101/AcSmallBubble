# NameTag 逻辑分析

本文档分析了车辆上方 NameTag（气泡）的渲染逻辑，重点关注画布尺寸、内容排列和居中逻辑。

## 1. 画布尺寸与坐标系统

基于 `src/config.lua`：

- **基础画布尺寸**：用于绘制 nametag 内容的画布具有固定的分辨率配置：
  - 宽度：`config.render.baseWidth` = **1200**
  - 高度：`config.render.baseHeight` = **500**

- **坐标系统**：
  - `(0, 0)` 为画布左上角。
  - X 轴范围：0 到 1200
  - Y 轴范围：0 到 500

## 2. 车手名字渲染 (Driver Name)

位于 `src/render.lua` -> `renderName(carInfo)`：

- **字体大小**：`config.render.driverNameFontSize` = **52**
- **区域定义**：`config.render.driverNameArea` = `vec2(1000, 60)`
- **对齐方式**：
  - 水平：`ui.Alignment.Center`
  - 垂直：`ui.Alignment.Center`
- **居中逻辑**：
  - 文本在一个 1000x60 的框内绘制。
  - `ui.dwriteTextAligned` 函数负责在该框内居中。
  - **隐性居中问题**：代码*没有*显式指定这个 1000x60 框的起始坐标（左上角位置）。
    - 如果 `p1`（位置）缺失或默认为当前光标位置，它可能会在 `(0,0)` 处绘制。
    - 由于画布宽 1200，而文本区域宽 1000，如果在 X=0 处绘制，相对于 1200 的画布来说，它其实是靠左的（占据 0-1000），右边会留空 200px。
    - **修正建议**：为了在 1200px 的画布上完美居中，这个 1000px 的文本框起始 X 坐标应为 `(1200 - 1000) / 2 = 100`。

## 3. 距离文本渲染 (Distance Text)

位于 `src/render.lua` -> `renderDistance(distance)`：

- **字体大小**：`config.render.distanceFontSize` = **42**
- **区域定义**：`config.render.distanceArea` = `vec2(1000, 40)`
- **对齐方式**：
  - 水平：`ui.Alignment.Center`
  - 垂直：`ui.Alignment.Center`
- **居中逻辑**：
  - 与名字渲染类似，也是使用 1000px 宽的框。
  - 同样存在潜在的未完全居中（偏左）风险，因为框的起始位置可能未显式计算为 `(1200 - 1000) / 2`。

## 4. 图片渲染 (Image/Bubble)

位于 `src/render.lua` -> `renderImage(distance)`：

- **图片源**：根据距离选择 A、B 或 C 图。
- **尺寸逻辑**：
  - **目标宽度**：固定为 **800** 像素 (`local width = 800`)。
  - **目标高度**：根据宽高比自动计算 (`size.y / size.x * width`)。
- **居中计算**：
  ```lua
  local screenWidth = config.render.baseWidth  -- 1200
  local posX = (screenWidth - width) / 2       -- (1200 - 800) / 2 = 200
  local posY = screenHeight - height - 20      -- 距离底部 20 像素
  ```
  - **分析**：`(screenWidth - width) / 2` 这一计算公式正确地将 800px 宽的图片在 1200px 的画布上水平居中了。
  - **位置**：`posX` 结果为 200。图片将绘制在 X=200 到 X=1000 的范围内。

## 5. 最终合成 (Final Composition)

`renderCustom` 函数将所有内容绘制到画布上：
1. 清空画布。
2. 绘制名字。
3. 绘制距离。
4. 绘制图片。

画布准备好后：
- 使用 `ui.drawImage(canvas, p1, p2, ...)` 将其绘制到游戏世界中。
- **世界定位**：
  - `src/utils.lua` 中的 `calculateDrawPosition(scale)` 决定了画布在车辆上方 3D 空间中的显示位置。
  - 画布本身会根据距离进行缩放 (`calculateScaleByDistance`)。

## 居中逻辑总结

| 元素 | 宽度 | 画布宽度 | 居中方法 | 状态 |
| :--- | :--- | :--- | :--- | :--- |
| **图片 (Image)** | 800 | 1200 | 显式数学计算：`(1200-800)/2` | ✅ **正确** |
| **名字 (Name)** | 1000 | 1200 | `ui.dwriteTextAligned` 文本框 | ⚠️ **潜在偏移** (需检查文本框起始是否为 X=0) |
| **距离 (Distance)** | 1000 | 1200 | `ui.dwriteTextAligned` 文本框 | ⚠️ **潜在偏移** (需检查文本框起始是否为 X=0) |

**关于名字/距离的建议**：
为了确保文本相对于图片和画布完美居中，渲染调用应该显式设置起始位置（居中偏移）：
```lua
-- 居中文本框的修复示例
local x_offset = (config.render.baseWidth - config.render.driverNameArea.x) / 2
ui.setCursor(vec2(x_offset, Y_POSITION)) -- 在绘制前设置光标位置
-- 或者如果在 dwriteTextAligned 中支持，直接传入计算后的 rect
```
*注：如果 `ui.dwriteTextAligned` 是相对于当前光标位置绘制，且光标默认在 (0,0)，那么 1000px 的文本块在 1200px 的画布上虽然文本块内部居中了，但整体是偏左的。*
