import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

import '../../interface/shared/colors.dart';
import '../../interface/shared/text_styles.dart';
import '../../interface/widgets/blurred_loader.dart';
import '../../interface/widgets/dialog_action.dart';
import '../../locator.dart';

/// Control interface elements without needing context
class InterfaceService {
  /// Navigation key to be used in the MaterialApp instance
  final navigationKey = GlobalKey<NavigatorState>();

  Future<dynamic> showModal({Widget widget, dynamic arguments}) {
    return navigationKey.currentState.push(
      PageRouteBuilder(
        settings: RouteSettings(
          arguments: arguments,
        ),
        pageBuilder: (context, animation, secondaryAnimation) => widget,
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          var begin = Offset(0.0, 1.0);
          var end = Offset.zero;
          var curve = Curves.ease;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  /// Shows a blurred loader on top of the app
  void showLoader() {
    BotToast.showCustomLoading(
      animationDuration: const Duration(milliseconds: 300),
      animationReverseDuration: const Duration(milliseconds: 300),
      backButtonBehavior: BackButtonBehavior.ignore,
      allowClick: false,
      ignoreContentClick: true,
      toastBuilder: (_) => BlurredLoader(),
    );
  }

  /// Closes the blurred loader if it exists
  void closeLoader() {
    BotToast.closeAllLoading();
  }

  /// Navigates to a page
  Future<dynamic> navigateTo(
    String routeName, {
    dynamic arguments,
  }) {
    return navigationKey.currentState.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  /// Navigates to a page and remove the current one from the stack
  Future<dynamic> replaceWith(
    String routeName, {
    dynamic arguments,
  }) {
    return navigationKey.currentState.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  /// Navigates to a page and remove all pages from the stack
  Future<dynamic> replaceAllWith(
    String routeName, {
    dynamic arguments,
  }) {
    return navigationKey.currentState.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Removes current page from the stack
  void goBack([dynamic result]) {
    navigationKey.currentState.pop(result);
  }

  /// Shows a snackbar with custom color and message
  void showSnackBar({
    @required String message,
    @required Color backgroundColor,
  }) {
    BotToast.showCustomText(
      align: Alignment.bottomCenter,
      toastBuilder: (_) => Container(
        height: 50,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10),
          ),
        ),
        width: double.maxFinite,
        padding: EdgeInsets.all(15),
        alignment: Alignment.center,
        child: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  /// Shows a dialog message with optional actions
  Future<dynamic> showDialogMessage({
    @required String title,
    @required String message,
    List<DialogAction> actions = const [],
    bool isDismissible = true,
  }) {
    var dialog = AlertDialog(
      title: Text(title),
      actionsPadding: EdgeInsets.only(right: 7.5),
      titleTextStyle: locator<TextStyles>().medium(fontSize: 16),
      content: Text(
        message,
      ),
      actions: List<DialogAction>.from(actions).map(
        (action) {
          if (action.title == 'Enviar' ||
              action.title == 'Confirmar' ||
              action.title == 'Criar' ||
              action.title == 'Cadastrar' ||
              action.title == 'Câmera' ||
              action.title == 'Galeria') {
            return Container(
              constraints: BoxConstraints(minWidth: 75, maxWidth: 100),
              // ignore: deprecated_member_use
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
                color: locator<AppColors>().primaryColor,
                onPressed: action.onPressed,
                child: Text(
                  action.title,
                  style: locator<TextStyles>().regular(
                    color: locator<AppColors>().backgroundColor,
                  ),
                ),
              ),
            );
          }
          return TextButton(
            onPressed: action.onPressed,
            child: Text(
              action.title,
              style: TextStyle(color: locator<AppColors>().primaryColor),
            ),
          );
        },
      ).toList(),
    );

    return showDialog(
      context: navigationKey.currentContext,
      builder: (context) => isDismissible
          ? dialog
          : WillPopScope(
              onWillPop: () async => false,
              child: dialog,
            ),
      barrierDismissible: isDismissible,
    );
  }

  Future<dynamic> showDialogWithWidgets({
    String title,
    String message,
    @required Widget widget,
    Color color,
    List<DialogAction> actions = const [],
    bool isDismissible = true,
  }) {
    var dialog = AlertDialog(
      titleTextStyle: locator<TextStyles>().medium(fontSize: 16),
      actionsPadding: EdgeInsets.fromLTRB(0, 0, 15, 5),
      title: title != null
          ? Text(
              title,
            )
          : Container(),
      content: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message != null) Text(message),
            if (message != null) SizedBox(height: 15),
            widget
          ],
        ),
      ),
      actions: List<DialogAction>.from(actions).map((action) {
        if (action.title == 'Enviar' ||
            action.title == 'Confirmar' ||
            action.title == 'Criar' ||
            action.title == 'Cadastrar' ||
            action.title == 'Câmera' ||
            action.title == 'Filtrar' ||
            action.title == 'Galeria' ||
            action.title == 'Transferir' ||
            action.title == 'Continuar') {
          return Container(
            constraints: BoxConstraints(minWidth: 75, maxWidth: 100),
            // ignore: deprecated_member_use
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
              color: color,
              onPressed: action.onPressed,
              child: Text(
                action.title,
                style: locator<TextStyles>().regular(
                  color: locator<AppColors>().backgroundColor,
                ),
              ),
            ),
          );
        }
        return TextButton(
          onPressed: action.onPressed,
          child: Text(
            action.title,
            style: locator<TextStyles>().regular(
              color: color,
            ),
          ),
        );
      }).toList(),
    );

    return showDialog(
      context: navigationKey.currentContext,
      builder: (context) => isDismissible
          ? dialog
          : WillPopScope(
              onWillPop: () async => false,
              child: dialog,
            ),
      barrierDismissible: isDismissible,
    );
  }
}
