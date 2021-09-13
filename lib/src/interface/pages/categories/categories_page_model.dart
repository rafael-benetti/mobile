import 'package:stacked/stacked.dart';
import '../../../core/providers/categories_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/interface_service.dart';
import '../../../locator.dart';

class CategoriesPageModel extends BaseViewModel {
  final user = locator<UserProvider>().user;
  void loadData() async {
    setBusy(true);
    locator<InterfaceService>().showLoader();
    await locator<CategoriesProvider>().getAllCategories();
    locator<InterfaceService>().closeLoader();
    setBusy(false);
  }
}
