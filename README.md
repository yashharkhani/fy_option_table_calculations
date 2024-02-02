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

Include `optionChainTable` in your widget tree to display the table.

Creating a detailed mathematical documentation to accompany the `OptionChainTable` library involves elaborating on the formulas and calculations used within the rendering and dimension analysis components. This document will focus on the underlying math used in `OptionChainDimensionAnalyzer`, `IndexRangeMapper`, and the custom rendering logic, which are pivotal for the dynamic layout computation and efficient rendering of the option chain table.

---

# Mathematical Foundations of the OptionChainTable Library

This section outlines the mathematical concepts and formulas underlying the `OptionChainTable` library's rendering and layout computation mechanisms. It aims to provide clarity on how dimensions are calculated, how data is mapped to screen space, and the optimizations that ensure efficient rendering.

## 1. Dimension Analysis

The `OptionChainDimensionAnalyzer` class calculates the space each column in the table should occupy based on the content size and available viewport dimensions.

### Space Division Formula

Given:

- \(W\_{total}\) = Total width available for the table.
- \(W\_{middle}\) = Width required by the middle column, calculated based on its content.

The available space for left and right columns is calculated as:

- \(W*{available} = \frac{W*{total} - W\_{middle}}{2}\)

### Column Width Calculation

For each column:

- \(W\_{column} = \max(\text{width of all cells in the column})\)

## 2. IndexRangeMapper Calculations

The `IndexRangeMapper` class maps scroll positions to indices in the data set, using binary search for efficient lookup.

### Binary Search Algorithm

Given a scroll position \(S\), the algorithm finds the corresponding range index \(i\) such that:

- \(R*{i}.start \leq S < R*{i}.end\)

Where:

- \(R\_{i}.start\) = Start of the range for index \(i\).
- \(R\_{i}.end\) = End of the range for index \(i\).
- \(R\) = List of all ranges sorted by their start.

### Range Mapping

The mapping of a value \(V\) to a range index follows:

- If \(V\) is within the bounds of \(R\_{i}\), then \(i\) is the index of the range that \(V\) maps to.

## 3. Rendering Calculations

### Layout Computation

For efficient rendering, the layout computation takes into account the viewport size and the scroll position to determine which cells are visible.

Given:

- \(H\_{viewport}\) = Height of the viewport.
- \(W\_{viewport}\) = Width of the viewport.
- \(S_x\) = Horizontal scroll position.
- \(S_y\) = Vertical scroll position.

The visible range of rows (\(R*{visible}\)) and columns (\(C*{visible}\)) are calculated as:

- \(R*{visible} = \left[\frac{S_y}{H*{cell}}, \frac{S*y + H*{viewport}}{H\_{cell}}\right]\)
- \(C*{visible} = \text{Find using } IndexRangeMapper \text{ based on } S_x \text{ and } W*{viewport}\)

Where:

- \(H\_{cell}\) = Height of each cell in the table.

### Optimizations

To minimize layout computations and redraws:

- Only cells within \(R*{visible}\) and \(C*{visible}\) are laid out and rendered.
- Cells outside the visible range are not rendered, conserving resources.
