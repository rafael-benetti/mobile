import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';
import '../../../core/providers/counter_types_provider.dart';
import '../../../core/services/interface_service.dart';
import 'widgets.dart';
import '../edit_counter_type/edit_counter_type_page.dart';
import '../../shared/colors.dart';
import '../../shared/validators.dart';
import '../../widgets/current_path.dart';
import '../../widgets/titled_text_field.dart';

import '../../../locator.dart';
import 'counter_types_page_model.dart';

class CounterTypesPage extends StatelessWidget {
  static const route = '/counterTypes';

  final colors = locator<AppColors>();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CounterTypesPageModel>.reactive(
      viewModelBuilder: () => CounterTypesPageModel(),
      onModelReady: (model) => model.loadData(),
      builder: (context, model, child) => Scaffold(
        body: Consumer<CounterTypesProvider>(
          builder: (context, _counterTypesProvider, _) => model.isBusy
              ? Center()
              : CustomScrollView(
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
                            bottomFinalText: ' / Tipos de contadores',
                            buttonText: 'Novo Tipo',
                            topText: 'Tipos de contadores',
                            onPressed: model.user.permissions.createCategories
                                ? () {
                                    locator<InterfaceService>()
                                        .navigateTo(EditCounterTypePage.route);
                                  }
                                : null,
                          ),
                          TitledTextField(
                            title: 'Pesquisar',
                            onChanged: (value) {},
                          ),
                          if (_counterTypesProvider.counterTypes.isNotEmpty)
                            SliverList(
                              delegate: SliverChildListDelegate(
                                [
                                  TableName(),
                                  Column(
                                    children: List.generate(
                                      _counterTypesProvider.counterTypes.length,
                                      (index) => GestureDetector(
                                        onTap: () {
                                          if (model.user.permissions
                                              .editCategories) {
                                            locator<InterfaceService>()
                                                .navigateTo(
                                              EditCounterTypePage.route,
                                              arguments: _counterTypesProvider
                                                  .counterTypes[index],
                                            );
                                          }
                                        },
                                        child: SingleCounterType(
                                          index: index,
                                          title:
                                              '${_counterTypesProvider.counterTypes[index].label} (${translateType(_counterTypesProvider.counterTypes[index].type)})',
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          else
                            SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  SizedBox(height: 25),
                                  Text(
                                    'Você não possui nenhum tipo de contador cadastrado.',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
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
