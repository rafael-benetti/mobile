import 'package:flutter/material.dart';
import '../../../../src/core/models/route.dart';
import '../../../core/models/group.dart';
import '../../../core/models/point_of_sale.dart';
import '../../../core/providers/groups_provider.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';
import '../../shared/validators.dart';

import '../../../locator.dart';

final styles = locator<TextStyles>();
final colors = locator<AppColors>();

class PointOfSaleCard extends StatelessWidget {
  final PointOfSale pointOfSale;
  final List<Group> groups;
  final List<OperatorRoute> routes;

  const PointOfSaleCard({
    this.pointOfSale,
    this.groups,
    this.routes,
  });

  @override
  Widget build(BuildContext context) {
    String getRouteName() {
      try {
        return routes
            .firstWhere(
              (element) => element.id == pointOfSale.routeId,
            )
            .label;
      } catch (e) {
        return '-';
      }
    }

    return Container(
      margin: EdgeInsets.all(3),
      padding: EdgeInsets.all(15),
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
                  style: styles.medium(fontSize: 16),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Container(
                  child: Text(
                    pointOfSale.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 7.5),
          if (locator<GroupsProvider>().groups.length > 1)
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      child: Text(
                        'Parceria:',
                        style: styles.medium(fontSize: 16),
                      ),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Container(
                        child: Text(
                          groups
                              .firstWhere((element) =>
                                  element.id == pointOfSale.groupId)
                              .label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 7.5),
              ],
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                child: Text(
                  'Rota:',
                  style: styles.medium(fontSize: 16),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Container(
                  child: Text(
                    pointOfSale.routeId == null ? '-' : getRouteName(),
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
                  'Contato:',
                  style: styles.medium(fontSize: 16),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Container(
                  child: Text(
                    pointOfSale.contactName,
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
                  'Telefone:',
                  style: styles.medium(fontSize: 16),
                ),
              ),
              SizedBox(width: 5),
              Text(
                convertPhoneNumberFromAPI(pointOfSale.primaryPhoneNumber),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ],
      ),
    );
  }
}
