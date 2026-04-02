import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../screens/splash_landing_screen.dart';
import '../../screens/user_type_selection.dart';
import '../../screens/auth/worker_signup.dart';
import '../../screens/auth/employer_signup.dart';
import '../../screens/auth/otp_verification_screen.dart';
import '../../screens/auth/verification_success_screen.dart';
import '../../screens/worker/worker_dashboard.dart';
import '../../screens/worker/worker_profile_screen.dart';
import '../../screens/worker/worker_subscription_screen.dart';
import '../../screens/worker/worker_jobs_screen.dart';
import '../../screens/employer/employer_dashboard.dart';
import '../../screens/worker/job_detail_screen.dart';
import '../../screens/worker/employer_public_profile_screen.dart';
import '../../screens/feed/feed_screen.dart';
import '../../screens/feed/create_post_screen.dart';
import '../../screens/feed/post_detail_screen.dart';
import '../../screens/subscription/subscription_plans_screen.dart';
import '../../screens/subscription/subscription_checkout_screen.dart';
import '../../screens/subscription/subscription_success_screen.dart';
import '../../screens/admin/admin_login_screen.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/admin/admin_posts_screen.dart';
import '../../screens/admin/admin_users_screen.dart';
import '../../screens/banned_screen.dart';
import '../../widgets/common/page_transitions.dart';
// Shell scaffold for Worker — holds bottom nav bar
class WorkerShell extends ConsumerStatefulWidget {
  final Widget child;
  final int currentIndex;
  const WorkerShell({super.key, required this.child, required this.currentIndex});

  @override
  ConsumerState<WorkerShell> createState() => _WorkerShellState();
}

class _WorkerShellState extends ConsumerState<WorkerShell> {
  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/worker/dashboard');
        break;
      case 1:
        context.go('/worker/jobs');
        break;
      case 2:
        context.push('/feed');
        break;
      case 3:
        context.go('/worker/subscriptions');
        break;
      case 4:
        context.go('/worker/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(context, 0, Icons.home_outlined, Icons.home, 'Home'),
                _navItem(context, 1, Icons.work_outline, Icons.work, 'Jobs'),
                GestureDetector(
                  onTap: () => _onNavTap(context, 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1D4ED8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 28),
                      ),
                      const SizedBox(height: 2),
                      const Text('Post', style: TextStyle(fontSize: 10, color: Color(0xFF1D4ED8), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                _navItem(context, 3, Icons.card_membership_outlined, Icons.card_membership, 'Pro'),
                _navItem(context, 4, Icons.person_outline, Icons.person, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, int index, IconData icon, IconData activeIcon, String label) {
    final isActive = widget.currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onNavTap(context, index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? const Color(0xFF1D4ED8) : const Color(0xFF94A3B8),
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? const Color(0xFF1D4ED8) : const Color(0xFF94A3B8),
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = auth != null;
      final isAuthRoute = state.matchedLocation.startsWith('/splash') ||
          state.matchedLocation.startsWith('/role-select') ||
          state.matchedLocation.startsWith('/worker/signup') ||
          state.matchedLocation.startsWith('/employer/signup') ||
          state.matchedLocation.startsWith('/otp') ||
          state.matchedLocation.startsWith('/admin') ||
          state.matchedLocation.startsWith('/verified');
      
      // Basic ban checking logic here if implemented, or assumed elsewhere
      
      if (isLoggedIn && isAuthRoute) {
        return auth.role == 'employer' ? '/employer/dashboard' : '/worker/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashLandingScreen()),
      GoRoute(path: '/role-select', builder: (_, __) => const UserTypeSelectionScreen()),
      GoRoute(path: '/worker/signup', builder: (_, __) => const WorkerSignupScreen()),
      GoRoute(path: '/employer/signup', builder: (_, __) => const EmployerSignupScreen()),
      GoRoute(
        path: '/otp',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, String>? ?? {};
          return fadeInPage(
            state,
            OtpVerificationScreen(
              phone: extra['phone'] ?? '',
              role: extra['role'] ?? 'worker',
              name: extra['name'] ?? '',
              skill: extra['skill'] ?? '',
              experience: extra['experience'] ?? '',
            ),
          );
        },
      ),
      GoRoute(
        path: '/verified', 
        pageBuilder: (context, state) => fadeInPage(state, const VerificationSuccessScreen()),
      ),
      
      // Detailed Views (Full Screen)
      GoRoute(
        path: '/job/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return slideRightPage(state, JobDetailScreen(jobId: id));
        },
      ),
      GoRoute(
        path: '/employer/:uid',
        pageBuilder: (context, state) {
          final uid = state.pathParameters['uid']!;
          return slideRightPage(state, EmployerPublicProfileScreen(employerId: uid));
        },
      ),

      // Worker shell routes
      ShellRoute(
        builder: (context, state, child) {
          final loc = state.matchedLocation;
          int currentIndex = 0;
          if (loc.startsWith('/worker/jobs')) currentIndex = 1;
          if (loc.startsWith('/worker/subscriptions')) currentIndex = 3;
          if (loc.startsWith('/worker/profile')) currentIndex = 4;
          return WorkerShell(currentIndex: currentIndex, child: child);
        },
        routes: [
          GoRoute(path: '/worker/dashboard', builder: (_, __) => const WorkerHomeFeed()),
          GoRoute(path: '/worker/jobs', builder: (_, __) => const WorkerJobsScreen()),
          GoRoute(path: '/worker/subscriptions', builder: (_, __) => const WorkerSubscriptionScreen()),
          GoRoute(path: '/worker/profile', builder: (_, __) => const WorkerProfileScreen()),
        ],
      ),
      // Employer routes
      GoRoute(path: '/employer/dashboard', builder: (_, __) => const EmployerDashboardScreen()),

      // Feed routes
      GoRoute(path: '/feed', builder: (_, __) => const FeedScreen()),
      GoRoute(path: '/feed/create', builder: (_, __) => const CreatePostScreen()),
      GoRoute(
        path: '/feed/post/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return slideRightPage(state, PostDetailScreen(postId: id));
        },
      ),

      // Subscription routes
      GoRoute(path: '/subscription-plans', builder: (_, __) => const SubscriptionPlansScreen()),
      GoRoute(
        path: '/subscription-checkout',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return SubscriptionCheckoutScreen(
            tier: extra['tier'] ?? 'pro',
            priceStr: extra['priceStr'] ?? '₹299',
          );
        },
      ),
      GoRoute(path: '/subscription-success', builder: (_, __) => const SubscriptionSuccessScreen()),

      // Admin routes
      GoRoute(path: '/admin/login', builder: (_, __) => const AdminLoginScreen()),
      GoRoute(path: '/admin/dashboard', builder: (_, __) => const AdminDashboardScreen()),
      GoRoute(path: '/admin/posts', builder: (_, __) => const AdminPostsScreen()),
      GoRoute(path: '/admin/users', builder: (_, __) => const AdminUsersScreen()),

      // Banned Screen
      GoRoute(path: '/banned', builder: (_, __) => const BannedScreen()),
    ],
  );
});
