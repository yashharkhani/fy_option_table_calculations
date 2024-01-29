library option_chain_table;

// import 'dart:math';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// import 'package:option_chain_renderer/option_chain_table/linked_scroll_controllers.dart';
// import 'package:option_chain_renderer/option_chain_table/option_chain_controller.dart';
// import 'package:option_chain_renderer/option_chain_table/option_chain_dimension_analyzer.dart';
// import 'package:option_chain_renderer/option_chain_table/two_dimensional_scroller.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

part 'index_range_mapper.dart';
part 'linked_scroll_controllers.dart';
part 'option_chain_controller.dart';
part 'option_chain_dimension_analyzer.dart';
part 'two_dimensional_scroller.dart';

class OptionChainTable extends StatefulWidget {
  final double tableWidth;
  final double tableHeight;
  final OptionChainController optionChainController;

  const OptionChainTable({
    super.key,
    required this.tableWidth,
    required this.tableHeight,
    required this.optionChainController,
  });

  @override
  State<OptionChainTable> createState() => _OptionChainTableState();
}

class _OptionChainTableState extends State<OptionChainTable> {
  late OptionChainDimensionAnalyzer optionChainDimensionAnalyzer;

  late LinkedScrollControllerGroup horizontalScrollerGroupc;
  late ScrollController positiveXScroller;
  late ScrollController negativeXScroller;

  late LinkedScrollControllerGroup verticalScrollerGroupc;
  late ScrollController rightYScroller;
  late ScrollController leftYScroller;
  late ScrollController middleYScroller;

  int rowsN = 100;
  int columnsN = 50;

  void _generateRandomData() {
    horizontalScrollerGroupc = LinkedScrollControllerGroup();
    positiveXScroller = horizontalScrollerGroupc.addAndGet();
    negativeXScroller = horizontalScrollerGroupc.addAndGet();

    verticalScrollerGroupc = LinkedScrollControllerGroup();
    rightYScroller = verticalScrollerGroupc.addAndGet();
    leftYScroller = verticalScrollerGroupc.addAndGet();
    middleYScroller = verticalScrollerGroupc.addAndGet();

    List<OptionChainColumm> columnData =
        _generateRandomNColumns(columnsN, rowsN);
    optionChainDimensionAnalyzer = OptionChainDimensionAnalyzer(
      tableWidth: widget.tableWidth,
      tableHeight: widget.tableHeight,
      cellHeight: 50,
      leftColumns: columnData,
      middleColumn: _generateRandomNColumns(1, rowsN).first,
      rightColumns: columnData,
    );
  }

