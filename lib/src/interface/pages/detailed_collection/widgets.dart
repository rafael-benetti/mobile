import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../src/core/models/box_collection.dart';
import '../../../../src/core/models/collection.dart';
import '../../../../src/core/models/counter_collection.dart';
import '../../../../src/core/services/interface_service.dart';
import '../../../../src/interface/pages/photo_view/full_photo_page.dart';
import '../../../../src/interface/shared/colors.dart';
import '../../../../src/interface/shared/text_styles.dart';
import '../../../../src/interface/shared/validators.dart';
import '../../../../src/interface/widgets/custom_text_field.dart';
import '../../../locator.dart';

final styles = locator<TextStyles>();
final colors = locator<AppColors>();

class CurrentData extends StatelessWidget {
  final String userName;
  final DateTime endTime;
  final DateTime startTime;

  const CurrentData({
    Key key,
    this.userName,
    this.endTime,
    this.startTime,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dados da Coleta Atual', style: styles.medium(fontSize: 16)),
        SizedBox(height: 10),
        Text(
          'Data de início',
          style: styles.light(),
        ),
        SizedBox(height: 5),
        CustomTextField(
          enabled: false,
          initialValue: startTime != null ? getFormattedDate(startTime) : '-',
        ),
        SizedBox(height: 10),
        Text(
          'Realizada em',
          style: styles.light(),
        ),
        SizedBox(height: 5),
        CustomTextField(
          enabled: false,
          initialValue: endTime != null ? getFormattedDate(endTime) : '-',
        ),
        SizedBox(height: 15),
        Text(
          'Feita por',
          style: styles.light(),
        ),
        SizedBox(height: 5),
        CustomTextField(
          enabled: false,
          initialValue: userName,
        ),
      ],
    );
  }
}

class Map extends StatelessWidget {
  final Coordinates startLocation;
  final Coordinates endLocation;

  Map({Key key, this.startLocation, this.endLocation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        GestureDetector(
          onTap: () {
            locator<InterfaceService>().showDialogMessage(
                title: 'Atenção',
                message:
                    'Caso não consiga ver dois pontos no mapa, remova o zoom para encontrar o outro.');
          },
          child: Row(
            children: [
              Text('Localização inicial e final do usuário'),
              SizedBox(width: 2),
              Icon(
                Icons.info_outline,
                color: colors.primaryColor,
              )
            ],
          ),
        ),
        SizedBox(height: 5),
        Container(
          height: 200,
          width: screenWidth,
          padding: EdgeInsets.symmetric(vertical: 5),
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
                target: LatLng(startLocation.latitude, startLocation.longitude),
                zoom: 19),
            markers: <Marker>{
              Marker(
                alpha: 1,
                infoWindow: InfoWindow(title: 'Localização inicial'),
                markerId: MarkerId('marker_1'),
                position:
                    LatLng(startLocation.latitude, startLocation.longitude),
              ),
              Marker(
                alpha: 1,
                infoWindow: InfoWindow(title: 'Localização inicial'),
                markerId: MarkerId('marker_1'),
                position: LatLng(
                  endLocation.latitude + 0.00001,
                  endLocation.longitude + 0.00001,
                ),
              )
            },
          ),
        ),
      ],
    );
  }
}

class Observations extends StatelessWidget {
  final String observations;

  const Observations({Key key, this.observations}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        Text('Observações da coleta'),
        SizedBox(height: 10),
        CustomTextField(
          enabled: false,
          initialValue: observations,
        ),
      ],
    );
  }
}

class PreviousData extends StatelessWidget {
  final String userName;
  final DateTime endTime;
  final DateTime startTime;

  const PreviousData({
    Key key,
    this.userName,
    this.endTime,
    this.startTime,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dados da Coleta Anterior', style: styles.medium(fontSize: 16)),
        SizedBox(height: 10),
        Text(
          'Data de início',
          style: styles.light(),
        ),
        SizedBox(height: 5),
        CustomTextField(
          enabled: false,
          initialValue: startTime != null ? getFormattedDate(startTime) : '-',
        ),
        SizedBox(height: 5),
        Text(
          'Realizada em',
          style: styles.light(),
        ),
        SizedBox(height: 5),
        CustomTextField(
          enabled: false,
          initialValue: endTime != null ? getFormattedDate(endTime) : '-',
        ),
        SizedBox(height: 15),
        Text(
          'Feita por',
          style: styles.light(),
        ),
        SizedBox(height: 5),
        CustomTextField(
          enabled: false,
          initialValue: userName,
        ),
      ],
    );
  }
}

class ColumnNames extends StatelessWidget {
  final bool isMoneyRelated;

