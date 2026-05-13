import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/stats_viewmodel.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'views/home/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

  // Check for incomplete projects and remind
  final projects = await StorageService().loadProjects();
  await NotificationService.checkAndRemindIncompleteProjects(projects);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => StatsViewModel()),
      ],
      child: const YTChampApp(),
    ),
  );
}

class YTChampApp extends StatelessWidget {
  const YTChampApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YT Champ Learner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeView(),
    );
  }
}