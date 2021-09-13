import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kow_form/kow_form.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';
import 'widgets.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';
import '../../widgets/current_path.dart';
import '../../../locator.dart';
import 'edit_point_of_sale_page_model.dart';

class EditPointOfSalePage extends StatelessWidget {
  static const route = '/editPointOfSale';
  final styles = locator<TextStyles>();
  final colors = locator<AppColors>();
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EditPointOfSalePageModel>.reactive(
        viewModelBuilder: () => EditPointOfSalePageModel(),
        onModelReady: (model) {
          if (ModalRoute.of(context).settings.arguments != null) {
            model.pointOfSale = ModalRoute.of(context).settings.arguments;
            model.state = model.pointOfSale.state;
            model.city = model.pointOfSale.city;
            model.neighborhood = model.pointOfSale.neighborhood;
            model.street = model.pointOfSale.street;
            model.isPercentage = model.pointOfSale.isPercentage ?? false;
            model.chosenGroup = model.groups
                .firstWhere(
                    (element) => element.id == model.pointOfSale.groupId)
                .label;
          }
        },
        builder: (context, model, child) {
          return Scaffold(
            body: KowForm(
              initialData: model.initialData(),
              onSubmit: (data) {
                data['address']['zipCode'] = data['address']['zipCode']
                    .replaceAll('.', '')
                    .replaceAll('-', '');
                model.pointOfSaleData = data;
              },
              child: CustomScrollView(
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
                          topText: model.pointOfSale != null
                              ? 'Editar Ponto de Venda'
                              : 'Novo Ponto de Venda',
                          bottomFinalText: model.pointOfSale != null
                              ? ' / Pontos de Venda / Editar Ponto de Venda'
                              : ' / Pontos de Venda / Novo Ponto de Venda',
                        ),
                        KowRentField(
                          title: 'Aluguel',
                          path: 'rent',
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          isPercentage: model.isPercentage,
                          getRentType: model.getRentType,
                        ),
                        if (model.groups.length > 1)
                          if (model.pointOfSale == null)
                            GroupDropdown(groups: model.groups)
                          else
                            KowTextField(
                              path: 'groupId',
                              title: 'Parceria',
                              enabled: false,
                              initialValue: model.chosenGroup,
                            ),
                        KowTextField(
                          path: 'label',
                          title: 'Nome',
                          extraFunction: (value) => model.name = value,
                        ),
                        KowTextField(
                          path: 'contactName',
                          title: 'Contato',
                          extraFunction: (value) => model.contactName = value,
                        ),
                        KowTextField(
                          path: 'primaryPhoneNumber',
                          title: 'Telefone 1',
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            TelefoneInputFormatter(),
                          ],
                          extraFunction: (value) =>
                              model.primaryPhoneNumber = value,
                        ),
                        KowTextField(
                          path: 'secondaryPhoneNumber',
                          title: 'Telefone 2',
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            TelefoneInputFormatter(),
                          ],
                          extraFunction: (value) =>
                              model.secondaryPhoneNumber = value,
                        ),
                        KowTextField(
                          path: 'address.zipCode',
                          keyboardType: TextInputType.number,
                          title: 'CEP',
                          enabled: model.pointOfSale != null ? false : true,
                          extraFunction: model.findCEP,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            CepInputFormatter()
                          ],
                        ),
                        KowTextField(
                          path: 'address.state',
                          title: 'Estado',
                          extraFunction: (value) {
                            model.state = value;
                          },
                          enabled: true,
                          initialValue: model.state,
                        ),
                        KowTextField(
                          path: 'address.city',
                          title: 'Cidade',
                          extraFunction: (value) {
                            model.city = value;
                          },
                          enabled: true,
                          initialValue: model.city,
                        ),
                        KowTextField(
                          path: 'address.neighborhood',
                          title: 'Bairro',
                          extraFunction: (value) {
                            model.neighborhood = value;
                          },
                          enabled: true,
                          initialValue: model.neighborhood,
                        ),
                        KowTextField(
                          path: 'address.street',
                          title: 'Logradouro',
                          extraFunction: (value) {
                            model.street = value;
                          },
                          enabled: true,
                          initialValue: model.street,
                        ),
                        KowTextField(
                          path: 'address.number',
                          enabled: model.pointOfSale != null ? false : true,
                          title: 'Número',
                        ),
                        KowTextField(
                            path: 'address.extraInfo', title: 'Complemento'),
                        SliverToBoxAdapter(
                          child: KowSubmitButton(
                            builder: (context, onSubmit) => SubmitButtons(
                              submitText: model.pointOfSale != null
                                  ? 'Salvar'
                                  : 'Cadastrar',
                              onSubmit: () {
                                onSubmit();
                                model.pointOfSale == null
                                    ? model.createPointOfSale()
                                    : model.updatePointOfSale();
                              },
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
        });
  }
}
