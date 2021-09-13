import 'dart:io';

import 'package:flutter/material.dart';
import '../../../../src/core/models/counter_collection.dart';
import '../../../../src/interface/shared/colors.dart';

import '../../../locator.dart';

class FullPhotoPage extends StatelessWidget {
  static const route = '/fullPhoto';
  @override
  Widget build(BuildContext context) {
    File file;
    String url;
    if (ModalRoute.of(context).settings.arguments is File) {
      file = ModalRoute.of(context).settings.arguments;
    } else {
      url = (ModalRoute.of(context).settings.arguments as CounterPhoto)
          .downloadUrl;
    }
    return Stack(
      children: [
        Container(
          color: Colors.black,
          height: MediaQuery.of(context).size.height,
          child: file != null
              ? Image.file(
                  file,
                  fit: BoxFit.cover,
                )
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                ),
        ),
        Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: locator<AppColors>().primaryColor),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          backgroundColor: Colors.transparent,
        )
      ],
    );
  }
}
