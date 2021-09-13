import 'package:flutter/material.dart';
import '../../../../src/interface/shared/validators.dart';
import '../../../core/models/group.dart';
import '../../../core/models/telemetry_board.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';

import '../../../locator.dart';

final colors = locator<AppColors>();
final styles = locator<TextStyles>();

class TelemetryBoardCard extends StatelessWidget {
  final TelemetryBoard telemetryBoard;
  final List<Group> groups;

  TelemetryBoardCard({Key key, this.telemetryBoard, this.groups})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(3),
      padding: EdgeInsets.all(10),
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    child: Text(
                      'Código:',
                      style: styles.medium(fontSize: 16),
                    ),
                  ),
                  SizedBox(width: 5),
                  Container(
                    child: Text(
                      'STG-${telemetryBoard.id}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              getTelemetryIcon(telemetryBoard, false),
            ],
          ),
          SizedBox(height: 7.5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                child: Text(
                  'Parceria:',
                  style: styles.medium(fontSize: 16),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Container(
                  child: Text(
                    groups
                        .firstWhere(
                            (element) => element.id == telemetryBoard.groupId)
                        .label,
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
                  'Máquina:',
                  style: styles.medium(fontSize: 16),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Container(
                  child: Text(
                    telemetryBoard.machineSerialNumber ?? '-',
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
                  'Última conexão:',
                  style: styles.medium(fontSize: 16),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Container(
                  child: Text(
                    telemetryBoard.lastConnection != null
                        ? getFormattedDate(
                            DateTime.parse(telemetryBoard.lastConnection))
                        : '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
