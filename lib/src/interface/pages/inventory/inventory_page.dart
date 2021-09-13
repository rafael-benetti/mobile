import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/interface/pages/inventory/inventory_page_model.dart';

class InventoryPage extends StatelessWidget {
  static const route = '/inventory';

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<InventoryPageModel>.reactive(
      viewModelBuilder: () => InventoryPageModel(),
      builder: (context, model, child) => Scaffold(body: Container()),
    );
  }
}
