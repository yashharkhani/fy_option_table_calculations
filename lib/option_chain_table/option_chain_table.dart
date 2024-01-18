import 'dart:math';

import 'package:flutter/material.dart';
import 'package:option_chain_renderer/option_chain_table/option_chain_dimension_analyzer.dart';
import 'package:option_chain_renderer/option_chain_table/two_dimensional_scroller.dart';

class OptionChainTable extends StatefulWidget {
  final double tableWidth;
  final double tableHeight;
  const OptionChainTable({
    super.key,
    required this.tableWidth,
    required this.tableHeight,
  });

  @override
  State<OptionChainTable> createState() => _OptionChainTableState();
}

class _OptionChainTableState extends State<OptionChainTable> {
  late OptionChainDimensionAnalyzer optionChainDimensionAnalyzer;

  void _generateRandomData() {
    optionChainDimensionAnalyzer = OptionChainDimensionAnalyzer(
      tableWidth: widget.tableWidth,
      tableHeight: widget.tableHeight,
      cellHeight: 50,
      leftColumns: _generateRandomNColumns(10, 20),
      middleColumn: _generateRandomNColumns(1, 20).first,
      rightColumns: _generateRandomNColumns(10, 20),
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
    super.initState();
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
          color: Colors.red,
          child: Stack(
            children: [
              _optionChainLayer1(),
              _optionChainLayer2(),
            ],
          ),
        ),
      ),
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
          itemBuilder: (context, index) {
            return Container(
              width:
                  optionChainDimensionAnalyzer.middleColumn.maxCellRenderWidth,
              height: optionChainDimensionAnalyzer.cellHeight,
              color:
                  Colors.primaries[Random().nextInt(Colors.primaries.length)],
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
            ),
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
            ),
          ),
        ),
      ],
    );
  }

  Widget _divisionScroller(
      OptionChain2DLayoutingConfigurations configurations) {
    return OptionChainTwoDimensionalDivisionScroller(
      configurations: configurations,
      delegate: TwoDimensionalChildBuilderDelegate(
        maxXIndex: configurations.columns.length - 1,
        maxYIndex: configurations.columns.first.cells.length - 1,
        builder: (context, vicinity) => Container(
          height: 200,
          width: 200,
          color: vicinity.xIndex.isEven && vicinity.yIndex.isEven
              ? Colors.amber[50]
              : (vicinity.xIndex.isOdd && vicinity.yIndex.isOdd
                  ? Colors.purple[50]
                  : null),
          child: Center(
            child: Text(
              'Row ${vicinity.yIndex}: Column ${vicinity.xIndex}',
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
          rawData: _generateRandomString(5, 15),
          textStyle: cellTextStyle,
        );
      },
    );
  }

  String _generateRandomString(int minLength, int maxLength) {
    final Random random = Random();
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
