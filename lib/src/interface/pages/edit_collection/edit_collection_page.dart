import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/core/models/box_collection.dart';
import '../../../../src/core/models/collection.dart';
import '../../../../src/core/models/machine.dart';

import '../../../../src/core/services/interface_service.dart';
import '../../../../src/interface/pages/edit_collection/edit_collection_page_model.dart';
import '../../../../src/interface/pages/edit_collection/widgets.dart';
import '../../../../src/interface/shared/colors.dart';
import '../../../../src/interface/shared/text_styles.dart';
import '../../../../src/interface/widgets/current_path.dart';

import '../../../../src/interface/widgets/side_buttons.dart';
import '../../../locator.dart';
import '../photo_view/full_photo_page.dart';

class EditCollectionPage extends StatefulWidget {
  static const route = '/editcollect';

  @override
  _EditCollectionPageState createState() => _EditCollectionPageState();
}

class _EditCollectionPageState extends State<EditCollectionPage> {
  final styles = locator<TextStyles>();

  final colors = locator<AppColors>();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EditCollectionPageModel>.reactive(
      viewModelBuilder: () => EditCollectionPageModel(),
      onModelReady: (model) async {
        if (ModalRoute.of(context).settings.arguments is Machine) {
          model.machine = ModalRoute.of(context).settings.arguments;
          model.initializeCreateCollection();
          model.creatingCollection = true;
        } else {
          model.creatingCollection = false;
          var boxCollections = <BoxCollection>[];
          var collection =
              ModalRoute.of(context).settings.arguments as Collection;
          model.collection = collection;
          collection.boxCollections.forEach((element) {
            var bC = BoxCollection();
            bC.boxId = element.boxId;
            bC.counterCollections = [...element.counterCollections];
            boxCollections.add(bC);
          });
          model.collection.boxCollections = [];
          model.collection.boxCollections = [...boxCollections];
          model.initializeEditCollection();
        }
      },
      disposeViewModel: true,
      builder: (context, model, child) => Scaffold(
          body: !model.isBusy
              ? CustomScrollView(
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
                            topText: model.machine != null
                                ? 'Criar coleta - ${model.machine.serialNumber}'
                                : 'Criar coleta - ${model.collection.machine.serialNumber}',
                            bottomFinalText: ' / criar coleta',
                          ),
                          SliverToBoxAdapter(
                            child: Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (model.digitalCounters.isNotEmpty)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Contadores Digitais',
                                          style: styles.medium(fontSize: 20),
                                        ),
                                        SizedBox(height: 15),
                                        Column(
                                          children: List.generate(
                                            model.digitalCounters.length,
                                            (index) => CollectionTextField(
                                              initialValue: ModalRoute.of(
                                                          context)
                                                      .settings
                                                      .arguments is Machine
                                                  ? ''
                                                  : model
                                                      .digitalCounters[index]
                                                          ['counter']
                                                      .digitalCount
                                                      .toString(),
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              title: model.counterTypesProvider
                                                      .counterTypes
                                                      .firstWhere((element) =>
                                                          element.id ==
                                                          model
                                                              .digitalCounters[
                                                                  index]
                                                                  ['counter']
                                                              .counterTypeId)
                                                      .label +
                                                  model.digitalCounters[index]
                                                      ['box'],
                                              onChanged: (value) {
                                                if (model.creatingCollection) {
                                                  if (value == '') {
                                                    model.addToDigitalCounter(
                                                        model
                                                            .digitalCounters[
                                                                index]
                                                                ['counter']
                                                            .id,
                                                        null);
                                                  } else {
                                                    model.addToDigitalCounter(
                                                        model
                                                            .digitalCounters[
                                                                index]
                                                                ['counter']
                                                            .id,
                                                        value);
                                                  }
                                                } else {
                                                  if (value == '') {
                                                    model.addToDigitalCounter(
                                                        model
                                                            .digitalCounters[
                                                                index]
                                                                ['counter']
                                                            .counterId,
                                                        null);
                                                  } else {
                                                    model.addToDigitalCounter(
                                                        model
                                                            .digitalCounters[
                                                                index]
                                                                ['counter']
                                                            .counterId,
                                                        value);
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        Divider(),
                                        SizedBox(height: 10),
                                      ],
                                    ),
                                  if (model.mechanicalCounters.isNotEmpty)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Contadores Mecânicos',
                                          style: styles.medium(fontSize: 20),
                                        ),
                                        SizedBox(height: 15),
                                        Column(
                                          children: List.generate(
                                            model.mechanicalCounters.length,
                                            (index) => CollectionTextField(
                                              initialValue: ModalRoute.of(
                                                          context)
                                                      .settings
                                                      .arguments is Machine
                                                  ? ''
                                                  : model
                                                      .mechanicalCounters[index]
                                                          ['counter']
                                                      .mechanicalCount
                                                      .toString(),
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              title: model.counterTypesProvider
                                                      .counterTypes
                                                      .firstWhere((element) =>
                                                          element.id ==
                                                          model
                                                              .mechanicalCounters[
                                                                  index]
                                                                  ['counter']
                                                              .counterTypeId)
                                                      .label +
                                                  model.mechanicalCounters[
                                                      index]['box'],
                                              onChanged: (value) {
                                                if (model.creatingCollection) {
                                                  if (value == '') {
                                                    model.addToMechanicalCounter(
                                                        model
                                                            .mechanicalCounters[
                                                                index]
                                                                ['counter']
                                                            .id,
                                                        null);
                                                  } else {
                                                    model.addToMechanicalCounter(
                                                        model
                                                            .mechanicalCounters[
                                                                index]
                                                                ['counter']
                                                            .id,
                                                        value);
                                                  }
                                                } else {
                                                  if (value == '') {
                                                    model.addToMechanicalCounter(
                                                        model
                                                            .mechanicalCounters[
                                                                index]
                                                                ['counter']
                                                            .counterId,
                                                        null);
                                                  } else {
                                                    model.addToMechanicalCounter(
                                                        model
                                                            .mechanicalCounters[
                                                                index]
                                                                ['counter']
                                                            .counterId,
                                                        value);
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        Divider(),
                                        SizedBox(height: 10),
                                      ],
                                    ),
                                  if (model.countedCounters.isNotEmpty)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Recolhido',
                                          style: styles.medium(fontSize: 20),
                                        ),
                                        SizedBox(height: 15),
                                        Column(
                                          children: List.generate(
                                            model.countedCounters.length,
                                            (index) => CollectionTextField(
                                              initialValue: ModalRoute.of(
                                                          context)
                                                      .settings
                                                      .arguments is Machine
                                                  ? ''
                                                  : model
                                                      .countedCounters[index]
                                                          ['counter']
                                                      .userCount
                                                      .toString(),
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              title: model.counterTypesProvider
                                                      .counterTypes
                                                      .firstWhere((element) =>
                                                          element.id ==
                                                          model
                                                              .countedCounters[
                                                                  index]
                                                                  ['counter']
                                                              .counterTypeId)
                                                      .label +
                                                  model.countedCounters[index]
                                                      ['box'],
                                              onChanged: (value) {
                                                if (model.creatingCollection) {
                                                  if (value == '') {
                                                    model.addToCountedMechanical(
                                                        model
                                                            .countedCounters[
                                                                index]
                                                                ['counter']
                                                            .id,
                                                        null);
                                                  } else {
                                                    model.addToCountedMechanical(
                                                        model
                                                            .countedCounters[
                                                                index]
                                                                ['counter']
                                                            .id,
                                                        value);
                                                  }
                                                } else {
                                                  if (value == '') {
                                                    model.addToCountedMechanical(
                                                        model
                                                            .countedCounters[
                                                                index]
                                                                ['counter']
                                                            .counterId,
                                                        null);
                                                  } else {
                                                    model.addToCountedMechanical(
                                                        model
                                                            .countedCounters[
                                                                index]
                                                                ['counter']
                                                            .counterId,
                                                        value);
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        Divider(),
                                        SizedBox(height: 10),
                                      ],
                                    ),
                                  Text(
                                    'Fotos',
                                    style: styles.medium(fontSize: 20),
                                  ),
                                  SizedBox(height: 15),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: List.generate(
                                      model.totalCounters.length,
                                      (index) => Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            model.counterTypesProvider
                                                    .counterTypes
                                                    .firstWhere((element) =>
                                                        element.id ==
                                                        model
                                                            .totalCounters[
                                                                index]
                                                                ['counter']
                                                            .counterTypeId)
                                                    .label +
                                                model.totalCounters[index]
                                                    ['box'],
                                            style: styles.regular(),
                                          ),
                                          SizedBox(height: 5),
                                          if (model.filesPerCounter[index]
                                              .isNotEmpty)
                                            Container(
                                              height: 100,
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: model
                                                    .filesPerCounter[index]
                                                    .length,
                                                itemBuilder:
                                                    (context, fileIndex) => Row(
                                                  children: [
                                                    if (fileIndex == 0)
                                                      GestureDetector(
                                                        onTap: () => model
                                                            .popSourceOfFileDialog(
                                                                index, context),
                                                        child: Container(
                                                          height: 100,
                                                          width: 75,
                                                          color: Colors
                                                              .grey.shade300,
                                                          child: Center(
                                                            child: Icon(
                                                              Icons.add,
                                                              size: 30,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    Stack(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            locator<InterfaceService>().navigateTo(
                                                                FullPhotoPage
                                                                    .route,
                                                                arguments: model
                                                                            .filesPerCounter[
                                                                        index][
                                                                    fileIndex]);
                                                          },
                                                          child: Container(
                                                              width: 75,
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 5),
                                                              child: model.filesPerCounter[
                                                                              index]
                                                                          [
                                                                          fileIndex]
                                                                      is File
                                                                  ? Image.file(
                                                                      model.filesPerCounter[
                                                                              index]
                                                                          [
                                                                          fileIndex],
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    )
                                                                  : Image
                                                                      .network(
                                                                      model
                                                                          .filesPerCounter[
                                                                              index]
                                                                              [
                                                                              fileIndex]
                                                                          .downloadUrl,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    )),
                                                        ),
                                                        Positioned(
                                                          top: 0,
                                                          right: 0,
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              model.removeAt(
                                                                  index,
                                                                  fileIndex);
                                                            },
                                                            child: Container(
                                                              height: 25,
                                                              width: 25,
                                                              color: colors
                                                                  .mediumBlack,
                                                              child: Center(
                                                                child: Icon(
                                                                  Icons.close,
                                                                  color: colors
                                                                      .backgroundColor
                                                                      .withOpacity(
                                                                          0.8),
                                                                  size: 15,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          else
                                            GestureDetector(
                                              onTap: () =>
                                                  model.popSourceOfFileDialog(
                                                      index, context),
                                              child: Container(
                                                height: 100,
                                                width: 75,
                                                color: Colors.grey.shade300,
                                                child: Center(
                                                  child: Icon(
                                                    Icons.add,
                                                    size: 30,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          SizedBox(height: 15),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // if (ModalRoute.of(context).settings.arguments
                                  //         is Machine &&
                                  //     (model.userProvider.user.role ==
                                  //             Role.OWNER ||
                                  //         (model.userProvider.user.permissions
                                  //             .fixMachineStock)))
                                  //   Column(
                                  //     crossAxisAlignment:
                                  //         CrossAxisAlignment.start,
                                  //     children: [
                                  //       Divider(),
                                  //       SizedBox(height: 10),
                                  //       Text(
                                  //         'Correção de estoque (opcional)',
                                  //         style: styles.medium(fontSize: 20),
                                  //       ),
                                  //       SizedBox(height: 15),
                                  //       Column(
                                  //         children: List.generate(
                                  //             model.collection.boxCollections
                                  //                 .length,
                                  //             (index) => Column(
                                  //                   crossAxisAlignment:
                                  //                       CrossAxisAlignment
                                  //                           .start,
                                  //                   children: [
                                  //                     Text(
                                  //                       model.machine
                                  //                               .categoryLabel
                                  //                               .toLowerCase()
                                  //                               .contains(
                                  //                                   'roleta')
                                  //                           ? 'Haste ${index + 1}'
                                  //                           : 'Cabine ${index + 1}',
                                  //                       style: styles.regular(),
                                  //                     ),
                                  //                     SizedBox(height: 3),
                                  //                     CustomTextField(
                                  //                       onChanged: (v) {
                                  //                         if (v == '') {
                                  //                           model
                                  //                               .collection
                                  //                               .boxCollections[
                                  //                                   index]
                                  //                               .prizeCount = null;
                                  //                         } else {
                                  //                           model
                                  //                                   .collection
                                  //                                   .boxCollections[
                                  //                                       index]
                                  //                                   .prizeCount =
                                  //                               int.parse(v);
                                  //                         }
                                  //                       },
                                  //                       keyboardType:
                                  //                           TextInputType
                                  //                               .number,
                                  //                       inputFormatters: [
                                  //                         FilteringTextInputFormatter
                                  //                             .digitsOnly,
                                  //                       ],
                                  //                     ),
                                  //                     SizedBox(height: 10),
                                  //                   ],
                                  //                 )),
                                  //       ),
                                  //     ],
                                  //   ),
                                  Divider(),
                                  SizedBox(height: 10),
                                  Text(
                                    'Observações gerais',
                                    style: styles.medium(fontSize: 20),
                                  ),
                                  SizedBox(height: 15),
                                  GeneralObservations(
                                    onChanged: model.fillObservations,
                                    initialValue: ModalRoute.of(context)
                                            .settings
                                            .arguments is Machine
                                        ? ''
                                        : model.collection.observations,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Buttons(
                            onSubmit: () {
                              if (model.creatingCollection) {
                                model.createCollection();
                              } else {
                                model.editCollection();
                              }
                            },
                            submitText: 'Salvar',
                          ),
                        ],
                      ),
                    )
                  ],
                )
              : Container()),
    );
  }
}
