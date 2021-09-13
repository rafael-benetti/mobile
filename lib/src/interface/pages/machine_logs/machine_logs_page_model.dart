import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/core/models/machine.dart';
import '../../../../src/core/providers/machine_logs_provider.dart';
import '../../../../src/core/services/interface_service.dart';
import '../../../../src/interface/shared/colors.dart';
import '../../../../src/interface/widgets/custom_dropdown.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../locator.dart';

class MachineLogsPageModel extends BaseViewModel {
  final interfaceService = locator<InterfaceService>();
  final colors = locator<AppColors>();
  final machineLogsProvider = locator<MachineLogsProvider>();
  Machine machine;
  DateTimeRange dateRange = DateTimeRange(
      start: DateTime.now().subtract(Duration(days: 30)), end: DateTime.now());
  String type;
  int offset = 0;

  void initData() async {
    filterMachineLogs();
  }

  void selectType(DropdownInputOption option) {
    if (option.option == 'Todos') {
      type = null;
    } else {
      type = option.option;
    }
    filterMachineLogs();
  }

  void filterMachineLogs() async {
    setBusy(true);
    offset = 0;
    await machineLogsProvider.getMachineLogs(
      machineId: machine.id,
      offset: offset,
      shouldClearCurrentList: true,
      startDate: dateRange.start.add(Duration(hours: 3)).toIso8601String(),
      endDate: dateRange.end.add(Duration(hours: 3)).toIso8601String(),
      type: type,
    );
    setBusy(false);
  }

  void loadMoreMachineLogs() async {
    offset += 5;
    interfaceService.showLoader();
    await machineLogsProvider.getMachineLogs(
      offset: offset,
      machineId: machine.id,
      startDate: dateRange.start.toIso8601String(),
      endDate: dateRange.end.toIso8601String(),
      type: type,
      shouldClearCurrentList: false,
    );
    interfaceService.closeLoader();
  }

  void showDateRangePicker() {
    interfaceService.showModal(
      widget: Scaffold(
        appBar: AppBar(
          backgroundColor: colors.backgroundColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () async {
              interfaceService.goBack();
              filterMachineLogs();
            },
            icon: Icon(
              Icons.keyboard_arrow_down_outlined,
              color: Colors.black,
              size: 25,
            ),
          ),
          title: Text('Selecione o período'),
          iconTheme: IconThemeData(color: colors.primaryColor),
        ),
        backgroundColor: colors.backgroundColor,
        body: SfDateRangePicker(
          maxDate: DateTime.now(),
          minDate: DateTime(DateTime.now().year - 5),
          rangeSelectionColor: colors.primaryColor.withOpacity(0.5),
          endRangeSelectionColor: colors.primaryColor,
          startRangeSelectionColor: colors.primaryColor,
          onSelectionChanged: (args) {
            if (args.value is PickerDateRange) {
              PickerDateRange pickerDateRange = args.value;
              if (pickerDateRange.startDate != null &&
                  pickerDateRange.endDate != null) {
                dateRange = DateTimeRange(
                  start: pickerDateRange.startDate,
                  end: pickerDateRange.endDate,
                );
              }
            }
          },
          selectionMode: DateRangePickerSelectionMode.range,
          initialSelectedRange: dateRange != null
              ? PickerDateRange(
                  dateRange.start,
                  dateRange.end,
                )
              : null,
        ),
      ),
    );
  }

  void popObservationsDialog(String observations) {
    interfaceService.showDialogMessage(
        title: 'Observações', message: observations);
  }
}
