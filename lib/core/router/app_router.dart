/// Centralized route names for the entire application.
/// Use [AppRouter.onGenerateRoute] in MaterialApp to resolve routes.
library;

import 'package:flutter/material.dart';
import '../../presentation/screens/auth/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/auth/verification_pending_screen.dart';
import '../../presentation/screens/auth/verification_rejected_screen.dart';
import '../../presentation/screens/student/student_shell_screen.dart';
import '../../presentation/screens/student/hostel_detail_screen.dart';
import '../../presentation/screens/student/my_bookings_screen.dart';
import '../../presentation/screens/student/student_active_stay_dashboard.dart';
import '../../presentation/screens/student/student_complaint_screen.dart';
import '../../presentation/screens/student/student_dues_screen.dart';
import '../../presentation/screens/admin/admin_shell_screen.dart';
import '../../presentation/screens/admin/add_hostel_screen.dart';
import '../../presentation/screens/admin/admin_complaints_screen.dart';
import '../../presentation/screens/admin/admin_residents_screen.dart';
import '../../presentation/screens/admin/admin_post_notice_screen.dart';
import '../../presentation/screens/admin/admin_hostel_management_screen.dart';
import '../../presentation/screens/admin/admin_dues_dashboard_screen.dart';
import '../../presentation/screens/admin/admin_bookings_screen.dart';
import '../../presentation/screens/admin/admin_dues_settings_screen.dart';
import '../../presentation/screens/admin/user_dues_history_screen.dart';
import '../../presentation/screens/admin/hostel_admin_edit_profile_screen.dart';
import '../../presentation/screens/platform_admin/platform_admin_dashboard_screen.dart';
import '../../presentation/screens/platform_admin/verification_dashboard_screen.dart';
import '../../presentation/screens/platform_admin/user_verification_detail_screen.dart';
import '../../presentation/screens/auth/onboarding_screen.dart';
import '../../presentation/widgets/common/location_picker_screen.dart';
import '../../data/models/user_model.dart';
import '../../data/models/hostel_model.dart';
import 'package:latlong2/latlong.dart';

class AppRouter {
  AppRouter._();

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String splash               = '/';
  static const String login                = '/login';
  static const String register             = '/register';
  static const String forgotPassword       = '/forgot-password';
  static const String verificationPending  = '/verification/pending';
  static const String verificationRejected = '/verification/rejected';
  static const String onboarding           = '/onboarding';

  // ── Student ───────────────────────────────────────────────────────────────
  static const String studentHome          = '/student/home';
  static const String hostelDetail         = '/student/hostel-detail';
  static const String myBookings           = '/student/bookings';
  static const String activeStay           = '/student/active-stay';
  static const String studentComplaints    = '/student/complaints';
  static const String studentDues          = '/student/dues';

  // ── Hostel Admin ──────────────────────────────────────────────────────────
  static const String adminDashboard       = '/admin/dashboard';
  static const String addHostel            = '/admin/add-hostel';
  static const String adminComplaints      = '/admin/complaints';
  static const String adminResidents       = '/admin/residents';
  static const String adminPostNotice      = '/admin/notice';
  static const String adminHostelMgmt      = '/admin/hostel-management';
  static const String adminDues            = '/admin/dues';
  static const String adminBookings        = '/admin/bookings';
  static const String adminDuesSettings    = '/admin/dues-settings';
  static const String userDuesHistory     = '/admin/dues-history';
  static const String adminEditProfile    = '/admin/edit-profile';

  // ── Platform Admin ────────────────────────────────────────────────────────
  static const String platformDashboard    = '/platform/dashboard';
  static const String verificationDashboard= '/platform/verifications';
  static const String userVerificationDetail = '/platform/verification-detail';
  static const String locationPicker         = '/common/location-picker';

  /// Generates routes based on route names.
  /// Screens that need arguments still accept them via [settings.arguments].
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth
      case splash:
        return _slide(const SplashScreen());
      case login:
        return _slide(const LoginScreen());
      case register:
        return _slide(const RegisterScreen());
      case forgotPassword:
        return _slide(const ForgotPasswordScreen());
      case verificationPending:
        return _slide(const VerificationPendingScreen());
      case verificationRejected:
        final reason = (settings.arguments as String?) ?? '';
        return _slide(VerificationRejectedScreen(rejectionReason: reason));
      case onboarding:
        final destination = settings.arguments as String;
        return _slide(OnboardingScreen(destinationRoute: destination));

      // Student
      case studentHome:
        return _slide(const StudentShellScreen());
      case hostelDetail:
        final raw = settings.arguments;
        final String hostelId;
        final bool hideBookingCta;
        if (raw is Map) {
          hostelId = raw['hostelId'] as String;
          hideBookingCta = raw['hideBooking'] == true;
        } else {
          hostelId = raw as String;
          hideBookingCta = false;
        }
        return _slide(HostelDetailScreen(
          hostelId: hostelId,
          hideBookingCta: hideBookingCta,
        ));
      case myBookings:
        return _slide(const MyBookingsScreen());
      case activeStay:
        return _slide(const StudentActiveStayDashboard());
      case studentComplaints:
        final args = settings.arguments as Map<String, String>?;
        return _slide(StudentComplaintScreen(
          hostelId: args?['hostelId'],
          hostelName: args?['hostelName'],
        ));
      case studentDues:
        return _slide(const StudentDuesScreen());

      // Hostel Admin
      case adminDashboard:
        return _slide(const AdminShellScreen());
      case addHostel:
        final hostel = settings.arguments as HostelModel?;
        return _slide(AddHostelScreen(hostel: hostel));
      case adminComplaints:
        final initialHostelId = settings.arguments as String?;
        return _slide(AdminComplaintsScreen(initialHostelId: initialHostelId));
      case adminResidents:
        final initialHostelId = settings.arguments as String?;
        return _slide(AdminResidentsScreen(initialHostelId: initialHostelId));
      case adminPostNotice:
        return _slide(const AdminPostNoticeScreen());
      case adminHostelMgmt:
        final hostelId = settings.arguments as String;
        return _slide(AdminHostelManagementScreen(hostelId: hostelId));
      case adminDues:
        return _slide(AdminDuesDashboardScreen());
      case adminBookings:
        final args = settings.arguments as Map<String, String>;
        return _slide(AdminBookingsScreen(
          hostelId: args['hostelId']!,
          hostelName: args['hostelName']!,
        ));
      case adminDuesSettings:
        final hostelId = settings.arguments as String;
        return _slide(AdminDuesSettingsScreen(hostelId: hostelId));
      case userDuesHistory:
        final args = settings.arguments as Map<String, String>;
        return _slide(UserDuesHistoryScreen(
          studentId: args['studentId']!,
          studentName: args['studentName']!,
        ));
      case adminEditProfile:
        return _slide(const HostelAdminEditProfileScreen());

      // Platform Admin
      case platformDashboard:
        return _slide(const PlatformAdminDashboardScreen());
      case verificationDashboard:
        return _slide(const VerificationDashboardScreen());
      case userVerificationDetail:
        final user = settings.arguments as UserModel;
        return _slide(UserVerificationDetailScreen(user: user));
      case locationPicker:
        final initialLocation = settings.arguments as LatLng?;
        return _slide(LocationPickerScreen(initialLocation: initialLocation));

      default:
        return _slide(const SplashScreen());
    }
  }

  static PageRouteBuilder<T> _slide<T>(Widget page) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(name: page.runtimeType.toString()),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        return SlideTransition(
          position: Tween(begin: begin, end: end)
              .chain(CurveTween(curve: curve))
              .animate(animation),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 280),
    );
  }
}
