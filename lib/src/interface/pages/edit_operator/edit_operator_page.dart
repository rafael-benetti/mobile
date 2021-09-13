import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/interface/shared/validators.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';
import '../../widgets/current_path.dart';
import '../../widgets/custom_text_field.dart';

import '../../../locator.dart';
import 'edit_operator_page_model.dart';

class EditOperatorPage extends StatelessWidget {
  static const route = '/editOperator';

  final styles = locator<TextStyles>();
  final colors = locator<AppColors>();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EditOperatorPageModel>.reactive(
      viewModelBuilder: () => EditOperatorPageModel(),
      onModelReady: (model) {
        model.loadData();
        if (ModalRoute.of(context).settings.arguments != null) {
          model.user = ModalRoute.of(context).settings.arguments;
        }
      },
      builder: (context, model, child) => Scaffold(
        body: model.isBusy
            ? Center()
            : CustomScrollView(
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
                          topText:
                              ModalRoute.of(context).settings.arguments == null
                                  ? 'Novo Operador'
                                  : 'Editar Operador',
                          bottomFinalText:
                              ModalRoute.of(context).settings.arguments == null
                                  ? ' / Operadores / Novo Operador'
                                  : ' / Operadores / Editar Operador',
                        ),
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nome',
                                style: styles.light(fontSize: 16),
                              ),
                              SizedBox(height: 5),
                              CustomTextField(
                                initialValue: model.user.name ?? '',
                                enabled:
                                    ModalRoute.of(context).settings.arguments ==
                                        null,
                                onChanged: (value) {
                                  if (value != '') {
                                    model.user.name = value;
                                  } else {
                                    model.user.name = null;
                                  }
                                },
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email',
                                style: styles.light(fontSize: 16),
                              ),
                              SizedBox(height: 5),
                              CustomTextField(
                                enabled:
                                    ModalRoute.of(context).settings.arguments ==
                                        null,
                                initialValue: model.user.email ?? '',
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) {
                                  if (value != '') {
                                    model.user.email = value;
                                  } else {
                                    model.user.email = null;
                                  }
                                },
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Telefone',
                                style: styles.light(fontSize: 16),
                              ),
                              SizedBox(height: 5),
                              CustomTextField(
                                initialValue: model.user.phoneNumber != null
                                    ? convertPhoneNumberFromAPI(
                                        model.user.phoneNumber)
                                    : '',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  TelefoneInputFormatter(),
                                ],
                                onChanged: (value) {
                                  if (value != '') {
                                    model.user.phoneNumber = value;
                                  } else {
                                    model.user.phoneNumber = null;
                                  }
                                },
                              ),
                              SizedBox(height: 15),
                            ],
                          ),
                        ),
                        if (ModalRoute.of(context).settings.arguments != null)
                          SliverToBoxAdapter(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 3,
                                ),
                                Text(
                                  'Ativo',
                                  style: styles.light(fontSize: 16),
                                ),
                                SizedBox(height: 5),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Switch(
                                    value: model.user.isActive,
                                    activeColor: colors.primaryColor,
                                    onChanged: (value) {
                                      model.changeIsActive(value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SliverList(
                          delegate: SliverChildListDelegate(
                            [
                                  Divider(),
                                  SizedBox(height: 15),
                                  Text(
                                    'Parcerias (${model.groupsProvider.groups.length})',
                                    style: styles.medium(fontSize: 16),
                                  ),
                                  SizedBox(height: 10),
                                ] +
                                List.generate(
                                  model.groupsProvider.groups.length,
                                  (index) => Column(
                                    children: [
                                      GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          model.addGroupId(model
                                              .groupsProvider.groups[index].id);
                                        },
                                        child: Row(
                                          children: [
                                            Checkbox(
                                              activeColor: colors.primaryColor,
                                              value: model.user.groupIds
                                                  .contains(model.groupsProvider
                                                      .groups[index].id),
                                              onChanged: (value) {
                                                model.addGroupId(model
                                                    .groupsProvider
                                                    .groups[index]
                                                    .id);
                                              },
                                            ),
                                            SizedBox(width: 5),
                                            Text(model.groupsProvider
                                                .groups[index].label)
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              Divider(),
                              SizedBox(height: 15),
                              Text(
                                'Permissões (5)',
                                style: styles.medium(fontSize: 16),
                              ),
                              SizedBox(height: 10),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  model.user.permissions.editCollections =
                                      !model.user.permissions.editCollections;
                                  model.notifyListeners();
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value: model
                                          .user.permissions.editCollections,
                                      onChanged: (value) {
                                        model.user.permissions.editCollections =
                                            !model.user.permissions
                                                .editCollections;
                                        model.notifyListeners();
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Editar coletas'),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  model.user.permissions.deleteCollections =
                                      !model.user.permissions.deleteCollections;
                                  model.notifyListeners();
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value: model
                                          .user.permissions.deleteCollections,
                                      onChanged: (value) {
                                        model.user.permissions
                                                .deleteCollections =
                                            !model.user.permissions
                                                .deleteCollections;
                                        model.notifyListeners();
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Deletar coletas')
                                  ],
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  model.user.permissions.editMachines =
                                      !model.user.permissions.editMachines;
                                  model.notifyListeners();
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value:
                                          model.user.permissions.editMachines,
                                      onChanged: (value) {
                                        model.user.permissions.editMachines =
                                            !model
                                                .user.permissions.editMachines;
                                        model.notifyListeners();
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Editar máquinas')
                                  ],
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  model.user.permissions.deleteMachines =
                                      !model.user.permissions.deleteMachines;
                                  model.notifyListeners();
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value:
                                          model.user.permissions.deleteMachines,
                                      onChanged: (value) {
                                        model.user.permissions.deleteMachines =
                                            !model.user.permissions
                                                .deleteMachines;
                                        model.notifyListeners();
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Deletar máquinas'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            model.user.permissions.fixMachineStock =
                                !model.user.permissions.fixMachineStock;
                            model.notifyListeners();
                          },
                          child: Row(
                            children: [
                              Checkbox(
                                activeColor: colors.primaryColor,
                                value: model.user.permissions.fixMachineStock,
                                onChanged: (value) {
                                  model.user.permissions.fixMachineStock =
                                      !model.user.permissions.fixMachineStock;
                                  model.notifyListeners();
                                },
                              ),
                              SizedBox(width: 5),
                              Text('Corrigir estoque das máquinas')
                            ],
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              Divider(),
                              SizedBox(height: 15),
                              Text(
                                'Permissões extras (2)',
                                style: styles.medium(fontSize: 16),
                              ),
                              SizedBox(height: 10),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  model.user.permissions.toggleMaintenanceMode =
                                      !model.user.permissions
                                          .toggleMaintenanceMode;
                                  model.notifyListeners();
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value: model.user.permissions
                                          .toggleMaintenanceMode,
                                      onChanged: (value) {
                                        model.user.permissions
                                                .toggleMaintenanceMode =
                                            !model.user.permissions
                                                .toggleMaintenanceMode;
                                        model.notifyListeners();
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Modo manutenção')
                                  ],
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  model.user.permissions.addRemoteCredit =
                                      !model.user.permissions.addRemoteCredit;
                                  model.notifyListeners();
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value: model
                                          .user.permissions.addRemoteCredit,
                                      onChanged: (value) {
                                        model.user.permissions.addRemoteCredit =
                                            !model.user.permissions
                                                .addRemoteCredit;
                                        model.notifyListeners();
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Crédito remoto')
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 100,
                              // ignore: deprecated_member_use
                              child: RaisedButton(
                                color: colors.primaryColor,
                                onPressed: () {
                                  if (ModalRoute.of(context)
                                          .settings
                                          .arguments ==
                                      null) {
                                    model.createOperator();
                                  } else {
                                    model.updateOperator();
                                  }
                                },
                                child: Text(
                                  ModalRoute.of(context).settings.arguments ==
                                          null
                                      ? 'Criar'
                                      : 'Editar',
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
