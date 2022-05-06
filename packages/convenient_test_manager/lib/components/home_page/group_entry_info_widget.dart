import 'package:convenient_test_common/convenient_test_common.dart';
import 'package:convenient_test_manager/components/home_page/log_entry_widget.dart';
import 'package:convenient_test_manager/components/misc/state_indicator.dart';
import 'package:convenient_test_manager/misc/protobuf_extensions.dart';
import 'package:convenient_test_manager/services/misc_service.dart';
import 'package:convenient_test_manager/stores/highlight_store.dart';
import 'package:convenient_test_manager/stores/log_store.dart';
import 'package:convenient_test_manager/stores/suite_info_store.dart';
import 'package:convenient_test_manager/stores/video_store.dart';
import 'package:convenient_test_manager/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:tuple/tuple.dart';

class HomePageGroupEntryInfoSectionBuilder extends StaticSectionBuilder {
  final int groupEntryId;
  final int depth;
  final bool showHeader;

  const HomePageGroupEntryInfoSectionBuilder({
    required this.groupEntryId,
    required this.depth,
    this.showHeader = true,
  });

  @override
  Iterable<StaticSection> build() {
    final suiteInfoStore = GetIt.I.get<SuiteInfoStore>();

    final info = suiteInfoStore.suiteInfo?.entryMap[groupEntryId];
    if (info == null) return const [];

    if (info is GroupInfo) return _GroupInfoSectionBuilder(info: info, depth: depth, showHeader: showHeader).build();
    if (info is TestInfo) return _TestInfoSectionBuilder(info: info, depth: depth).build();
    throw Exception('unknown info=$info');
  }
}

class _GroupInfoSectionBuilder extends StaticSectionBuilder {
  final GroupInfo info;
  final int depth;
  final bool showHeader;

  const _GroupInfoSectionBuilder({
    required this.info,
    required this.depth,
    this.showHeader = true,
  });

  @override
  Iterable<StaticSection> build() sync* {
    if (showHeader) {
      yield StaticSection.single(child: _buildHeader());
    }

    if (expanding || !showHeader) {
      for (final childGroupEntryId in info.entryIds) {
        yield* HomePageGroupEntryInfoSectionBuilder(
          groupEntryId: childGroupEntryId,
          depth: depth + 1,
        ).build();
      }
    }
  }

  Widget _buildHeader() {
    return Observer(builder: (_) {
      final highlightStore = GetIt.I.get<HighlightStore>();
      final suiteInfoStore = GetIt.I.get<SuiteInfoStore>();

      return InkWell(
        onTap: () {
          highlightStore
            ..enableAutoExpand = false
            ..expandGroupEntryMap[info.id] = !expanding;
        },
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: Padding(
            padding: const EdgeInsets.only(left: 8) + EdgeInsets.only(left: depth * 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24,
                  height: 12,
                  child: Icon(
                    expanding ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    size: 16,
                  ),
                ),
                Expanded(
                  child: Text(
                    info.calcBriefName(suiteInfoStore.suiteInfo!),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ..._buildGroupStat(),
                _RunTestButton(filterNameRegex: '^${info.name}.*'),
              ],
            ),
          ),
        ),
      );
    });
  }

  List<Widget> _buildGroupStat() {
    final suiteInfoStore = GetIt.I.get<SuiteInfoStore>();

    final stateCountMap = ExhaustiveMap(SimplifiedStateEnum.values, (_) => 0);
    info.traverse(suiteInfoStore.suiteInfo!, (groupEntryInfo) {
      if (groupEntryInfo is TestInfo) {
        stateCountMap[suiteInfoStore.getSimplifiedState(groupEntryInfo.id)]++;
      }
    });

    return SimplifiedStateEnum.values.expand<Widget>((state) {
      final count = stateCountMap[state];
      if (count == 0) return const [SizedBox.shrink()];

      return [
        Text('${count}x', style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 2),
        StateIndicatorWidget(state: state),
      ];
    }).toList();
  }

  bool get expanding => GetIt.I.get<HighlightStore>().expandGroupEntryMap[info.id];
}

class _TestInfoSectionBuilder extends StaticSectionBuilder {
  final TestInfo info;
  final int depth;

