import 'package:stacked/stacked.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/interface_service.dart';

import '../../../locator.dart';

class OperatorsPageModel extends BaseViewModel {
  final interfaceService = locator<InterfaceService>();
  final userProvider = locator<UserProvider>();

  void loadData() async {
    setBusy(true);
    interfaceService.showLoader();
    await userProvider.getAllOperators();
    interfaceService.closeLoader();
    setBusy(false);
  }
}
