import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';
import 'widgets.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';
import '../../shared/validators.dart';
import '../../widgets/current_path.dart';
import '../../widgets/side_buttons.dart';
import '../../widgets/titled_text_field.dart';
import '../../../locator.dart';
import 'edit_profile_page_model.dart';

class EditProfilePage extends StatelessWidget {
  static const route = '/editprofile';
  final styles = locator<TextStyles>();
  final colors = locator<AppColors>();
  final screenKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EditProfilePageModel>.reactive(
      viewModelBuilder: () => EditProfilePageModel(),
      disposeViewModel: true,
      onModelReady: (model) async {
        await model.fetchUser();
        model.name = model.userProvider.user.name;
        model.phone =
            convertPhoneNumberFromAPI(model.userProvider.user.phoneNumber);
      },
      builder: (context, model, child) => Scaffold(
        body: CustomScrollView(
          shrinkWrap: true,
          controller: _scrollController,
          slivers: !model.isBusy
              ? [
                  SliverAppBar(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    iconTheme: IconThemeData(color: colors.primaryColor),
                    elevation: 0,
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                    sliver: MultiSliver(
                      children: [
                        CurrentPath(
                          topText: 'Meu Perfil',
                          bottomFinalText: ' / Editar',
                        ),
                        ProfilePicture(
                          profilePic: model.userProvider.user.photo,
                          image: model.image,
                          imgFromCamera: model.imgFromCamera,
                          imgFromGallery: model.imgFromGallery,
                        ),
                        TitledTextField(
                          title: 'Nome',
                          initialValue: model.userProvider.user.name,
                          onChanged: (value) => model.name = value,
                        ),
                        TitledTextField(
                          title: 'Email',
                          initialValue: model.userProvider.user.email,
                          enabled: false,
                          keyboardType: TextInputType.datetime,
                        ),
                        TitledTextField(
                          title: 'Telefone',
                          keyboardType: TextInputType.number,
                          initialValue:
                              model.userProvider.user.phoneNumber != null
                                  ? convertPhoneNumberFromAPI(
                                      model.userProvider.user.phoneNumber)
                                  : '',
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            TelefoneInputFormatter(),
                          ],
                          onChanged: (value) {
                            if (value == '') {
                              model.phone = null;
                            } else {
                              model.phone = value;
                            }
                          },
                        ),
                        ChangePassword(
                          onCurrentPasswordChanged: (value) =>
                              model.oldPassword = value,
                          onNewPasswordChanged: (value) =>
                              model.newPassword = value,
                          onConfirmNewPasswordChanged: (value) =>
                              model.confirmNewPassword = value,
                        ),
                        Buttons(
                          onSubmit: model.updateProfile,
                          submitText: 'Salvar',
                        )
                      ],
                    ),
                  )
                ]
              : [],
        ),
      ),
    );
  }
}
