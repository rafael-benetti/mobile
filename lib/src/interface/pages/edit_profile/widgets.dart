import 'dart:io';

import 'package:flutter/material.dart';
import '../../widgets/dialog_action.dart';
import '../../../core/services/interface_service.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';
import '../../widgets/custom_text_field.dart';

import '../../../locator.dart';

final styles = locator<TextStyles>();
final colors = locator<AppColors>();

class ProfilePicture extends StatelessWidget {
  final File image;
  final Function imgFromCamera;
  final String profilePic;
  final Function imgFromGallery;

  const ProfilePicture({
    this.image,
    this.profilePic,
    this.imgFromCamera,
    this.imgFromGallery,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () {
          locator<InterfaceService>().showDialogWithWidgets(
            widget: Container(),
            color: colors.primaryColor,
            title: 'Foto de perfil',
            actions: [
              DialogAction(
                title: 'Cancelar',
                onPressed: () {
                  locator<InterfaceService>().goBack();
                },
              ),
              DialogAction(
                title: 'Galeria',
                onPressed: () async {
                  await imgFromGallery();
                  locator<InterfaceService>().goBack();
                },
              ),
              DialogAction(
                title: 'Câmera',
                onPressed: () async {
                  await imgFromCamera();
                  locator<InterfaceService>().goBack();
                },
              ),
            ],
          );
        },
        child: Container(
          height: 230,
          child: Center(
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                border: Border.all(color: colors.lightBlack, width: 2),
                borderRadius: BorderRadius.circular(100),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: image == null
                    ? (profilePic == null
                        ? Image.asset(
                            'assets/profile_thumbnail.png',
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            profilePic,
                            fit: BoxFit.cover,
                          ))
                    : Image.file(
                        image,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChangePassword extends StatefulWidget {
  final Function(String) onCurrentPasswordChanged;
  final Function(String) onNewPasswordChanged;
  final Function(String) onConfirmNewPasswordChanged;

  const ChangePassword(
      {Key key,
      this.onCurrentPasswordChanged,
      this.onNewPasswordChanged,
      this.onConfirmNewPasswordChanged})
      : super(key: key);
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword>
    with TickerProviderStateMixin {
  bool changePassword = false;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AnimatedSize(
        duration: Duration(milliseconds: 200),
        curve: Curves.linear,
        vsync: this,
        child: !changePassword
            ? Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      changePassword = !changePassword;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 25),
                    child: Text(
                      'Trocar senha',
                      style: styles.regular(color: colors.primaryColor),
                    ),
                  ),
                ),
              )
            : Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(),
                    SizedBox(height: 10),
                    Text(
                      'Senha atual',
                      style: styles.light(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      obscureText: true,
                      onChanged: widget.onCurrentPasswordChanged,
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Nova senha',
                      style: styles.light(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      obscureText: true,
                      onChanged: widget.onNewPasswordChanged,
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Confirmar nova senha',
                      style: styles.light(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      obscureText: true,
                      onChanged: widget.onConfirmNewPasswordChanged,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            changePassword = !changePassword;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 15, 0, 10),
                          child: Text(
                            'Cancelar',
                            style: styles.regular(color: colors.primaryColor),
                          ),
                        ),
                      ),
                    ),
                    Divider(),
                    SizedBox(height: 15),
                  ],
                ),
              ),
      ),
    );
  }
}
