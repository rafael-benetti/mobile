import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/core/models/user.dart';
import '../../../../src/interface/widgets/custom_dropdown.dart';
import '../../../../src/interface/widgets/icon_translator.dart';
import '../../../core/providers/telemetry_boards_provider.dart';
import 'telemetry_boards_page_model.dart';
import 'widgets.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';
import '../../widgets/current_path.dart';
import '../../widgets/custom_text_field.dart';

import '../../../locator.dart';

class TelemetryBoardsPage extends StatelessWidget {
  static const route = '/telemetryBoards';
  final colors = locator<AppColors>();
  final styles = locator<TextStyles>();

  @override
  Widget build(BuildContext context) {
    Timer _timer;
    return ViewModelBuilder<TelemetryBoardsPageModel>.reactive(
      viewModelBuilder: () => TelemetryBoardsPageModel(),
      onModelReady: (model) => model.loadData(),
      builder: (context, model, child) => Consumer<TelemetryBoardsProvider>(
          builder: (context, _telemetryBoardsProvider, _) {
        final _scrollController = ScrollController();
        _scrollController.addListener(() {
          if (_scrollController.position.extentAfter == 0 &&
              _telemetryBoardsProvider.telemetries.length !=
                  _telemetryBoardsProvider.count) {
            model.offset += 5;
            model.filterTelemetries(false);
          }
        });
        return Scaffold(
          body: model.isBusy
              ? Center()
              : CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverAppBar(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      iconTheme: IconThemeData(color: colors.primaryColor),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                      sliver: MultiSliver(
                        children: [
                          CurrentPath(
                            topText: 'Telemetrias',
                            bottomFinalText: ' / telemetrias',
                          ),
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pesquisar por número da placa',
                                  style: styles.light(fontSize: 16),
                                ),
                                SizedBox(height: 10),
                                CustomTextField(
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) async {
                                    if (_timer != null) {
                                      _timer.cancel();
                                    }
                                    if (value != '') {
                                      model.telemetryBoardId = value;
                                    } else {
                                      model.telemetryBoardId = null;
                                    }
                                    _timer = Timer(
                                      Duration(milliseconds: 500),
                                      () => model.filterTelemetries(true),
                                    );
                                  },
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                          if (model.userProvider.user.role != Role.OPERATOR)
                            SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Parceria',
                                    style: styles.light(fontSize: 16),
                                  ),
                                  SizedBox(height: 10),
                                  CustomDropdownButton(
                                    initialValue: DropdownInputOption(
                                      title: 'Todas',
                                      option: null,
                                    ),
                                    onSelect: (value) async {
                                      if (value.title != 'Todas') {
                                        model.groupId = value.option;
                                      } else {
                                        model.groupId = null;
                                      }
                                      await model.filterTelemetries(true);
                                    },
                                    maxHeight: 157.5,
                                    values: [
                                          DropdownInputOption(
                                              title: 'Todas', option: null)
                                        ] +
                                        List.generate(
                                          model.groupsProvider.groups.length,
                                          (index) => DropdownInputOption(
                                            title: model.groupsProvider
                                                .groups[index].label,
                                            option: model.groupsProvider
                                                .groups[index].id,
                                          ),
                                        ),
                                  ),
                                  SizedBox(height: 15),
                                ],
                              ),
                            ),
                          if (_telemetryBoardsProvider.telemetries.isNotEmpty)
                            SliverList(
                              delegate: SliverChildListDelegate(
                                [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Telemetrias (${_telemetryBoardsProvider.count})',
                                            style: styles.light(fontSize: 16),
                                          ),
                                          Row(
                                            children: [
                                              IconTranslator(
                                                icon:
                                                    Icons.warning_amber_rounded,
                                                iconColor: Colors.amber,
                                                onTap: popIconTranslatorDialog,
                                              ),
                                              IconTranslator(
                                                icon: Feather.wifi_off,
                                                iconColor: colors.red,
                                                onTap: popIconTranslatorDialog,
                                              ),
                                              IconTranslator(
                                                icon: Feather.wifi,
                                                iconColor: colors.lightGreen,
                                                onTap: popIconTranslatorDialog,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                    ] +
                                    List.generate(
                                      _telemetryBoardsProvider
                                          .telemetries.length,
                                      (index) => Column(
                                        children: [
                                          SizedBox(height: 10),
                                          GestureDetector(
                                            onTap: () =>
                                                model.popTransferBoardDialog(
                                              _telemetryBoardsProvider
                                                  .telemetries[index],
                                            ),
                                            child: TelemetryBoardCard(
                                              telemetryBoard:
                                                  _telemetryBoardsProvider
                                                      .telemetries[index],
                                              groups:
                                                  model.groupsProvider.groups,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              ),
                            )
                          else
                            Text(
                              'Nenhuma telemetria cadastrada.',
                              textAlign: TextAlign.center,
                            )
                        ],
                      ),
                    )
                  ],
                ),
        );
      }),
    );
  }
}