  TextStyle cellTextStyle = const TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12,
  );

  @override
  void initState() {
    _generateRandomData();
    optionChainDimensionAnalyzer.compute();

    _jumpToCenter();
    _computeStrikePosition();

    middleYScroller.addListener(() {
      _computeStrikeRenderPosition();
    });

    super.initState();
  }

  int strikeIndex = 0;
  double strikePosition = 0;

  void _computeStrikePosition() {
    strikeIndex = rowsN ~/ 2;
    strikePosition =
        (strikeIndex + 1) * optionChainDimensionAnalyzer.cellHeight;
    strikeRenderPosition =
        ValueNotifier<double>(optionChainDimensionAnalyzer.tableHeight);
  }

  void _computeStrikeRenderPosition() {
    double yStart = middleYScroller.offset;
    double yEnd =
        middleYScroller.offset + optionChainDimensionAnalyzer.tableHeight;
    if (strikePosition < yStart) {
      strikeRenderPosition.value = 0;
      return;
    }

    if (strikePosition > yEnd) {
      strikeRenderPosition.value = optionChainDimensionAnalyzer.tableHeight;
      return;
    }

    strikeRenderPosition.value = _mapValue(
        yStart, yEnd, optionChainDimensionAnalyzer.tableHeight, strikePosition);
  }

  double _mapValue(double a, double b, double max, double P) {
    // Ensure a < b and P lies within [a, b]
    if (a >= b || P < a || P > b) {
      throw ArgumentError(
          'Invalid arguments: a should be less than b, and P should be between a and b.');
    }

    // Linear transformation
    return (P - a) * max / (b - a);
  }

  void _jumpToCenter() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      middleYScroller.animateTo(
        middleYScroller.position.maxScrollExtent * 0.5,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      child: Center(
        child: Container(
          width: optionChainDimensionAnalyzer.tableWidth,
          height: optionChainDimensionAnalyzer.tableHeight,
          // color: Colors.red,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _optionChainLayer1(),
              _optionChainLayer2(),
              ..._optionChainLayer3(),
            ],
          ),
        ),
      ),
    );
  }

  final ValueNotifier<double> sliderValue = ValueNotifier<double>(50);
  late ValueNotifier<double> strikeRenderPosition;

  List<Widget> _optionChainLayer3() {
    return [
      Positioned(
        bottom: 0,
        left: optionChainDimensionAnalyzer.leftDivisonAvailableSpace,
        child: ValueListenableBuilder<double>(
            valueListenable: sliderValue,
            builder: (context, val, _) {
              return SfSlider(
                value: val,
                min: 0,
                max: 100,
                // divisions: 1,
                onChanged: (value) {
                  sliderValue.value = value;
                  _computeXScroll(value);
                },
              );
            }),
      ),
      ValueListenableBuilder<double>(
          valueListenable: strikeRenderPosition,
          child: Row(
            children: [
              Container(
                color: Colors.green,
                height: 3,
                width: optionChainDimensionAnalyzer.leftDivisonAvailableSpace,
              ),
              InkWell(
                onTap: () {
                  _jumpToCenter();
                },
                child: Container(
                  height: 20,
                  width:
                      optionChainDimensionAnalyzer.middleDivisionAvailableSpace,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Container(
                color: Colors.green,
                height: 3,
                width: optionChainDimensionAnalyzer.leftDivisonAvailableSpace,
              ),
            ],
          ),
          builder: (context, val, c) {
            return Positioned(
              top: val - 10,
              child: c!,
            );
          }),
    ];
  }

  void _computeXScroll(double sliderVal) {
    double normalizedValue = 50 - sliderVal;
    if (normalizedValue < 0) {
      normalizedValue = -1 * normalizedValue;
    }

    double mutiplicationFactor = normalizedValue / 50;

    positiveXScroller.jumpTo(
      positiveXScroller.position.maxScrollExtent * mutiplicationFactor,
      // duration: const Duration(milliseconds: 100),
      // curve: Curves.easeIn,
    );
  }

  Widget _optionChainLayer2() {
    return Positioned(
      left: optionChainDimensionAnalyzer.leftDivisonAvailableSpace,
      child: SizedBox(
        width: optionChainDimensionAnalyzer.middleDivisionAvailableSpace,
        height: optionChainDimensionAnalyzer.tableHeight,
        child: ListView.builder(
          itemCount: optionChainDimensionAnalyzer.middleColumn.cells.length,
          controller: middleYScroller,
          itemBuilder: (context, index) {
            return Container(
              width:
                  optionChainDimensionAnalyzer.middleColumn.maxCellRenderWidth,
              height: optionChainDimensionAnalyzer.cellHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey,
                  ),
                ),
              ),
              child: Text(
                optionChainDimensionAnalyzer.middleColumn.cells[index].rawData,
                style: cellTextStyle,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _optionChainLayer1() {
    return Row(
      children: [
        // calls grid
        Container(
          width: optionChainDimensionAnalyzer.leftDivisonAvailableSpace,
          height: optionChainDimensionAnalyzer.tableHeight,
          color: Colors.white,
          child: _divisionScroller(
            OptionChain2DLayoutingConfigurations(
              columns: optionChainDimensionAnalyzer.leftColumns,
              cellHeight: optionChainDimensionAnalyzer.cellHeight,
              indexRangeMapper: optionChainDimensionAnalyzer.lcIdxRangeMapper,
              maxYExtent:
                  optionChainDimensionAnalyzer.leftDivisionRequiredSpace,
              // reverse: true,
              horizontalScroller: negativeXScroller,
              verticalScroller: leftYScroller,
            ),
            reverseScroller: true,
          ),
        ),
        SizedBox(
          width: optionChainDimensionAnalyzer.middleDivisionAvailableSpace,
        ),
        // puts grid
        Container(
          width: optionChainDimensionAnalyzer.leftDivisonAvailableSpace,
          height: optionChainDimensionAnalyzer.tableHeight,
          color: Colors.white,
          child: _divisionScroller(
            OptionChain2DLayoutingConfigurations(
              columns: optionChainDimensionAnalyzer.rightColumns,
              cellHeight: optionChainDimensionAnalyzer.cellHeight,
              indexRangeMapper: optionChainDimensionAnalyzer.rcIdxRangeMapper,
              maxYExtent:
                  optionChainDimensionAnalyzer.rightDivisionRequiredSpace,
              horizontalScroller: positiveXScroller,
              verticalScroller: rightYScroller,
            ),
          ),
        ),
      ],
    );
  }

  Widget _divisionScroller(
    OptionChain2DLayoutingConfigurations configurations, {
    bool reverseScroller = false,
  }) {
    return OptionChainTwoDimensionalDivisionScroller(
      configurations: configurations,
      horizontalDetails: ScrollableDetails.horizontal(
        controller: configurations.horizontalScroller,
        reverse: reverseScroller,
        physics: const NeverScrollableScrollPhysics(),
      ),
      verticalDetails: ScrollableDetails.vertical(
        controller: configurations.verticalScroller,
      ),
      delegate: TwoDimensionalChildBuilderDelegate(
        maxXIndex: configurations.columns.length - 1,
        maxYIndex: configurations.columns.first.cells.length - 1,
        builder: (context, vicinity) => Container(
          height: configurations.cellHeight,
          width: configurations.columns[vicinity.xIndex].maxCellRenderWidth,
          decoration: BoxDecoration(
              color: vicinity.xIndex.isEven && vicinity.yIndex.isEven
                  ? Colors.amber[50]
                  : (vicinity.xIndex.isOdd && vicinity.yIndex.isOdd
                      ? Colors.purple[50]
                      : null),
              border: const Border(
                bottom: BorderSide(
                  color: Colors.grey,
                ),
              )),
          child: Center(
            child: Text(
              '${configurations.columns[vicinity.xIndex].cells[vicinity.yIndex].rawData}\nR${vicinity.yIndex}:C${vicinity.xIndex}',
            ),
          ),
        ),
      ),
    );
  }

  List<OptionChainColumm> _generateRandomNColumns(int n, int columnSize) {
    return List.generate(
      n,
      (index) => OptionChainColumm(
        cells: _generateCells(columnSize),
      ),
    );
  }

  List<OptionChainCellData> _generateCells(int columnSize) {
    return List.generate(
      columnSize,
      (index) {
        return OptionChainCellData(
          rawData: _generateRandomString(5, 40),
          textStyle: cellTextStyle,
        );
      },
    );
  }

  String _generateRandomString(int minLength, int maxLength) {
    final math.Random random = math.Random();
    const String chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    // Ensure maxLength is not less than minLength
    if (maxLength < minLength) {
      maxLength = minLength;
    }

    // Randomly choose a length in the given range
    int length = minLength + random.nextInt(maxLength - minLength + 1);

    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ));
  }
}