  const _TestInfoSectionBuilder({
    required this.info,
    required this.depth,
  });

  @override
  Iterable<StaticSection> build() sync* {
    final suiteInfoStore = GetIt.I.get<SuiteInfoStore>();

    final state = suiteInfoStore.getSimplifiedState(info.id);

    yield StaticSection.single(child: _buildHeader(state));

    if (expanding) {
      yield* _buildLogEntries(state);
    }
  }

  Widget _buildHeader(SimplifiedStateEnum state) {
    final highlightStore = GetIt.I.get<HighlightStore>();
    final suiteInfoStore = GetIt.I.get<SuiteInfoStore>();

    return Observer(builder: (_) {
      return InkWell(
        onTap: () {
          highlightStore
            ..enableAutoExpand = false
            ..expandGroupEntryMap[info.id] = !expanding
            ..highlightTestEntryId = info.id;
        },
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4) + EdgeInsets.only(left: 16 + depth * 12),
            child: Row(
              children: [
                StateIndicatorWidget(
                  state: state,
                  enableAnimation: true,
                ),
                Text(
                  info.calcBriefName(suiteInfoStore.suiteInfo!),
                  style: const TextStyle(),
                ),
                Expanded(child: Container()),
                _buildPlayVideoButton(),
                _RunTestButton(filterNameRegex: '^${info.name}\$'),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPlayVideoButton() {
    if (logEntryIds.isEmpty) return const SizedBox.shrink();

    return IconButton(
      visualDensity: VisualDensity.compact,
      onPressed: _handleTapPlayVideoButton,
      tooltip: 'Play video recording',
      icon: const Icon(
        Icons.movie,
        color: Colors.teal,
        size: 16,
      ),
    );
  }

  void _handleTapPlayVideoButton() {
    final videoStore = GetIt.I.get<VideoStore>();
    final logStore = GetIt.I.get<LogStore>();

    final logSubEntryIds = logStore.logSubEntryInTest(info.id);
    if (logSubEntryIds.isEmpty) return;

    final logSubEntryTimes =
        logSubEntryIds.map((logSubEntryId) => logStore.logSubEntryMap[logSubEntryId]!.timeTyped).toList();

    final startTime = logSubEntryTimes.reduce((a, b) => a.isBefore(b) ? a : b);
    final endTime = logSubEntryTimes.reduce((a, b) => a.isAfter(b) ? a : b);

    videoStore.displayRange = Tuple2(
      videoStore.absoluteToVideoTime(startTime),
      videoStore.absoluteToVideoTime(endTime),
    );
  }

  List<int> get logEntryIds => GetIt.I.get<LogStore>().logEntryInTest[info.id] ?? <int>[];

  Iterable<StaticSection> _buildLogEntries(SimplifiedStateEnum state) sync* {
    final logEntryIds = this.logEntryIds;

    if (logEntryIds.isEmpty) {
      yield StaticSection.single(
        child: const Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 12),
          child: Text(
            'No log entries for this test',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ),
      );
    } else {
      yield StaticSection(
        metadata: TestInfoLogEntrySectionMetadata(
          testInfoId: info.id,
        ),
        count: logEntryIds.length,
        builder: (_, i) => HomePageLogEntryWidget(
          order: i,
          testEntryId: info.id,
          logEntryId: logEntryIds[i],
          running: state == SimplifiedStateEnum.running && i == logEntryIds.length - 1,
        ),
      );
    }
  }

  bool get expanding => GetIt.I.get<HighlightStore>().expandGroupEntryMap[info.id];
}

@immutable
class TestInfoLogEntrySectionMetadata {
  final int testInfoId;

  const TestInfoLogEntrySectionMetadata({required this.testInfoId});
}

class _RunTestButton extends StatelessWidget {
  final String filterNameRegex;

  const _RunTestButton({Key? key, required this.filterNameRegex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      onPressed: () {
        GetIt.I.get<HighlightStore>().enableAutoExpand = true;
        GetIt.I.get<MiscService>().hotRestartAndRunTests(filterNameRegex: filterNameRegex);
      },
      tooltip: 'Run this test',
      icon: const Icon(
        Icons.play_arrow,
        color: Colors.blue,
        size: 16,
      ),
    );
  }
}