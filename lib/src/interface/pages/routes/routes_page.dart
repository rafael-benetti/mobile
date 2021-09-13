import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/core/models/user.dart';
import '../../../../src/interface/pages/detailed_route/detailed_route_page.dart';
import '../../../../src/interface/widgets/custom_dropdown.dart';
import '../../../core/providers/routes_provider.dart';
import '../../../core/services/interface_service.dart';
import '../edit_route/edit_route_page.dart';
import 'routes_page_model.dart';
import 'widgets.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';
import '../../widgets/current_path.dart';
import '../../widgets/custom_text_field.dart';

import '../../../locator.dart';

class RoutesPage extends StatelessWidget {
  static const route = '/routes';

  final styles = locator<TextStyles>();
  final colors = locator<AppColors>();

  @override
  Widget build(BuildContext context) {
    Timer _timer;
    return ViewModelBuilder<RoutesPageModel>.reactive(
      viewModelBuilder: () => RoutesPageModel(),
      onModelReady: (model) => model.loadData(),
      builder: (context, model, child) => Scaffold(
        body: Consumer<RoutesProvider>(builder: (context, _routesProvider, _) {
          final _scrollController = ScrollController();
          _scrollController.addListener(() {
            if (_scrollController.position.extentAfter == 0 &&
                _routesProvider.routes.length != _routesProvider.count) {
              model.offset += 5;
              model.filterRoutes(false);
            }
          });
          return model.isBusy
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
                            topText: 'Rotas',
                            bottomFinalText: ' / Rotas',
                            buttonText: 'Nova Rota',
                            onPressed:
                                model.userProvider.user.permissions.createRoutes
                                    ? () => {
                                          locator<InterfaceService>()
                                              .navigateTo(EditRoutePage.route),
                                          model.clearFilteredGroupIds(),
                                          _routesProvider.filterRoutes()
                                        }
                                    : null,
                          ),
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 5),
                                Text(
                                  'Pesquisar',
                                  style: styles.light(fontSize: 16),
                                ),
                                SizedBox(height: 5),
                                CustomTextField(
                                  initialValue: '',
                                  onChanged: (value) {
                                    model.offset = 0;
                                    if (_timer != null) {
                                      _timer.cancel();
                                    }
                                    if (value != '') {
                                      model.label = value;
                                      _timer = Timer(
                                        Duration(milliseconds: 500),
                                        () => model.filterRoutes(true),
                                      );
                                    } else {
                                      model.label = null;
                                      model.filterRoutes(true);
                                    }
                                  },
                                ),
                                if (model.userProvider.user.role !=
                                    Role.OPERATOR)
                                  Column(
                                    children: [
                                      SizedBox(height: 10),
                                      Text(
                                        'Parceria',
                                        style: styles.light(fontSize: 16),
                                      ),
                                      SizedBox(height: 5),
                                      CustomDropdownButton(
                                        initialValue:
                                            DropdownInputOption(title: 'Todas'),
                                        maxHeight: 157.5,
                                        values: [
                                              DropdownInputOption(
                                                  title: 'Todas')
                                            ] +
                                            List.generate(
                                              model
                                                  .groupsProvider.groups.length,
                                              (index) => DropdownInputOption(
                                                  title: model.groupsProvider
                                                      .groups[index].label,
                                                  option: model.groupsProvider
                                                      .groups[index].id),
                                            ),
                                        onSelect: (inputOption) {
                                          if (inputOption.title != 'Todas') {
                                            model.groupId = model
                                                .groupsProvider.groups
                                                .firstWhere((element) =>
                                                    element.id ==
                                                    inputOption.option)
                                                .id;
                                          } else {
                                            model.groupId = null;
                                          }
                                          model.offset = 0;
                                          model.filterRoutes(true);
                                        },
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Ponto de venda',
                                        style: styles.light(fontSize: 16),
                                      ),
                                      SizedBox(height: 5),
                                      CustomDropdownButton(
                                        initialValue:
                                            DropdownInputOption(title: 'Todos'),
                                        maxHeight: 157.5,
                                        values: [
                                              DropdownInputOption(
                                                  title: 'Todos')
                                            ] +
                                            List.generate(
                                              model.pointsOfSaleProvider
                                                  .pointsOfSale.length,
                                              (index) => DropdownInputOption(
                                                  title: model
                                                      .pointsOfSaleProvider
                                                      .pointsOfSale[index]
                                                      .label,
                                                  option: model
                                                      .pointsOfSaleProvider
                                                      .pointsOfSale[index]
                                                      .id),
                                            ),
                                        onSelect: (inputOption) {
                                          if (inputOption.title != 'Todos') {
                                            model.pointOfSaleId = model
                                                .pointsOfSaleProvider
                                                .pointsOfSale
                                                .firstWhere((element) =>
                                                    element.id ==
                                                    inputOption.option)
                                                .id;
                                          } else {
                                            model.pointOfSaleId = null;
                                          }
                                          model.offset = 0;
                                          model.filterRoutes(true);
                                        },
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Operador',
                                        style: styles.light(fontSize: 16),
                                      ),
                                      SizedBox(height: 5),
                                      CustomDropdownButton(
                                        initialValue:
                                            DropdownInputOption(title: 'Todos'),
                                        maxHeight: 157.5,
                                        values: [
                                              DropdownInputOption(
                                                  title: 'Todos')
                                            ] +
                                            List.generate(
                                              model.userProvider.operators
                                                  .length,
                                              (index) => DropdownInputOption(
                                                  title: model.userProvider
                                                      .operators[index].name,
                                                  option: model.userProvider
                                                      .operators[index].id),
                                            ),
                                        onSelect: (inputOption) {
                                          if (inputOption.title != 'Todos') {
                                            model.operatorId = model
                                                .userProvider.operators
                                                .firstWhere((element) =>
                                                    element.id ==
                                                    inputOption.option)
                                                .id;
                                          } else {
                                            model.operatorId = null;
                                          }
                                          model.offset = 0;
                                          model.filterRoutes(true);
                                        },
                                      ),
                                    ],
                                  ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                          if (_routesProvider.filteredRoutes.isNotEmpty)
                            SliverList(
                              delegate: SliverChildListDelegate(
                                [
                                      Text(
                                        'Rotas (${_routesProvider.filteredRoutes.length})',
                                        style: styles.light(fontSize: 16),
                                      ),
                                      SizedBox(height: 10),
                                    ] +
                                    List.generate(
                                      _routesProvider.filteredRoutes.length,
                                      (index) => Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              model.clearFilteredGroupIds();
                                              _routesProvider.filterRoutes();
                                              locator<InterfaceService>()
                                                  .navigateTo(
                                                      DetailedRoutePage.route,
                                                      arguments: _routesProvider
                                                          .filteredRoutes[index]
                                                          .id);
                                            },
                                            child: RouteCard(
                                              operators:
                                                  model.userProvider.operators,
                                              route: _routesProvider
                                                  .filteredRoutes[index],
                                              pointsOfSale: model
                                                  .pointsOfSaleProvider
                                                  .pointsOfSale,
                                            ),
                                          ),
                                          SizedBox(height: 5)
                                        ],
                                      ),
                                    ),
                              ),
                            )
                          else
                            SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 15),
                                  Text(
                                    model.filteredGroupsIds.isEmpty
                                        ? 'Nenhuma rota cadastrada.'
                                        : 'Nenhuma rota encontrada.',
                                  ),
                                ],
                              ),
                            )
                        ],
                      ),
                    )
                  ],
                );
        }),
      ),
    );
  }
}
