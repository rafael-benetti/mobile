import 'dart:convert';

String translateError(response) {
  var data;
  try {
    data = json.decode(response)['errorCode'];
  } catch (e) {
    print(e);
  }

  switch (data) {
    case 'EMAIL_ALREADY_USED':
      return 'Este email já está em uso.';
    case 'LABEL_ALREADY_USED':
      return 'Este nome já está em uso.';
    case 'MACHINE_BELONGS_TO_A_ROUTE':
      return 'Esta máquina pertence a uma rota.';
    case 'SERIAL_NUMBER_ALREADY_USED':
      return 'Este número de série já está em uso.';
    case 'INCORRECT_EMAIL_PASSWORD_COMBINATION':
      return 'Email ou senha incorretos.';
    case 'VALIDATION_ERROR':
      return 'Campos inválidos.';
    case 'YOU_CAN_ONLY_EDIT_LAST_COLLECTION':
      return 'Você só pode editar a última coleta.';
    case 'TELEMETRY_BOARD_NOT_FOUND':
      return 'Esta máquina não possui telemetria.';
    case 'THIS_MACHINE_IS_OFFLINE':
      return 'Esta máquina está offline.';
    case 'MACHINE_CATEGORY_NOT_FOUND':
      return 'Esta máquina está offline.';
    case 'USER_IS_INACTIVE':
      return 'Este usuário está desativado.';
    default:
      return 'Algo deu errado. Tente novamente.';
  }
}
