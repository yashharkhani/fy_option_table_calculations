// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:option_chain_renderer/option_chain_table/option_chain_dimension_analyzer.dart';

class OptionChainTwoDimensionalDivisionScroller
    extends TwoDimensionalScrollView {
  final OptionChain2DLayoutingConfigurations configurations;
  const OptionChainTwoDimensionalDivisionScroller({
    super.key,
    super.primary,
    super.mainAxis = Axis.vertical,
    super.verticalDetails = const ScrollableDetails.vertical(),
    super.horizontalDetails = const ScrollableDetails.horizontal(),
    required TwoDimensionalChildBuilderDelegate delegate,
    super.cacheExtent,
    super.diagonalDragBehavior = DiagonalDragBehavior.none,
    super.dragStartBehavior = DragStartBehavior.start,
    super.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    super.clipBehavior = Clip.hardEdge,
    required this.configurations,
  }) : super(delegate: delegate);

  @override
  Widget buildViewport(
    BuildContext context,
    ViewportOffset verticalOffset,
    ViewportOffset horizontalOffset,
  ) {
    return TwoDimensionalScrollerViewport(
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalDetails.direction,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalDetails.direction,
      mainAxis: mainAxis,
      delegate: delegate as TwoDimensionalChildBuilderDelegate,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
      configurations: configurations,
    );
  }
}

class TwoDimensionalScrollerViewport extends TwoDimensionalViewport {
  final OptionChain2DLayoutingConfigurations configurations;

  const TwoDimensionalScrollerViewport({
    super.key,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required TwoDimensionalChildBuilderDelegate super.delegate,
    required super.mainAxis,
    super.cacheExtent,
    super.clipBehavior = Clip.hardEdge,
    required this.configurations,
  });

  @override
  RenderTwoDimensionalViewport createRenderObject(BuildContext context) {
    return RenderTwoDimensionalGridViewport(
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalAxisDirection,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalAxisDirection,
      mainAxis: mainAxis,
      delegate: delegate as TwoDimensionalChildBuilderDelegate,
      childManager: context as TwoDimensionalChildManager,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
      configurations: configurations,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTwoDimensionalGridViewport renderObject,
  ) {
    renderObject
      ..horizontalOffset = horizontalOffset
      ..horizontalAxisDirection = horizontalAxisDirection
      ..verticalOffset = verticalOffset
      ..verticalAxisDirection = verticalAxisDirection
      ..mainAxis = mainAxis
      ..delegate = delegate
      ..cacheExtent = cacheExtent
      ..clipBehavior = clipBehavior;
  }
}

class RenderTwoDimensionalGridViewport extends RenderTwoDimensionalViewport {
  final OptionChain2DLayoutingConfigurations configurations;

  RenderTwoDimensionalGridViewport({
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required TwoDimensionalChildBuilderDelegate delegate,
    required super.mainAxis,
    required super.childManager,
    super.cacheExtent,
    super.clipBehavior = Clip.hardEdge,
    required this.configurations,
  }) : super(delegate: delegate);

  @override
  void layoutChildSequence() {
    final double horizontalPixels = horizontalOffset.pixels;
    final double verticalPixels = verticalOffset.pixels;
    final double viewportWidth = viewportDimension.width + cacheExtent;
    final double viewportHeight = viewportDimension.height + cacheExtent;
    final TwoDimensionalChildBuilderDelegate builderDelegate =
        delegate as TwoDimensionalChildBuilderDelegate;

    final int maxRowIndex = builderDelegate.maxYIndex!;
    final int maxColumnIndex = builderDelegate.maxXIndex!;

    // final int leadingColumn = math.max((horizontalPixels / 200).floor(), 0);

    // final int leadIdx =
    //     configurations.indexRangeMapper.findRangeIndex(horizontalPixels);

    final int leadingColumn = configurations.indexRangeMapper.findRangeIndex(
      horizontalPixels,
      defaultVal: 0,
    );

    final int leadingRow =
        math.max((verticalPixels / configurations.cellHeight).floor(), 0);

    final int trailingColumn = configurations.indexRangeMapper.findRangeIndex(
      horizontalPixels + viewportWidth,
      defaultVal: maxColumnIndex,
    );
    //  math.min(
    //   ((horizontalPixels + viewportWidth) / 200).ceil(),
    //   maxColumnIndex,
    // );
    final int trailingRow = math.min(
      ((verticalPixels + viewportHeight) / configurations.cellHeight).ceil(),
      maxRowIndex,
    );

    double xLayoutOffset = configurations.indexRangeMapper
            .getRangeAtIndex(leadingColumn)
            .startRange -
        horizontalOffset.pixels;

    for (int column = leadingColumn; column <= trailingColumn; column++) {
      double yLayoutOffset =
          (leadingRow * configurations.cellHeight) - verticalOffset.pixels;

      for (int row = leadingRow; row <= trailingRow; row++) {
        final ChildVicinity vicinity =
            ChildVicinity(xIndex: column, yIndex: row);
        final RenderBox child = buildOrObtainChildFor(vicinity)!;
        child.layout(constraints.loosen());

        // Subclasses only need to set the normalized layout offset. The super
        // class adjusts for reversed axes.
        parentDataOf(child).layoutOffset = Offset(xLayoutOffset, yLayoutOffset);
        yLayoutOffset += configurations.cellHeight;
      }
      xLayoutOffset += configurations.columns[column].maxCellRenderWidth!;
    }

    // Set the min and max scroll extents for each axis.
    final double verticalExtent = configurations.cellHeight * (maxRowIndex + 1);

    verticalOffset.applyContentDimensions(
      0.0,
      clampDouble(
          verticalExtent - viewportDimension.height, 0.0, double.infinity),
    );

    final double horizontalExtent = configurations.maxYExtent;

    horizontalOffset.applyContentDimensions(
      0.0,
      clampDouble(
          horizontalExtent - viewportDimension.width, 0.0, double.infinity),
    );
    // Super class handles garbage collection too!
  }
}
