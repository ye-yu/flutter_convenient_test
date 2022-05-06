import 'package:convenient_test_common/convenient_test_common.dart';
import 'package:convenient_test_manager/stores/log_store.dart';
import 'package:convenient_test_manager/utils/utils.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';

part 'suite_info_store.g.dart';

class SuiteInfoStore = _SuiteInfoStore with _$SuiteInfoStore;

abstract class _SuiteInfoStore with Store {
  @observable
  SuiteInfo? suiteInfo;

  final testEntryStateMap = ObservableDefaultMap<int, TestEntryState>(
      createDefaultValue: (_) => TestEntryState(status: 'pending', result: 'success'));

  SimplifiedStateEnum getSimplifiedState(int testInfoId) =>
      testEntryStateMap[testInfoId].toSimplifiedStateEnum(isFlaky: GetIt.I.get<LogStore>().isTestFlaky(testInfoId));

  void clear() {
    suiteInfo = null;
    testEntryStateMap.clear();
  }
}