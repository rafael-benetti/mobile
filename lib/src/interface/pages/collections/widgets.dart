import 'package:flutter/material.dart';

import '../../../core/models/collection.dart';
import '../../../core/models/machine.dart';
import '../../../locator.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';
import '../../shared/validators.dart';
import '../../widgets/custom_text_field.dart';

final styles = locator<TextStyles>();
final colors = locator<AppColors>();

class MachinesList extends StatefulWidget {
  final List<LeanMachine> searchedMachines;
  final Function setSelectedMachine;

  const MachinesList({Key key, this.searchedMachines, this.setSelectedMachine})
      : super(key: key);
  @override
  _MachinesListState createState() => _MachinesListState();
}

class _MachinesListState extends State<MachinesList> {
  List<LeanMachine> machinesToDisplay;
  @override
  void initState() {
    machinesToDisplay = widget.searchedMachines;
    super.initState();
  }

  int selectedIndex = -1;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pesquisar por número de série'),
        SizedBox(height: 5),
        CustomTextField(
          onChanged: (v) {
            setState(() {
              selectedIndex = -1;
              widget.setSelectedMachine(null);
              if (v == '') {
                machinesToDisplay = widget.searchedMachines;
              } else {
                machinesToDisplay = widget.searchedMachines
                    .where((element) => element.serialNumber
                        .toLowerCase()
                        .contains(v.toLowerCase()))
                    .toList();
              }
            });
          },
        ),
        SizedBox(height: 10),
        Text('Máquinas em pontos de venda'),
        SizedBox(height: 5),
        Container(
          width: 500,
          height: 157.5,
          decoration: BoxDecoration(
              border: Border.all(color: colors.lightBlack, width: 1)),
          child: ListView.builder(
            itemCount: machinesToDisplay.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
                widget.setSelectedMachine(machinesToDisplay[index]);
              },
              child: Container(
                height: 45,
                padding: EdgeInsets.only(left: 10, bottom: 5, top: 5),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: index == selectedIndex
                      ? colors.primaryColor.withOpacity(0.8)
                      : colors.backgroundColor,
                  border: Border(
                    bottom: BorderSide(
                      color: selectedIndex == index
                          ? colors.backgroundColor
                          : colors.lightBlack,
                      width: 1,
                    ),
                  ),
                ),
                child: Text(
                  machinesToDisplay[index].serialNumber,
                  style: TextStyle(
                      color: selectedIndex == index
                          ? colors.backgroundColor
                          : Colors.black),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CollectionCard extends StatelessWidget {
  final Collection collection;

  const CollectionCard({Key key, this.collection}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(3),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: colors.backgroundColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            spreadRadius: 2,
            color: colors.lightBlack,
            offset: Offset(1, 1),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                child: Text(
                  'Realizada em:',
                  style: styles.medium(fontSize: 16),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Container(
                  child: Text(
                    getFormattedDate(collection.endTime),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 7.5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                child: Text(
                  'Num. Série:',
                  style: styles.medium(fontSize: 16),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Container(
                  child: Text(
                    collection.machine.serialNumber,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 7.5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                child: Text(
                  'Localização:',
                  style: styles.medium(fontSize: 16),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Container(
                  child: Text(
                    collection.pointOfSaleLabel ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 7.5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                child: Text(
                  'Usuário:',
                  style: styles.medium(fontSize: 16),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        collection.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Text('Detalhes',
                              style:
                                  styles.regular(color: colors.primaryColor)),
                          Icon(
                            Icons.arrow_forward_ios_outlined,
                            color: colors.primaryColor,
                            size: 15,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
