import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';
import '../../../core/providers/categories_provider.dart';
import '../../../core/services/interface_service.dart';
import 'widgets.dart';
import '../edit_category/edit_category_page.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';
import '../../widgets/current_path.dart';
import '../../widgets/custom_text_field.dart';

import '../../../locator.dart';
import 'categories_page_model.dart';

class CategoriesPage extends StatelessWidget {
  static const route = '/categories';
  final styles = locator<TextStyles>();
  final colors = locator<AppColors>();
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CategoriesPageModel>.reactive(
      viewModelBuilder: () => CategoriesPageModel(),
      onModelReady: (model) => model.loadData(),
      builder: (context, model, child) => Scaffold(
          body: Consumer<CategoriesProvider>(
        builder: (context, _categoriesProvider, _) => model.isBusy
            ? Center()
            : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    iconTheme: IconThemeData(color: colors.primaryColor),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                    sliver: MultiSliver(children: [
                      CurrentPath(
                        topText: 'Categorias',
                        bottomFinalText: ' / Categorias',
                        buttonText: 'Nova Categoria',
                        onPressed: model.user.permissions.createCategories
                            ? () {
                                locator<InterfaceService>()
                                    .navigateTo(EditCategoryPage.route);
                              }
                            : null,
                      ),
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            Text(
                              'Pesquisar',
                              style: styles.light(fontSize: 16),
                            ),
                            SizedBox(height: 10),
                            CustomTextField(
                              initialValue: '',
                              onChanged: (value) =>
                                  _categoriesProvider.filterCategories(value),
                            ),
                            SizedBox(height: 25),
                          ],
                        ),
                      ),
                      if (_categoriesProvider.filteredCategories.isNotEmpty)
                        SliverList(
                          delegate: SliverChildListDelegate([
                            TableName(),
                            Column(
                              children: List.generate(
                                _categoriesProvider.filteredCategories.length,
                                (index) => GestureDetector(
                                  onTap: () {
                                    if (model.user.permissions.editCategories) {
                                      locator<InterfaceService>().navigateTo(
                                          EditCategoryPage.route,
                                          arguments: _categoriesProvider
                                              .filteredCategories[index]);
                                    }
                                  },
                                  child: SingleCategory(
                                    index: index,
                                    category: _categoriesProvider
                                        .filteredCategories[index],
                                  ),
                                ),
                              ),
                            )
                          ]),
                        )
                      else
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 15),
                              Text('Nenhuma categoria cadastrada.')
                            ],
                          ),
                        )
                    ]),
                  )
                ],
              ),
      )),
    );
  }
}
