import 'package:stacked/stacked.dart';

import '../../../core/models/user.dart';
import '../../../core/providers/notifications_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/interface_service.dart';
import '../../../locator.dart';
import '../home/home_page.dart';
import '../login/login_page.dart';

class SplashPageModel extends BaseViewModel {
  final _hiveService = locator<HiveService>();
  final _apiService = locator<ApiService>();
  final _userProvider = locator<UserProvider>();
  final _notificationsProvider = locator<NotificationsProvider>();

  Future checkAuth() async {
    await _notificationsProvider.init();
    await _hiveService.initHive();
    var jwt = await _hiveService.boxNotEmpty(boxName: 'JWT');
    if (jwt) {
      var jwt = await _hiveService.getDataFromBox('JWT');
      await _apiService.generateToken(jwt);
      var response = await _userProvider.fetchUser();
      if (response.status == Status.success) {
        if (_userProvider.user.role != Role.OWNER &&
            _userProvider.user.deviceToken !=
                _notificationsProvider.deviceToken) {
          await _userProvider
              .updateDeviceToken(_notificationsProvider.deviceToken);
        }
        await locator<InterfaceService>().replaceAllWith(HomePage.route);
      } else {
        await locator<InterfaceService>().replaceAllWith(LoginPage.route);
      }
    } else {
      await locator<InterfaceService>().navigateTo(LoginPage.route);
    }
  }
}
