import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../shared/colors.dart';
import '../shared/text_styles.dart';
import '../../locator.dart';

final colors = locator<AppColors>();
final styles = locator<TextStyles>();

class CustomTextField extends StatelessWidget {
  final String hintText;
  final Function(String) onChanged;
  final String initialValue;
  final bool enabled;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final bool obscureText;

  CustomTextField({
    this.hintText,
    this.obscureText,
    this.onChanged,
    this.inputFormatters,
    this.initialValue,
    this.enabled,
    this.keyboardType,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      child: TextFormField(
        onChanged: onChanged,
        inputFormatters: inputFormatters ?? [],
        keyboardType: keyboardType ?? TextInputType.text,
        initialValue: initialValue,
        obscureText: obscureText ?? false,
        onEditingComplete: () {
          FocusScope.of(context).nextFocus();
        },
        decoration: InputDecoration(
          fillColor: colors.backgroundColor,
          filled: enabled ?? true,
          enabled: enabled ?? true,
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: Color(0xff80bdff).withOpacity(0.3), width: 5),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colors.lightBlack, width: 1),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: colors.lightBlack, width: 1),
          ),
          hintText: hintText ?? '',
          hintStyle: styles.light(color: Colors.black38),
        ),
      ),
    );
  }
}

class CustomTextFieldWithController extends StatelessWidget {
  final String hintText;
  final Function(String) onChanged;
  final String initialValue;
  final bool enabled;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final bool obscureText;

  CustomTextFieldWithController({
    this.hintText,
    this.obscureText,
    this.onChanged,
    this.inputFormatters,
    this.initialValue,
    this.enabled,
    this.keyboardType,
  });
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      inputFormatters: inputFormatters ?? [],
      keyboardType: keyboardType ?? TextInputType.text,
      controller: TextEditingController(text: initialValue),
      obscureText: obscureText ?? false,
      decoration: InputDecoration(
        fillColor: colors.backgroundColor,
        filled: enabled ?? true,
        enabled: enabled ?? true,
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: Color(0xff80bdff).withOpacity(0.3), width: 5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.lightBlack, width: 1),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: colors.lightBlack, width: 1),
        ),
        hintText: hintText ?? '',
        hintStyle: styles.light(color: Colors.black38),
      ),
    );
  }
}
