import 'package:flutter/material.dart';
import '../../../core/models/group.dart';
import '../../../core/models/point_of_sale.dart';
import '../../../core/models/route.dart';
import '../../../core/models/user.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';

import '../../../locator.dart';

final styles = locator<TextStyles>();
final colors = locator<AppColors>();

class GroupsCheckboxes extends StatefulWidget {
  final List<Group> groups;
  final List<String> filteredGroupsIds;
  final Function addToFilteredGroupsIds;
  final Function removeFromFilteredGroupsIds;

  const GroupsCheckboxes({
    this.groups,
    this.filteredGroupsIds,
    this.addToFilteredGroupsIds,
    this.removeFromFilteredGroupsIds,
  });

  @override
  _GroupsCheckboxesState createState() => _GroupsCheckboxesState();
}

class _GroupsCheckboxesState extends State<GroupsCheckboxes> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 25,
      children: List.generate(
        widget.groups.length,
        (index) => Row(
          children: [
            Checkbox(
              checkColor: locator<AppColors>().backgroundColor,
              activeColor: locator<AppColors>().primaryColor,
              value: widget.filteredGroupsIds.contains(widget.groups[index].id),
              onChanged: (value) {
                setState(() {
                  if (value) {
                    widget.addToFilteredGroupsIds(widget.groups[index].id);
                  } else {
                    widget.removeFromFilteredGroupsIds(widget.groups[index].id);
                  }
                });
              },
            ),
            Text(widget.groups[index].label)
          ],
        ),
      ),
    );
  }
}

class RouteCard extends StatelessWidget {
  final OperatorRoute route;
  final List<User> operators;
  final List<PointOfSale> pointsOfSale;

  const RouteCard({Key key, this.route, this.operators, this.pointsOfSale})
      : super(key: key);

  String getOperatorName() {
    try {
      return operators.firstWhere((op) => op.id == route.operatorId).name;
    } catch (e) {
      return null;
    }
  }

  String getPointsOfSale() {
    var temp = <PointOfSale>[];
    var pointOfSaleString = '';
    pointsOfSale.forEach((pdv) {
      if (route.pointsOfSaleIds.contains(pdv.id)) {
        temp.add(pdv);
      }
    });
    for (var i = 0; i < temp.length; i++) {
      if (i == temp.length - 1) {
        pointOfSaleString += temp[i].label;
      } else {
        pointOfSaleString += '${temp[i].label}, ';
      }
    }
    return pointOfSaleString;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(3),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: colors.backgroundColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            spreadRadius: 2,
            color: colors.lightBlack,
            offset: Offset(1, 1),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                child: Text(
                  'Nome:',
                  style: styles.medium(fontSize: 15),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Container(
                  child: Text(
                    route.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 7.5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                child: Text(
                  'Pontos de venda:',
                  style: styles.medium(fontSize: 15),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  getPointsOfSale(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
          SizedBox(height: 7.5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                child: Text(
                  'Operador:',
                  style: styles.medium(fontSize: 15),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  getOperatorName() ?? '-',
                ),
              ),
              Row(
                children: [
                  Text(
                    'Detalhes',
                    style: styles.regular(color: colors.primaryColor),
                  ),
                  SizedBox(width: 5),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: colors.primaryColor,
                    size: 15,
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
