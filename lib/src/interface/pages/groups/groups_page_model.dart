import 'package:stacked/stacked.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/groups_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/interface_service.dart';

import '../../../locator.dart';

class GroupsPageModel extends BaseViewModel {
  final _groupsProvider = locator<GroupsProvider>();

  void loadData() async {
    setBusy(true);
    locator<InterfaceService>().showLoader();
    await _groupsProvider.getAllGroups();
    locator<InterfaceService>().closeLoader();
    setBusy(false);
  }

  void filterGroups() {
    _groupsProvider.filterGroups();
  }

  final _user = locator<UserProvider>().user;
  User get user => _user;
}
