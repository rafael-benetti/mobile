import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/core/models/collection.dart';
import '../../../../src/core/models/user.dart';
import '../../../../src/core/providers/collections_provider.dart';
import '../../../../src/core/providers/user_provider.dart';
import '../../../../src/interface/pages/detailed_collection/widgets.dart';
import '../../../../src/interface/pages/edit_collection/edit_collection_page.dart';
import '../../../../src/interface/shared/colors.dart';
import '../../../../src/interface/shared/text_styles.dart';
import '../../../../src/interface/widgets/current_path.dart';
import '../../../../src/interface/widgets/icon_translator.dart';

import '../../../locator.dart';
import 'detailed_collection_page_model.dart';

class DetailedCollectionPage extends StatelessWidget {
  static const route = '/detailedCollection';
  final styles = locator<TextStyles>();
  final colors = locator<AppColors>();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DetailedCollectionPageModel>.reactive(
      viewModelBuilder: () => DetailedCollectionPageModel(),
      onModelReady: (model) {
        model.loadData(ModalRoute.of(context).settings.arguments as Collection);
      },
      builder: (context, model, child) => Consumer<CollectionsProvider>(
        builder: (context, collectionsProvider, _) => Scaffold(
          floatingActionButton: model.userProvider.user.role != Role.OPERATOR &&
                  model.userProvider.user.permissions.editCollections
              ? FloatingActionButton.extended(
                  backgroundColor:
                      collectionsProvider.detailedCollection.reviewedData ==
                              null
                          ? colors.primaryColor
                          : colors.darkGreen,
                  onPressed:
                      collectionsProvider.detailedCollection.reviewedData ==
                              null
                          ? () => model.reviewCollection(
                              collectionsProvider.detailedCollection.id)
                          : () => model.popReviewDataDialog(),
                  icon: collectionsProvider.detailedCollection.reviewedData ==
                          null
                      ? Icon(Icons.save)
                      : Icon(Icons.check),
                  label: collectionsProvider.detailedCollection.reviewedData ==
                          null
                      ? Text('Revisar coleta')
                      : Row(
                          children: [
                            Text('Coleta revisada'),
                          ],
                        ),
                )
              : null,
          body: model.isBusy
              ? Center()
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      iconTheme: IconThemeData(color: colors.primaryColor),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(15, 15, 15, 60),
                      sliver: MultiSliver(
                        children: [
                          CurrentPath(
                            topText: 'Coleta',
                            bottomFinalText:
                                ' / Visão geral / ${collectionsProvider.detailedCollection.machine.serialNumber}',
                            buttonText: 'Editar',
                            onPressed: locator<UserProvider>()
                                    .user
                                    .permissions
                                    .editCollections
                                ? () {
                                    interfaceService.navigateTo(
                                        EditCollectionPage.route,
                                        arguments: collectionsProvider
                                            .detailedCollection);
                                  }
                                : null,
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 15),
                              child: Column(
                                children: [
                                  PreviousData(
                                    startTime: collectionsProvider
                                                .detailedCollection
                                                .previousCollection !=
                                            null
                                        ? collectionsProvider.detailedCollection
                                            .previousCollection.startTime
                                        : null,
                                    endTime: collectionsProvider
                                                .detailedCollection
                                                .previousCollection !=
                                            null
                                        ? collectionsProvider.detailedCollection
                                            .previousCollection.endTime
                                        : null,
                                    userName: collectionsProvider
                                                .detailedCollection
                                                .previousCollection !=
                                            null
                                        ? collectionsProvider.detailedCollection
                                            .previousCollection.userName
                                        : '-',
                                  ),
                                  Divider(height: 35),
                                  CurrentData(
                                    endTime: collectionsProvider
                                        .detailedCollection.endTime,
                                    userName: collectionsProvider
                                        .detailedCollection.userName,
                                    startTime: collectionsProvider
                                        .detailedCollection.startTime,
                                  ),
                                  if (collectionsProvider.detailedCollection
                                              .startLocation !=
                                          null &&
                                      collectionsProvider
                                              .detailedCollection.endLocation !=
                                          null)
                                    Map(
                                      startLocation: collectionsProvider
                                          .detailedCollection.startLocation,
                                      endLocation: collectionsProvider
                                          .detailedCollection.endLocation,
                                    ),
                                  Observations(
                                    observations: collectionsProvider
                                        .detailedCollection.observations,
                                  ),
                                  Divider(height: 35),
                                  Column(
                                    children: List.generate(
                                      collectionsProvider.detailedCollection
                                          .boxCollections.length,
                                      (index) => SingleBoxCollection(
                                        categoryLabel: collectionsProvider
                                            .detailedCollection
                                            .machine
                                            .categoryLabel,
                                        boxCollection: collectionsProvider
                                            .detailedCollection
                                            .boxCollections[index],
                                        previousBoxCollection: model
                                                    .collectionsProvider
                                                    .detailedCollection
                                                    .previousCollection !=
                                                null
                                            ? (collectionsProvider
                                                        .detailedCollection
                                                        .previousCollection
                                                        .boxCollections
                                                        .length >
                                                    index
                                                ? collectionsProvider
                                                    .detailedCollection
                                                    .previousCollection
                                                    .boxCollections[index]
                                                : null)
                                            : null,
                                        cabinNumber: '${index + 1}',
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
