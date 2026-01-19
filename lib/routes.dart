import 'package:flutter/material.dart';

// Auth
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';

// User
import 'screens/user/user_bottom_nav.dart';
import 'screens/user/user_requests_screen.dart';

// Volunteer
import 'screens/volunteer/volunteer_bottom_nav.dart';
import 'screens/volunteer/volunteer_requests_screen.dart';

import 'screens/admin/admin_home_screen.dart';
import 'screens/admin/admin_analytics_screen.dart';
import 'screens/admin/admin_root_screen.dart';
// Common
import 'screens/profile/profile_screen.dart';

class Routes {
  // --------------------
  // Route names
  // --------------------
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';

  static const String userHome = '/userHome';
  static const String userRequests = '/userRequests';

  static const String volunteerHome = '/volunteerHome';
  static const String volunteerRequests = '/volunteerRequests';
  static const adminHome = '/admin/home';
  static const adminAnalytics = '/admin/analytics';
  static const adminRoot = '/admin';



  static const String profile = '/profile';

  // --------------------
  // Route generator
  // --------------------
  static Route<dynamic> onGenerate(RouteSettings settings) {
    switch (settings.name) {
      // Temporary splash → login
      case splash:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      // Auth
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case signup:
        return MaterialPageRoute(
          builder: (_) => const SignupScreen(),
        );

      // USER FLOW (Blinkit-style)
      case userHome:
        return MaterialPageRoute(
          builder: (_) => const UserBottomNav(), // 🔥 important
        );

      case userRequests:
        return MaterialPageRoute(
          builder: (_) => const UserRequestsScreen(),
        );

      // VOLUNTEER FLOW
      case volunteerHome:
        return MaterialPageRoute(
          builder: (_) => const VolunteerBottomNav(),
        );
      case volunteerRequests:
        return MaterialPageRoute(
          builder: (_) => const VolunteerRequestsScreen(),
        );
        case adminHome:
  return MaterialPageRoute(
    builder: (_) => const AdminHomeScreen(),
  );
  case Routes.adminAnalytics:
  return MaterialPageRoute(
    builder: (_) => const AdminAnalyticsScreen(),
  );
  case Routes.adminRoot:
  return MaterialPageRoute(
    builder: (_) => const AdminRootScreen(),
  );

      // PROFILE
      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
    }
  }
}
