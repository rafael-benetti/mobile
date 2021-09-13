import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';
import '../../widgets/current_path.dart';
import '../../widgets/custom_text_field.dart';

import '../../../locator.dart';
import 'edit_group_page_model.dart';

class EditGroupPage extends StatelessWidget {
  static const route = '/editpartnership';

  final styles = locator<TextStyles>();
  final colors = locator<AppColors>();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EditGroupPageModel>.nonReactive(
      viewModelBuilder: () => EditGroupPageModel(),
      onModelReady: (model) {
        if (ModalRoute.of(context).settings.arguments != null) {
          model.group = ModalRoute.of(context).settings.arguments;
          model.label = model.group.label;
        }
      },
      builder: (context, model, child) => Scaffold(
        body: CustomScrollView(
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
                    topText: model.group != null
                        ? 'Editar Parceria'
                        : 'Criar Parceria',
                    bottomMiddleTexts: [' / Parceria'],
                    bottomFinalText:
                        model.group != null ? ' / Editar' : ' / Criar',
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
                          onChanged: (value) => model.label = value,
                          initialValue:
                              model.group != null ? model.group.label : null,
                        ),
                        SizedBox(height: 25),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Align(
                      alignment: Alignment.centerRight,
                      // ignore: deprecated_member_use
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        color: colors.primaryColor,
                        onPressed: model.group == null
                            ? model.createGroup
                            : model.editGroup,
                        child: Text(
                          model.group != null ? 'Salvar' : 'Cadastrar',
                          style: styles.regular(color: colors.backgroundColor),
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
