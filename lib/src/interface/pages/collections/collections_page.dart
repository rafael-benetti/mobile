import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/core/models/user.dart';
import '../../../../src/core/providers/collections_provider.dart';
import '../../../../src/interface/pages/detailed_collection/detailed_collection_page.dart';
import '../../../../src/interface/widgets/current_path.dart';
import '../../../../src/interface/pages/collections/widgets.dart';
import '../../../../src/interface/shared/colors.dart';
import '../../../../src/interface/shared/text_styles.dart';
import '../../../../src/interface/widgets/custom_dropdown.dart';
import '../../../../src/interface/widgets/custom_text_field.dart';
import '../../../../src/interface/widgets/icon_translator.dart';

import '../../../locator.dart';
import 'collections_page_model.dart';

class CollectionsPage extends StatelessWidget {
  static const route = '/collection';
  final styles = locator<TextStyles>();
  final colors = locator<AppColors>();

  @override
  Widget build(BuildContext context) {
    Timer _timer;
    return ViewModelBuilder<CollectionsPageModel>.reactive(
      viewModelBuilder: () => CollectionsPageModel(),
      onModelReady: (model) => model.loadData(),
      builder: (context, model, child) => Scaffold(
        body: Consumer<CollectionsProvider>(
          builder: (context, _collectionsProvider, _) {
            final _scrollController = ScrollController();
            _scrollController.addListener(
              () {
                if (_scrollController.position.extentAfter == 0 &&
                    _collectionsProvider.filteredCollections.length !=
                        _collectionsProvider.count) {
                  model.offset += 5;
                  model.filterCollections(false);
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
                        padding: EdgeInsets.all(15),
                        sliver: MultiSliver(
                          children: [
                            CurrentPath(
                              topText: 'Coletas',
                              bottomFinalText: ' / Coletas',
                              buttonText: 'Nova Coleta',
                              onPressed: () => model.newCollection(),
                            ),
                            SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pesquisar por número de série',
                                    style: styles.light(fontSize: 16),
                                  ),
                                  SizedBox(height: 5),
                                  CustomTextField(
                                    initialValue: '',
                                    onChanged: (v) {
                                      if (_timer != null) {
                                        _timer.cancel();
                                      }
                                      if (v == '') {
                                        model.keywords = null;
                                      } else {
                                        model.keywords = v;
                                      }
                                      _timer = Timer(
                                        Duration(milliseconds: 500),
                                        () => model.filterCollections(true),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 7.5),
                                  if (model.userProvider.user.role !=
                                      Role.OPERATOR)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
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
                                                      element.label ==
                                                      value.title)
                                                  .id;
                                            }
                                            model.offset = 0;
                                            model.filterCollections(true);
                                          },
                                          initialValue: DropdownInputOption(
                                              title: 'Todas'),
                                          values: [
                                                DropdownInputOption(
                                                    title: 'Todas')
                                              ] +
                                              List.generate(
                                                model.routesProvider.routes
                                                    .length,
                                                (index) => DropdownInputOption(
                                                  title: model.routesProvider
                                                      .routes[index].label,
                                                ),
                                              ),
                                        ),
                                        SizedBox(height: 7.5),
                                        Text(
                                          'Usuário',
                                          style: styles.light(fontSize: 16),
                                        ),
                                        SizedBox(height: 5),
                                        CustomDropdownButton(
                                          maxHeight: 157.5,
                                          onSelect: (value) {
                                            if (value.title.toLowerCase() ==
                                                'todas') {
                                              model.userId = null;
                                            } else {
                                              model.userId = model
                                                  .availableUsers
                                                  .firstWhere((element) =>
                                                      element.name ==
                                                      value.title)
                                                  .id;
                                            }
                                            model.offset = 0;
                                            model.filterCollections(true);
                                          },
                                          initialValue: DropdownInputOption(
                                              title: 'Todas'),
                                          values: [
                                                DropdownInputOption(
                                                    title: 'Todas')
                                              ] +
                                              List.generate(
                                                model.availableUsers.length,
                                                (index) => DropdownInputOption(
                                                  title: model
                                                      .availableUsers[index]
                                                      .name,
                                                ),
                                              ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            if (_collectionsProvider
                                .filteredCollections.isNotEmpty)
                              SliverList(
                                delegate: SliverChildListDelegate(
                                  [
                                        SizedBox(height: 10),
                                        Text(
                                          'Coletas (${_collectionsProvider.count})',
                                          style: styles.light(fontSize: 16),
                                        ),
                                        SizedBox(height: 10),
                                      ] +
                                      List.generate(
                                        _collectionsProvider
                                            .filteredCollections.length,
                                        (index) => Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                interfaceService.navigateTo(
                                                    DetailedCollectionPage
                                                        .route,
                                                    arguments: _collectionsProvider
                                                            .filteredCollections[
                                                        index]);
                                              },
                                              child: CollectionCard(
                                                collection: _collectionsProvider
                                                    .filteredCollections[index],
                                              ),
                                            ),
                                            SizedBox(height: 10)
                                          ],
                                        ),
                                      ),
                                ),
                              )
                            else
                              SliverToBoxAdapter(
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.only(top: 25),
                                  child: Text('Nenhuma coleta encontrada.'),
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
