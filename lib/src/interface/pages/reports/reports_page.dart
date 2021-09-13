import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/interface/pages/reports/reports_page_model.dart';
import '../../../../src/interface/pages/reports/widgets.dart';
import '../../../../src/interface/shared/colors.dart';
import '../../../../src/interface/shared/text_styles.dart';
import '../../../../src/interface/widgets/current_path.dart';
import '../../../../src/interface/widgets/custom_dropdown.dart';
import '../../../../src/interface/widgets/date_range_placeholder.dart';

import '../../../locator.dart';

class ReportsPage extends StatelessWidget {
  static const route = '/reports';
  final colors = locator<AppColors>();
  final styles = locator<TextStyles>();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReportsPageModel>.reactive(
      viewModelBuilder: () => ReportsPageModel(),
      builder: (context, model, child) => Scaffold(
        body: model.isBusy
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(colors.primaryColor),
                ),
              )
            : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    iconTheme: IconThemeData(
                      color: colors.primaryColor,
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                    sliver: MultiSliver(
                      children: [
                        CurrentPath(
                          topText: 'Relatórios',
                          bottomFinalText: ' / Exportar relatório',
                        ),
                        ReportTypeSelector(onSelect: model.onSelect),
                        if (!model.isBusy &&
                            model.selectedReportType == 'collections')
                          PointOfSaleSelector(
                            onSelect: (DropdownInputOption value) =>
                                model.selectedPointOfSaleId = value.option,
                            pointsOfSale:
                                model.pointsOfSaleProvider.pointsOfSale,
                          ),
                        if (model.selectedReportType != null &&
                            model.selectedReportType != 'stocks')
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 20),
                                Text(
                                  'Selecione o período',
                                  style: styles.light(fontSize: 16),
                                ),
                                SizedBox(height: 7.5),
                                GestureDetector(
                                  onTap: () => model.showDateRangePicker(),
                                  child: DateRangePlaceHolder(
                                    dateRange: model.dateRange,
                                  ),
                                )
                              ],
                            ),
                          ),
                        if (model.dateRange != null ||
                            model.selectedReportType == 'stocks')
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                SizedBox(height: 25),
                                Container(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => model.baga(),
                                    style: ElevatedButton.styleFrom(
                                        primary: colors.primaryColor),
                                    child: Text('Extrair relatório em excel'),
                                  ),
                                ),
                              ],
                            ),
                          )
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
