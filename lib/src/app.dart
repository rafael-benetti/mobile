import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'core/providers/collections_provider.dart';
import 'core/providers/dashboard_provider.dart';
import 'core/providers/machine_logs_provider.dart';
import 'core/providers/notifications_provider.dart';
import 'core/providers/points_of_sale_provider.dart';
import 'core/providers/telemetry_logs_provider.dart';
import 'core/services/interface_service.dart';
import 'core/providers/categories_provider.dart';
import 'core/providers/counter_types_provider.dart';
import 'core/providers/groups_provider.dart';
import 'core/providers/machines_provider.dart';
import 'core/providers/routes_provider.dart';
import 'core/providers/telemetry_boards_provider.dart';
import 'core/providers/user_provider.dart';
import 'locator.dart';
import 'router.dart' as r;

List<SingleChildWidget> providers = [
  ListenableProvider.value(value: locator<MachinesProvider>()),
  ListenableProvider.value(value: locator<PointsOfSaleProvider>()),
  ListenableProvider.value(value: locator<CategoriesProvider>()),
  ListenableProvider.value(value: locator<GroupsProvider>()),
  ListenableProvider.value(value: locator<MachinesProvider>()),
  ListenableProvider.value(value: locator<UserProvider>()),
  ListenableProvider.value(value: locator<RoutesProvider>()),
  ListenableProvider.value(value: locator<CounterTypesProvider>()),
  ListenableProvider.value(value: locator<TelemetryBoardsProvider>()),
  ListenableProvider.value(value: locator<CollectionsProvider>()),
  ListenableProvider.value(value: locator<DashboardProvider>()),
  ListenableProvider.value(value: locator<NotificationsProvider>()),
  ListenableProvider.value(value: locator<TelemetryLogsProvider>()),
  ListenableProvider.value(value: locator<MachineLogsProvider>()),
];

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('pt'),
        ],
        builder: BotToastInit(),
        navigatorObservers: [
          BotToastNavigatorObserver(),
        ],
        theme: ThemeData(fontFamily: 'Rubik'),
        navigatorKey: locator<InterfaceService>().navigationKey,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: r.Router.generateRoute,
      ),
    );
  }
}
