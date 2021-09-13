import 'package:flutter/material.dart';
import '../../../core/models/point_of_sale.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';

import '../../../locator.dart';

final styles = locator<TextStyles>();
final colors = locator<AppColors>();

class PointsOfSaleCheckboxes extends StatefulWidget {
  final List<PointOfSale> availablePointsOfSale;
  final List<String> selectedPointsOfSaleIds;
  final Function addToSelectedPointsOfSale;
  final Function removeFromSelectedPointsOfSale;

  const PointsOfSaleCheckboxes({
    this.availablePointsOfSale,
    this.selectedPointsOfSaleIds,
    this.addToSelectedPointsOfSale,
    this.removeFromSelectedPointsOfSale,
  });

  @override
  _PointsOfSaleCheckboxesState createState() => _PointsOfSaleCheckboxesState();
}

class _PointsOfSaleCheckboxesState extends State<PointsOfSaleCheckboxes> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 25,
      children: List.generate(
        widget.availablePointsOfSale.length,
        (index) => Row(
          children: [
            Checkbox(
              checkColor: locator<AppColors>().backgroundColor,
              activeColor: locator<AppColors>().primaryColor,
              value: widget.selectedPointsOfSaleIds
                  .contains(widget.availablePointsOfSale[index].id),
              onChanged: (value) {
                setState(() {
                  if (value) {
                    widget.addToSelectedPointsOfSale(
                        widget.availablePointsOfSale[index].id);
                  } else {
                    widget.removeFromSelectedPointsOfSale(
                        widget.availablePointsOfSale[index].id);
                  }
                });
              },
            ),
            Text(widget.availablePointsOfSale[index].label)
          ],
        ),
      ),
    );
  }
}
