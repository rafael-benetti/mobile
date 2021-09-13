import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import '../../../../src/core/models/income_method_distribution.dart';
import '../../../../src/core/providers/dashboard_provider.dart';
import '../../../../src/interface/pages/collections/collections_page.dart';
import '../../../../src/interface/pages/detailed_machine/detailed_machine_page.dart';
import '../../../../src/interface/pages/reports/reports_page.dart';
import '../../../../src/interface/shared/validators.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/interface_service.dart';
import '../categories/categories_page.dart';
import '../counter_types/counter_types_page.dart';
import '../edit_profile/edit_profile_page.dart';
import '../group_stock/group_stock_page.dart';
import '../groups/groups_page.dart';
import '../login/login_page.dart';
import '../machines/machines_page.dart';
import '../managers/managers_page.dart';
import '../operators/operators_page.dart';
import '../personal_stock/personal_stock_page.dart';
import '../points_of_sale/points_of_sale_page.dart';
import '../routes/routes_page.dart';
import '../telemetry_boards/telemetry_boards_page.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';
import 'dart:math' as math;
import '../../../locator.dart';

final colors = locator<AppColors>();
final styles = locator<TextStyles>();
final chartColors = List.generate(
    30, (i) => Color((math.Random().nextDouble() * 0xFFFFFF).toInt()));

class AppDrawer extends StatefulWidget {
  final String versionNumber;

