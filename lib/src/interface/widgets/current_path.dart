import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../locator.dart';
import '../shared/colors.dart';
import '../shared/text_styles.dart';

final colors = locator<AppColors>();
final styles = locator<TextStyles>();

class CurrentPath extends StatelessWidget {
  final Function onPressed;
  final String topText;
  final String buttonText;
  final List<String> bottomMiddleTexts;
  final String bottomFinalText;
  const CurrentPath(
      {this.onPressed,
      this.topText,
      this.bottomMiddleTexts,
      this.bottomFinalText,
      this.buttonText});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.only(bottom: 25),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topText,
                    style: styles.medium(
                      fontSize: 20,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Feather.home,
                        color: colors.primaryColor,
                        size: 15,
                      ),
                      if (bottomMiddleTexts != null)
                        Row(
                          children: List.generate(
                            bottomMiddleTexts.length,
                            (index) => Text(
                              bottomMiddleTexts[index],
                              style: styles.regular(
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          bottomFinalText,
                          style: styles.regular(
                            color: Colors.black38,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            if (onPressed != null)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation:
                      buttonText.toLowerCase().contains('deletar') ? 0 : 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 7.5),
                  primary: buttonText.toLowerCase().contains('deletar')
                      ? Theme.of(context).scaffoldBackgroundColor
                      : colors.primaryColor,
                ),
                onPressed: onPressed,
                child: Center(
                  child: Text(
                    buttonText,
                    style: styles.regular(
                        fontSize: 12,
                        color: buttonText.toLowerCase().contains('deletar')
                            ? colors.red
                            : colors.backgroundColor),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
