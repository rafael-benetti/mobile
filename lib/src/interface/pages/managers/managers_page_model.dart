import 'package:stacked/stacked.dart';
import '../../../../src/core/providers/telemetry_boards_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/interface_service.dart';

import '../../../locator.dart';

class ManagersPageModel extends BaseViewModel {
  final userProvider = locator<UserProvider>();
  final interfaceService = locator<InterfaceService>();
  final telemetryBoardsProvider = locator<TelemetryBoardsProvider>();

  void loadData() async {
    setBusy(true);
    interfaceService.showLoader();
    await userProvider.getAllManagers();
    await telemetryBoardsProvider.getAllTelemetries();
    interfaceService.closeLoader();
    setBusy(false);
  }
}
