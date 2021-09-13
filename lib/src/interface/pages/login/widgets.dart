import 'package:flutter/material.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';

import '../../../locator.dart';

final colors = locator<AppColors>();
final styles = locator<TextStyles>();

class Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: double.infinity,
      child: Image.asset(
        'assets/logo2.png',
        height: screenHeight * 0.20,
        fit: BoxFit.fitHeight,
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  final Function onPressed;

  const LoginButton({Key key, @required this.onPressed}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: colors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      onPressed: onPressed,
      child: Text(
        'Acessar',
        style: styles.regular(
          color: colors.backgroundColor,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
