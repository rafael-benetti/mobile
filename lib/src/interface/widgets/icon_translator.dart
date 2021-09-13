import 'package:black_telemetry/src/core/services/interface_service.dart';
import 'package:black_telemetry/src/interface/shared/colors.dart';
import 'package:black_telemetry/src/interface/shared/text_styles.dart';
import 'package:flutter/material.dart';

import '../../locator.dart';
import 'dialog_action.dart';

final colors = locator<AppColors>();
final styles = locator<TextStyles>();
final interfaceService = locator<InterfaceService>();

class IconTranslator extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Function onTap;
  final double iconSize;

  const IconTranslator(
      {Key key, this.icon, this.iconColor, this.onTap, this.iconSize})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (iconColor == Colors.amber) {
          onTap(
            'Nunca conectada',
            'unplugged',
          );
        } else if (iconColor == colors.lightGreen) {
          onTap(
            'Online',
            'online',
          );
        } else if (iconColor == colors.red) {
          onTap(
            'Offline',
            'offline',
          );
        }
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Icon(
            icon,
            size: iconSize ?? 20,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

void popIconTranslatorDialog(String title, String type) {
  var message;
  if (type == 'offline') {
    message =
        'Esse ícone indica que a placa está offline a mais de 10 minutos.';
  } else if (type == 'online') {
    message =
        'Esse ícone indica que a sistema recebeu um sinal da placa a menos de 10 minutos.';
  } else if (type == 'unplugged') {
    message =
        'Esse ícone indica que a placa nunca foi conectada, ou seja, nunca emitiu um sinal para o sistema.';
  }

  interfaceService.showDialogMessage(
    title: title,
    message: message,
    actions: [
      DialogAction(
        title: 'Ok, entendi',
        onPressed: () {
          interfaceService.goBack();
        },
      ),
    ],
  );
}
