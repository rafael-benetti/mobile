import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kow_form/kow_form.dart';
import '../../../core/models/group.dart';
import '../../../core/services/interface_service.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';
import '../../widgets/custom_dropdown.dart';

import '../../../locator.dart';

final styles = locator<TextStyles>();
final colors = locator<AppColors>();

class SubmitButtons extends StatelessWidget {
  final Function onSubmit;
  final String submitText;

  const SubmitButtons({Key key, this.onSubmit, this.submitText})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 35,
            // ignore: deprecated_member_use
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
              color: colors.red,
              onPressed: () {
                locator<InterfaceService>().goBack();
              },
              child: Text(
                'Cancelar',
                style: styles.regular(
                  color: colors.backgroundColor,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Container(
            height: 35,
            // ignore: deprecated_member_use
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
              color: colors.primaryColor,
              onPressed: onSubmit,
              child: Text(
                submitText,
                style: styles.regular(
                  color: colors.backgroundColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GroupDropdown extends StatelessWidget {
  final List<Group> groups;

  const GroupDropdown({Key key, this.groups}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: KowInput(
          path: 'groupId',
          builder: (context, onSelected, initialValue) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parceria',
                  style: styles.light(fontSize: 16),
                ),
                SizedBox(height: 10),
                CustomDropdownButton(
                  maxHeight: 112.5,
                  onSelect: (selected) => {
                    onSelected(
                      groups
                          .firstWhere(
                              (element) => element.label == selected.title)
                          .id,
                    )
                  },
                  initialValue: DropdownInputOption(
                    title: initialValue != ''
                        ? groups
                            .firstWhere((element) => element.id == initialValue)
                            .label
                        : '',
                  ),
                  values: List.generate(
                    groups.length,
                    (index) => DropdownInputOption(
                      title: groups[index].label,
                    ),
                  ),
                ),
                SizedBox(height: 15),
              ],
            );
          }),
    );
  }
}

class KowRentField extends StatefulWidget {
  final String path;
  final String title;
  final Function(String) extraFunction;
  final List<TextInputFormatter> inputFormatters;
  final TextInputType keyboardType;
  final bool enabled;
  final bool isPercentage;
  final Function(int) getRentType;

  const KowRentField({
    Key key,
    this.path,
    this.title,
    this.enabled,
    this.keyboardType,
    this.inputFormatters,
    this.extraFunction,
    this.isPercentage,
    this.getRentType,
  }) : super(key: key);

  @override
  _KowRentFieldState createState() => _KowRentFieldState();
}

class _KowRentFieldState extends State<KowRentField> {
  int groupValue;
  bool reset = false;
  @override
  void initState() {
    if (widget.isPercentage != null) {
      groupValue = widget.isPercentage ? 1 : 0;
    } else {
      groupValue = 0;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: styles.light(fontSize: 16),
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: KowInput(
                  path: widget.path,
                  builder: (context, onChanged, formInitialValue) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EditPointOfSaleTextField(
                        suffixText: Text(groupValue == 0 ? 'R\$' : '%'),
                        enabled: widget.enabled,
                        keyboardType: widget.keyboardType,
                        initialValue: formInitialValue.toString(),
                        inputFormatters: groupValue == 0
                            ? [
                                FilteringTextInputFormatter.digitsOnly,
                                RealInputFormatter(centavos: true)
                              ]
                            : [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                        onChanged: (value) {
                          if (widget.extraFunction != null) {
                            widget.extraFunction(value);
                          }
                          if (value != '') {
                            value =
                                value.replaceAll('.', '').replaceAll(',', '.');
                            onChanged(double.parse(value));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10),
              Container(
                constraints: BoxConstraints(minWidth: 200),
                child: Row(
                  children: [
                    Radio(
                      activeColor: locator<AppColors>().primaryColor,
                      groupValue: groupValue,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: 0,
                      onChanged: (value) {
                        widget.getRentType(value);
                        setState(() {
                          groupValue = value;
                          reset = true;
                        });
                      },
                    ),
                    Text('Reais'),
                    SizedBox(width: 10),
                    Radio(
                      activeColor: locator<AppColors>().primaryColor,
                      groupValue: groupValue,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: 1,
                      onChanged: (value) {
                        widget.getRentType(value);
                        setState(() {
                          groupValue = value;
                          reset = true;
                        });
                      },
                    ),
                    Text('Porcento')
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 15)
        ],
      ),
    );
  }
}

class KowTextField extends StatelessWidget {
  final String path;
  final String title;
  final Function(String) extraFunction;
  final List<TextInputFormatter> inputFormatters;
  final TextInputType keyboardType;
  final String initialValue;
  final bool enabled;

  const KowTextField({
    Key key,
    this.path,
    this.title,
    this.enabled,
    this.initialValue,
    this.keyboardType,
    this.inputFormatters,
    this.extraFunction,
  }) : super(key: key);

  String getInitialValue(String formInitialValue, String initialValue) {
    if (initialValue != null) return initialValue;

    if (formInitialValue != '') {
      return formInitialValue;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: KowInput(
        path: path,
        builder: (context, onChanged, formInitialValue) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: styles.light(fontSize: 16),
            ),
            SizedBox(height: 10),
            EditPointOfSaleTextField(
              enabled: enabled,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              onChanged: (value) {
                if (extraFunction != null) {
                  extraFunction(value);
                }
                onChanged(value);
              },
              initialValue: getInitialValue(formInitialValue, initialValue),
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

class EditPointOfSaleTextField extends StatelessWidget {
  final String hintText;
  final Function(String) onChanged;
  final String initialValue;
  final bool enabled;
  final Text suffixText;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;

  EditPointOfSaleTextField({
    this.hintText,
    this.onChanged,
    this.inputFormatters,
    this.initialValue,
    this.suffixText,
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
      onEditingComplete: () {
        FocusScope.of(context).nextFocus();
      },
      decoration: InputDecoration(
        suffix: suffixText,
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
