import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';
import '../../../core/models/counter_type.dart';
import '../../shared/colors.dart';
import '../../shared/enums.dart';
import '../../shared/text_styles.dart';
import '../../widgets/current_path.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/titled_text_field.dart';

import '../../../locator.dart';
import 'edit_counter_type_page_model.dart';

class EditCounterTypePage extends StatelessWidget {
  static const route = '/editCounterTypes';

  final styles = locator<TextStyles>();
  final colors = locator<AppColors>();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EditCounterTypePageModel>.reactive(
      viewModelBuilder: () => EditCounterTypePageModel(),
      onModelReady: (model) {
        if (ModalRoute.of(context).settings.arguments != null) {
          model.label =
              (ModalRoute.of(context).settings.arguments as CounterType).label;
          model.id =
              (ModalRoute.of(context).settings.arguments as CounterType).id;
          if ((ModalRoute.of(context).settings.arguments as CounterType).type ==
              CType.IN) {
            model.type = 'IN';
          } else if ((ModalRoute.of(context).settings.arguments as CounterType)
                  .type ==
              CType.OUT) {
            model.type = 'OUT';
          }
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
                    elevation: 0,
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                    sliver: MultiSliver(
                      children: [
                        CurrentPath(
                          topText:
                              ModalRoute.of(context).settings.arguments != null
                                  ? model.label
                                  : 'Tipos de Contador',
                          bottomFinalText:
                              ModalRoute.of(context).settings.arguments != null
                                  ? ' / Editar'
                                  : ' / Criar',
                        ),
                        TitledTextField(
                          title: 'Nome',
                          initialValue: model.label ?? '',
                          onChanged: (value) {
                            if (value == '') {
                              model.label = null;
                            } else {
                              model.label = value;
                            }
                          },
                        ),
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tipo',
                                style: styles.light(fontSize: 16),
                              ),
                              SizedBox(height: 10),
                              if (ModalRoute.of(context).settings.arguments ==
                                  null)
                                CustomDropdownButton(
                                  initialValue: DropdownInputOption(
                                    title: '',
                                  ),
                                  onSelect: (value) {
                                    if (value.title == 'Entrada') {
                                      model.type = 'IN';
                                    } else {
                                      model.type = 'OUT';
                                    }
                                  },
                                  values: [
                                    DropdownInputOption(title: 'Entrada'),
                                    DropdownInputOption(title: 'Saída'),
                                  ],
                                )
                              else
                                CustomTextField(
                                  initialValue:
                                      model.type == 'IN' ? 'Entrada' : 'Saída',
                                  enabled: false,
                                ),
                              SizedBox(height: 10),
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
                              onPressed: () => {
                                if (ModalRoute.of(context).settings.arguments ==
                                    null)
                                  model.createCounterType()
                                else
                                  model.editCounterType()
                              },
                              child: Text(
                                ModalRoute.of(context).settings.arguments !=
                                        null
                                    ? 'Editar'
                                    : 'Criar',
                                style: styles.regular(
                                    color: colors.backgroundColor),
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
