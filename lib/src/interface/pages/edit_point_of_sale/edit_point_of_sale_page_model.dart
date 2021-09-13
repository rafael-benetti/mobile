import 'dart:convert';

import 'package:http/http.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/core/services/api_service.dart';
import '../../../../src/interface/shared/error_translator.dart';
import '../../../core/models/group.dart';
import '../../../core/models/point_of_sale.dart';
import '../../../core/providers/groups_provider.dart';
import '../../../core/providers/points_of_sale_provider.dart';
import '../../../core/services/interface_service.dart';
import '../../shared/colors.dart';
import '../../shared/validators.dart';

import '../../../locator.dart';

class EditPointOfSalePageModel extends BaseViewModel {
  PointOfSale _pointOfSale;
  set pointOfSale(value) => _pointOfSale = value;
  PointOfSale get pointOfSale => _pointOfSale;

  final _pointsOfSaleProvider = locator<PointsOfSaleProvider>();

  final _groups = locator<GroupsProvider>().groups;
  List<Group> get groups => _groups;

  Map<String, dynamic> pointOfSaleData;

  final _client = Client();

  String chosenGroup;
  String state;
  String city;
  String neighborhood;
  String street;
  String name;
  String contactName;
  String primaryPhoneNumber;
  String secondaryPhoneNumber;
  bool isPercentage = false;

  void getRentType(int value) {
    switch (value) {
      case 0:
        isPercentage = false;
        return;
      case 1:
        isPercentage = true;
        return;
      default:
        return;
    }
  }

  Future findCEP(String cep) async {
    cep = cep.replaceAll('.', '').replaceAll('-', '');
    if (cep.length < 8) return;
    locator<InterfaceService>().showLoader();
    await _client
        .get(Uri.parse('https://viacep.com.br/ws/$cep/json/'))
        .then((value) {
      var tmp = json.decode(value.body);
      city = tmp['localidade'];
      state = tmp['uf'];
      neighborhood = tmp['bairro'];
      street = tmp['logradouro'];

      notifyListeners();
    }).timeout(Duration(seconds: 10), onTimeout: () {
      locator<InterfaceService>().closeLoader();
    });
    locator<InterfaceService>().closeLoader();
  }

  Map<String, dynamic> initialData() {
    if (_pointOfSale == null) {
      return {
        'groupId': '',
        'label': '',
        'contactName': '',
        'primaryPhoneNumber': '',
        'secondaryPhoneNumber': '',
        'rent': 0,
        'isPercentage': '',
        'address': {
          'zipCode': '',
          'state': '',
          'city': '',
          'neighborhood': '',
          'street': '',
          'number': '',
          'extraInfo': ''
        }
      };
    } else {
      return {
        'groupId': _pointOfSale.groupId,
        'label': _pointOfSale.label,
        'contactName': _pointOfSale.contactName,
        'primaryPhoneNumber':
            convertPhoneNumberFromAPI(_pointOfSale.primaryPhoneNumber),
        'secondaryPhoneNumber':
            convertPhoneNumberFromAPI(_pointOfSale.secondaryPhoneNumber),
        'rent':
            _pointOfSale.rent.toStringAsFixed(2).replaceAll('.', ',') ?? '0',
        'isPercentage': _pointOfSale.isPercentage ?? '',
        'address': {
          'zipCode': _pointOfSale.zipCode,
          'state': _pointOfSale.state,
          'city': _pointOfSale.city,
          'neighborhood': _pointOfSale.neighborhood,
          'street': _pointOfSale.street,
          'number': _pointOfSale.number,
          'extraInfo': _pointOfSale.extraInfo
        }
      };
    }
  }

  Future updatePointOfSale() async {
    if (pointOfSaleData['secondaryPhoneNumber'] == '' ||
        pointOfSaleData['secondaryPhoneNumber'] == null) {
      pointOfSaleData.remove('secondaryPhoneNumber');
    }
    if (validateFields() == '') {
      if (checkPhoneNumbers()) {
        if (pointOfSaleData['address']['extraInfo'] == '' ||
            pointOfSaleData['address']['extraInfo'] == null) {
          pointOfSaleData.remove('address');
        } else {
          pointOfSaleData['address'] = {
            'extraInfo': pointOfSaleData['address']['extraInfo']
          };
        }
        pointOfSaleData.remove('groupId');
        if (pointOfSaleData['rent'].runtimeType == String) {
          pointOfSaleData['rent'] =
              double.parse(pointOfSaleData['rent'].replaceAll(',', '.'));
        }
        locator<InterfaceService>().showLoader();
        var response = await _pointsOfSaleProvider.editPointOfSale(
            pointOfSale.id, pointOfSaleData);
        locator<InterfaceService>().closeLoader();
        if (response.status == Status.success) {
          locator<InterfaceService>().showSnackBar(
            message: 'Ponto de venda editado com sucesso',
            backgroundColor: locator<AppColors>().lightGreen,
          );
          locator<InterfaceService>().goBack();
        } else {
          locator<InterfaceService>().showSnackBar(
            message: translateError(response.data),
            backgroundColor: locator<AppColors>().red,
          );
        }
      }
    } else {
      locator<InterfaceService>().showSnackBar(
          message: translateValidation(validateFields()),
          backgroundColor: locator<AppColors>().red);
    }
  }

