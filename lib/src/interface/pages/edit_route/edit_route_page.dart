import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';
import '../../widgets/current_path.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_text_field.dart';

import '../../../locator.dart';
import 'edit_route_page_model.dart';

class EditRoutePage extends StatelessWidget {
  static const route = '/editroute';

  final colors = locator<AppColors>();
  final styles = locator<TextStyles>();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EditRoutePageModel>.reactive(
      viewModelBuilder: () => EditRoutePageModel(),
      disposeViewModel: true,
      onModelReady: (model) {
        model.loadData();
        if (ModalRoute.of(context).settings.arguments != null) {
          model.operatorRoute = ModalRoute.of(context).settings.arguments;
          model.selectedPointsOfSaleIds =
              List<String>.from(model.operatorRoute.pointsOfSaleIds);
          model.selectedOperatorId = model.operatorRoute.operatorId;
          model.label = model.operatorRoute.label;
          model.getAvailableOperators();
          model.fillPreviousPointsOfSale();
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
                          topText: model.operatorRoute != null
                              ? 'Editar Rota'
                              : 'Nova Rota',
                          bottomFinalText: model.operatorRoute != null
                              ? '/ Rotas / Editar Rota'
                              : ' / Rotas / Nova Rota',
                        ),
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nome',
                                style: styles.light(fontSize: 16),
                              ),
                              SizedBox(height: 10),
                              CustomTextField(
                                initialValue: model.label ?? '',
                                onChanged: (value) {
                                  if (value != '') {
                                    model.label = value;
                                  } else {
                                    model.label = null;
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
                                'Selecione abaixo os pontos de venda que farão parte desta rota',
                                style: styles.light(fontSize: 16),
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding: EdgeInsets.only(bottom: 5),
                                child: Text(
                                  'Pontos de venda selecionados: ${model.selectedPointsOfSaleIds.length}',
                                  style: styles.regular(
                                      color:
                                          model.selectedPointsOfSaleIds.isEmpty
                                              ? colors.red
                                              : colors.lightGreen),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                // ignore: deprecated_member_use
                                child: RaisedButton(
                                  color: colors.primaryColor,
                                  onPressed: () =>
                                      model.popSelectPointsOfSaleDialog(),
                                  child: Text(
                                    'Selecionar pontos de venda',
                                    style: styles.regular(
                                        color: colors.backgroundColor),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                        if (model.selectedPointsOfSaleIds.isNotEmpty ||
                            model.selectedOperatorId != null)
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Operador responsável',
                                  style: styles.light(fontSize: 16),
                                ),
                                SizedBox(height: 10),
                                if (model.availableOperators.isNotEmpty ||
                                    model.selectedOperatorId != null)
                                  CustomKrowchDropdownButton(
                                    currentValue: DropdownInputOption(
                                        title: model.selectedOperatorId == null
                                            ? ''
                                            : model.userProvider.operators
                                                .firstWhere((element) =>
                                                    element.id ==
                                                    model.selectedOperatorId)
                                                .name),
                                    onSelect: (value) {
                                      model.selectedOperatorId = model
                                          .userProvider.operators
                                          .firstWhere((element) =>
                                              element.name == value.title)
                                          .id;
                                      model.notifyListeners();
                                    },
                                    values: List.generate(
                                      model.availableOperators.length,
                                      (index) => DropdownInputOption(
                                          title: model
                                              .availableOperators[index].name),
                                    ),
                                  ),
                                if (model.availableOperators.isEmpty &&
                                    model.selectedOperatorId == null)
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 15),
                                    child: Text(
                                      'No momento, nenhum operador tem acesso à todos os pontos de venda selecionados.\nVocê poderá definir o operador responsável posteriormente.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        if (model.selectedPointsOfSaleIds.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Container(
                              alignment: Alignment.centerRight,
                              // ignore: deprecated_member_use
                              child: RaisedButton(
                                color: colors.primaryColor,
                                onPressed: () => {
                                  if (model.operatorRoute != null)
                                    model.editRoute()
                                  else
                                    model.createRoute()
                                },
                                child: Text(
                                  model.operatorRoute != null
                                      ? 'Editar Rota'
                                      : 'Criar rota',
                                  style: styles.regular(
                                      color: colors.backgroundColor),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
