import 'package:flutter/material.dart';
import '../../../../src/core/models/point_of_sale.dart';
import '../../../../src/interface/shared/colors.dart';
import '../../../../src/interface/shared/text_styles.dart';
import '../../../../src/interface/widgets/custom_dropdown.dart';

import '../../../locator.dart';

final colors = locator<AppColors>();
final styles = locator<TextStyles>();

class ReportTypeSelector extends StatelessWidget {
  final Function onSelect;

  const ReportTypeSelector({Key key, this.onSelect}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecione o tipo de relatório',
            style: styles.light(fontSize: 16),
          ),
          SizedBox(height: 7.5),
          CustomDropdownButton(
            onSelect: (v) => onSelect(v.option),
            initialValue: DropdownInputOption(title: ''),
            values: [
              DropdownInputOption(
                  title: 'Relatório de parcerias', option: 'groups'),
              DropdownInputOption(
                  title: 'Relatório de máquinas', option: 'machines'),
              // DropdownInputOption(
              //     title: 'Relatório de estoques de usuários', option: 'stocks'),
              DropdownInputOption(
                  title: 'Relatório de pontos de venda',
                  option: 'pointsOfSale'),
              DropdownInputOption(
                  title: 'Relatório de coletas (por PdV)',
                  option: 'collections'),
            ],
          ),
        ],
      ),
    );
  }
}

class PointOfSaleSelector extends StatelessWidget {
  final List<PointOfSale> pointsOfSale;
  final Function onSelect;

  const PointOfSaleSelector({Key key, this.pointsOfSale, this.onSelect})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text(
            'Selecione o ponto de venda',
            style: styles.light(fontSize: 16),
          ),
          SizedBox(height: 7.5),
          CustomDropdownButton(
            onSelect: onSelect,
            initialValue: DropdownInputOption(title: ''),
            values: List.generate(
              pointsOfSale.length,
              (index) => DropdownInputOption(
                title: pointsOfSale[index].label,
                option: pointsOfSale[index].id,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
