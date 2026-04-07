import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class KIBottomNavBar extends ConsumerWidget {
  final int currentIndex;

  const KIBottomNavBar({super.key, required this.currentIndex});

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.work_outline_rounded, label: 'Jobs'),
    _NavItem(icon: null, label: 'Post'), // FAB center slot
    _NavItem(icon: Icons.card_membership_rounded, label: 'Subscription'),
    _NavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
  ];

  void _onTap(WidgetRef ref, BuildContext context, int index) {
    if (index == currentIndex) return;
    
    final role = ref.read(authProvider)?.role ?? 'worker';

    switch (index) {
      case 0:
        context.go(role == 'employer' ? '/employer/dashboard' : '/worker/dashboard');
        break;
      case 1:
        context.go(role == 'employer' ? '/employer/my-jobs' : '/worker/jobs');
        break;
      case 2:
        context.push('/feed');
        break;
      case 3:
        context.push('/subscription-plans'); // Push overlay or go? Go usually if tab. 
        // We'll use go('/subscription-plans') if we want it as a tab, but it doesn't have a shell route. 
        // Wait, if we use go and it has no shell route, the bottom nav disappears. Let's make it a general push if it's not in the shell, OR add it to the shell.
        // Actually, the user says "subscription opens subscirption page for both workers and employers".
        context.push('/subscription-plans'); 
        break;
      case 4:
        context.go(role == 'employer' ? '/employer/profile' : '/worker/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1), width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_items.length, (i) {
              // Center FAB slot
              if (i == 2) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onTap(ref, context, i),
                    child: Center(
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add_rounded,
                            color: Colors.white, size: 26),
                      ),
                    ),
                  ),
                );
              }

              final selected = currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onTap(ref, context, i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _items[i].icon,
                          color: selected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _items[i].label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: selected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData? icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
