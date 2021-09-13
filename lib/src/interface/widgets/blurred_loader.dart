import 'dart:ui';

import 'package:flutter/material.dart';

import '../../locator.dart';
import '../shared/colors.dart';

class BlurredLoader extends StatelessWidget {
  const BlurredLoader({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 5,
        sigmaY: 5,
      ),
      child: Container(
        height: size.height,
        width: size.width,
        alignment: Alignment.center,
        color: Colors.grey.withOpacity(0.6),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            locator<AppColors>().primaryColor,
          ),
        ),
      ),
    );
  }
}