  bool checkPhoneNumbers() {
    if (pointOfSaleData['secondaryPhoneNumber'] != null &&
        pointOfSaleData['secondaryPhoneNumber'] != '') {
      if (pointOfSaleData['secondaryPhoneNumber'].length < 14) {
        locator<InterfaceService>().showSnackBar(
          message: 'O campo Telefone 2 deve conter 14 ou 15 dígitos.',
          backgroundColor: locator<AppColors>().red,
        );
        return false;
      } else {
        pointOfSaleData['secondaryPhoneNumber'] =
            '+55${pointOfSaleData['primaryPhoneNumber'].replaceAll(' ', '').replaceAll('(', '').replaceAll(')', '').replaceAll('-', '')}';
      }
    }
    if (pointOfSaleData['primaryPhoneNumber'].length < 14) {
      locator<InterfaceService>().showSnackBar(
        message: 'O campo Telefone 1 deve conter 14 ou 15 dígitos.',
        backgroundColor: locator<AppColors>().red,
      );
      return false;
    }
    pointOfSaleData['primaryPhoneNumber'] =
        '+55${pointOfSaleData['primaryPhoneNumber'].replaceAll(' ', '').replaceAll('(', '').replaceAll(')', '').replaceAll('-', '')}';
    return true;
  }

  Future createPointOfSale() async {
    if (pointOfSaleData['address']['extraInfo'] == '') {
      pointOfSaleData['address'].remove('extraInfo');
    }
    if (pointOfSaleData['secondaryPhoneNumber'] == '') {
      pointOfSaleData.remove('secondaryPhoneNumber');
    }
    if (groups.length == 1) {
      pointOfSaleData['groupId'] = groups[0].id;
    }
    if (validateFields() == '') {
      if (checkPhoneNumbers()) {
        locator<InterfaceService>().showLoader();
        var response =
            await _pointsOfSaleProvider.createPointOfSale(pointOfSaleData);
        locator<InterfaceService>().closeLoader();
        if (response.status == Status.success) {
          locator<InterfaceService>().showSnackBar(
            message: 'Ponto de venda criado com sucesso',
            backgroundColor: locator<AppColors>().lightGreen,
          );
          locator<InterfaceService>().goBack();
        } else {
          locator<InterfaceService>().showSnackBar(
            message: translateError(response.data),
            backgroundColor: locator<AppColors>().red,
          );
        }
      }
    } else {
      locator<InterfaceService>().showSnackBar(
          message: translateValidation(validateFields()),
          backgroundColor: locator<AppColors>().red);
    }
  }

  String translateValidation(String validation) {
    switch (validation) {
      case 'groupId':
        return 'O campo Parceria é obrigatório.';
      case 'label':
        return 'O campo Nome é obrigatório.';
      case 'contactName':
        return 'O campo Contato é obrigatório.';
      case 'primaryPhoneNumber':
        return 'O campo Telefone 1 é obrigatório.';
      case 'zipCode':
        return 'O campo CEP é obrigatório.';
      case 'number':
        return 'O campo Número é obrigatório.';
      case 'invalid ZipCode':
        return 'CEP inválido';
      case 'state':
        return 'O campo Estado é obrigatório';
      case 'city':
        return 'O campo Cidade é obrigatório';
      case 'neighborhood':
        return 'O campo Bairro é obrigatório';
      case 'street':
        return 'O campo Rua é obrigatório';
      default:
        return validation;
    }
  }

  String validateFields() {
    var emptyFields = [];
    if (pointOfSaleData['address']['state'] == '') {
      pointOfSaleData['address']['state'] = state;
    }
    if (pointOfSaleData['address']['city'] == '') {
      pointOfSaleData['address']['city'] = city;
    }
    if (pointOfSaleData['address']['neighborhood'] == '') {
      pointOfSaleData['address']['neighborhood'] = neighborhood;
    }
    if (pointOfSaleData['address']['street'] == '') {
      pointOfSaleData['address']['street'] = street;
    }
    pointOfSaleData['isPercentage'] = isPercentage;
    if (city == null ||
        state == null ||
        neighborhood == null ||
        street == null) {
      return 'invalid ZipCode';
    }
    if (pointOfSaleData['rent'] == '' || pointOfSaleData['rent'] == null) {
      pointOfSaleData.remove('rent');
      pointOfSaleData.remove('isPercentage');
    }
    pointOfSaleData.forEach((key, value) {
      if (value == '') {
        if (key != 'secondaryPhoneNumber') emptyFields.add(key);
      }
    });

    pointOfSaleData['address'].forEach((key, value) {
      if (value == '') if (key != 'extraInfo') emptyFields.add(key);
    });
    if (emptyFields.isNotEmpty) {
      return emptyFields[0];
    }
    return '';
  }
}
