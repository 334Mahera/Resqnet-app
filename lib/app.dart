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
        debugShowCheckedModeBanner: false, 
        theme: AppTheme.lightTheme,       
        initialRoute: Routes.splash,
        onGenerateRoute: Routes.onGenerate,
      ),
    );
  }
}
