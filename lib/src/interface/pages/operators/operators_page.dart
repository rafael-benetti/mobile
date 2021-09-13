import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';

import '../../../core/providers/user_provider.dart';
import '../../../core/services/interface_service.dart';
import '../../../locator.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';
import '../../widgets/current_path.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/user_card.dart';
import '../edit_operator/edit_operator_page.dart';
import 'operators_page_model.dart';

class OperatorsPage extends StatelessWidget {
  static const route = '/operators';

  final styles = locator<TextStyles>();
  final colors = locator<AppColors>();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<OperatorsPageModel>.reactive(
      viewModelBuilder: () => OperatorsPageModel(),
      onModelReady: (model) => model.loadData(),
      builder: (context, model, child) => Consumer<UserProvider>(
        builder: (context, _userProvider, _) => Scaffold(
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
                      padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                      sliver: MultiSliver(
                        children: [
                          CurrentPath(
                            topText: 'Operadores',
                            bottomFinalText: ' / Operadores',
                            buttonText: 'Novo Operador',
                            onPressed:
                                _userProvider.user.permissions.createOperators
                                    ? () {
                                        locator<InterfaceService>()
                                            .navigateTo(EditOperatorPage.route);
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
                                SizedBox(height: 10),
                                CustomTextField(
                                  initialValue: '',
                                  onChanged: (value) {
                                    if (value != '') {
                                      _userProvider.filterOperators(
                                          keywords: value);
                                    } else {
                                      _userProvider.filterOperators();
                                    }
                                  },
                                ),
                                SizedBox(height: 15),
                              ],
                            ),
                          ),
                          if (_userProvider.filteredOperators.isNotEmpty)
                            SliverList(
                              delegate: SliverChildListDelegate(
                                [
                                      Text(
                                        'Operadores (${_userProvider.filteredOperators.length})',
                                        style: styles.light(fontSize: 16),
                                      ),
                                      SizedBox(height: 10),
                                    ] +
                                    List.generate(
                                      _userProvider.filteredOperators.length,
                                      (index) => Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              if (locator<UserProvider>()
                                                  .user
                                                  .permissions
                                                  .createOperators) {
                                                locator<InterfaceService>()
                                                    .navigateTo(
                                                  EditOperatorPage.route,
                                                  arguments: _userProvider
                                                      .filteredOperators[index],
                                                );
                                              }
                                            },
                                            child: UserCard(
                                              user: _userProvider
                                                  .filteredOperators[index],
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 15),
                                  Text(
                                    'Nenhum operador encontrado.',
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
