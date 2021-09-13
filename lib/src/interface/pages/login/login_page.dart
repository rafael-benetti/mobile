import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'login_page_model.dart';
import 'widgets.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';
import '../../widgets/custom_text_field.dart';

import '../../../locator.dart';

class LoginPage extends StatelessWidget {
  final colors = locator<AppColors>();
  final styles = locator<TextStyles>();
  static const route = '/login';
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return ViewModelBuilder<LoginPageModel>.reactive(
      viewModelBuilder: () => LoginPageModel(),
      builder: (context, model, child) => Scaffold(
        body: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Container(
            height: screenHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Logo(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  margin: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        'Email',
                        style: styles.regular(letterSpacing: 0.5),
                      ),
                      SizedBox(height: 5),
                      CustomTextField(
                        hintText: 'Email',
                        initialValue: model.email,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) => model.email = value,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Senha',
                        style: styles.regular(letterSpacing: 0.5),
                      ),
                      SizedBox(height: 5),
                      CustomTextField(
                        hintText: 'Senha',
                        obscureText: true,
                        initialValue: model.pass,
                        onChanged: (value) => model.pass = value,
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => model.forgotPassword(),
                            child: FittedBox(
                              child: Text(
                                'Esqueci minha senha',
                                style:
                                    styles.regular(color: colors.primaryColor),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          LoginButton(
                            onPressed: model.authenticate,
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