  const AppDrawer({Key key, this.versionNumber}) : super(key: key);
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  var selector = 0;
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, _) {
      var role = userProvider.user.role;
      return SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.fromLTRB(15, 40, 15, 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  locator<InterfaceService>().navigateTo(EditProfilePage.route);
                },
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(75),
                          child: userProvider.user.photo == null
                              ? Image.asset(
                                  'assets/user_thumbnail.png',
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  userProvider.user.photo,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userProvider.user.name,
                              style: styles.medium(fontSize: 20),
                            ),
                            Text(
                              userProvider.user.role == Role.OPERATOR
                                  ? 'Operador'
                                  : userProvider.user.role == Role.MANAGER
                                      ? 'Colaborador'
                                      : 'Administrador',
                              style: styles.light(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 7.5),
              Divider(),
              SizedBox(height: 7.5),
              if (userProvider.user.role != Role.OPERATOR)
                Cabinet(
                  icon: Feather.activity,
                  text: 'Visão Geral',
                  isSelected: selector == 0 ? true : false,
                  onClick: () {
                    setState(() {
                      selector = 0;
                    });
                    locator<InterfaceService>().goBack();
                  },
                ),
              Cabinet(
                icon: Feather.hard_drive,
                text: role == Role.OPERATOR ? 'Minhas Máquinas' : 'Máquinas',
                subCabinets: role == Role.OPERATOR
                    ? null
                    : [
                        {
                          'Minhas Máquinas': () async {
                            await locator<InterfaceService>()
                                .navigateTo(MachinesPage.route);
                          },
                        },
                        {
                          'Categorias': () async {
                            await locator<InterfaceService>()
                                .navigateTo(CategoriesPage.route);
                          },
                        },
                        {
                          'Tipos de contadores': () async {
                            await locator<InterfaceService>()
                                .navigateTo(CounterTypesPage.route);
                          },
                        }
                      ],
                isSelected: selector == 1 ? true : false,
                onClick: role == Role.OPERATOR
                    ? () {
                        setState(() {
                          selector = 1;
                        });
                        locator<InterfaceService>()
                            .navigateTo(MachinesPage.route);
                      }
                    : () {
                        setState(() {
                          if (selector != 1) {
                            selector = 1;
                          } else {
                            selector = -1;
                          }
                        });
                      },
              ),
              Cabinet(
                icon: Feather.pocket,
                text: 'Coletas',
                isSelected: selector == 2 ? true : false,
                onClick: () {
                  setState(() {
                    selector = 2;
                  });
                  locator<InterfaceService>().navigateTo(CollectionsPage.route);
                },
              ),
              Cabinet(
                icon: Feather.radio,
                text: 'Telemetrias',
                isSelected: selector == 3 ? true : false,
                onClick: () {
                  setState(() {
                    selector = 3;
                  });
                  locator<InterfaceService>()
                      .navigateTo(TelemetryBoardsPage.route);
                },
              ),
              Cabinet(
                icon: Feather.gift,
                text: role == Role.OPERATOR
                    ? 'Meu estoque'
                    : role == Role.OWNER
                        ? 'Estoque'
                        : 'Estoques',
                isSelected: selector == 4 ? true : false,
                subCabinets: userProvider.user.role == Role.MANAGER
                    ? [
                        {
                          'Estoque da parceria': () {
                            locator<InterfaceService>()
                                .navigateTo(GroupStockPage.route);
                          },
                        },
                        {
                          'Meu estoque pessoal': () async {
                            await locator<InterfaceService>()
                                .navigateTo(PersonalStockPage.route);
                          },
                        }
                      ]
                    : null,
                onClick: role == Role.MANAGER
                    ? () {
                        setState(() {
                          if (selector != 4) {
                            selector = 4;
                          } else {
                            selector = -1;
                          }
                        });
                      }
                    : () {
                        setState(() {
                          selector = 4;
                        });
                        if (role == Role.OPERATOR) {
                          locator<InterfaceService>()
                              .navigateTo(PersonalStockPage.route);
                        } else {
                          locator<InterfaceService>()
                              .navigateTo(GroupStockPage.route);
                        }
                      },
              ),
              Cabinet(
                icon: Feather.home,
                text: 'Pontos de Venda',
                isSelected: selector == 5 ? true : false,
                onClick: () async {
                  setState(() {
                    selector = 5;
                  });
                  await locator<InterfaceService>()
                      .navigateTo(PointsOfSalePage.route);
                },
              ),
              Cabinet(
                icon: Feather.map,
                text: 'Rotas',
                isSelected: selector == 6 ? true : false,
                onClick: () {
                  setState(() {
                    selector = 6;
                  });
                  locator<InterfaceService>().navigateTo(RoutesPage.route);
                },
              ),
              if (role != Role.OPERATOR)
                Cabinet(
                  icon: Feather.thumbs_up,
                  text: 'Parcerias',
                  isSelected: selector == 7 ? true : false,
                  onClick: () async {
                    setState(() {
                      selector = 7;
                    });
                    await locator<InterfaceService>()
                        .navigateTo(GroupsPage.route);
                  },
                ),
              if (userProvider.user.permissions.generateReports)
                Cabinet(
                  icon: Feather.file_text,
                  text: 'Relatório',
                  isSelected: selector == 8 ? true : false,
                  onClick: () {
                    locator<InterfaceService>().navigateTo(ReportsPage.route);
                    setState(() {
                      selector = 8;
                    });
                  },
                ),
              if (userProvider.user.permissions.listManagers &&
                  userProvider.user.permissions.listOperators)
                Cabinet(
                  icon: Feather.users,
                  text: 'Usuários',
                  subCabinets: [
                    {
                      'Colaboradores': () {
                        locator<InterfaceService>()
                            .navigateTo(ManagersPage.route);
                      }
                    },
                    {
                      'Operadores': () {
                        locator<InterfaceService>()
                            .navigateTo(OperatorsPage.route);
                      },
                    },
                  ],
                  isSelected: selector == 9 ? true : false,
                  onClick: () {
                    setState(() {
                      if (selector == 9) {
                        selector = -1;
                        return;
                      }
                      selector = 9;
                    });
                  },
                )
              else if (userProvider.user.permissions.listManagers)
                Cabinet(
                  icon: Feather.users,
                  text: 'Colaboradores',
                  isSelected: selector == 9 ? true : false,
                  onClick: () {
                    setState(() {
                      selector = 9;
                    });
                    locator<InterfaceService>().navigateTo(ManagersPage.route);
                  },
                )
              else if (userProvider.user.permissions.listOperators)
                Cabinet(
                  icon: Feather.users,
                  text: 'Operadores',
                  isSelected: selector == 9 ? true : false,
                  onClick: () {
                    setState(() {
                      selector = 9;
                    });
                    locator<InterfaceService>().navigateTo(OperatorsPage.route);
                  },
                ),
              Cabinet(
                icon: Feather.user,
                text: 'Meu Perfil',
                isSelected: selector == 10 ? true : false,
                onClick: () async {
                  setState(() {
                    selector = 10;
                  });
                  await locator<InterfaceService>()
                      .navigateTo(EditProfilePage.route);
                },
              ),
              Cabinet(
                icon: Feather.external_link,
                text: 'Sair',
                isSelected: selector == 11 ? true : false,
                onClick: () {
                  locator<HiveService>().clearBox('JWT');
                  locator<InterfaceService>().replaceAllWith(LoginPage.route);
                  setState(() {
                    selector = 11;
                  });
                },
              ),
              SizedBox(height: 15),
              Divider(),
              Container(
                height: 50,
                child: Center(
                  child: Text('Versão ${widget.versionNumber}'),
                ),
              ),
              SizedBox(height: 5),
            ],
          ),
        ),
      );
    });
  }
}

