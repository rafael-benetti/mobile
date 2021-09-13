import 'package:stacked/stacked.dart';
import '../../../core/providers/counter_types_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/interface_service.dart';

import '../../../locator.dart';

class CounterTypesPageModel extends BaseViewModel {
  final interfaceService = locator<InterfaceService>();
  final counterTypesProvider = locator<CounterTypesProvider>();
  final user = locator<UserProvider>().user;

  void loadData() async {
    setBusy(true);
    interfaceService.showLoader();
    await counterTypesProvider.getAllCounterTypes();
    interfaceService.closeLoader();
    setBusy(false);
  }
}
