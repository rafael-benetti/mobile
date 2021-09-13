import 'package:stacked/stacked.dart';
import '../../../../src/core/models/collection.dart';
import '../../../../src/core/providers/collections_provider.dart';
import '../../../../src/core/providers/user_provider.dart';
import '../../../../src/core/services/interface_service.dart';
import '../../../../src/interface/shared/validators.dart';

import '../../../locator.dart';

class DetailedCollectionPageModel extends BaseViewModel {
  final interfaceService = locator<InterfaceService>();
  final collectionsProvider = locator<CollectionsProvider>();
  final userProvider = locator<UserProvider>();

  void loadData(Collection collection) async {
    setBusy(true);
    interfaceService.showLoader();
    collectionsProvider.setDetailedCollection(collection);
    interfaceService.closeLoader();
    setBusy(false);
  }

  void reviewCollection(String id) async {
    interfaceService.showLoader();
    await collectionsProvider.reviewCollection(id);
    interfaceService.closeLoader();
  }

  void popReviewDataDialog() {
    interfaceService.showDialogMessage(
        title: 'Coleta revisada',
        message:
            'Revisada por ${collectionsProvider.detailedCollection.reviewedData.reviewerName} em ${getFormattedDate(collectionsProvider.detailedCollection.reviewedData.date)}');
  }
}
