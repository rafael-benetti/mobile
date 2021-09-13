import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/interface_service.dart';
import '../edit_manager/edit_manager_page.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';
import '../../widgets/current_path.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/user_card.dart';

import '../../../locator.dart';
import 'managers_page_model.dart';

class ManagersPage extends StatelessWidget {
  static const route = '/managers';

  final styles = locator<TextStyles>();
  final colors = locator<AppColors>();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ManagersPageModel>.reactive(
      viewModelBuilder: () => ManagersPageModel(),
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
                            topText: 'Colaboradores',
                            bottomFinalText: ' / Colaboradores',
                            buttonText: 'Novo Colaborador',
                            onPressed:
                                _userProvider.user.permissions.createManagers
                                    ? () {
                                        locator<InterfaceService>()
                                            .navigateTo(EditManagerPage.route);
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
                                        _userProvider.filterManagers(
                                            keywords: value);
                                      } else {
                                        _userProvider.filterManagers();
                                      }
                                    }),
                                SizedBox(height: 15),
                              ],
                            ),
                          ),
                          if (_userProvider.filteredManagers.isNotEmpty)
                            SliverList(
                              delegate: SliverChildListDelegate(
                                [
                                      Text(
                                        'Colaboradores (${_userProvider.filteredManagers.length})',
                                        style: styles.light(fontSize: 16),
                                      ),
                                      SizedBox(height: 10),
                                    ] +
                                    List.generate(
                                      _userProvider.filteredManagers.length,
                                      (index) => Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              if (locator<UserProvider>()
                                                  .user
                                                  .permissions
                                                  .createManagers) {
                                                locator<InterfaceService>()
                                                    .navigateTo(
                                                        EditManagerPage.route,
                                                        arguments: _userProvider
                                                                .filteredManagers[
                                                            index]);
                                              }
                                            },
                                            child: UserCard(
                                              user: _userProvider
                                                  .filteredManagers[index],
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
                                    'Nenhum colaborador encontrado.',
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
