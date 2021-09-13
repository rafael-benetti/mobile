import 'package:flutter/material.dart';
import '../shared/colors.dart';
import '../shared/text_styles.dart';

import '../../locator.dart';

final colors = locator<AppColors>();
final styles = locator<TextStyles>();

class DropdownInputOption {
  final String title;
  final String option;

  DropdownInputOption({@required this.title, this.option});
}

class CustomDropdownButton extends StatefulWidget {
  final List<DropdownInputOption> values;
  final void Function(DropdownInputOption value) onSelect;
  final DropdownInputOption initialValue;
  final void Function(bool expanded) onExpand;
  final double maxHeight;

  const CustomDropdownButton({
    this.onExpand,
    this.values = const [],
    this.onSelect,
    this.initialValue,
    this.maxHeight,
  });

  @override
  _CustomDropdownButtonState createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {
  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      selected = widget.initialValue;
    }
  }

  bool expanded = false;
  DropdownInputOption selected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        setState(() {
          expanded = !expanded;

          if (widget.onExpand != null) widget.onExpand(expanded);
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 150),
            curve: Curves.easeOut,
            height: 48,
            alignment: Alignment.center,
            width: double.maxFinite,
            padding: EdgeInsets.only(left: 15),
            decoration: BoxDecoration(
              color: colors.backgroundColor,
              borderRadius: expanded
                  ? BorderRadius.vertical(
                      top: Radius.circular(
                        5,
                      ),
                    )
                  : BorderRadius.all(
                      Radius.circular(
                        5,
                      ),
                    ),
              border: Border.all(
                color: colors.lightBlack,
                width: 1,
                style: BorderStyle.solid,
              ),
            ),
            child: TextField(
              enabled: false,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: selected == null ? 'Selecione' : selected.title,
                contentPadding: EdgeInsets.only(bottom: 5),
                hintStyle: styles.regular(color: Colors.black),
                suffixIcon: Icon(
                  !expanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 150),
            height: expanded ? widget.values.length * 45.0 : 0,
            constraints:
                BoxConstraints(maxHeight: widget.maxHeight ?? double.infinity),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              border: expanded
                  ? Border.all(width: 1, color: colors.lightBlack)
                  : null,
              color: colors.backgroundColor,
              borderRadius: expanded
                  ? BorderRadius.vertical(
                      bottom: Radius.circular(
                        10,
                      ),
                    )
                  : BorderRadius.all(
                      Radius.circular(
                        10,
                      ),
                    ),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: List<Widget>.from(
                widget.values.map(
                  (value) => GestureDetector(
                    onTap: () {
                      setState(() {
                        selected = value;
                        expanded = false;
                        widget.onSelect(value);
                      });
                    },
                    behavior: HitTestBehavior.translucent,
                    child: Container(
                      color: colors.backgroundColor,
                      height: 45,
                      padding: EdgeInsets.only(
                        left: 15,
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value.title,
                        style: styles.regular(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomKrowchDropdownButton extends StatefulWidget {
  final List<DropdownInputOption> values;
  final void Function(DropdownInputOption value) onSelect;
  final DropdownInputOption currentValue;
  final double maxHeight;

  const CustomKrowchDropdownButton({
    this.values = const [],
    this.onSelect,
    this.currentValue,
    this.maxHeight,
  });

  @override
  _CustomKrowchDropdownButtonState createState() =>
      _CustomKrowchDropdownButtonState();
}

class _CustomKrowchDropdownButtonState
    extends State<CustomKrowchDropdownButton> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        setState(() {
          expanded = !expanded;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 150),
            curve: Curves.easeOut,
            height: 48,
            alignment: Alignment.center,
            width: double.maxFinite,
            padding: EdgeInsets.only(left: 15),
            decoration: BoxDecoration(
              color: colors.backgroundColor,
              borderRadius: expanded
                  ? BorderRadius.vertical(
                      top: Radius.circular(
                        5,
                      ),
                    )
                  : BorderRadius.all(
                      Radius.circular(
                        5,
                      ),
                    ),
              border: Border.all(
                color: colors.lightBlack,
                width: 1,
                style: BorderStyle.solid,
              ),
            ),
            child: TextField(
              enabled: false,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.currentValue == null
                    ? 'Selecione'
                    : widget.currentValue.title,
                contentPadding: EdgeInsets.only(bottom: 5),
                hintStyle: styles.regular(color: Colors.black),
                suffixIcon: Icon(
                  !expanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 150),
            height: expanded ? widget.values.length * 45.0 : 0,
            constraints:
                BoxConstraints(maxHeight: widget.maxHeight ?? double.infinity),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              border: expanded
                  ? Border.all(width: 1, color: colors.lightBlack)
                  : null,
              color: colors.backgroundColor,
              borderRadius: expanded
                  ? BorderRadius.vertical(
                      bottom: Radius.circular(
                        10,
                      ),
                    )
                  : BorderRadius.all(
                      Radius.circular(
                        10,
                      ),
                    ),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: List<Widget>.from(
                widget.values.map(
                  (value) => GestureDetector(
                    onTap: () {
                      widget.onSelect(value);
                      setState(() {
                        expanded = !expanded;
                      });
                    },
                    behavior: HitTestBehavior.translucent,
                    child: Container(
                      color: colors.backgroundColor,
                      height: 45,
                      padding: EdgeInsets.only(
                        left: 15,
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value.title,
                        style: styles.regular(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
