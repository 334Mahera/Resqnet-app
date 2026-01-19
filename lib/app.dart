import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'routes.dart';
import 'theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: MaterialApp(
        title: 'ResQnet',
        debugShowCheckedModeBanner: false, // ✅ remove debug banner
        theme: AppTheme.lightTheme,        // ✅ centralized theme
        initialRoute: Routes.splash,
        onGenerateRoute: Routes.onGenerate,
      ),
    );
  }
}
