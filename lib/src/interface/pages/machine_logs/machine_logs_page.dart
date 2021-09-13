import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/core/models/machine.dart';
import '../../../../src/core/providers/machine_logs_provider.dart';
import '../../../../src/interface/pages/machine_logs/widgets.dart';
import '../../../../src/interface/shared/colors.dart';
import '../../../../src/interface/shared/text_styles.dart';
import '../../../../src/interface/widgets/current_path.dart';
import '../../../../src/interface/widgets/date_range_placeholder.dart';

import '../../../locator.dart';
import 'machine_logs_page_model.dart';

class MachineLogsPage extends StatelessWidget {
  static const route = '/machineLogs';
  final colors = locator<AppColors>();
  final styles = locator<TextStyles>();
  final _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MachineLogsPageModel>.reactive(
      viewModelBuilder: () => MachineLogsPageModel(),
      onModelReady: (model) {
        model.machine = (ModalRoute.of(context).settings.arguments as Machine);
        model.initData();
      },
      builder: (context, model, child) => Consumer<MachineLogsProvider>(
        builder: (context, machineLogsProvider, _) {
          _controller.addListener(() {
            if (_controller.position.extentAfter == 0 &&
                machineLogsProvider.machineLogs.length !=
                    machineLogsProvider.count) {
              model.loadMoreMachineLogs();
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
                        topText: 'Histórico de eventos',
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
                                      colors.primaryColor),
                                ),
                              ],
                            ))
                          : SliverList(
                              delegate: SliverChildListDelegate(
                                [
                                  if (MediaQuery.of(context).size.height > 900)
                                    SizedBox(height: 30),
                                  SizedBox(height: 15),
                                  Row(
                                    children: [
                                      Icon(Icons.info_outline),
                                      Text(
                                        ' - Clique para ver as observações do evento',
                                        style: styles.regular(fontSize: 12),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Column(
                                    children: List.generate(
                                      machineLogsProvider.machineLogs.length,
                                      (index) => MachineLogCard(
                                        machineLog: machineLogsProvider
                                            .machineLogs[index],
                                        popObservationsDialog:
                                            model.popObservationsDialog,
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
