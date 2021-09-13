import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/interface/shared/error_translator.dart';
import '../../../../src/interface/shared/validators.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/interface_service.dart';
import '../../shared/colors.dart';
import '../../widgets/dialog_action.dart';
import '../../../locator.dart';
import 'package:http/http.dart' as http;

class EditProfilePageModel extends BaseViewModel {
  File _image;
  File get image => _image;
  final interfaceService = locator<InterfaceService>();

  final userProvider = locator<UserProvider>();

  Future fetchUser() async {
    setBusy(true);
    interfaceService.showLoader();
    var response = await locator<UserProvider>().fetchUser();
    interfaceService.closeLoader();
    if (response.status != Status.success) {
      interfaceService.goBack();
      await interfaceService.showDialogMessage(
        title: 'Ops! Algo aconteceu...',
        message: 'Verifique sua conexão e tente novamente.',
        actions: [
          DialogAction(
            onPressed: () => interfaceService.goBack(),
            title: 'Voltar',
          )
        ],
      );
      return;
    }
    setBusy(false);
    notifyListeners();
  }

  String name;
  String phone;
  String newPassword;
  String confirmNewPassword;
  String oldPassword;
  Map data = {};

  String validationError;

  Future<bool> createProfileData() async {
    if (phone != null) {
      if (phone.length == 14 || phone.length == 15) {
        if (!phone.contains('+55')) phone = convertPhoneNumberToAPI(phone);
        data['phoneNumber'] = phone;
      } else {
        validationError = 'Telefone inválido.';
        return false;
      }
    }
    //validation 1
    if (name.replaceAll(' ', '') == '' || name == null) {
      validationError = 'Nome é obrigatório.';
      return false;
    }
    data['name'] = name;

    //validation 2
    if ((oldPassword == null && newPassword != null) ||
        (oldPassword != null && newPassword == null)) {
      validationError = 'Campos de senha incompletos.';
      return false;
    }

    if (newPassword != confirmNewPassword) {
      validationError =
          'Confirmação de nova senha não coincide com nova senha.';
      return false;
    }

    if (newPassword != null) {
      data['newPassword'] = newPassword;
      data['password'] = oldPassword;
    }
    return true;
  }

  Future updateProfile() async {
    var canUpdate = await createProfileData();
    if (canUpdate) {
      interfaceService.showLoader();
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('${ApiService.baseUrl}${ApiRoutes().profile}'),
      );
      request.fields['name'] = data['name'];
      if (data['phoneNumber'] != null) {
        request.fields['phoneNumber'] = data['phoneNumber'];
      }
      if (data['password'] != null) {
        request.fields['newPassword'] = data['newPassword'];
        request.fields['password'] = data['password'];
      }
      if (_image != null) {
        request.files
            .add(await http.MultipartFile.fromPath('file', _image.path));
      }
      request.headers.addAll(ApiService.baseHeaders);
      await request.send().then((http.StreamedResponse response) async {
        var body = await response.stream.bytesToString();
        interfaceService.closeLoader();
        if (response.statusCode == 200) {
          await userProvider.fetchUser();
          interfaceService.goBack();
          interfaceService.showSnackBar(
              message: 'Perfil atualizado.',
              backgroundColor: colors.lightGreen);
        } else {
          interfaceService.showSnackBar(
              message: translateError(body), backgroundColor: colors.red);
        }
      });
    } else {
      //dialog
      interfaceService.showSnackBar(
          message: validationError, backgroundColor: locator<AppColors>().red);
    }
  }

  void imgFromCamera() async {
    var image = await ImagePicker().getImage(source: ImageSource.camera);
    _image = File(image.path);
    notifyListeners();
  }

  void imgFromGallery() async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    _image = File(image.path);
    notifyListeners();
  }
}
