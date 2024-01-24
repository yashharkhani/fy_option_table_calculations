import 'package:flutter/material.dart';
import 'package:option_chain_renderer/option_chain_table/index_range_mapper.dart';

class OptionChainDimensionAnalyzer {
  double tableWidth;
  double tableHeight;
  final double cellHeight;

  final List<OptionChainColumm> leftColumns;
  final OptionChainColumm middleColumn;
  final List<OptionChainColumm> rightColumns;

  OptionChainDimensionAnalyzer({
    required this.tableWidth,
    required this.tableHeight,
    required this.cellHeight,
    required this.leftColumns,
    required this.middleColumn,
    required this.rightColumns,
  });

  late double _middleColumnWidth;
  late double _lcAvailableSpace;
  late double _rcAvailableSpace;
  late double _lcRequiredSpace;
  late double _rcRequiredSpace;

  double get leftDivisonAvailableSpace => _lcAvailableSpace;
  double get rightDivisionAvailableSpace => _rcAvailableSpace;

  double get middleDivisionAvailableSpace => _middleColumnWidth;

  double get leftDivisionRequiredSpace => _lcRequiredSpace;
  double get rightDivisionRequiredSpace => _rcRequiredSpace;

  late IndexRangeMapper lcIdxRangeMapper;
  late IndexRangeMapper rcIdxRangeMapper;

  void compute() {
    // dividing the available space into three different parts
    _divideSpaces();

    // compute invidual column occupancy space
    _computeIndividualColumnRequiredSpaces();

    print(this);
  }

  void _divideSpaces() {
    _middleColumnWidth = middleColumn.getMaxRenderWidth();
    _lcAvailableSpace = (tableWidth - _middleColumnWidth) / 2;
    _rcAvailableSpace = _lcAvailableSpace;
  }

  void _computeIndividualColumnRequiredSpaces() {
    _lcRequiredSpace = 0;
    List<Range> lcRanges = [];
    for (int idx = 0; idx < leftColumns.length; idx++) {
      num start = _lcRequiredSpace;
      _lcRequiredSpace += leftColumns[idx].getMaxRenderWidth();
      // storing the ranges
      lcRanges.add(Range(
        startRange: start,
        endRange: _lcRequiredSpace,
      ));
    }
    _rcRequiredSpace = 0;
    List<Range> rcRanges = [];
    for (int idx = 0; idx < rightColumns.length; idx++) {
      num start = _rcRequiredSpace;
      _rcRequiredSpace += rightColumns[idx].getMaxRenderWidth();
      // storing the ranges
      rcRanges.add(Range(
        startRange: start,
        endRange: _rcRequiredSpace,
      ));
    }

    lcIdxRangeMapper = IndexRangeMapper(ranges: lcRanges);
    rcIdxRangeMapper = IndexRangeMapper(ranges: rcRanges);
  }

  // recompute on window resize
  void recomputeResize({required double height, required double width}) {
    if (height == tableHeight && width == tableWidth) return;
    tableHeight = height;
    tableWidth = width;
    compute();
  }
}

class OptionChainColumm {
  final List<OptionChainCellData> cells;

  double? maxCellRenderWidth;
  int? maxCellIdx;

  double getMaxRenderWidth() {
    if (maxCellRenderWidth != null) return maxCellRenderWidth!;
    return _computeMaxWidth();
  }

  double _computeMaxWidth() {
    int len = -1;
    for (int idx = 0; idx < cells.length; idx++) {
      int currLen = cells[idx].rawData.length;
      if (currLen > len) {
        maxCellIdx = idx;
        len = currLen;
      }
    }
    maxCellRenderWidth = cells[maxCellIdx!].computeCellRenderWidth();

    return maxCellRenderWidth!;
  }

  OptionChainColumm({required this.cells});
}

class OptionChainCellData {
  final String rawData;
  final TextStyle textStyle;

  double? _renderWidth;

  OptionChainCellData({
    required this.rawData,
    required this.textStyle,
  });

  // compute the widh
  double computeCellRenderWidth() {
    if (_renderWidth != null) return _renderWidth!;

    // computeing the width for the text rendering and rounding of the value for easier range detection during the grid layout
    _renderWidth = _textSize(rawData, textStyle).width.floorToDouble();

    return _renderWidth!;
  }
}

Size _textSize(String text, TextStyle style) {
  final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr)
    ..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}

class OptionChain2DLayoutingConfigurations {
  final List<OptionChainColumm> columns;
  final double cellHeight;
  final IndexRangeMapper indexRangeMapper;
  final double maxYExtent;
  final bool reverse;
  final ScrollController horizontalScroller;
  final ScrollController verticalScroller;
  OptionChain2DLayoutingConfigurations({
    required this.columns,
    required this.cellHeight,
    required this.indexRangeMapper,
    required this.maxYExtent,
    required this.horizontalScroller,
    required this.verticalScroller,
    this.reverse = false,
  });
}
