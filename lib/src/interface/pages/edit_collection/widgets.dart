import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../../../src/interface/shared/colors.dart';
import '../../../../src/interface/shared/text_styles.dart';

import '../../../locator.dart';

final styles = locator<TextStyles>();
final colors = locator<AppColors>();

enum FlashState { OFF, ON, AUTO }

class CollectionCamera extends StatefulWidget {
  final Function onTap;
  final CameraController cameraController;

  const CollectionCamera({Key key, this.onTap, this.cameraController})
      : super(key: key);

  @override
  State<CollectionCamera> createState() => _CollectionCameraState();
}

class _CollectionCameraState extends State<CollectionCamera> {
  FlashState flash = FlashState.OFF;
  @override
  Widget build(BuildContext context) {
    if (flash == FlashState.OFF) {
      widget.cameraController.setFlashMode(FlashMode.off);
    } else if (flash == FlashState.ON) {
      widget.cameraController.setFlashMode(FlashMode.always);
    } else if (flash == FlashState.AUTO) {
      widget.cameraController.setFlashMode(FlashMode.auto);
    }
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.85,
          width: double.infinity,
          child: CameraPreview(widget.cameraController),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            iconTheme: IconThemeData(color: locator<AppColors>().primaryColor),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
              color: Colors.black,
              height: MediaQuery.of(context).size.height * 0.15,
              child: Row(
                children: [
                  Expanded(
                      child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      setState(() {
                        if (flash == FlashState.OFF) {
                          flash = FlashState.ON;
                          widget.cameraController
                              .setFlashMode(FlashMode.always);
                        } else if (flash == FlashState.ON) {
                          flash = FlashState.AUTO;
                          widget.cameraController.setFlashMode(FlashMode.auto);
                        } else if (flash == FlashState.AUTO) {
                          flash = FlashState.OFF;
                          widget.cameraController.setFlashMode(FlashMode.off);
                        }
                      });
                    },
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          flash == FlashState.OFF
                              ? Icons.flash_off_rounded
                              : flash == FlashState.ON
                                  ? Icons.flash_on_rounded
                                  : Icons.flash_auto_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await widget.cameraController
                            .setFocusMode(FocusMode.auto);
                        widget.onTap();
                      },
                      child: Center(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.08,
                          width: MediaQuery.of(context).size.height * 0.08,
                          padding: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.003,
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width:
                                    MediaQuery.of(context).size.height * 0.003,
                              ),
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: Container())
                ],
              )),
        )
      ],
    );
  }
}

class CollectionTextField extends StatelessWidget {
  final String title;
  final Function(String) onChanged;
  final List<TextInputFormatter> inputFormatters;
  final TextInputType keyboardType;
  final String initialValue;

  const CollectionTextField({
    Key key,
    this.onChanged,
    this.initialValue,
    this.keyboardType,
    this.title,
    this.inputFormatters,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              '$title',
              style: styles.regular(),
            ),
          ],
        ),
        SizedBox(height: 5),
        Container(
          height: 45,
          child: TextFormField(
            onChanged: onChanged,
            inputFormatters: inputFormatters ?? [],
            keyboardType: keyboardType ?? TextInputType.text,
            initialValue: initialValue,
            onEditingComplete: () {
              FocusScope.of(context).nextFocus();
            },
            decoration: InputDecoration(
              fillColor: colors.backgroundColor,
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: Color(0xff80bdff).withOpacity(0.3), width: 5),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.lightBlack, width: 1),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: colors.lightBlack, width: 1),
              ),
              hintStyle: styles.light(color: Colors.black38),
            ),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }
}

class PhotoService extends StatefulWidget {
  final Function onTakePicture;
  final Function onGalleryClick;
  final List<File> files;
  final Function removeAt;
  final Function removeAll;

  const PhotoService({
    Key key,
    @required this.onTakePicture,
    @required this.onGalleryClick,
    @required this.removeAll,
    @required this.removeAt,
    @required this.files,
  }) : super(key: key);
  @override
  _PhotoServiceState createState() => _PhotoServiceState();
}

class _PhotoServiceState extends State<PhotoService>
    with TickerProviderStateMixin {
  bool addPhoto = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fotos:',
              style: styles.medium(fontSize: 20),
            ),
            AnimatedSize(
              duration: Duration(milliseconds: 100),
              curve: Curves.linear,
              vsync: this,
              child: Container(
                child: !addPhoto
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (widget.files.isNotEmpty)
                            Row(
                              children: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(3)),
                                  ),
                                  onPressed: widget.removeAll,
                                  child: Text(
                                    'Limpar',
                                    style: styles.regular(
                                        color: colors.primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(width: 5),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: colors.primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3)),
                            ),
                            onPressed: () {
                              setState(() {
                                addPhoto = !addPhoto;
                              });
                            },
                            child: Text(
                              'Adicionar foto',
                              style:
                                  styles.regular(color: colors.backgroundColor),
                            ),
                          )
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3)),
                            ),
                            onPressed: () {
                              setState(() {
                                addPhoto = !addPhoto;
                              });
                            },
                            child: Text(
                              'Cancelar',
                              style: styles.regular(color: colors.primaryColor),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: colors.primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3)),
                            ),
                            onPressed: () {
                              addPhoto = !addPhoto;
                              widget.onTakePicture();
                            },
                            child: Text(
                              'Câmera',
                              style:
                                  styles.regular(color: colors.backgroundColor),
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: colors.primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3)),
                            ),
                            onPressed: () {
                              addPhoto = !addPhoto;
                              widget.onGalleryClick();
                            },
                            child: Text(
                              'Galeria',
                              style:
                                  styles.regular(color: colors.backgroundColor),
                            ),
                          )
                        ],
                      ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        if (widget.files.isNotEmpty)
          Column(
              children: List.generate(
            widget.files.length,
            (index) => Container(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.passthrough,
                  children: [
                    Image.file(widget.files[index]),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () {
                          widget.removeAt(index);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10)),
                            color: Colors.black,
                          ),
                          height: 40,
                          width: 40,
                          child: Icon(
                            Feather.x,
                            color: colors.backgroundColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ))
        else
          Container(
            margin: EdgeInsets.only(bottom: 25),
            height: MediaQuery.of(context).size.width - 50,
            width: MediaQuery.of(context).size.width,
            child: Image.asset(
              'assets/thumbnail.png',
              fit: BoxFit.fitHeight,
            ),
          ),
      ],
    );
  }
}

class GeneralObservations extends StatelessWidget {
  final colors = locator<AppColors>();
  final styles = locator<TextStyles>();
  final String initialValue;
  final Function(String) onChanged;

  GeneralObservations({this.onChanged, this.initialValue});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          onChanged: (v) => onChanged(v),
          maxLines: null,
          initialValue: initialValue,
          decoration: InputDecoration(
            fillColor: colors.backgroundColor,
            filled: true,
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: Color(0xff80bdff).withOpacity(0.3), width: 5),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colors.lightBlack, width: 1),
            ),
            hintStyle: styles.light(color: Colors.black38),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }
}
