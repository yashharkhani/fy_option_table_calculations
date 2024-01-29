part of option_chain_table;

typedef StateUpdator = void Function(void Function() fn);

class OptionChainController {
  OptionChainTableView _optionChainTableView = OptionChainTableView.defaultView;

  void expandRight() {
    _optionChainTableView = OptionChainTableView.rightExpandedView;
  }

  void expandLeft() {
    _optionChainTableView = OptionChainTableView.leftExpandedView;
  }

  void closeExpanded() {
    _optionChainTableView = OptionChainTableView.defaultView;
  }

  OptionChainTableView get currentView => _optionChainTableView;

  OptionChainDimensionAnalyzer? _optionChainDimensionAnalyzer;
  late StateUpdator _stateUpdator;

  void init({
    required OptionChainDimensionAnalyzer optionChainDimensionAnalyzer,
    required StateUpdator stateUpdator,
  }) {
    _optionChainDimensionAnalyzer = optionChainDimensionAnalyzer;
    _stateUpdator = stateUpdator;
  }

  void recomputeAndRerender({required double height, required double width}) {
    bool? recomputeSuccessful = _optionChainDimensionAnalyzer?.recomputeResize(
      height: height,
      width: width,
    );

    if (recomputeSuccessful == true) {
      refresh();
    }
  }

  void refresh({VoidCallback? onRefresh}) {
    _stateUpdator.call(onRefresh ?? () {});
  }
}

enum OptionChainTableView {
  defaultView,
  leftExpandedView,
  rightExpandedView,
}
