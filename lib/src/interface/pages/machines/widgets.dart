import 'package:flutter/material.dart';
import '../../../../src/core/models/user.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';
import '../../widgets/custom_dropdown.dart';

import '../../../locator.dart';

final styles = locator<TextStyles>();
final colors = locator<AppColors>();

class FilterDropdown extends StatelessWidget {
  final String title;
  final String filteredField;
  final Function filterField;
  final List<dynamic> listOfOptions;

  const FilterDropdown(
      {Key key,
      this.title,
      this.filteredField,
      this.filterField,
      this.listOfOptions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        SizedBox(height: 5),
        SizedBox(
          width: 600,
          child: CustomDropdownButton(
            initialValue: DropdownInputOption(
              title: filteredField == 'null'
                  ? 'Em Estoque'
                  : filteredField != null
                      ? listOfOptions[0] is User
                          ? listOfOptions
                              .firstWhere(
                                  (element) => element.id == filteredField)
                              .name
                          : filteredField != null
                              ? listOfOptions
                                  .firstWhere(
                                      (element) => element.id == filteredField)
                                  .label
                              : 'Todos'
                      : 'Todos',
            ),
            maxHeight: 112.5,
            onSelect: (option) {
              if (option.title.toLowerCase().contains('estoque')) {
                filterField('null');
              } else if (option.title.toLowerCase() == 'todas' ||
                  option.title.toLowerCase() == 'todos') {
                filterField(null);
              } else {
                filterField(listOfOptions
                    .firstWhere((element) => element is User
                        ? element.name == option.title
                        : element.label == option.title)
                    .id);
              }
            },
            values: [
                  DropdownInputOption(
                    title: 'Todas',
                  ),
                  if (title == 'Localização')
                    DropdownInputOption(title: 'Em estoque')
                ] +
                List.generate(
                  listOfOptions.length,
                  (index) => DropdownInputOption(
                    title: listOfOptions[index] is User
                        ? listOfOptions[index].name
                        : listOfOptions[index].label,
                  ),
                ),
          ),
        ),
      ],
    );
  }
}
