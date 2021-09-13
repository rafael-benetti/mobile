import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../shared/text_styles.dart';
import 'custom_text_field.dart';

import '../../locator.dart';

final styles = locator<TextStyles>();

class TitledTextField extends StatelessWidget {
  final String title;
  final Function(String) onChanged;
  final String initialValue;
  final bool enabled;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;

  const TitledTextField({
    this.title,
    this.onChanged,
    this.initialValue,
    this.keyboardType,
    this.enabled,
    this.inputFormatters,
  });
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: styles.light(fontSize: 16),
          ),
          SizedBox(height: 10),
          CustomTextField(
            enabled: enabled,
            onChanged: onChanged,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters ?? [],
            initialValue: initialValue,
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}
