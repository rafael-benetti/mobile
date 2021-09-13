import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/models/group.dart';
import '../../core/models/user.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/interface_service.dart';
import '../shared/colors.dart';

import '../../locator.dart';

void riseItemModalBottomSheet(
    {dynamic item,
    BuildContext context,
    Function popAddToStockDialog,
    Function removeFromStockDialog,
    Function popSelectRecipientDialog,
    String type}) {
  if (Platform.isIOS) {
    showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
              cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  locator<InterfaceService>().goBack();
                },
                child: Text('Cancelar'),
              ),
              actions: [
                if (item.quantity > 0)
                  CupertinoActionSheetAction(
                    onPressed: () {
                      locator<InterfaceService>().goBack();
                      popSelectRecipientDialog(item, type);
                    },
                    child: Text('Transferir'),
                  ),
                if (popAddToStockDialog != null &&
                    locator<UserProvider>().user.permissions.createProducts)
                  CupertinoActionSheetAction(
                    onPressed: () {
                      locator<InterfaceService>().goBack();
                      popAddToStockDialog(item, type);
                    },
                    child: Text('Adicionar'),
                  ),
                if (removeFromStockDialog != null &&
                    locator<UserProvider>().user.permissions.createProducts &&
                    item.quantity > 0)
                  CupertinoActionSheetAction(
                    onPressed: () {
                      locator<InterfaceService>().goBack();
                      removeFromStockDialog(item, type);
                    },
                    child: Text('Remover'),
                  ),
              ],
            ));
  } else {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          margin: EdgeInsets.only(bottom: 10, left: 10),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              if (item.quantity > 0)
                ListTile(
                  leading: Icon(
                    Icons.swap_horiz_outlined,
                    color: locator<AppColors>().primaryColor,
                  ),
                  title: Text('Transferir'),
                  onTap: () {
                    locator<InterfaceService>().goBack();
                    popSelectRecipientDialog(item, type);
                  },
                ),
              if (popAddToStockDialog != null &&
                  locator<UserProvider>().user.permissions.createProducts)
                ListTile(
                  leading: Icon(
                    Icons.add,
                    color: locator<AppColors>().lightGreen,
                  ),
                  title: Text('Adicionar'),
                  onTap: () {
                    locator<InterfaceService>().goBack();
                    popAddToStockDialog(item, type);
                  },
                ),
              if (removeFromStockDialog != null &&
                  locator<UserProvider>().user.permissions.createProducts &&
                  item.quantity > 0)
                ListTile(
                  leading: Icon(
                    Icons.remove,
                    color: locator<AppColors>().red,
                  ),
                  title: Text('Remover'),
                  onTap: () {
                    locator<InterfaceService>().goBack();
                    removeFromStockDialog(item, type);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class RadioSelector extends StatefulWidget {
  final Function getSelectedOption;
  final List<Group> groups;
  final List<User> operators;
  final List<User> managers;
  final bool isFromGroupStock;

  const RadioSelector({
    Key key,
    this.getSelectedOption,
    this.groups,
    this.operators,
    this.managers,
    @required this.isFromGroupStock,
  }) : super(key: key);
  @override
  _RadioSelectorState createState() => _RadioSelectorState();
}

class _RadioSelectorState extends State<RadioSelector> {
  int groupValue = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.groups.length <= 1 &&
        widget.managers.isEmpty &&
        widget.operators.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma parceria, operador, colaborador ou máquina encontrada para transferir',
        ),
      );
    } else {
      return Container(
        width: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isFromGroupStock && widget.groups.length > 1)
              InkWell(
                onTap: () {
                  setState(() {
                    groupValue = 0;
                    widget.getSelectedOption(0);
                  });
                },
                child: Row(
                  children: [
                    Radio(
                      value: 0,
                      groupValue: groupValue,
                      onChanged: (value) {
                        setState(() {
                          groupValue = 0;
                          widget.getSelectedOption(0);
                        });
                      },
                    ),
                    Expanded(
                      child: Text('Estoque de outra parceria'),
                    ),
                  ],
                ),
              )
            else if (widget.groups.isNotEmpty)
              InkWell(
                onTap: () {
                  setState(() {
                    groupValue = 0;
                    widget.getSelectedOption(0);
                  });
                },
                child: Row(
                  children: [
                    Radio(
                      value: 0,
                      groupValue: groupValue,
                      onChanged: (value) {
                        setState(() {
                          groupValue = 0;
                          widget.getSelectedOption(0);
                        });
                      },
                    ),
                    Expanded(
                      child: Text('Estoque de parceria'),
                    ),
                  ],
                ),
              ),
            if (widget.managers.isNotEmpty)
              InkWell(
                onTap: () {
                  setState(() {
                    groupValue = 1;
                    widget.getSelectedOption(1);
                  });
                },
                child: Row(
                  children: [
                    Radio(
                      value: 1,
                      groupValue: groupValue,
                      onChanged: (value) {
                        setState(() {
                          groupValue = 1;
                          widget.getSelectedOption(1);
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        !widget.isFromGroupStock
                            ? 'Outro colaborador'
                            : 'Colaborador',
                      ),
                    ),
                  ],
                ),
              ),
            if (widget.operators.isNotEmpty &&
                locator<UserProvider>().user.role != Role.OPERATOR)
              InkWell(
                onTap: () {
                  setState(() {
                    groupValue = 2;
                    widget.getSelectedOption(2);
                  });
                },
                child: Row(
                  children: [
                    Radio(
                      value: 2,
                      groupValue: groupValue,
                      onChanged: (value) {
                        setState(() {
                          groupValue = 2;
                          widget.getSelectedOption(2);
                        });
                      },
                    ),
                    Expanded(
                      child: Text('Operador'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }
  }
}
