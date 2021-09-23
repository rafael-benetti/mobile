import 'package:black_telemetry/src/interface/pages/detailed_operator/detailed_operator_page_model.dart';
import 'package:black_telemetry/src/interface/shared/colors.dart';
import 'package:black_telemetry/src/interface/shared/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../locator.dart';

final colors = locator<AppColors>();
final styles = locator<TextStyles>();

class PrizeList extends ViewModelWidget<DetailedOperatorPageModel> {
  @override
  Widget build(BuildContext context, DetailedOperatorPageModel model) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prêmios',
            style: styles.light(fontSize: 16),
          ),
          SizedBox(height: 10),
          Column(
            children: List.generate(
              model.user.stock.prizes.length,
              (index) => Container(
                margin: EdgeInsets.fromLTRB(3, 3, 3, 10),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                              model.user.stock.prizes[index].label,
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
                            'Quantidade:',
                            style: styles.medium(fontSize: 16),
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Container(
                            child: Text(
                              model.user.stock.prizes[index].quantity
                                  .toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SupplyList extends ViewModelWidget<DetailedOperatorPageModel> {
  @override
  Widget build(BuildContext context, DetailedOperatorPageModel model) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suprimentos',
            style: styles.light(fontSize: 16),
          ),
          SizedBox(height: 10),
          Column(
            children: List.generate(
              model.user.stock.supplies.length,
              (index) => Container(
                margin: EdgeInsets.fromLTRB(3, 3, 3, 10),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                              model.user.stock.supplies[index].label,
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
                            'Quantidade:',
                            style: styles.medium(fontSize: 16),
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Container(
                            child: Text(
                              model.user.stock.supplies[index].quantity
                                  .toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
