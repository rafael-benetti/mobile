import 'package:flutter/material.dart';
import 'custom_dropdown.dart';

class TitledDropDown extends StatelessWidget {
  final String initialValue;
  final List<DropdownInputOption> options;
  final String title;
  final Function(DropdownInputOption) onSelect;

  const TitledDropDown({
    Key key,
    this.initialValue,
    @required this.onSelect,
    @required this.options,
    @required this.title,
  }) : super(key: key);
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
          CustomDropdownButton(
            onSelect: onSelect,
            onExpand: (expanded) {},
            initialValue: DropdownInputOption(title: initialValue ?? ''),
            values: options,
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}
