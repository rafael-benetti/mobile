import 'package:flutter/material.dart';
import '../shared/colors.dart';
import '../shared/enums.dart';
import '../shared/text_styles.dart';

import '../../locator.dart';

final styles = locator<TextStyles>();
final colors = locator<AppColors>();

class StockSwitcher extends StatefulWidget {
  final int numberOfMachines;
  final int numberOfPrizes;
  final int numberOfSupplies;
  final Function setCurrentlyShowing;
  final CurrentlyShowing currentlyShowing;

  const StockSwitcher({
    Key key,
    this.numberOfMachines,
    this.numberOfPrizes,
    this.numberOfSupplies,
    this.setCurrentlyShowing,
    this.currentlyShowing,
  }) : super(key: key);

  @override
  _StockSwitcherState createState() => _StockSwitcherState();
}

class _StockSwitcherState extends State<StockSwitcher> {
  int selected;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    selected = widget.currentlyShowing == CurrentlyShowing.PRIZES
        ? 0
        : widget.currentlyShowing == CurrentlyShowing.MACHINES
            ? 1
            : 2;
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.only(bottom: 15),
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            if (widget.numberOfPrizes > 0)
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selected = 0;
                    });
                    widget.setCurrentlyShowing(CurrentlyShowing.PRIZES);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: selected == 0 ? 2 : 1,
                          color: selected == 0
                              ? colors.primaryColor
                              : Colors.transparent,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Prêmios (${widget.numberOfPrizes})',
                        style: selected == 0
                            ? styles.medium(color: colors.primaryColor)
                            : styles.regular(color: Colors.black54),
                      ),
                    ),
                  ),
                ),
              ),
            if (widget.numberOfMachines > 0)
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selected = 1;
                    });
                    widget.setCurrentlyShowing(CurrentlyShowing.MACHINES);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: selected == 1 ? 2 : 1,
                          color: selected == 1
                              ? colors.primaryColor
                              : Colors.transparent,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Máquinas (${widget.numberOfMachines})',
                        style: selected == 1
                            ? styles.medium(color: colors.primaryColor)
                            : styles.regular(color: Colors.black54),
                      ),
                    ),
                  ),
                ),
              ),
            if (widget.numberOfSupplies > 0)
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selected = 2;
                    });
                    widget.setCurrentlyShowing(CurrentlyShowing.SUPPLIES);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: selected == 2 ? 2 : 1,
                          color: selected == 2
                              ? colors.primaryColor
                              : Colors.transparent,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Suprimentos (${widget.numberOfSupplies})',
                        style: selected == 2
                            ? styles.medium(color: colors.primaryColor)
                            : styles.regular(color: Colors.black54),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
