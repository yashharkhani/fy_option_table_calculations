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
