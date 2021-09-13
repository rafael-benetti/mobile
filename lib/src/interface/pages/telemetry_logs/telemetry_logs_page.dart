import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/core/providers/telemetry_logs_provider.dart';
import '../../../../src/core/models/machine.dart';
import '../../../../src/interface/pages/telemetry_logs/widgets.dart';
import '../../../../src/interface/pages/telemetry_logs/telemetry_logs_page_model.dart';
import '../../../../src/interface/shared/text_styles.dart';
import '../../../../src/interface/shared/colors.dart';
import '../../../../src/interface/widgets/date_range_placeholder.dart';
import '../../../../src/interface/widgets/current_path.dart';

import '../../../locator.dart';

class TelemetryLogsPage extends StatelessWidget {
  static const route = '/telemetryLogs';
  final colors = locator<AppColors>();
  final styles = locator<TextStyles>();
  final _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TelemetryLogsPageModel>.reactive(
      viewModelBuilder: () => TelemetryLogsPageModel(),
      onModelReady: (model) {
        model.machine = (ModalRoute.of(context).settings.arguments as Machine);
        model.initData();
      },
      builder: (context, model, child) => Consumer<TelemetryLogsProvider>(
        builder: (context, telemetryLogsProvider, _) {
          _controller.addListener(() async {
            if (_controller.position.extentAfter == 0 &&
                telemetryLogsProvider.telemetryLogs.length !=
                    telemetryLogsProvider.count) {
              await model.loadMoreTelemetryLogs();
            }
          });
          return Scaffold(
            body: CustomScrollView(
              controller: _controller,
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
                        topText: 'Histórico de jogadas',
                        bottomFinalText: ' / ${model.machine.serialNumber}',
                      ),
                      TypeSelector(
                        onSelect: (type) => model.selectType(type),
                      ),
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
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
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            SizedBox(height: 15),
                            Divider(),
                          ],
                        ),
                      ),
                      model.isBusy
                          ? Center(
                              child: Column(
                              children: [
                                SizedBox(height: 125),
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                    colors.primaryColor,
                                  ),
                                ),
                              ],
                            ))
                          : SliverList(
                              delegate: SliverChildListDelegate(
                                [
                                  SizedBox(height: 15),
                                  Row(
                                    children: [
                                      Icon(Icons.construction),
                                      Text(
                                        ' - Gerados em modo manutenção',
                                        style: styles.regular(fontSize: 12),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Column(
                                    children: List.generate(
                                      telemetryLogsProvider
                                          .telemetryLogs.length,
                                      (index) => TelemetryLogCard(
                                        telemetryLog: telemetryLogsProvider
                                            .telemetryLogs[index],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
