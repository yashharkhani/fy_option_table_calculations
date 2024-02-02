# OptionChainTable

## Overview

The `OptionChainTable` library is a Flutter-based solution designed to display financial option chains in a two-dimensional, scrollable table. It is optimized for performance and flexibility, catering to large datasets with dynamic content sizes. The library includes several key components: `OptionChainTable`, `OptionChainDimensionAnalyzer`, `OptionChainTwoDimensionalDivisionScroller`, `IndexRangeMapper`, and custom render objects, which work together to provide a smooth and efficient user experience.

## Key Components

### OptionChainTable Widget

The centerpiece of the library, `OptionChainTable`, displays the option chain data. It initializes with a controller and dimensions, and internally uses `OptionChainDimensionAnalyzer` for layout calculations and `OptionChainTwoDimensionalDivisionScroller` for rendering the table.

### OptionChainDimensionAnalyzer

This class computes the dimensions of the table based on the content. It divides the available space into columns and calculates each column's required width to optimize space usage and maintain a user-friendly layout.

#### Underlying Mathematics

- **Space Division**: The total available width is divided among the left, middle, and right columns. The width allocated to the middle column is based on its content, while the remaining space is equally divided between the left and right columns.
- **Column Width Calculation**: For each column, the maximum width needed to render the content without truncation is calculated. This ensures that all data is visible and legibly presented.

### OptionChainTwoDimensionalDivisionScroller

Implements a custom scrolling mechanism that allows users to navigate through the option chain data both horizontally and vertically. This component is essential for handling large datasets efficiently.

### IndexRangeMapper and Range

`IndexRangeMapper` is a utility class that maps numerical values to specific ranges. This is crucial for identifying which rows and columns of data are visible in the viewport, based on scroll positions.

#### Underlying Mathematics

- **Binary Search**: To find a value's corresponding range, `IndexRangeMapper` performs a binary search. This algorithm is efficient for sorted data, providing quick access to the required range.

- **Range Representation**: Each range is defined as `[startRange, endRange)`, including the start value but excluding the end. This convention simplifies calculations for boundary conditions.

### Custom Render Objects

The library defines custom render objects to manage the rendering of the option chain table. These objects are optimized for performance, using Flutter's rendering pipeline to efficiently layout and paint the table based on the calculated dimensions and current scroll positions.

## Usage Example

```dart
OptionChainTable optionChainTable = OptionChainTable(
    tableWidth: 600.0,
    tableHeight: 400.0,
    optionChainController: OptionChainController(),
);
```

---

# Mathematical Foundations of the OptionChainTable Library

This document outlines the simplified mathematical concepts used in the `OptionChainTable` library's rendering and layout computation mechanisms.

## 1. Dimension Analysis

### Space Division Formula

Given:

- `W_total` = Total width available for the table.
- `W_middle` = Width required by the middle column, calculated based on its content.

The available space for left and right columns is calculated as:

```
W_available = (W_total - W_middle) / 2
```

### Column Width Calculation

For each column, the width is the maximum width of all cells in the column:

```
W_column = max(width of all cells in the column)
```

## 2. IndexRangeMapper Calculations

### Binary Search Algorithm

To find the corresponding range index `i` for a scroll position `S`, ensuring:

```
R[i].start <= S < R[i].end
```

Where `R[i].start` and `R[i].end` represent the start and end of the range for index `i`, respectively.

### Range Mapping

The mapping of a value `V` to a range index is determined by locating which range `V` falls into.

## 3. Rendering Calculations

### Layout Computation

Determining which cells are visible based on the viewport size and scroll position:

Given:

- `H_viewport` = Height of the viewport.
- `W_viewport` = Width of the viewport.
- `S_x` = Horizontal scroll position.
- `S_y` = Vertical scroll position.

The visible range of rows `R_visible` and columns `C_visible` are calculated as follows:

```
R_visible = [S_y / H_cell, (S_y + H_viewport) / H_cell]
C_visible = Find using IndexRangeMapper based on S_x and W_viewport
```

Where `H_cell` is the height of each cell.

### Optimizations

To ensure efficiency, only cells within `R_visible` and `C_visible` are rendered, minimizing resource usage.

### Linear Transformation for Strike Position Rendering

The purpose of this transformation is to calculate the precise screen position (`strikeRenderPosition`) for the strike indicator, ensuring it accurately reflects the strike's position within the scrolled option chain table.

Given:

- `strikePosition` as the vertical position of the strike from the top of the table, calculated as `(strikeIndex + 1) * cellHeight`.
- The viewport's vertical scroll offset (`S_y`), which indicates how far the table has been scrolled vertically.
- The viewport's height (`H_viewport`), representing the visible portion of the table.

The goal is to map `strikePosition` from the data space (the entire table height) to the screen space (the viewport).

### Calculating the Strike Render Position

1. **Determine if the Strike is Within the Viewport**: First, check if the strike position falls within the current vertical scroll range of the viewport:

   - If `strikePosition < S_y`, the strike is above the viewport and not visible.
   - If `strikePosition > S_y + H_viewport`, the strike is below the viewport and not visible.

2. **Perform the Linear Transformation**: If the strike is within the viewport, we perform a linear transformation to find its position relative to the viewport top. This transformation takes the form of a mapping from the data coordinate system (the entire table) to the screen coordinate system (the viewport).

   The formula for `strikeRenderPosition` within the viewport is:

   ```
   strikeRenderPosition = (strikePosition - S_y) / H_viewport * viewportHeight
   ```

   This formula effectively maps the strike position from the table's coordinate system to the viewport's coordinate system, scaling the position proportionally to the viewport's height.

### Example

Assuming a viewport height of 400 pixels, a cell height of 20 pixels, a strike index of 50, and the current vertical scroll position (`S_y`) of 400 pixels:

- Calculate the `strikePosition` as `(50 + 1) * 20 = 1020` pixels from the top of the table.
- If the user has scrolled down 400 pixels (`S_y = 400`), the `strikePosition` relative to the viewport's top would be `1020 - 400 = 620` pixels.

If the viewport can only show 400 pixels of content at a time, and assuming the strike position (1020) is within the range of `S_y` and `S_y + H_viewport`, the strike indicator would be positioned at 620 pixels from the top of the viewport, assuming no scaling is needed. If scaling or additional adjustments are required based on the viewport height or other factors, the linear transformation would adjust `strikeRenderPosition` accordingly.
