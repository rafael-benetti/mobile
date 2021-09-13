import 'package:stacked/stacked.dart';

import '../../../core/models/user.dart';
import '../../../core/providers/notifications_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../locator.dart';
import '../../shared/colors.dart';
import '../../shared/error_translator.dart';
import '../../widgets/icon_translator.dart';
import '../home/home_page.dart';

class LoginPageModel extends BaseViewModel {
  final _userProvider = locator<UserProvider>();
  final _colors = locator<AppColors>();
  final notificationsProvider = locator<NotificationsProvider>();

  String _email;
  set email(value) => _email = value;
  String get email => _email;

  String _pass;
  set pass(value) => _pass = value;
  String get pass => _pass;

  Future authenticate() async {
    if (email == null ||
        email == '' ||
        !email.contains('@') ||
        !email.contains('.')) {
      interfaceService.showSnackBar(
          message: 'Insira um email válido.', backgroundColor: _colors.red);
      return;
    }

    if (pass == '' || pass == null) {
      interfaceService.showSnackBar(
          message: 'Insira uma senha válida.', backgroundColor: _colors.red);
      return;
    }

    interfaceService.showLoader();
    var response = await _userProvider.authenticate(_email, _pass);

    if (response.status == Status.success) {
      if (_userProvider.user.role != Role.OWNER &&
          _userProvider.user.deviceToken != notificationsProvider.deviceToken) {
        await _userProvider
            .updateDeviceToken(notificationsProvider.deviceToken);
      }
      interfaceService.closeLoader();
      await interfaceService.replaceAllWith(HomePage.route);
    } else {
      interfaceService.closeLoader();
      interfaceService.showSnackBar(
        message: translateError(response.data),
        backgroundColor: locator<AppColors>().red,
      );
    }
  }

  void forgotPassword() async {
    if (email == null ||
        email == '' ||
        !email.contains('@') ||
        !email.contains('.')) {
      interfaceService.showSnackBar(
          message: 'Insira um email válido.', backgroundColor: _colors.red);
      return;
    }
    interfaceService.showLoader();
    var response = await _userProvider.forgotPassword(email);
    interfaceService.closeLoader();
    if (response.status == Status.success) {
      await interfaceService.showDialogMessage(
        title: 'Email enviado',
        message: 'Enviamos um email para você com as próximas instruções',
      );
    } else {
      interfaceService.showSnackBar(
        message: 'Algo de errado aconteceu. Tente novamente',
        backgroundColor: colors.red,
      );
    }
  }
}