class Cabinet extends StatefulWidget {
  final IconData icon;
  final String text;
  final List<Map<String, dynamic>> subCabinets;
  final bool isSelected;
  final Function onClick;

  const Cabinet(
      {this.onClick, this.isSelected, this.icon, this.text, this.subCabinets});

  @override
  _CabinetState createState() => _CabinetState();
}

class _CabinetState extends State<Cabinet> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onClick(),
      child: Column(
        children: [
          Container(
            height: 55,
            decoration: BoxDecoration(
              gradient: widget.isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      colors: [
                        colors.primaryColor,
                        Color(0xffe6e7e8),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(15),
            ),
            padding: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.icon,
                      color: widget.isSelected
                          ? colors.backgroundColor
                          : Colors.black,
                    ),
                    SizedBox(width: 15),
                    Text(
                      widget.text,
                      style: styles.bold(
                        letterSpacing: 0.5,
                        color: widget.isSelected
                            ? colors.backgroundColor
                            : Colors.black,
                      ),
                    )
                  ],
                ),
                if (widget.subCabinets != null)
                  Icon(
                    widget.isSelected
                        ? Icons.keyboard_arrow_down_sharp
                        : Icons.arrow_forward_ios,
                    size: widget.isSelected ? 25 : 15,
                    color: widget.isSelected
                        ? colors.backgroundColor
                        : Colors.black,
                  )
              ],
            ),
          ),
          AnimatedSize(
            duration: Duration(milliseconds: 300),
            curve: Curves.linear,
            vsync: this,
            child: widget.subCabinets == null
                ? SizedBox()
                : !widget.isSelected
                    ? SizedBox()
                    : Container(
                        height: widget.subCabinets.length == 2 ? 75 : 110,
                        padding: EdgeInsets.only(left: 25),
                        child: Stack(
                          fit: StackFit.passthrough,
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 7.5),
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: colors.primaryColor,
                                    width: 0.5,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                                left: 0,
                                child: SizedBox(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      InkWell(
                                        onTap:
                                            widget.subCabinets[0].values.first,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Row(
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(
                                                  left: 2.5,
                                                ),
                                                height: 10,
                                                width: 10,
                                                decoration: BoxDecoration(
                                                  color: colors.backgroundColor,
                                                  border: Border.all(
                                                    color: colors.primaryColor,
                                                    width: 2,
                                                    style: BorderStyle.solid,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                widget
                                                    .subCabinets[0].keys.first,
                                                style: styles.regular(
                                                    color: colors.primaryColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap:
                                            widget.subCabinets[1].values.first,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Row(
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(
                                                  left: 2.5,
                                                ),
                                                height: 10,
                                                width: 10,
                                                decoration: BoxDecoration(
                                                    color:
                                                        colors.backgroundColor,
                                                    border: Border.all(
                                                      color:
                                                          colors.primaryColor,
                                                      width: 2,
                                                      style: BorderStyle.solid,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25)),
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                widget
                                                    .subCabinets[1].keys.first,
                                                style: styles.regular(
                                                    color: colors.primaryColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (widget.subCabinets.length == 3)
                                        InkWell(
                                          onTap: widget
                                              .subCabinets[2].values.first,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Row(
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.only(
                                                    left: 2.5,
                                                  ),
                                                  height: 10,
                                                  width: 10,
                                                  decoration: BoxDecoration(
                                                      color: colors
                                                          .backgroundColor,
                                                      border: Border.all(
                                                        color:
                                                            colors.primaryColor,
                                                        width: 2,
                                                        style:
                                                            BorderStyle.solid,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25)),
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  widget.subCabinets[2].keys
                                                      .first,
                                                  style: styles.regular(
                                                      color:
                                                          colors.primaryColor),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ))
                          ],
                        ),
                      ),
          )
        ],
      ),
    );
  }
}

class DashboardInfo extends StatelessWidget {
  final Function filters;
  final int numberOfAppliedFilters;

  const DashboardInfo({Key key, this.filters, this.numberOfAppliedFilters})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                'PAINEL GERAL',
                style: styles.bold(fontSize: 18),
              ),
              SizedBox(width: 7.5),
              InkWell(
                onTap: filters,
                child: Row(
                  children: [
                    SizedBox(width: 7.5),
                    Text(
                      'Filtros',
                      style: styles.regular(
                        color: colors.primaryColor,
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(
                      Icons.filter_list,
                      color: colors.primaryColor,
                      size: 20,
                    ),
                    SizedBox(width: 3),
                    if (numberOfAppliedFilters != 0)
                      Text(
                        '($numberOfAppliedFilters)',
                        style: styles.regular(
                          color: colors.primaryColor,
                        ),
                      )
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class DashboardChart extends StatefulWidget {
  final Map<String, dynamic> setup;

  const DashboardChart({Key key, this.setup}) : super(key: key);
  @override
  State<StatefulWidget> createState() => DashboardChartState();
}

class DashboardChartState extends State<DashboardChart> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.20,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          color: colors.backgroundColor,
        ),
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  height: 37,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 25),
                    child: BarChart(
                      sample(),
                      swapAnimationDuration: const Duration(milliseconds: 100),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BarChartData sample() {
    return BarChartData(
      gridData: FlGridData(
        show: true,
        horizontalInterval: widget.setup['maxY'] < 10
            ? 2
            : widget.setup['maxY'] < 50
                ? 5
                : widget.setup['maxY'] < 100
                    ? 10
                    : widget.setup['maxY'] < 500
                        ? 50
                        : widget.setup['maxY'] < 1000
                            ? 100
                            : widget.setup['maxY'] < 10000
                                ? 1000
                                : widget.setup['maxY'] < 100000
                                    ? 10000
                                    : 10000,
      ),
      barTouchData: BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipPadding: const EdgeInsets.all(0),
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.y.round().toString(),
              TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 20,
          getTextStyles: (bc, value) => TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          margin: 3,
          getTitles: (value) {
            if (widget.setup['period'] == 'DAILY') {
              if (value % 6 == 0) {
                var hour;
                if (widget.setup['xArray'][(value.toInt())].hour
                        .toString()
                        .length ==
                    1) {
                  hour = '0${widget.setup['xArray'][(value.toInt())].hour}';
                } else {
                  hour =
                      widget.setup['xArray'][(value.toInt())].hour.toString();
                }
                return '$hour:00';
              }
            } else if (widget.setup['period'] == 'WEEKLY') {
              var day;
              var month;
              if (widget.setup['xArray'][(value.toInt())].day
                      .toString()
                      .length ==
                  1) {
                day = '0${widget.setup['xArray'][(value.toInt())].day}';
              } else {
                day = widget.setup['xArray'][(value.toInt())].day.toString();
              }
              if (widget.setup['xArray'][(value.toInt())].month
                      .toString()
                      .length ==
                  1) {
                month = '0${widget.setup['xArray'][(value.toInt())].month}';
              } else {
                month =
                    widget.setup['xArray'][(value.toInt())].month.toString();
              }
              return '$day/$month';
            } else {
              if (value % 5 == 0 || value == widget.setup['xArray'].length) {
                var day;
                var month;
                if (widget.setup['xArray'][(value.toInt())].day
                        .toString()
                        .length ==
                    1) {
                  day = '0${widget.setup['xArray'][(value.toInt())].day}';
                } else {
                  day = widget.setup['xArray'][(value.toInt())].day.toString();
                }
                if (widget.setup['xArray'][(value.toInt())].month
                        .toString()
                        .length ==
                    1) {
                  month = '0${widget.setup['xArray'][(value.toInt())].month}';
                } else {
                  month =
                      widget.setup['xArray'][(value.toInt())].month.toString();
                }
                return '$day/$month';
              }
            }

            return '';
          },
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (bc, value) => TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
          getTitles: (value) {
            if (value == 0) {
              return '';
            }
            if (value == widget.setup['maxY']) {
              return '${value.toStringAsFixed(0).replaceAll('.', ',')}';
            } else if (widget.setup['maxY'] <= 10) {
              return '${value.toStringAsFixed(0).replaceAll('.', ',')}';
            } else if (widget.setup['maxY'] <= 50) {
              if (value % 5 == 0) {
                return '${value.toStringAsFixed(0).replaceAll('.', ',')}';
              }
            } else if (widget.setup['maxY'] <= 100) {
              if (value % 10 == 0) {
                return '${value.toStringAsFixed(0).replaceAll('.', ',')}';
              }
            } else if (widget.setup['maxY'] <= 1000) {
              if (value % 100 == 0) {
                return '${value.toStringAsFixed(0).replaceAll('.', ',')}';
              }
            } else if (widget.setup['maxY'] <= 10000) {
              if (value % 1000 == 0) {
                return '${value.toStringAsFixed(0).replaceAll('.', ',')}';
              }
            } else if (widget.setup['maxY'] <= 1000000) {
              if (value % 10000 == 0) {
                return '${value.toStringAsFixed(0).replaceAll('.', ',')}';
              }
            }
            return '';
          },
          margin: 5,
          reservedSize: 33,
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(
            color: Color(0xff4e4965),
            width: 1,
          ),
          left: BorderSide(
            color: Color(0xff4e4965),
            width: 1,
          ),
          right: BorderSide(
            color: Colors.transparent,
          ),
          top: BorderSide(
            color: Colors.transparent,
          ),
        ),
      ),
      groupsSpace: 4,
      barGroups: data(),
      maxY: widget.setup['maxY'],
      minY: 0,
    );
  }

  List<BarChartGroupData> data() {
    return List.generate(
      widget.setup['incomeSpots'].length,
      (index) {
        return BarChartGroupData(
          x: index,
          barsSpace: 4,
          barRods: [
            BarChartRodData(
                y: widget.setup['incomeSpots'][index].y +
                    widget.setup['prizesSpots'][index].y,
                rodStackItems: [
                  BarChartRodStackItem(
                      0, widget.setup['prizesSpots'][index].y, Colors.red),
                  BarChartRodStackItem(
                      widget.setup['prizesSpots'][index].y,
                      widget.setup['incomeSpots'][index].y +
                          widget.setup['prizesSpots'][index].y,
                      Colors.green),
                ],
                borderRadius: const BorderRadius.all(Radius.zero))
          ],
        );
      },
    );
  }
}

class DashboardPieChart extends StatefulWidget {
  final List<IncomeMethodDistribution> incomeMethodDistributions;

  const DashboardPieChart({Key key, this.incomeMethodDistributions})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => DashboardPieChartState();
}

class DashboardPieChartState extends State<DashboardPieChart> {
  int touchedIndex;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          color: colors.backgroundColor,
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 250,
                child: PieChart(
                  PieChartData(
                    pieTouchData:
                        PieTouchData(touchCallback: (pieTouchResponse) {
                      setState(() {
                        final desiredTouch =
                            pieTouchResponse.touchInput is! PointerExitEvent &&
                                pieTouchResponse.touchInput is! PointerUpEvent;
                        if (desiredTouch &&
                            pieTouchResponse.touchedSection != null) {
                        } else {
                          touchedIndex = -1;
                        }
                      });
                    }),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 1,
                    centerSpaceRadius: 0,
                    sections: showingSections(widget.incomeMethodDistributions),
                  ),
                ),
              ),
            ),
            Container(
              height: 250,
              width: 90,
              padding: EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.incomeMethodDistributions.length,
                  (index) {
                    return Row(
                      children: [
                        Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            color: chartColors[index].withOpacity(1.0),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 3),
                        Text(widget.incomeMethodDistributions[index]
                                .counterLabel ??
                            ''),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections(
      List<IncomeMethodDistribution> incomeMethodDistributions) {
    var total = 0.0;
    incomeMethodDistributions.forEach((element) {
      total += element.total;
    });

    return List.generate(incomeMethodDistributions.length, (index) {
      return PieChartSectionData(
        color: chartColors[index].withOpacity(1.0),
        value: incomeMethodDistributions[index].total,
        title:
            '${incomeMethodDistributions[index].counterLabel}\nR\$${incomeMethodDistributions[index].total.toStringAsFixed(2).replaceAll('.', ',')}\n${(incomeMethodDistributions[index].total / total * 100).toStringAsFixed(0)}%',
        radius: 100,
        titleStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff)),
      );
    });
  }
}

class Notifications extends StatelessWidget {
  final int unreadNotifications;
  final Function riseNotificationsPage;

  const Notifications({
    Key key,
    this.unreadNotifications,
    this.riseNotificationsPage,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: riseNotificationsPage,
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(
                Icons.notifications,
              ),
            ),
          ),
          if (unreadNotifications != 0)
            Positioned(
              right: 10,
              top: 12.5,
              child: Container(
                constraints: BoxConstraints(maxHeight: 15, maxWidth: 15),
                padding: EdgeInsets.all(1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.red,
                ),
                child: Center(
                  child: FittedBox(
                    child: Text(
                      unreadNotifications.toString(),
                      style: styles.light(
                        color: colors.backgroundColor,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}

class NotificationList extends StatelessWidget {
  final Function getMoreNotifications;

  NotificationList({Key key, this.getMoreNotifications});
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child:
          Consumer<DashboardProvider>(builder: (context, dashboardProvider, _) {
        _scrollController.addListener(() async {
          if (_scrollController.position.extentAfter == 0 &&
              dashboardProvider.notifications.length !=
                  dashboardProvider.notificationsCount) {
            await getMoreNotifications();
          }
        });
        return Column(
          children: List.generate(
            dashboardProvider.notifications.length,
            (index) => GestureDetector(
              onTap: () => locator<InterfaceService>().navigateTo(
                  DetailedMachinePage.route,
                  arguments: dashboardProvider.notifications[index].machineId),
              child: Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0)),
                child: Container(
                  height: 110,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dashboardProvider.notifications[index].title,
                            style: styles.medium(),
                          ),
                          Text(
                            getFormattedDate(
                                dashboardProvider.notifications[index].date),
                            style: styles.light(),
                          )
                        ],
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            dashboardProvider.notifications[index].body,
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Acessar máquina',
                            style: styles.regular(color: colors.primaryColor),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 15,
                            color: colors.primaryColor,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
