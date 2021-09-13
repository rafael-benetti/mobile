import 'package:flutter/material.dart';
import '../../core/models/box.dart';
import '../../core/models/counter_type.dart';
import '../../core/services/interface_service.dart';
import '../shared/colors.dart';
import '../shared/text_styles.dart';
import '../shared/validators.dart';
import 'custom_dropdown.dart';
import 'custom_text_field.dart';
import 'dialog_action.dart';
import '../../locator.dart';

final styles = locator<TextStyles>();
final colors = locator<AppColors>();

class Boxes extends StatelessWidget {
  final bool isCreatingCategory;
  final Function addBox;
  final Function addCounter;
  final Function removeBox;
  final Function removeCounter;
  final Function updatePinList;
  final List<String> pinList;
  final String categoryLabel;
  final List<CounterType> counterTypes;

  final List<Box> boxes;
  final ScrollController scrollController;

  const Boxes({
    Key key,
    @required this.isCreatingCategory,
    @required this.addBox,
    @required this.removeBox,
    @required this.categoryLabel,
    @required this.updatePinList,
    @required this.pinList,
    @required this.removeCounter,
    @required this.boxes,
    @required this.addCounter,
    @required this.counterTypes,
    @required this.scrollController,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoryLabel.toLowerCase().contains('roleta')
                    ? 'Hastes'
                    : 'Cabines',
                style: styles.light(fontSize: 16),
              ),
              if (isCreatingCategory)
                TextButton(
                  onPressed: () => addBox(scrollController),
                  child: Text(
                    categoryLabel.toLowerCase().contains('roleta')
                        ? 'Adicionar haste'
                        : 'Adicionar cabine',
                    style: styles.regular(color: colors.primaryColor),
                  ),
                )
              else
                SizedBox(height: 35)
            ],
          ),
          Column(
            children: List.generate(
              boxes.length,
              (boxIndex) => Container(
                margin: EdgeInsets.fromLTRB(2, 10, 2, 10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 5,
                      offset: Offset(0, 0),
                      color: colors.lightBlack,
                    )
                  ],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (isCreatingCategory)
                              Container(
                                width: 45,
                                child: Center(
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.highlight_remove_outlined,
                                      color: colors.red,
                                    ),
                                    onPressed: () => removeBox(boxIndex),
                                  ),
                                ),
                              )
                            else
                              SizedBox(width: 5),
                            Container(
                              child: Text(
                                categoryLabel.toLowerCase().contains('roleta')
                                    ? 'Haste ${boxIndex + 1}'
                                    : 'Cabine ${boxIndex + 1}',
                                style: styles.medium(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        AddCounter(
                          addCounter: () => addCounter(boxIndex),
                          scrollController: scrollController,
                        )
                      ],
                    ),
                    Column(
                      children: List.generate(
                        boxes[boxIndex].counters.length,
                        (counterIndex) => SingleCounter(
                          pinList: pinList,
                          updatePinList: updatePinList,
                          removeCounter: removeCounter,
                          counterIndex: counterIndex,
                          boxIndex: boxIndex,
                          boxes: boxes,
                          counterTypes: counterTypes,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AddCounter extends StatelessWidget {
  final Function addCounter;
  final ScrollController scrollController;

  const AddCounter({Key key, this.addCounter, this.scrollController})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextButton(
        onPressed: addCounter,
        child: Text(
          'Adicionar contador',
          style: styles.regular(color: colors.primaryColor),
        ),
      ),
    );
  }
}

class SingleCounter extends StatelessWidget {
  final int counterIndex;
  final int boxIndex;
  final Function removeCounter;
  final List<CounterType> counterTypes;
  final List<String> pinList;
  final Function updatePinList;
  final List<Box> boxes;

  const SingleCounter({
    @required this.counterIndex,
    @required this.boxIndex,
    @required this.pinList,
    @required this.updatePinList,
    @required this.removeCounter,
    @required this.counterTypes,
    @required this.boxes,
  });

  CounterType getCounterType() {
    return counterTypes.firstWhere((element) =>
            element.id ==
            boxes[boxIndex].counters[counterIndex].counterTypeId) ??
        '';
  }

  String getInitialCounterTypeValue() {
    if (boxes[boxIndex].counters[counterIndex].counterTypeId != null) {
      if (counterTypes.firstWhere(
            (element) =>
                element.id ==
                boxes[boxIndex].counters[counterIndex].counterTypeId,
          ) !=
          null) {
        return '${counterTypes.firstWhere((element) => element.id == boxes[boxIndex].counters[counterIndex].counterTypeId).label} (${translateType(counterTypes.firstWhere((element) => element.id == boxes[boxIndex].counters[counterIndex].counterTypeId).type)})';
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.only(bottom: 15, top: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.lightBlack, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                child: IconButton(
                  icon: Icon(
                    Icons.highlight_off_outlined,
                    color: colors.red,
                  ),
                  onPressed: () {
                    if (!boxes[boxIndex].counters[counterIndex].isEmpty()) {
                      locator<InterfaceService>().showDialogMessage(
                        title: 'Atenção!',
                        message: 'Você realmenter deseja remover um contador?',
                        actions: [
                          DialogAction(
                            title: 'Cancelar',
                            onPressed: () =>
                                locator<InterfaceService>().goBack(),
                          ),
                          DialogAction(
                            title: 'Confirmar',
                            onPressed: () => {
                              removeCounter(boxIndex, counterIndex),
                              locator<InterfaceService>().goBack(),
                              locator<InterfaceService>().showSnackBar(
                                  message: 'Contador removido.',
                                  backgroundColor: colors.lightGreen)
                            },
                          )
                        ],
                      );
                    } else {
                      removeCounter(boxIndex, counterIndex);
                      locator<InterfaceService>().showSnackBar(
                          message: 'Contador removido.',
                          backgroundColor: colors.lightGreen);
                    }
                  },
                ),
              ),
              Text(
                'Contador ${counterIndex + 1}',
                style: styles.regular(fontSize: 16),
              ),
            ],
          ),
          Divider(),
          Row(
            children: [
              CounterDropDown(
                initialValue: getInitialCounterTypeValue(),
                maxHeight: 112.5,
                title: 'Tipo de contador',
                onSelect: (value) {
                  boxes[boxIndex].counters[counterIndex].counterTypeId =
                      counterTypes
                          .firstWhere((element) =>
                              element.label == value.title.split(' ')[0])
                          .id;
                },
                values: List.generate(
                  counterTypes.length,
                  (index) => DropdownInputOption(
                      title:
                          '${counterTypes[index].label} (${translateType(counterTypes[index].type)})'),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CounterDropDown(
                initialValue: boxes[boxIndex].counters[counterIndex].pin,
                maxHeight: 112.5,
                title: 'Pino da telemetria',
                onSelect: (value) {
                  boxes[boxIndex].counters[counterIndex].pin = value.title;
                  updatePinList();
                },
                values: List.generate(
                  pinList.length,
                  (index) => DropdownInputOption(title: pinList[index]),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DigitalCheckBox(
                initialValue: boxes[boxIndex].counters[counterIndex].hasDigital,
                onDigitalClick: (value) {
                  boxes[boxIndex].counters[counterIndex].hasDigital = value;
                },
              ),
              AnalogicCheckBox(
                initialValue:
                    boxes[boxIndex].counters[counterIndex].hasMechanical,
                onAnalogicClick: (value) {
                  boxes[boxIndex].counters[counterIndex].hasMechanical = value;
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}

class DigitalCheckBox extends StatefulWidget {
  final Function(bool) onDigitalClick;
  final bool initialValue;

  const DigitalCheckBox({
    Key key,
    this.onDigitalClick,
    this.initialValue,
  }) : super(key: key);

  @override
  _DigitalCheckBoxState createState() => _DigitalCheckBoxState();
}

class _DigitalCheckBoxState extends State<DigitalCheckBox> {
  bool digital = false;

  @override
  void initState() {
    if (widget.initialValue != null) {
      digital = widget.initialValue;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Relógios'),
          Row(
            children: [
              Checkbox(
                activeColor: colors.primaryColor,
                value: digital,
                onChanged: (value) {
                  setState(() {
                    digital = value;
                  });
                  widget.onDigitalClick(value);
                },
              ),
              Text('Digital'),
            ],
          )
        ],
      ),
    );
  }
}

class AnalogicCheckBox extends StatefulWidget {
  final Function(bool) onAnalogicClick;
  final bool initialValue;

  const AnalogicCheckBox({
    Key key,
    this.onAnalogicClick,
    this.initialValue,
  }) : super(key: key);

  @override
  _AnalogicCheckBoxState createState() => _AnalogicCheckBoxState();
}

class _AnalogicCheckBoxState extends State<AnalogicCheckBox> {
  bool analogic = false;

  @override
  void initState() {
    if (widget.initialValue != null) {
      analogic = widget.initialValue;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(''),
          Row(
            children: [
              Checkbox(
                activeColor: colors.primaryColor,
                value: analogic,
                onChanged: (value) {
                  setState(() {
                    analogic = value;
                  });
                  widget.onAnalogicClick(value);
                },
              ),
              Text('Mecânico'),
            ],
          )
        ],
      ),
    );
  }
}

class CounterTextField extends StatelessWidget {
  final String title;
  final String initialValue;
  final Function onChanged;
  final TextInputType keyboardType;

  const CounterTextField({
    Key key,
    @required this.title,
    this.initialValue,
    @required this.onChanged,
    this.keyboardType,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text(title),
          ),
          SizedBox(height: 10),
          CustomTextFieldWithController(
            keyboardType: keyboardType ?? TextInputType.text,
            onChanged: onChanged,
            initialValue: initialValue,
          ),
        ],
      ),
    );
  }
}

class CounterDropDown extends StatelessWidget {
  final String title;
  final String initialValue;
  final List<DropdownInputOption> values;
  final Function(DropdownInputOption) onSelect;
  final double maxHeight;

  const CounterDropDown({
    Key key,
    @required this.title,
    this.initialValue,
    @required this.values,
    @required this.onSelect,
    this.maxHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 5),
                child: Text(title),
              ),
            ],
          ),
          SizedBox(height: 10),
          CustomDropdownButton(
            maxHeight: maxHeight,
            initialValue: DropdownInputOption(
              title: initialValue ?? '',
            ),
            onSelect: onSelect,
            onExpand: (expanded) {},
            values: values,
          ),
        ],
      ),
    );
  }
}
