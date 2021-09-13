import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../shared/colors.dart';
import 'splash_page_model.dart';

import '../../../locator.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SplashPageModel>.nonReactive(
      viewModelBuilder: () => SplashPageModel(),
      onModelReady: (model) {
        model.checkAuth();
      },
      builder: (context, model, child) => Scaffold(
          backgroundColor: locator<AppColors>().backgroundColor,
          body: Center(
            child: Image.asset(
              'assets/logo.png',
              width: MediaQuery.of(context).size.width * 0.8,
              fit: BoxFit.fitWidth,
            ),
          )),
    );
  }
}