  const ColumnNames({Key key, this.isMoneyRelated}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25,
      margin: EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        children: [
          SizedBox(width: 85),
          Expanded(
            child: Container(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(5),
                      child: FittedBox(
                        child: Text(
                          isMoneyRelated ? 'Anterior (R\$)' : 'Anterior',
                          style: styles.medium(fontSize: 11),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(5),
                      child: FittedBox(
                        child: Text(
                          isMoneyRelated ? 'Atual (R\$)' : 'Atual',
                          style: styles.medium(fontSize: 11),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(5),
                      child: FittedBox(
                        child: Text(
                          isMoneyRelated ? 'Diferença (R\$)' : 'Diferença',
                          style: styles.medium(fontSize: 11),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class SingleRow extends StatelessWidget {
  final String title;
  final double previous;
  final double current;
  final double difference;

  const SingleRow(
      {Key key, this.title, this.previous, this.current, this.difference})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25,
      margin: EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        children: [
          Container(
            width: 85,
            child: Center(
              child: Text(
                title,
                style: styles.medium(),
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(5),
                      child: Text(
                        previous != null ? previous.toString() : '-',
                        style: styles.light(
                          color: Color(
                            0xffffc107,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(5),
                      child: Text(
                        current != null ? current.toString() : '-',
                        style: styles.light(
                          color: colors.lightGreen,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(5),
                      child: Text(
                        difference != null ? difference.toString() : '-',
                        style: styles.medium(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class SingleCounterCollection extends StatelessWidget {
  final String counterTypeLabel;
  final CounterCollection currentCounterCollection;
  final CounterCollection previousCounterCollection;

  const SingleCounterCollection({
    Key key,
    this.currentCounterCollection,
    this.counterTypeLabel,
    this.previousCounterCollection,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  width: 1,
                  color: colors.lightBlack,
                )),
            child: Column(
              children: [
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.mediumBlack, width: 1),
                    color: colors.primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        counterTypeLabel,
                        style: styles.regular(color: colors.backgroundColor),
                      ),
                      Text(
                        'Telemetria: ${currentCounterCollection.telemetryCount}',
                        style: styles.medium(color: colors.backgroundColor),
                      ),
                    ],
                  ),
                ),
                ColumnNames(
                  isMoneyRelated: counterTypeLabel == 'Prêmio' ? false : true,
                ),
                Divider(
                  height: 0,
                ),
                SingleRow(
                  current: currentCounterCollection.digitalCount,
                  previous: previousCounterCollection != null
                      ? previousCounterCollection.digitalCount ?? 0
                      : null,
                  difference: previousCounterCollection != null
                      ? (previousCounterCollection.digitalCount != null
                          ? currentCounterCollection.digitalCount -
                              previousCounterCollection.digitalCount
                          : currentCounterCollection.digitalCount)
                      : null,
                  title: 'Digital',
                ),
                Divider(
                  height: 0,
                ),
                SingleRow(
                  current: currentCounterCollection.mechanicalCount,
                  previous: previousCounterCollection != null
                      ? previousCounterCollection.mechanicalCount ?? 0
                      : null,
                  difference: previousCounterCollection != null
                      ? (previousCounterCollection.mechanicalCount != null
                          ? currentCounterCollection.mechanicalCount -
                              previousCounterCollection.mechanicalCount
                          : currentCounterCollection.mechanicalCount)
                      : null,
                  title: 'Mecânico',
                ),
                Divider(
                  height: 0,
                ),
                SingleRow(
                  current: currentCounterCollection.userCount,
                  title: 'Recolhido',
                ),
                Divider(height: 0),
                if (currentCounterCollection.photos.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: currentCounterCollection.photos.length,
                            itemBuilder: (context, photoIndex) {
                              if (currentCounterCollection
                                      .photos[photoIndex].runtimeType ==
                                  CounterPhoto) {
                                return GestureDetector(
                                  onTap: () {
                                    locator<InterfaceService>().navigateTo(
                                        FullPhotoPage.route,
                                        arguments: currentCounterCollection
                                            .photos[photoIndex]);
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width / 4.5,
                                    margin: EdgeInsets.only(left: 5),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: Image.network(
                                        currentCounterCollection
                                            .photos[photoIndex].downloadUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return Container();
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    height: 55,
                    child: Center(
                      child: Text('Nenhuma foto deste contador.'),
                    ),
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SingleBoxCollection extends StatelessWidget {
  final BoxCollection boxCollection;
  final BoxCollection previousBoxCollection;
  final String cabinNumber;
  final String categoryLabel;

  const SingleBoxCollection({
    this.boxCollection,
    this.previousBoxCollection,
    this.cabinNumber,
    this.categoryLabel,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.black45),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Container(
            height: 50,
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  categoryLabel.toLowerCase().contains('roleta')
                      ? 'Haste $cabinNumber'
                      : 'Cabine $cabinNumber',
                  style: styles.medium(),
                ),
              ],
            ),
          ),
          Column(
            children: List.generate(
              boxCollection.counterCollections.length,
              (cIndex) {
                return SingleCounterCollection(
                  counterTypeLabel:
                      boxCollection.counterCollections[cIndex].counterTypeLabel,
                  currentCounterCollection:
                      boxCollection.counterCollections[cIndex],
                  previousCounterCollection: previousBoxCollection != null
                      ? (previousBoxCollection.counterCollections.length >
                              cIndex
                          ? previousBoxCollection.counterCollections[cIndex]
                          : null)
                      : null,
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
