import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';
import '../../widgets/boxes.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';
import '../../widgets/current_path.dart';
import '../../widgets/custom_text_field.dart';

import '../../../locator.dart';
import 'edit_category_page_model.dart';

class EditCategoryPage extends StatelessWidget {
  static const route = '/editcategory';
  final styles = locator<TextStyles>();
  final colors = locator<AppColors>();
  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EditCategoryPageModel>.reactive(
      viewModelBuilder: () => EditCategoryPageModel(),
      onModelReady: (model) {
        model.loadData();
        if (ModalRoute.of(context).settings.arguments != null) {
          model.category = ModalRoute.of(context).settings.arguments;
          model.boxes = model.category.boxes;
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
                          topText:
                              ModalRoute.of(context).settings.arguments != null
                                  ? model.category.label
                                  : 'Criar Categoria',
                          bottomMiddleTexts: [' / Categorias'],
                          bottomFinalText:
                              ModalRoute.of(context).settings.arguments != null
                                  ? ' / Editar categoria'
                                  : ' / Criar categoria',
                        ),
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Text(
                                'Nome',
                                style: styles.light(fontSize: 16),
                              ),
                              SizedBox(height: 10),
                              CustomTextField(
                                initialValue:
                                    ModalRoute.of(context).settings.arguments !=
                                            null
                                        ? model.category.label
                                        : '',
                                enabled:
                                    ModalRoute.of(context).settings.arguments !=
                                            null
                                        ? false
                                        : true,
                                onChanged: (value) {
                                  if (value != '') {
                                    model.category.label = value;
                                  } else {
                                    model.category.label = null;
                                  }
                                  model.notifyListeners();
                                },
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                        Boxes(
                          isCreatingCategory:
                              ModalRoute.of(context).settings.arguments == null,
                          boxes: model.boxes,
                          addBox: model.addBox,
                          categoryLabel: model.category.label ?? '',
                          removeBox: model.removeBox,
                          removeCounter: model.removeCounter,
                          addCounter: model.addCounter,
                          scrollController: _scrollController,
                          counterTypes: model.counterTypesProvider.counterTypes,
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
                                  if (ModalRoute.of(context)
                                          .settings
                                          .arguments ==
                                      null) {
                                    model.createCategory();
                                  } else {
                                    model.editCategory();
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
