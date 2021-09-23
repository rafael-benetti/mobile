import 'package:black_telemetry/src/core/models/user.dart';
import 'package:black_telemetry/src/core/providers/user_provider.dart';
import 'package:stacked/stacked.dart';

import '../../../locator.dart';

class DetailedOperatorPageModel extends BaseViewModel {
  User user;
  final userProvider = locator<UserProvider>();
}
