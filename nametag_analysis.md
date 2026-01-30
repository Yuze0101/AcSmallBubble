# NameTag Logic Analysis

This document analyzes the logic for rendering the NameTag (bubble) above cars, specifically focusing on canvas size, content arrangement, and centering logic.

## 1. Canvas Dimensions & Coordinate System

Based on `src/config.lua`:

- **Base Canvas Size**: The canvas used for drawing the nametag content has a fixed resolution defined in config:
  - Width: `config.render.baseWidth` = **1200**
  - Height: `config.render.baseHeight` = **500**

- **Coordinate System**:
  - `(0, 0)` is the top-left corner of the canvas.
  - X axis: 0 to 1200
  - Y axis: 0 to 500

## 2. Driver Name Rendering

Located in `src/render.lua` -> `renderName(carInfo)`:

- **Font Size**: `config.render.driverNameFontSize` = **52**
- **Area Definition**: `config.render.driverNameArea` = `vec2(1000, 60)`
- **Alignment**:
  - `ui.Alignment.Center` (Horizontal)
  - `ui.Alignment.Center` (Vertical)
- **Centering Logic**:
  - The text is drawn inside a box of size 1000x60.
  - The `ui.dwriteTextAligned` function handles the centering within this box.
  - **Implicit Centering Issue**: The code does *not* explicitly specify the position (top-left) of this 1000x60 box in `ui.dwriteTextAligned`.
    - If `p1` (position) is omitted or defaults to current cursor, it might be drawn at `(0,0)`.
    - Since the canvas is 1200 wide and the text area is 1000 wide, if drawn at X=0, it would be left-aligned relative to the canvas (0-1000), leaving 200px empty on the right.
    - **Correction Needed**: To be perfectly centered on a 1200px canvas, the 1000px text box should start at X = `(1200 - 1000) / 2 = 100`.

## 3. Distance Text Rendering

Located in `src/render.lua` -> `renderDistance(distance)`:

- **Font Size**: `config.render.distanceFontSize` = **42**
- **Area Definition**: `config.render.distanceArea` = `vec2(1000, 40)`
- **Alignment**:
  - `ui.Alignment.Center` (Horizontal)
  - `ui.Alignment.Center` (Vertical)
- **Centering Logic**:
  - Similar to the name, it uses a 1000px wide box.
  - Likely faces the same potential off-center issue if the box position isn't explicitly calculated to be `(1200 - 1000) / 2`.

## 4. Image Rendering (Bubble)

Located in `src/render.lua` -> `renderImage(distance)`:

- **Image Source**: Selects image A, B, or C based on distance.
- **Sizing Logic**:
  - **Target Width**: Fixed at **800** pixels (`local width = 800`).
  - **Target Height**: Calculated to maintain aspect ratio (`size.y / size.x * width`).
- **Centering Calculation**:
  ```lua
  local screenWidth = config.render.baseWidth  -- 1200
  local posX = (screenWidth - width) / 2       -- (1200 - 800) / 2 = 200
  local posY = screenHeight - height - 20      -- 20 pixels from bottom
  ```
  - **Analysis**: The calculation `(screenWidth - width) / 2` correctly centers the image horizontally on the 1200px canvas.
  - **Position**: `posX` will be 200. The image spans from X=200 to X=1000.

## 5. Final Composition

The `renderCustom` function draws everything onto the canvas:
1. Clears canvas.
2. Draws Name.
3. Draws Distance.
4. Draws Image.

After the canvas is prepared:
- It is drawn into the world using `ui.drawImage(canvas, p1, p2, ...)`
- **World Positioning**:
  - `calculateDrawPosition(scale)` in `src/utils.lua` determines where the canvas appears in 3D space above the car.
  - The canvas itself is scaled based on distance (`calculateScaleByDistance`).

## Summary of Centering Logic

| Element | Width | Canvas Width | Centering Method | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Image** | 800 | 1200 | Explicit Math: `(1200-800)/2` | ✅ **Correct** |
| **Name** | 1000 | 1200 | `ui.dwriteTextAligned` box | ⚠️ **Potential Offset** (Checks needed if box starts at X=0) |
| **Distance** | 1000 | 1200 | `ui.dwriteTextAligned` box | ⚠️ **Potential Offset** (Checks needed if box starts at X=0) |

**Recommendation for Name/Distance**:
To ensure text is perfectly centered relative to the image and canvas, rendering calls should explicitely set the standard position:
```lua
-- Example fix for centering text box
local x_offset = (config.render.baseWidth - config.render.driverNameArea.x) / 2
ui.setCursor(vec2(x_offset, Y_POSITION)) -- Set cursor before drawing if strictly checking relative pos
-- OR pass the rect explicitly to the draw command if supported
```
*Note: If `ui.dwriteTextAligned` draws relative to the current cursor position and the cursor is at (0,0), then the text block (1000px) is technically not centered in the 1200px canvas, it's shifted left.*
