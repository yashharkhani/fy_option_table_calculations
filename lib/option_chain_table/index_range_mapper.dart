class IndexRangeMapper {
  List<Range> ranges;

  IndexRangeMapper({required this.ranges});

  Range getRangeAtIndex(int idx) {
    if (idx < 0 || idx >= ranges.length) {
      throw "out of bounds";
    }

    return ranges[idx];
  }

  int findRangeIndex(num value, {int? defaultVal}) {
    int low = 0;
    int high = ranges.length - 1;

    while (low <= high) {
      int mid = (low + high) ~/ 2;
      if (ranges[mid].startRange <= value && value < ranges[mid].endRange) {
        // Including start_i, excluding end_i
        return mid; // Found the range containing the value
      } else if (ranges[mid].startRange > value) {
        high = mid - 1;
      } else {
        low = mid + 1;
      }
    }

    return defaultVal ?? -1; // Value not found in any range
  }
}

/// the algorithm on range will work as [startRange, endRange)
class Range {
  final num startRange;
  final num endRange;

  Range({
    required this.startRange,
    required this.endRange,
  });
}
