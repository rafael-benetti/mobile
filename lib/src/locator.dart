import 'package:get_it/get_it.dart';
import 'core/providers/categories_provider.dart';
import 'core/providers/collections_provider.dart';
import 'core/providers/counter_types_provider.dart';
import 'core/providers/dashboard_provider.dart';
import 'core/providers/machine_logs_provider.dart';
import 'core/providers/notifications_provider.dart';
import 'core/providers/points_of_sale_provider.dart';
import 'core/providers/routes_provider.dart';
import 'core/providers/telemetry_logs_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/services/api_service.dart';
import 'core/services/interface_service.dart';

import 'core/providers/groups_provider.dart';
import 'core/providers/machines_provider.dart';
import 'core/providers/telemetry_boards_provider.dart';
import 'core/services/hive_service.dart';
import 'interface/shared/colors.dart';
import 'interface/shared/text_styles.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => AppColors());
  locator.registerLazySingleton(() => TextStyles());
  locator.registerLazySingleton(() => InterfaceService());
  locator.registerLazySingleton(() => ApiService());
  locator.registerLazySingleton(() => UserProvider());
  locator.registerLazySingleton(() => HiveService());
  locator.registerLazySingleton(() => GroupsProvider());
  locator.registerLazySingleton(() => CategoriesProvider());
  locator.registerLazySingleton(() => PointsOfSaleProvider());
  locator.registerLazySingleton(() => MachinesProvider());
  locator.registerLazySingleton(() => RoutesProvider());
  locator.registerLazySingleton(() => CounterTypesProvider());
  locator.registerLazySingleton(() => TelemetryBoardsProvider());
  locator.registerLazySingleton(() => CollectionsProvider());
  locator.registerLazySingleton(() => NotificationsProvider());
  locator.registerLazySingleton(() => DashboardProvider());
  locator.registerLazySingleton(() => TelemetryLogsProvider());
  locator.registerLazySingleton(() => MachineLogsProvider());
}
