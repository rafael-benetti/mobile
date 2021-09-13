import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/core/models/box.dart';
import '../../../core/models/machine.dart';
import '../../widgets/boxes.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';
import '../../widgets/current_path.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_text_field.dart';

import '../../../locator.dart';
import 'edit_machine_page_model.dart';

class EditMachinePage extends StatelessWidget {
  static const route = '/editmachine';

  final styles = locator<TextStyles>();
  final colors = locator<AppColors>();

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EditMachinePageModel>.reactive(
      viewModelBuilder: () => EditMachinePageModel(),
      disposeViewModel: true,
      onModelReady: (model) async {
        await model.loadData();
        if (ModalRoute.of(context).settings.arguments != null) {
          if (ModalRoute.of(context).settings.arguments is Machine) {
            model.machine = ModalRoute.of(context).settings.arguments;
            model.machine.boxes.forEach((box) {
              var b = Box(box.id);
              b.counters = [...box.counters];
              model.boxes.add(b);
            });
            model.sortListsByGroup();
            model.updatePinList();
          } else {
            model.creatingInStock = true;
          }
        }
        if (model.groups.length == 1) {
          model.machine.groupId = model.groups[0].id;
          model.pointsOfSaleByGroup = model.pointsOfSale
              .where((element) => element.groupId == model.machine.groupId)
              .toList();
          model.sortListsByGroup();
        }
      },
      builder: (context, model, child) => Scaffold(
        body: model.isBusy
            ? Center()
            : CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    iconTheme: IconThemeData(color: colors.primaryColor),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                    sliver: MultiSliver(
                      children: [
                        CurrentPath(
                          topText: ModalRoute.of(context).settings.arguments
                                  is Machine
                              ? 'Editar Máquina'
                              : ModalRoute.of(context).settings.arguments ==
                                      null
                                  ? 'Criar Máquina'
                                  : 'Criar Máquina em Estoque',
                          bottomMiddleTexts: [' / Máquinas'],
                          bottomFinalText: ModalRoute.of(context)
                                  .settings
                                  .arguments is Machine
                              ? ' / Editar'
                              : ' / Criar',
                        ),
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Text(
                                'Número de série',
                                style: styles.light(fontSize: 16),
                              ),
                              SizedBox(height: 10),
                              CustomTextField(
                                initialValue: model.machine.serialNumber ?? '',
                                onChanged: (value) =>
                                    model.machine.serialNumber = value,
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                        if (model.groups.length > 1 &&
                            !(ModalRoute.of(context).settings.arguments
                                is Machine))
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
                                Text(
                                  'Parceria',
                                  style: styles.light(fontSize: 16),
                                ),
                                SizedBox(height: 10),
                                CustomDropdownButton(
                                  initialValue: DropdownInputOption(title: ''),
                                  onSelect: (value) {
                                    model.machine.groupId = model.groups
                                        .firstWhere((element) =>
                                            element.label == value.title)
                                        .id;
                                    model.machine.locationId = null;
                                    model.machine.operatorId = null;
                                    model.machine.telemetryBoardId = null;
                                    model.machine.typeOfPrize = null;
                                    model.sortListsByGroup();
                                  },
                                  values: List.generate(
                                    model.groups.length,
                                    (index) => DropdownInputOption(
                                      title: model.groups[index].label,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Text(
                                'Valor da jogada',
                                style: styles.light(fontSize: 16),
                              ),
                              SizedBox(height: 10),
                              CustomTextField(
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  RealInputFormatter(centavos: true)
                                ],
                                keyboardType: TextInputType.number,
                                initialValue: model.machine.gameValue != null
                                    ? model.machine.gameValue.toString()
                                    : '',
                                onChanged: (value) {
                                  if (value == '') {
                                    model.machine.gameValue = null;
                                  } else {
                                    var tmp = double.parse(
                                        value.replaceAll(',', '.'));
                                    model.machine.gameValue = tmp;
                                  }
                                },
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                        if (ModalRoute.of(context).settings.arguments == null)
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
                                Row(children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Estoque mínimo',
                                        style: styles.light(fontSize: 16),
                                      ),
                                      Text(
                                        ' (opcional)',
                                        style: styles.light(
                                            fontSize: 16,
                                            color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 5),
                                  GestureDetector(
                                    onTap: () =>
                                        model.popMinimumPrizeCountInfo(),
                                    child: Icon(
                                      Icons.info_outline,
                                      color: colors.primaryColor,
                                    ),
                                  )
                                ]),
                                SizedBox(height: 10),
                                CustomTextField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  keyboardType: TextInputType.number,
                                  initialValue: '',
                                  onChanged: (value) {
                                    if (value == '') {
                                      model.machine.minimumPrizeCount = null;
                                    } else {
                                      var tmp =
                                          int.parse(value.replaceAll(',', '.'));
                                      model.machine.minimumPrizeCount = tmp;
                                    }
                                  },
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        if (ModalRoute.of(context).settings.arguments == null)
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
                                Row(children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Meta de faturamento por prêmio',
                                        style: styles.light(fontSize: 16),
                                      ),
                                      Text(
                                        ' (opcional)',
                                        style: styles.light(
                                            fontSize: 16,
                                            color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          model.popIncomePerPrizeGoalInfo(),
                                      child: Icon(
                                        Icons.info_outline,
                                        color: colors.primaryColor,
                                      ),
                                    ),
                                  )
                                ]),
                                SizedBox(height: 10),
                                CustomTextField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    RealInputFormatter(centavos: true),
                                  ],
                                  keyboardType: TextInputType.number,
                                  initialValue: '',
                                  onChanged: (value) {
                                    if (value == '') {
                                      model.machine.incomePerPrizeGoal = null;
                                    } else {
                                      var tmp = double.parse(value
                                          .replaceAll('.', '')
                                          .replaceAll(',', '.'));
                                      model.machine.incomePerPrizeGoal = tmp;
                                    }
                                  },
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        if (ModalRoute.of(context).settings.arguments == null)
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
                                Row(children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Meta de faturamento por mês',
                                        style: styles.light(fontSize: 16),
                                      ),
                                      Text(
                                        ' (opcional)',
                                        style: styles.light(
                                            fontSize: 16,
                                            color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          model.popIncomePerMonthGoalInfo(),
                                      child: Icon(
                                        Icons.info_outline,
                                        color: colors.primaryColor,
                                      ),
                                    ),
                                  )
                                ]),
                                SizedBox(height: 10),
                                CustomTextField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    RealInputFormatter(centavos: true),
                                  ],
                                  keyboardType: TextInputType.number,
                                  initialValue: '',
                                  onChanged: (value) {
                                    if (value == '') {
                                      model.machine.incomePerMonthGoal = null;
                                    } else {
                                      var tmp = double.parse(value
                                          .replaceAll('.', '')
                                          .replaceAll(',', '.'));
                                      model.machine.incomePerMonthGoal = tmp;
                                    }
                                  },
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        if (model.machine.groupId != null)
                          MultiSliver(
                            children: [
                              if (ModalRoute.of(context).settings.arguments ==
                                  null)
                                SliverToBoxAdapter(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10),
                                      Text(
                                        'Tipo do prêmio',
                                        style: styles.light(fontSize: 16),
                                      ),
                                      SizedBox(height: 10),
                                      CustomKrowchDropdownButton(
                                        currentValue: DropdownInputOption(
                                          title: model.machine.typeOfPrize ==
                                                  null
                                              ? 'Indefinido'
                                              : model.machine.typeOfPrize.label,
                                        ),
                                        onSelect: (value) {
                                          if (value.title == 'Indefinido') {
                                            model.machine.typeOfPrize = null;
                                          } else {
                                            model.machine.typeOfPrize = model
                                                .groupsProvider.prizes
                                                .firstWhere((element) =>
                                                    element.label ==
                                                    value.title);
                                          }
                                          model.notifyListeners();
                                        },
                                        values: [
                                              DropdownInputOption(
                                                title: 'Indefinido',
                                              ),
                                            ] +
                                            List.generate(
                                              model
                                                  .groupsProvider.prizes.length,
                                              (index) => DropdownInputOption(
                                                title: model.groupsProvider
                                                    .prizes[index].label,
                                              ),
                                            ),
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              if (ModalRoute.of(context).settings.arguments ==
                                  null)
                                SliverToBoxAdapter(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10),
                                      Text(
                                        'Localização',
                                        style: styles.light(fontSize: 16),
                                      ),
                                      SizedBox(height: 10),
                                      CustomKrowchDropdownButton(
                                        currentValue: DropdownInputOption(
                                          title: model.machine.locationId ==
                                                  null
                                              ? 'Manter em estoque da parceria'
                                              : model.pointsOfSale
                                                  .firstWhere((element) =>
                                                      element.id ==
                                                      model.machine.locationId)
                                                  .label,
                                        ),
                                        onSelect: (value) {
                                          if (value.title ==
                                              'Manter em estoque da parceria') {
                                            model.machine.locationId = null;
                                          } else {
                                            model.machine.locationId = model
                                                .pointsOfSale
                                                .firstWhere((element) =>
                                                    element.label ==
                                                    value.title)
                                                .id;
                                          }
                                          model.notifyListeners();
                                        },
                                        values: [
                                              DropdownInputOption(
                                                title:
                                                    'Manter em estoque da parceria',
                                              ),
                                            ] +
                                            List.generate(
                                              model.pointsOfSaleByGroup.length,
                                              (index) => DropdownInputOption(
                                                title: model
                                                    .pointsOfSaleByGroup[index]
                                                    .label,
                                              ),
                                            ),
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              if (!(ModalRoute.of(context).settings.arguments
                                      is Machine) &&
                                  ModalRoute.of(context).settings.arguments !=
                                      null)
                                SliverToBoxAdapter(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10),
                                      Text(
                                        'Localização',
                                        style: styles.light(fontSize: 16),
                                      ),
                                      SizedBox(height: 10),
                                      CustomTextField(
                                        keyboardType: TextInputType.number,
                                        initialValue:
                                            'Manter em estoque da parceria',
                                        onChanged: (value) {},
                                        enabled: false,
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              SliverToBoxAdapter(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 10),
                                    Text(
                                      'Operador responsável',
                                      style: styles.light(fontSize: 16),
                                    ),
                                    SizedBox(height: 10),
                                    CustomKrowchDropdownButton(
                                      currentValue: DropdownInputOption(
                                          title: model.machine.operatorId ==
                                                  null
                                              ? 'Definir posteriormente'
                                              : model.userProvider.operators
                                                  .firstWhere((element) =>
                                                      element.id ==
                                                      model.machine.operatorId)
                                                  .name),
                                      onSelect: (value) {
                                        if (value.title ==
                                            'Definir posteriormente') {
                                          model.machine.operatorId = null;
                                        } else {
                                          model.machine.operatorId = model
                                              .userProvider.operators
                                              .firstWhere((element) =>
                                                  element.name == value.title)
                                              .id;
                                        }
                                        model.notifyListeners();
                                      },
                                      values: [
                                            DropdownInputOption(
                                                title: 'Definir posteriormente')
                                          ] +
                                          List.generate(
                                            model.operatorsByGroup.length,
                                            (index) => DropdownInputOption(
                                              title: model
                                                  .operatorsByGroup[index].name,
                                            ),
                                          ),
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 10),
                                    Text(
                                      'Telemetria',
                                      style: styles.light(fontSize: 16),
                                    ),
                                    SizedBox(height: 10),
                                    CustomKrowchDropdownButton(
                                      maxHeight: 157.5,
                                      currentValue: DropdownInputOption(
                                          title: model.machine
                                                      .telemetryBoardId ==
                                                  null
                                              ? 'Definir posteriormente'
                                              : 'STG-${model.machine.telemetryBoardId}'),
                                      onSelect: (value) {
                                        if (value.title !=
                                            'Definir posteriormente') {
                                          model.machine.telemetryBoardId = model
                                              .telemetriesByGroup
                                              .firstWhere((element) =>
                                                  element.id.toString() ==
                                                  value.title.split('-')[1])
                                              .id;
                                        } else {
                                          model.machine.telemetryBoardId = null;
                                        }
                                        model.notifyListeners();
                                      },
                                      values: [
                                            DropdownInputOption(
                                                title: 'Definir posteriormente')
                                          ] +
                                          List.generate(
                                            model.telemetriesByGroup.length,
                                            (index) => DropdownInputOption(
                                                title:
                                                    'STG-${model.telemetriesByGroup[index].id}'),
                                          ),
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        if (!(ModalRoute.of(context).settings.arguments
                            is Machine))
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
                                Text(
                                  'Categoria',
                                  style: styles.light(fontSize: 16),
                                ),
                                SizedBox(height: 10),
                                CustomDropdownButton(
                                  initialValue: DropdownInputOption(title: ''),
                                  maxHeight: 157.5,
                                  onSelect: (value) =>
                                      {model.setSelectedCategory(value.title)},
                                  values: List.generate(
                                    model.categories.length,
                                    (index) => DropdownInputOption(
                                        title: model.categories[index].label),
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          )
                        else
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
                                Text(
                                  'Categoria',
                                  style: styles.light(fontSize: 16),
                                ),
                                SizedBox(height: 10),
                                CustomTextField(
                                  enabled: false,
                                  keyboardType: TextInputType.number,
                                  initialValue: model.machine.categoryLabel,
                                  onChanged: (value) {},
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        if (model.boxes.isNotEmpty)
                          Boxes(
                            isCreatingCategory: false,
                            boxes: model.boxes,
                            addBox: model.addBox,
                            removeBox: model.removeBox,
                            removeCounter: model.removeCounter,
                            addCounter: model.addCounter,
                            scrollController: _scrollController,
                            categoryLabel: model.machine.categoryLabel,
                            counterTypes:
                                model.counterTypesProvider.counterTypes,
                            pinList: model.pinList,
                            updatePinList: model.updatePinList,
                          ),
                        SliverToBoxAdapter(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 100,
                              // ignore: deprecated_member_use
                              child: RaisedButton(
                                color: colors.primaryColor,
                                onPressed: () async {
                                  if (!(ModalRoute.of(context)
                                      .settings
                                      .arguments is Machine)) {
                                    model.createMachine();
                                  } else {
                                    model.editMachine();
                                  }
                                },
                                child: Text(
                                  ModalRoute.of(context).settings.arguments ==
                                          null
                                      ? 'Criar'
                                      : 'Salvar',
                                  style: styles.regular(
                                      color: colors.backgroundColor),
                                ),
                              ),
                            ),
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
