import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/interface/pages/detailed_group/detailed_group_page.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/groups_provider.dart';
import '../../../core/services/interface_service.dart';
import '../edit_group/edit_group_page.dart';
import 'widgets.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';
import '../../widgets/current_path.dart';
import '../../widgets/titled_text_field.dart';

import '../../../locator.dart';
import 'groups_page_model.dart';

class GroupsPage extends StatelessWidget {
  static const route = '/partnership';
  final styles = locator<TextStyles>();
  final colors = locator<AppColors>();
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<GroupsPageModel>.reactive(
      viewModelBuilder: () => GroupsPageModel(),
      onModelReady: (model) {
        model.loadData();
      },
      builder: (context, model, child) => Scaffold(
        body: Consumer<GroupsProvider>(builder: (context, groupsProvider, _) {
          return model.isBusy
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
                            bottomFinalText: ' / Parcerias',
                            buttonText: 'Nova Parceria',
                            topText: 'Parcerias',
                            onPressed: model.user.permissions.createGroups
                                ? () {
                                    locator<InterfaceService>()
                                        .navigateTo(EditGroupPage.route);
                                  }
                                : null,
                          ),
                          if (groupsProvider.groups.length > 1)
                            TitledTextField(
                              title: 'Pesquisar',
                              onChanged: (value) {
                                groupsProvider.filterGroups(value: value);
                              },
                            ),
                          if (!(groupsProvider.filteredGroups.length == 1 &&
                              groupsProvider.filteredGroups[0].isPersonal))
                            SliverList(
                              delegate: SliverChildListDelegate([
                                TableName(),
                                Column(
                                  children: List.generate(
                                    groupsProvider.filteredGroups.length,
                                    (index) => GestureDetector(
                                      onTap: () {
                                        locator<InterfaceService>().navigateTo(
                                          DetailedGroupPage.route,
                                          arguments: groupsProvider
                                              .filteredGroups[index].id,
                                        );
                                      },
                                      child: SingleGroup(
                                        index: index,
                                        title: groupsProvider
                                            .filteredGroups[index].label,
                                        numberOfMachines: groupsProvider
                                                .filteredGroups[index]
                                                .numberOfMachines ??
                                            0,
                                      ),
                                    ),
                                  ),
                                )
                              ]),
                            ),
                          if (groupsProvider.filteredGroups.length == 1 &&
                              groupsProvider.filteredGroups[0].isPersonal)
                            SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  SizedBox(height: 25),
                                  Text(
                                    model.user.role == Role.OWNER
                                        ? 'Você não possui nenhuma parceria além da parceria pessoal.'
                                        : 'Você não faz parte de nenhuma parceria além da parceria pessoal.',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                        ],
                      ),
                    )
                  ],
                );
        }),
      ),
    );
  }
}
