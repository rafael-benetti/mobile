import 'package:black_telemetry/src/core/models/telemetry_board.dart';
import 'package:black_telemetry/src/interface/shared/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'colors.dart';
import 'enums.dart';

import '../../locator.dart';

final colors = locator<AppColors>();
final styles = locator<TextStyles>();

Map<String, Color> translateTelemetry(telemetryStatus) {
  switch (telemetryStatus) {
    case TelemetryStatus.ACTIVE:
      return {'Ativo': colors.darkGreen};
    case TelemetryStatus.INACTIVE:
      return {'Inativo': colors.red};
    default:
      return {'Sem telemetria': Colors.grey};
  }
}

String convertPhoneNumberToAPI(String phone) {
  return '+55' +
      phone
          .replaceAll('(', '')
          .replaceAll(' ', '')
          .replaceAll(')', '')
          .replaceAll('-', '');
}

String convertPhoneNumberFromAPI(String phone) {
  if (phone == null) {
    return null;
  }
  var convertedPhone = phone.replaceAll('+55', '');
  //47996751113 -> 11 digitos
  if (convertedPhone.length == 11) {
    convertedPhone =
        '(${convertedPhone.substring(0, 2)}) ${convertedPhone.substring(2, 7)}-${convertedPhone.substring(7, 11)}';
    //4733482544  -> 10 digitos
  } else if (convertedPhone.length == 10) {
    convertedPhone =
        '(${convertedPhone.substring(0, 2)}) ${convertedPhone.substring(2, 6)}-${convertedPhone.substring(6, 10)}';
  }
  return convertedPhone;
}

String translateType(CType type) {
  switch (type) {
    case CType.IN:
      return 'Entrada';
    case CType.OUT:
      return 'Saída';
    default:
      return 'Indefinido';
  }
}

bool checkIfTelemetryIsOnline(TelemetryBoard telemetryBoard) {
  telemetryBoard ??= TelemetryBoard.fake();
  if (telemetryBoard.lastConnection != null) {
    var lastConnection =
        DateTime.parse(telemetryBoard.lastConnection).toLocal();
    if (DateTime.now().difference(lastConnection).inMinutes <= 10) {
      return true;
    }
  }
  return false;
}

Widget getTelemetryStatus(TelemetryBoard telemetryBoard) {
  if (telemetryBoard.lastConnection == null) {
    return FittedBox(
      child: Text(
        'Nunca conectada',
        textAlign: TextAlign.start,
        style: styles.medium(
          fontSize: 14,
          color: Colors.black,
        ),
      ),
    );
  } else {
    var lastConnection =
        DateTime.parse(telemetryBoard.lastConnection).toLocal();
    if (DateTime.now().difference(lastConnection).inMinutes > 10) {
      return Text(
        'Offline',
        textAlign: TextAlign.start,
        style: styles.medium(
          fontSize: 14,
          color: colors.red,
        ),
      );
    } else {
      return Text(
        'Online',
        textAlign: TextAlign.start,
        style: styles.medium(
          fontSize: 14,
          color: colors.lightGreen,
        ),
      );
    }
  }
}

Widget getTelemetryIconFromMachineLastConnection(DateTime lastConnection) {
  if (lastConnection == null) {
    return Icon(
      Icons.warning_amber_rounded,
      size: 20,
      color: Colors.amber,
    );
  } else {
    if (DateTime.now().difference(lastConnection).inMinutes > 10) {
      return Icon(
        Feather.wifi_off,
        size: 20,
        color: colors.red,
      );
    } else {
      return Icon(
        Feather.wifi,
        size: 20,
        color: colors.lightGreen,
      );
    }
  }
}

Widget getTelemetryIcon(TelemetryBoard telemetryBoard, bool isMachineCard) {
  if (!isMachineCard) {
    if (telemetryBoard.lastConnection == null) {
      return Icon(
        Icons.warning_amber_rounded,
        size: 20,
        color: Colors.amber,
      );
    } else {
      var lastConnection =
          DateTime.parse(telemetryBoard.lastConnection).toLocal();
      if (DateTime.now().difference(lastConnection).inMinutes > 10) {
        return Icon(
          Feather.wifi_off,
          size: 20,
          color: colors.red,
        );
      } else {
        return Icon(
          Feather.wifi,
          size: 20,
          color: colors.lightGreen,
        );
      }
    }
  } else {
    if (telemetryBoard.lastConnection == null) {
      return Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 20,
            color: Colors.amber,
          ),
          SizedBox(width: 5),
          Text('(STG-${telemetryBoard.id})'),
        ],
      );
    } else {
      var lastConnection =
          DateTime.parse(telemetryBoard.lastConnection).toLocal();
      if (DateTime.now().difference(lastConnection).inMinutes > 10) {
        return Row(
          children: [
            Icon(
              Feather.wifi_off,
              size: 20,
              color: colors.red,
            ),
            SizedBox(width: 5),
            Text('(STG-${telemetryBoard.id})'),
          ],
        );
      } else {
        return Row(
          children: [
            Icon(
              Feather.wifi,
              size: 20,
              color: colors.lightGreen,
            ),
            SizedBox(width: 5),
            Text('(STG-${telemetryBoard.id})'),
          ],
        );
      }
    }
  }
}

String getElapsedTime(DateTime date) {
  date = date.toLocal();
  var difference = DateTime.now().difference(date);
  var result = '';
  if (difference.inDays > 0) {
    result += '${difference.inDays}d';
    difference = difference - Duration(days: difference.inDays);
  }
  if (difference.inHours > 0) {
    if (result == '') {
      result += '${difference.inHours}h';
    } else {
      result += ', ${difference.inHours}h';
    }
    difference = difference - Duration(hours: difference.inHours);
  }
  if (difference.inMinutes > 0) {
    if (result == '') {
      result += '${difference.inMinutes}m';
    } else {
      result += ', ${difference.inMinutes}m';
    }
  }
  return result;
}

String getFormattedDate(DateTime date) {
  date = date.toLocal();
  var day =
      date.day.toString().length == 1 ? '0${date.day}' : date.day.toString();

  var month = date.month.toString().length == 1
      ? '0${date.month}'
      : date.month.toString();

  var year =
      date.year.toString().length == 1 ? '0${date.year}' : date.year.toString();

  var hour =
      date.hour.toString().length == 1 ? '0${date.hour}' : date.hour.toString();
  var minute = date.minute.toString().length == 1
      ? '0${date.minute}'
      : date.minute.toString();
  var second = date.second.toString().length == 1
      ? '0${date.second}'
      : date.second.toString();
  return '$day/$month/$year - $hour:$minute:$second';
}

String translateTelemetryStatus(String telemetryStatus) {
  switch (telemetryStatus) {
    case 'Online':
      return 'ONLINE';
    case 'Offline':
      return 'OFFLINE';
    case 'Nunca conectada':
      return 'VIRGIN';
    case 'Sem telemetria':
      return 'NO_TELEMETRY';

    default:
      return '';
  }
}
