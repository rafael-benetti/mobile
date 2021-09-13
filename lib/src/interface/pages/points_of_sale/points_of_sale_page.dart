import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/core/models/user.dart';
import '../../../core/providers/points_of_sale_provider.dart';
import '../../../core/services/interface_service.dart';
import '../detailed_point_of_sale/detailed_point_of_sale_page.dart';
import '../edit_point_of_sale/edit_point_of_sale_page.dart';
import 'points_of_sale_page_model.dart';
import 'widgets.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';
import '../../widgets/current_path.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_text_field.dart';

import '../../../locator.dart';

class PointsOfSalePage extends StatelessWidget {
  static const route = '/salespots';
  final styles = locator<TextStyles>();
  final colors = locator<AppColors>();

  @override
  Widget build(BuildContext context) {
    Timer _timer;
    return ViewModelBuilder<PointsOfSalePageModel>.reactive(
      viewModelBuilder: () => PointsOfSalePageModel(),
      onModelReady: (model) => model.loadData(),
      builder: (context, model, child) => Scaffold(
        body: Consumer<PointsOfSaleProvider>(
          builder: (context, pointsOfSaleProvider, _) {
            final _scrollController = ScrollController();
            _scrollController.addListener(
              () {
                if (_scrollController.position.extentAfter == 0 &&
                    pointsOfSaleProvider.filteredPointsOfSale.length !=
                        pointsOfSaleProvider.count) {
                  model.filteredOffset += 5;
                  model.filterPointsOfSale(false);
                }
              },
            );
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
                              topText: 'Pontos de Venda',
                              bottomFinalText: ' / Pontos de Venda',
                              buttonText: 'Novo Ponto de Venda',
                              onPressed:
                                  model.user.permissions.createPointsOfSale
                                      ? () async {
                                          model.clearAllFilters();
                                          await pointsOfSaleProvider
                                              .filterPointsOfSale(
                                                  offset: model.filteredOffset,
                                                  clearCurrentList: true);
                                          await locator<InterfaceService>()
                                              .navigateTo(
                                                  EditPointOfSalePage.route);
                                        }
                                      : null,
                            ),
                            SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pesquisar',
                                    style: styles.light(fontSize: 16),
                                  ),
                                  SizedBox(height: 5),
                                  CustomTextField(
                                    onChanged: (value) {
                                      if (_timer != null) {
                                        _timer.cancel();
                                      }
                                      if (value == '') {
                                        model.label = null;
                                      } else {
                                        model.label = value;
                                      }
                                      _timer =
                                          Timer(Duration(milliseconds: 500),
                                              () async {
                                        model.filteredOffset = 0;
                                        model.filterPointsOfSale(true);
                                      });
                                    },
                                  ),
                                  SizedBox(height: 7.5),
                                ],
                              ),
                            ),
                            if (model.groupsProvider.groups.length > 1 &&
                                model.user.role != Role.OPERATOR)
                              SliverToBoxAdapter(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Parceria',
                                      style: styles.light(fontSize: 16),
                                    ),
                                    SizedBox(height: 5),
                                    CustomDropdownButton(
                                      maxHeight: 157.5,
                                      onSelect: (value) {
                                        if (value.title.toLowerCase() ==
                                            'todas') {
                                          model.groupId = null;
                                        } else {
                                          model.groupId = model
                                              .groupsProvider.groups
                                              .firstWhere((element) =>
                                                  element.label == value.title)
                                              .id;
                                        }
                                        model.filteredOffset = 0;
                                        model.filterPointsOfSale(true);
                                      },
                                      initialValue:
                                          DropdownInputOption(title: 'Todas'),
                                      values: [
                                            DropdownInputOption(title: 'Todas')
                                          ] +
                                          List.generate(
                                            model.groupsProvider.groups.length,
                                            (index) => DropdownInputOption(
                                              title: model.groupsProvider
                                                  .groups[index].label,
                                            ),
                                          ),
                                    ),
                                    SizedBox(height: 7.5),
                                    Text(
                                      'Rota',
                                      style: styles.light(fontSize: 16),
                                    ),
                                    SizedBox(height: 5),
                                    CustomDropdownButton(
                                      maxHeight: 157.5,
                                      onSelect: (value) {
                                        if (value.title.toLowerCase() ==
                                            'todas') {
                                          model.routeId = null;
                                        } else {
                                          model.routeId = model
                                              .routesProvider.routes
                                              .firstWhere((element) =>
                                                  element.label == value.title)
                                              .id;
                                        }
                                        model.filteredOffset = 0;
                                        model.filterPointsOfSale(true);
                                      },
                                      initialValue:
                                          DropdownInputOption(title: 'Todas'),
                                      values: [
                                            DropdownInputOption(title: 'Todas')
                                          ] +
                                          List.generate(
                                            model.routesProvider.routes.length,
                                            (index) => DropdownInputOption(
                                              title: model.routesProvider
                                                  .routes[index].label,
                                            ),
                                          ),
                                    ),
                                    SizedBox(height: 7.5),
                                    Text(
                                      'Operador',
                                      style: styles.light(fontSize: 16),
                                    ),
                                    SizedBox(height: 5),
                                    CustomDropdownButton(
                                      maxHeight: 157.5,
                                      onSelect: (value) {
                                        if (value.title.toLowerCase() ==
                                            'todos') {
                                          model.operatorId = null;
                                        } else {
                                          model.operatorId = model
                                              .userProvider.operators
                                              .firstWhere((element) =>
                                                  element.name == value.title)
                                              .id;
                                        }
                                        model.filteredOffset = 0;
                                        model.filterPointsOfSale(true);
                                      },
                                      initialValue:
                                          DropdownInputOption(title: 'Todos'),
                                      values: [
                                            DropdownInputOption(title: 'Todos')
                                          ] +
                                          List.generate(
                                            model.userProvider.operators.length,
                                            (index) => DropdownInputOption(
                                              title: model.userProvider
                                                  .operators[index].name,
                                            ),
                                          ),
                                    ),
                                    SizedBox(height: 7.5),
                                  ],
                                ),
                              ),
                            if (pointsOfSaleProvider
                                .filteredPointsOfSale.isNotEmpty)
                              SliverList(
                                delegate: SliverChildListDelegate(
                                  [
                                        Text(
                                          'Pontos de Venda (${pointsOfSaleProvider.count})',
                                          style: styles.light(fontSize: 16),
                                        ),
                                        SizedBox(height: 10),
                                      ] +
                                      List.generate(
                                        pointsOfSaleProvider
                                            .filteredPointsOfSale.length,
                                        (index) => Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                if (model.userProvider.user
                                                        .role !=
                                                    Role.OPERATOR) {
                                                  locator<InterfaceService>()
                                                      .navigateTo(
                                                    DetailedPointOfSalePage
                                                        .route,
                                                    arguments:
                                                        pointsOfSaleProvider
                                                            .filteredPointsOfSale[
                                                                index]
                                                            .id,
                                                  );
                                                }
                                              },
                                              child: PointOfSaleCard(
                                                routes:
                                                    model.routesProvider.routes,
                                                groups:
                                                    model.groupsProvider.groups,
                                                pointOfSale: pointsOfSaleProvider
                                                        .filteredPointsOfSale[
                                                    index],
                                              ),
                                            ),
                                            SizedBox(height: 15)
                                          ],
                                        ),
                                      ),
                                ),
                              )
                            else
                              SliverToBoxAdapter(
                                child: Column(
                                  children: [
                                    SizedBox(height: 25),
                                    Text('Nenhum ponto de venda encontrado.')
                                  ],
                                ),
                              )
                          ],
                        ),
                      )
                    ],
                  );
          },
        ),
      ),
    );
  }
}
