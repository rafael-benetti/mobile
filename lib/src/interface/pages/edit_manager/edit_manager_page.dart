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
import 'edit_manager_page_model.dart';

class EditManagerPage extends StatelessWidget {
  static const route = '/editmanager';

  final styles = locator<TextStyles>();
  final colors = locator<AppColors>();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EditManagerPageModel>.reactive(
      viewModelBuilder: () => EditManagerPageModel(),
      disposeViewModel: true,
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
                                  ? 'Novo Colaborador'
                                  : 'Editar Colaborador',
                          bottomFinalText:
                              ModalRoute.of(context).settings.arguments == null
                                  ? ' / Colaboradores / Novo Colaborador'
                                  : ' / Colaboradores / Editar Colaborador',
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
                                        child: Container(
                                          child: Row(
                                            children: [
                                              Checkbox(
                                                activeColor:
                                                    colors.primaryColor,
                                                value: model.user.groupIds
                                                    .contains(model
                                                        .groupsProvider
                                                        .groups[index]
                                                        .id),
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
                                'Permissões especiais (2)',
                                style: styles.medium(fontSize: 16),
                              ),
                              SizedBox(height: 10),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  model.toggleCreateManager(
                                      !model.user.permissions.createManagers);
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value:
                                          model.user.permissions.createManagers,
                                      onChanged: (value) {
                                        model.toggleCreateManager(!model
                                            .user.permissions.createManagers);
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Criar colaboradores')
                                  ],
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  model.toggleCreateOperator(
                                      !model.user.permissions.createOperators);
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value: model
                                          .user.permissions.createOperators,
                                      onChanged: (value) {
                                        model.toggleCreateOperator(!model
                                            .user.permissions.createOperators);
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Criar operadores')
                                  ],
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
                                'Permissões (21)',
                                style: styles.medium(fontSize: 16),
                              ),
                              SizedBox(height: 10),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  if (!model.user.permissions.createManagers) {
                                    model.user.permissions.listManagers =
                                        !model.user.permissions.listManagers;
                                    model.notifyListeners();
                                  } else {
                                    var keepGoing = await model
                                        .warnUserAboutCreatingManager();
                                    if (keepGoing) {
                                      model.user.permissions.listManagers =
                                          !model.user.permissions.listManagers;
                                      model.user.permissions.createManagers =
                                          false;
                                      model.notifyListeners();
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value:
                                          model.user.permissions.listManagers,
                                      onChanged: (value) async {
                                        if (!model
                                            .user.permissions.createManagers) {
                                          model.user.permissions.listManagers =
                                              !model.user.permissions
                                                  .listManagers;
                                          model.notifyListeners();
                                        } else {
                                          var keepGoing = await model
                                              .warnUserAboutCreatingManager();
                                          if (keepGoing) {
                                            model.user.permissions
                                                    .listManagers =
                                                !model.user.permissions
                                                    .listManagers;
                                            model.user.permissions
                                                .createManagers = false;
                                            model.notifyListeners();
                                          }
                                        }
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Listar colaboradores')
                                  ],
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  if (!model.user.permissions.createManagers) {
                                    model.user.permissions.listOperators =
                                        !model.user.permissions.listOperators;
                                    model.notifyListeners();
                                  } else {
                                    var keepGoing = await model
                                        .warnUserAboutCreatingManager();
                                    if (keepGoing) {
                                      model.user.permissions.listOperators =
                                          !model.user.permissions.listOperators;
                                      model.user.permissions.createManagers =
                                          false;
                                      model.notifyListeners();
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value:
                                          model.user.permissions.listOperators,
                                      onChanged: (value) async {
                                        if (!model
                                            .user.permissions.createManagers) {
                                          model.user.permissions.listOperators =
                                              !model.user.permissions
                                                  .listOperators;
                                          model.notifyListeners();
                                        } else {
                                          var keepGoing = await model
                                              .warnUserAboutCreatingManager();
                                          if (keepGoing) {
                                            model.user.permissions
                                                    .listOperators =
                                                !model.user.permissions
                                                    .listOperators;
                                            model.user.permissions
                                                .createManagers = false;
                                            model.notifyListeners();
                                          }
                                        }
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Listar operadores')
                                  ],
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  if (!model.user.permissions.createManagers) {
                                    model.user.permissions.generateReports =
                                        !model.user.permissions.generateReports;
                                    model.notifyListeners();
                                  } else {
                                    var keepGoing = await model
                                        .warnUserAboutCreatingManager();
                                    if (keepGoing) {
                                      model.user.permissions.generateReports =
                                          !model
                                              .user.permissions.generateReports;
                                      model.user.permissions.createManagers =
                                          false;
                                      model.notifyListeners();
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value: model
                                          .user.permissions.generateReports,
                                      onChanged: (value) async {
                                        if (!model
                                            .user.permissions.createManagers) {
                                          model.user.permissions
                                                  .generateReports =
                                              !model.user.permissions
                                                  .generateReports;
                                          model.notifyListeners();
                                        } else {
                                          var keepGoing = await model
                                              .warnUserAboutCreatingManager();
                                          if (keepGoing) {
                                            model.user.permissions
                                                    .generateReports =
                                                !model.user.permissions
                                                    .generateReports;
                                            model.user.permissions
                                                .createManagers = false;
                                            model.notifyListeners();
                                          }
                                        }
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Gerar relatórios')
                                  ],
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  if (!model.user.permissions.createManagers) {
                                    model.user.permissions.createGroups =
                                        !model.user.permissions.createGroups;
                                    model.notifyListeners();
                                  } else {
                                    var keepGoing = await model
                                        .warnUserAboutCreatingManager();
                                    if (keepGoing) {
                                      model.user.permissions.createGroups =
                                          !model.user.permissions.createGroups;
                                      model.user.permissions.createManagers =
                                          false;
                                      model.notifyListeners();
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value:
                                          model.user.permissions.createGroups,
                                      onChanged: (value) async {
                                        if (!model
                                            .user.permissions.createManagers) {
                                          model.user.permissions.createGroups =
                                              !model.user.permissions
                                                  .createGroups;
                                          model.notifyListeners();
                                        } else {
                                          var keepGoing = await model
                                              .warnUserAboutCreatingManager();
                                          if (keepGoing) {
                                            model.user.permissions
                                                    .createGroups =
                                                !model.user.permissions
                                                    .createGroups;
                                            model.user.permissions
                                                .createManagers = false;
                                            model.notifyListeners();
                                          }
                                        }
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Criar parcerias')
                                  ],
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  if (!model.user.permissions.createManagers) {
                                    model.user.permissions.editGroups =
                                        !model.user.permissions.editGroups;
                                    model.notifyListeners();
                                  } else {
                                    var keepGoing = await model
                                        .warnUserAboutCreatingManager();
                                    if (keepGoing) {
                                      model.user.permissions.editGroups =
                                          !model.user.permissions.editGroups;
                                      model.user.permissions.createManagers =
                                          false;
                                      model.notifyListeners();
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value: model.user.permissions.editGroups,
                                      onChanged: (value) async {
                                        if (!model
                                            .user.permissions.createManagers) {
                                          model.user.permissions.editGroups =
                                              !model
                                                  .user.permissions.editGroups;
                                          model.notifyListeners();
                                        } else {
                                          var keepGoing = await model
                                              .warnUserAboutCreatingManager();
                                          if (keepGoing) {
                                            model.user.permissions.editGroups =
                                                !model.user.permissions
                                                    .editGroups;
                                            model.user.permissions
                                                .createManagers = false;
                                            model.notifyListeners();
                                          }
                                        }
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Editar parcerias')
                                  ],
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  if (!model.user.permissions.createManagers) {
                                    model.user.permissions.deleteGroups =
                                        !model.user.permissions.deleteGroups;
                                    model.notifyListeners();
                                  } else {
                                    var keepGoing = await model
                                        .warnUserAboutCreatingManager();
                                    if (keepGoing) {
                                      model.user.permissions.deleteGroups =
                                          !model.user.permissions.deleteGroups;
                                      model.user.permissions.createManagers =
                                          false;
                                      model.notifyListeners();
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value:
                                          model.user.permissions.deleteGroups,
                                      onChanged: (value) async {
                                        if (!model
                                            .user.permissions.createManagers) {
                                          model.user.permissions.deleteGroups =
                                              !model.user.permissions
                                                  .deleteGroups;
                                          model.notifyListeners();
                                        } else {
                                          var keepGoing = await model
                                              .warnUserAboutCreatingManager();
                                          if (keepGoing) {
                                            model.user.permissions
                                                    .deleteGroups =
                                                !model.user.permissions
                                                    .deleteGroups;
                                            model.user.permissions
                                                .createManagers = false;
                                            model.notifyListeners();
                                          }
                                        }
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Deletar parcerias')
                                  ],
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  if (!model.user.permissions.createManagers) {
                                    model.user.permissions.createRoutes =
                                        !model.user.permissions.createRoutes;
                                    model.notifyListeners();
                                  } else {
                                    var keepGoing = await model
                                        .warnUserAboutCreatingManager();
                                    if (keepGoing) {
                                      model.user.permissions.createRoutes =
                                          !model.user.permissions.createRoutes;
                                      model.user.permissions.createManagers =
                                          false;
                                      model.notifyListeners();
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value:
                                          model.user.permissions.createRoutes,
                                      onChanged: (value) async {
                                        if (!model
                                            .user.permissions.createManagers) {
                                          model.user.permissions.createRoutes =
                                              !model.user.permissions
                                                  .createRoutes;
                                          model.notifyListeners();
                                        } else {
                                          var keepGoing = await model
                                              .warnUserAboutCreatingManager();
                                          if (keepGoing) {
                                            model.user.permissions
                                                    .createRoutes =
                                                !model.user.permissions
                                                    .createRoutes;
                                            model.user.permissions
                                                .createManagers = false;
                                            model.notifyListeners();
                                          }
                                        }
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Criar rotas')
                                  ],
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  if (!model.user.permissions.createManagers) {
                                    model.user.permissions.editRoutes =
                                        !model.user.permissions.editRoutes;
                                    model.notifyListeners();
                                  } else {
                                    var keepGoing = await model
                                        .warnUserAboutCreatingManager();
                                    if (keepGoing) {
                                      model.user.permissions.editRoutes =
                                          !model.user.permissions.editRoutes;
                                      model.user.permissions.createManagers =
                                          false;
                                      model.notifyListeners();
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value: model.user.permissions.editRoutes,
                                      onChanged: (value) async {
                                        if (!model
                                            .user.permissions.createManagers) {
                                          model.user.permissions.editRoutes =
                                              !model
                                                  .user.permissions.editRoutes;
                                          model.notifyListeners();
                                        } else {
                                          var keepGoing = await model
                                              .warnUserAboutCreatingManager();
                                          if (keepGoing) {
                                            model.user.permissions.editRoutes =
                                                !model.user.permissions
                                                    .editRoutes;
                                            model.user.permissions
                                                .createManagers = false;
                                            model.notifyListeners();
                                          }
                                        }
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Editar rotas')
                                  ],
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  if (!model.user.permissions.createManagers) {
                                    model.user.permissions.deleteRoutes =
                                        !model.user.permissions.deleteRoutes;
                                    model.notifyListeners();
                                  } else {
                                    var keepGoing = await model
                                        .warnUserAboutCreatingManager();
                                    if (keepGoing) {
                                      model.user.permissions.deleteRoutes =
                                          !model.user.permissions.deleteRoutes;
                                      model.user.permissions.createManagers =
                                          false;
                                      model.notifyListeners();
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value:
                                          model.user.permissions.deleteRoutes,
                                      onChanged: (value) async {
                                        if (!model
                                            .user.permissions.createManagers) {
                                          model.user.permissions.deleteRoutes =
                                              !model.user.permissions
                                                  .deleteRoutes;
                                          model.notifyListeners();
                                        } else {
                                          var keepGoing = await model
                                              .warnUserAboutCreatingManager();
                                          if (keepGoing) {
                                            model.user.permissions
                                                    .deleteRoutes =
                                                !model.user.permissions
                                                    .deleteRoutes;
                                            model.user.permissions
                                                .createManagers = false;
                                            model.notifyListeners();
                                          }
                                        }
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Deletar rotas')
                                  ],
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  if (!model.user.permissions.createManagers) {
                                    model.user.permissions.createPointsOfSale =
                                        !model.user.permissions
                                            .createPointsOfSale;
                                    model.notifyListeners();
                                  } else {
                                    var keepGoing = await model
                                        .warnUserAboutCreatingManager();
                                    if (keepGoing) {
                                      model.user.permissions
                                              .createPointsOfSale =
                                          !model.user.permissions
                                              .createPointsOfSale;
                                      model.user.permissions.createManagers =
                                          false;
                                      model.notifyListeners();
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value: model
                                          .user.permissions.createPointsOfSale,
                                      onChanged: (value) async {
                                        if (!model
                                            .user.permissions.createManagers) {
                                          model.user.permissions
                                                  .createPointsOfSale =
                                              !model.user.permissions
                                                  .createPointsOfSale;
                                          model.notifyListeners();
                                        } else {
                                          var keepGoing = await model
                                              .warnUserAboutCreatingManager();
                                          if (keepGoing) {
                                            model.user.permissions
                                                    .createPointsOfSale =
                                                !model.user.permissions
                                                    .createPointsOfSale;
                                            model.user.permissions
                                                .createManagers = false;
                                            model.notifyListeners();
                                          }
                                        }
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Criar pontos de venda')
                                  ],
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  if (!model.user.permissions.createManagers) {
                                    model.user.permissions.editPointsOfSale =
                                        !model
                                            .user.permissions.editPointsOfSale;
                                    model.notifyListeners();
                                  } else {
                                    var keepGoing = await model
                                        .warnUserAboutCreatingManager();
                                    if (keepGoing) {
                                      model.user.permissions.editPointsOfSale =
                                          !model.user.permissions
                                              .editPointsOfSale;
                                      model.user.permissions.createManagers =
                                          false;
                                      model.notifyListeners();
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value: model
                                          .user.permissions.editPointsOfSale,
                                      onChanged: (value) async {
                                        if (!model
                                            .user.permissions.createManagers) {
                                          model.user.permissions
                                                  .editPointsOfSale =
                                              !model.user.permissions
                                                  .editPointsOfSale;
                                          model.notifyListeners();
                                        } else {
                                          var keepGoing = await model
                                              .warnUserAboutCreatingManager();
                                          if (keepGoing) {
                                            model.user.permissions
                                                    .editPointsOfSale =
                                                !model.user.permissions
                                                    .editPointsOfSale;
                                            model.user.permissions
                                                .createManagers = false;
                                            model.notifyListeners();
                                          }
                                        }
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Editar pontos de venda')
                                  ],
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  if (!model.user.permissions.createManagers) {
                                    model.user.permissions.deletePointsOfSale =
                                        !model.user.permissions
                                            .deletePointsOfSale;
                                    model.notifyListeners();
                                  } else {
                                    var keepGoing = await model
                                        .warnUserAboutCreatingManager();
                                    if (keepGoing) {
                                      model.user.permissions
                                              .deletePointsOfSale =
                                          !model.user.permissions
                                              .deletePointsOfSale;
                                      model.user.permissions.createManagers =
                                          false;
                                      model.notifyListeners();
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value: model
                                          .user.permissions.deletePointsOfSale,
                                      onChanged: (value) async {
                                        if (!model
                                            .user.permissions.createManagers) {
                                          model.user.permissions
                                                  .deletePointsOfSale =
                                              !model.user.permissions
                                                  .deletePointsOfSale;
                                          model.notifyListeners();
                                        } else {
                                          var keepGoing = await model
                                              .warnUserAboutCreatingManager();
                                          if (keepGoing) {
                                            model.user.permissions
                                                    .deletePointsOfSale =
                                                !model.user.permissions
                                                    .deletePointsOfSale;
                                            model.user.permissions
                                                .createManagers = false;
                                            model.notifyListeners();
                                          }
                                        }
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Deletar pontos de venda')
                                  ],
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  if (!model.user.permissions.createManagers) {
                                    model.user.permissions.createProducts =
                                        !model.user.permissions.createProducts;
                                    model.notifyListeners();
                                  } else {
                                    var keepGoing = await model
                                        .warnUserAboutCreatingManager();
                                    if (keepGoing) {
                                      model.user.permissions.createProducts =
                                          !model
                                              .user.permissions.createProducts;
                                      model.user.permissions.createManagers =
                                          false;
                                      model.notifyListeners();
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value:
                                          model.user.permissions.createProducts,
                                      onChanged: (value) async {
                                        if (!model
                                            .user.permissions.createManagers) {
                                          model.user.permissions
                                                  .createProducts =
                                              !model.user.permissions
                                                  .createProducts;
                                          model.notifyListeners();
                                        } else {
                                          var keepGoing = await model
                                              .warnUserAboutCreatingManager();
                                          if (keepGoing) {
                                            model.user.permissions
                                                    .createProducts =
                                                !model.user.permissions
                                                    .createProducts;
                                            model.user.permissions
                                                .createManagers = false;
                                            model.notifyListeners();
                                          }
                                        }
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Criar estoque')
                                  ],
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  if (!model.user.permissions.createManagers) {
                                    model.user.permissions.editProducts =
                                        !model.user.permissions.editProducts;
                                    model.notifyListeners();
                                  } else {
                                    var keepGoing = await model
                                        .warnUserAboutCreatingManager();
                                    if (keepGoing) {
                                      model.user.permissions.editProducts =
                                          !model.user.permissions.editProducts;
                                      model.user.permissions.createManagers =
                                          false;
                                      model.notifyListeners();
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value:
                                          model.user.permissions.editProducts,
                                      onChanged: (value) async {
                                        if (!model
                                            .user.permissions.createManagers) {
                                          model.user.permissions.editProducts =
                                              !model.user.permissions
                                                  .editProducts;
                                          model.notifyListeners();
                                        } else {
                                          var keepGoing = await model
                                              .warnUserAboutCreatingManager();
                                          if (keepGoing) {
                                            model.user.permissions
                                                    .editProducts =
                                                !model.user.permissions
                                                    .editProducts;
                                            model.user.permissions
                                                .createManagers = false;
                                            model.notifyListeners();
                                          }
                                        }
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Editar estoque')
                                  ],
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  if (!model.user.permissions.createManagers) {
                                    model.user.permissions.deleteProducts =
                                        !model.user.permissions.deleteProducts;
                                    model.notifyListeners();
                                  } else {
                                    var keepGoing = await model
                                        .warnUserAboutCreatingManager();
                                    if (keepGoing) {
                                      model.user.permissions.deleteProducts =
                                          !model
                                              .user.permissions.deleteProducts;
                                      model.user.permissions.createManagers =
                                          false;
                                      model.notifyListeners();
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value:
                                          model.user.permissions.deleteProducts,
                                      onChanged: (value) async {
                                        if (!model
                                            .user.permissions.createManagers) {
                                          model.user.permissions
                                                  .deleteProducts =
                                              !model.user.permissions
                                                  .deleteProducts;
                                          model.notifyListeners();
                                        } else {
                                          var keepGoing = await model
                                              .warnUserAboutCreatingManager();
                                          if (keepGoing) {
                                            model.user.permissions
                                                    .deleteProducts =
                                                !model.user.permissions
                                                    .deleteProducts;
                                            model.user.permissions
                                                .createManagers = false;
                                            model.notifyListeners();
                                          }
                                        }
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Deletar estoque'),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  if (!model.user.permissions.createManagers) {
                                    model.user.permissions.createCategories =
                                        !model
                                            .user.permissions.createCategories;
                                    model.notifyListeners();
                                  } else {
                                    var keepGoing = await model
                                        .warnUserAboutCreatingManager();
                                    if (keepGoing) {
                                      model.user.permissions.createCategories =
                                          !model.user.permissions
                                              .createCategories;
                                      model.user.permissions.createManagers =
                                          false;
                                      model.notifyListeners();
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value: model
                                          .user.permissions.createCategories,
                                      onChanged: (value) async {
                                        if (!model
                                            .user.permissions.createManagers) {
                                          model.user.permissions
                                                  .createCategories =
                                              !model.user.permissions
                                                  .createCategories;
                                          model.notifyListeners();
                                        } else {
                                          var keepGoing = await model
                                              .warnUserAboutCreatingManager();
                                          if (keepGoing) {
                                            model.user.permissions
                                                    .createCategories =
                                                !model.user.permissions
                                                    .createCategories;
                                            model.user.permissions
                                                .createManagers = false;
                                            model.notifyListeners();
                                          }
                                        }
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Criar categorias de máquina')
                                  ],
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  if (!model.user.permissions.createManagers) {
                                    model.user.permissions.editCategories =
                                        !model.user.permissions.editCategories;
                                    model.notifyListeners();
                                  } else {
                                    var keepGoing = await model
                                        .warnUserAboutCreatingManager();
                                    if (keepGoing) {
                                      model.user.permissions.editCategories =
                                          !model
                                              .user.permissions.editCategories;
                                      model.user.permissions.createManagers =
                                          false;
                                      model.notifyListeners();
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value:
                                          model.user.permissions.editCategories,
                                      onChanged: (value) async {
                                        if (!model
                                            .user.permissions.createManagers) {
                                          model.user.permissions
                                                  .editCategories =
                                              !model.user.permissions
                                                  .editCategories;
                                          model.notifyListeners();
                                        } else {
                                          var keepGoing = await model
                                              .warnUserAboutCreatingManager();
                                          if (keepGoing) {
                                            model.user.permissions
                                                    .editCategories =
                                                !model.user.permissions
                                                    .editCategories;
                                            model.user.permissions
                                                .createManagers = false;
                                            model.notifyListeners();
                                          }
                                        }
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Editar categorias de máquina')
                                  ],
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  if (!model.user.permissions.createManagers) {
                                    model.user.permissions.deleteCategories =
                                        !model
                                            .user.permissions.deleteCategories;
                                    model.notifyListeners();
                                  } else {
                                    var keepGoing = await model
                                        .warnUserAboutCreatingManager();
                                    if (keepGoing) {
                                      model.user.permissions.deleteCategories =
                                          !model.user.permissions
                                              .deleteCategories;
                                      model.user.permissions.createManagers =
                                          false;
                                      model.notifyListeners();
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value: model
                                          .user.permissions.deleteCategories,
                                      onChanged: (value) async {
                                        if (!model
                                            .user.permissions.createManagers) {
                                          model.user.permissions
                                                  .deleteCategories =
                                              !model.user.permissions
                                                  .deleteCategories;
                                          model.notifyListeners();
                                        } else {
                                          var keepGoing = await model
                                              .warnUserAboutCreatingManager();
                                          if (keepGoing) {
                                            model.user.permissions
                                                    .deleteCategories =
                                                !model.user.permissions
                                                    .deleteCategories;
                                            model.user.permissions
                                                .createManagers = false;
                                            model.notifyListeners();
                                          }
                                        }
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Deletar categorias de máquina'),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  if (!model.user.permissions.createManagers) {
                                    model.user.permissions.createMachines =
                                        !model.user.permissions.createMachines;
                                    model.notifyListeners();
                                  } else {
                                    var keepGoing = await model
                                        .warnUserAboutCreatingManager();
                                    if (keepGoing) {
                                      model.user.permissions.createMachines =
                                          !model
                                              .user.permissions.createMachines;
                                      model.user.permissions.createManagers =
                                          false;
                                      model.notifyListeners();
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value:
                                          model.user.permissions.createMachines,
                                      onChanged: (value) async {
                                        if (!model
                                            .user.permissions.createManagers) {
                                          model.user.permissions
                                                  .createMachines =
                                              !model.user.permissions
                                                  .createMachines;
                                          model.notifyListeners();
                                        } else {
                                          var keepGoing = await model
                                              .warnUserAboutCreatingManager();
                                          if (keepGoing) {
                                            model.user.permissions
                                                    .createMachines =
                                                !model.user.permissions
                                                    .createMachines;
                                            model.user.permissions
                                                .createManagers = false;
                                            model.notifyListeners();
                                          }
                                        }
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Criar máquinas')
                                  ],
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  if (!model.user.permissions.createManagers &&
                                      !model.user.permissions.createOperators) {
                                    model.user.permissions.editMachines =
                                        !model.user.permissions.editMachines;
                                    model.notifyListeners();
                                  } else {
                                    var keepGoingM = true;
                                    var keepGoingO = true;
                                    if (model.user.permissions.createManagers) {
                                      keepGoingM = await model
                                          .warnUserAboutCreatingManager();
                                    }
                                    if (model
                                        .user.permissions.createOperators) {
                                      keepGoingO = await model
                                          .warnUserAboutCreatingOperator();
                                    }

                                    if (keepGoingM && keepGoingO) {
                                      model.user.permissions.editMachines =
                                          !model.user.permissions.editMachines;
                                      model.user.permissions.createManagers =
                                          false;
                                      model.user.permissions.createOperators =
                                          false;
                                      model.notifyListeners();
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value:
                                          model.user.permissions.editMachines,
                                      onChanged: (value) async {
                                        if (!model.user.permissions
                                                .createManagers &&
                                            !model.user.permissions
                                                .createOperators) {
                                          model.user.permissions.editMachines =
                                              !model.user.permissions
                                                  .editMachines;
                                          model.notifyListeners();
                                        } else {
                                          var keepGoingM = true;
                                          var keepGoingO = true;
                                          if (model.user.permissions
                                              .createManagers) {
                                            keepGoingM = await model
                                                .warnUserAboutCreatingManager();
                                          }
                                          if (model.user.permissions
                                              .createOperators) {
                                            keepGoingO = await model
                                                .warnUserAboutCreatingOperator();
                                          }

                                          if (keepGoingM && keepGoingO) {
                                            model.user.permissions
                                                    .editMachines =
                                                !model.user.permissions
                                                    .editMachines;
                                            model.user.permissions
                                                .createManagers = false;
                                            model.user.permissions
                                                .createOperators = false;
                                            model.notifyListeners();
                                          }
                                        }
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Editar máquinas')
                                  ],
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  if (!model.user.permissions.createManagers &&
                                      !model.user.permissions.createOperators) {
                                    model.user.permissions.deleteMachines =
                                        !model.user.permissions.deleteMachines;
                                    model.notifyListeners();
                                  } else {
                                    var keepGoingM = true;
                                    var keepGoingO = true;
                                    if (model.user.permissions.createManagers) {
                                      keepGoingM = await model
                                          .warnUserAboutCreatingManager();
                                    }
                                    if (model
                                        .user.permissions.createOperators) {
                                      keepGoingO = await model
                                          .warnUserAboutCreatingOperator();
                                    }

                                    if (keepGoingM && keepGoingO) {
                                      model.user.permissions.deleteMachines =
                                          !model
                                              .user.permissions.deleteMachines;
                                      model.user.permissions.createManagers =
                                          false;
                                      model.user.permissions.createOperators =
                                          false;
                                      model.notifyListeners();
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value:
                                          model.user.permissions.deleteMachines,
                                      onChanged: (value) async {
                                        if (!model.user.permissions
                                                .createManagers &&
                                            !model.user.permissions
                                                .createOperators) {
                                          model.user.permissions
                                                  .deleteMachines =
                                              !model.user.permissions
                                                  .deleteMachines;
                                          model.notifyListeners();
                                        } else {
                                          var keepGoingM = true;
                                          var keepGoingO = true;
                                          if (model.user.permissions
                                              .createManagers) {
                                            keepGoingM = await model
                                                .warnUserAboutCreatingManager();
                                          }
                                          if (model.user.permissions
                                              .createOperators) {
                                            keepGoingO = await model
                                                .warnUserAboutCreatingOperator();
                                          }

                                          if (keepGoingM && keepGoingO) {
                                            model.user.permissions
                                                    .deleteMachines =
                                                !model.user.permissions
                                                    .deleteMachines;
                                            model.user.permissions
                                                .createManagers = false;
                                            model.user.permissions
                                                .createOperators = false;
                                            model.notifyListeners();
                                          }
                                        }
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
                          onTap: () async {
                            if (!model.user.permissions.createManagers &&
                                !model.user.permissions.createOperators) {
                              model.user.permissions.fixMachineStock =
                                  !model.user.permissions.fixMachineStock;
                              model.notifyListeners();
                            } else {
                              var keepGoingM = true;
                              var keepGoingO = true;
                              if (model.user.permissions.createManagers) {
                                keepGoingM =
                                    await model.warnUserAboutCreatingManager();
                              }
                              if (model.user.permissions.createOperators) {
                                keepGoingO =
                                    await model.warnUserAboutCreatingOperator();
                              }

                              if (keepGoingM && keepGoingO) {
                                model.user.permissions.fixMachineStock =
                                    !model.user.permissions.fixMachineStock;
                                model.user.permissions.createManagers = false;
                                model.user.permissions.createOperators = false;
                                model.notifyListeners();
                              }
                            }
                          },
                          child: Row(
                            children: [
                              Checkbox(
                                activeColor: colors.primaryColor,
                                value: model.user.permissions.fixMachineStock,
                                onChanged: (value) async {
                                  if (!model.user.permissions.createManagers &&
                                      !model.user.permissions.createOperators) {
                                    model.user.permissions.fixMachineStock =
                                        !model.user.permissions.fixMachineStock;
                                    model.notifyListeners();
                                  } else {
                                    var keepGoingM = true;
                                    var keepGoingO = true;
                                    if (model.user.permissions.createManagers) {
                                      keepGoingM = await model
                                          .warnUserAboutCreatingManager();
                                    }
                                    if (model
                                        .user.permissions.createOperators) {
                                      keepGoingO = await model
                                          .warnUserAboutCreatingOperator();
                                    }

                                    if (keepGoingM && keepGoingO) {
                                      model.user.permissions.fixMachineStock =
                                          !model
                                              .user.permissions.fixMachineStock;
                                      model.user.permissions.createManagers =
                                          false;
                                      model.user.permissions.createOperators =
                                          false;
                                      model.notifyListeners();
                                    }
                                  }
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
                                onTap: () async {
                                  if (!model.user.permissions.createManagers &&
                                      !model.user.permissions.createOperators) {
                                    model.user.permissions
                                            .toggleMaintenanceMode =
                                        !model.user.permissions
                                            .toggleMaintenanceMode;
                                    model.notifyListeners();
                                  } else {
                                    var keepGoingM = true;
                                    var keepGoingO = true;
                                    if (model.user.permissions.createManagers) {
                                      keepGoingM = await model
                                          .warnUserAboutCreatingManager();
                                    }
                                    if (model
                                        .user.permissions.createOperators) {
                                      keepGoingO = await model
                                          .warnUserAboutCreatingOperator();
                                    }

                                    if (keepGoingM && keepGoingO) {
                                      model.user.permissions
                                              .toggleMaintenanceMode =
                                          !model.user.permissions
                                              .toggleMaintenanceMode;
                                      model.user.permissions.createManagers =
                                          false;
                                      model.user.permissions.createOperators =
                                          false;
                                      model.notifyListeners();
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value: model.user.permissions
                                          .toggleMaintenanceMode,
                                      onChanged: (value) async {
                                        if (!model.user.permissions
                                                .createManagers &&
                                            !model.user.permissions
                                                .createOperators) {
                                          model.user.permissions
                                                  .toggleMaintenanceMode =
                                              !model.user.permissions
                                                  .toggleMaintenanceMode;
                                          model.notifyListeners();
                                        } else {
                                          var keepGoingM = true;
                                          var keepGoingO = true;
                                          if (model.user.permissions
                                              .createManagers) {
                                            keepGoingM = await model
                                                .warnUserAboutCreatingManager();
                                          }
                                          if (model.user.permissions
                                              .createOperators) {
                                            keepGoingO = await model
                                                .warnUserAboutCreatingOperator();
                                          }

                                          if (keepGoingM && keepGoingO) {
                                            model.user.permissions
                                                    .toggleMaintenanceMode =
                                                !model.user.permissions
                                                    .toggleMaintenanceMode;
                                            model.user.permissions
                                                .createManagers = false;
                                            model.user.permissions
                                                .createOperators = false;
                                            model.notifyListeners();
                                          }
                                        }
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Text('Modo manutenção')
                                  ],
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  if (!model.user.permissions.createManagers &&
                                      !model.user.permissions.createOperators) {
                                    model.user.permissions.addRemoteCredit =
                                        !model.user.permissions.addRemoteCredit;
                                    model.notifyListeners();
                                  } else {
                                    var keepGoingM = true;
                                    var keepGoingO = true;
                                    if (model.user.permissions.createManagers) {
                                      keepGoingM = await model
                                          .warnUserAboutCreatingManager();
                                    }
                                    if (model
                                        .user.permissions.createOperators) {
                                      keepGoingO = await model
                                          .warnUserAboutCreatingOperator();
                                    }

                                    if (keepGoingM && keepGoingO) {
                                      model.user.permissions.addRemoteCredit =
                                          !model
                                              .user.permissions.addRemoteCredit;
                                      model.user.permissions.createManagers =
                                          false;
                                      model.user.permissions.createOperators =
                                          false;
                                      model.notifyListeners();
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colors.primaryColor,
                                      value: model
                                          .user.permissions.addRemoteCredit,
                                      onChanged: (value) async {
                                        if (!model.user.permissions
                                                .createManagers &&
                                            !model.user.permissions
                                                .createOperators) {
                                          model.user.permissions
                                                  .addRemoteCredit =
                                              !model.user.permissions
                                                  .addRemoteCredit;
                                          model.notifyListeners();
                                        } else {
                                          var keepGoingM = true;
                                          var keepGoingO = true;
                                          if (model.user.permissions
                                              .createManagers) {
                                            keepGoingM = await model
                                                .warnUserAboutCreatingManager();
                                          }
                                          if (model.user.permissions
                                              .createOperators) {
                                            keepGoingO = await model
                                                .warnUserAboutCreatingOperator();
                                          }

                                          if (keepGoingM && keepGoingO) {
                                            model.user.permissions
                                                    .addRemoteCredit =
                                                !model.user.permissions
                                                    .addRemoteCredit;
                                            model.user.permissions
                                                .createManagers = false;
                                            model.user.permissions
                                                .createOperators = false;
                                            model.notifyListeners();
                                          }
                                        }
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
                                    model.createManager();
                                  } else {
                                    model.updateManager();
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
