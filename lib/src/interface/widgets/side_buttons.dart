import 'package:flutter/material.dart';
import '../../core/services/interface_service.dart';
import '../shared/colors.dart';
import '../shared/text_styles.dart';

import '../../locator.dart';

final styles = locator<TextStyles>();
final colors = locator<AppColors>();

class Buttons extends StatelessWidget {
  final Function onSubmit;
  final String submitText;

  const Buttons({
    this.onSubmit,
    @required this.submitText,
  });
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(bottom: 15, top: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 100,
              height: 35,
              // ignore: deprecated_member_use
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
                color: colors.red,
                onPressed: () {
                  locator<InterfaceService>().goBack();
                },
                child: Text(
                  'Cancelar',
                  style: styles.regular(
                    color: colors.backgroundColor,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            Container(
              width: 100,
              height: 35,
              // ignore: deprecated_member_use
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
                color: colors.primaryColor,
                onPressed: onSubmit,
                child: Text(
                  submitText,
                  style: styles.regular(
                    color: colors.backgroundColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
