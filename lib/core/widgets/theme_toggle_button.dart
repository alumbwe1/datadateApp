import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/theme_provider.dart';
import '../theme/theme_extensions.dart';

class ThemeToggleButton extends ConsumerWidget {
  final bool showLabel;
  final double? iconSize;

  const ThemeToggleButton({super.key, this.showLabel = false, this.iconSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    if (showLabel) {
      return ListTile(
        leading: Icon(
          isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
          color: context.primaryColor,
          size: iconSize ?? 24.sp,
        ),
        title: Text(
          isDarkMode ? 'Light Mode' : 'Dark Mode',
          style: context.bodyMedium,
        ),
        trailing: Switch.adaptive(
          value: isDarkMode,
          onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
          activeThumbColor: context.primaryColor,
        ),
        onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
      );
    }

    return IconButton(
      onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return RotationTransition(turns: animation, child: child);
        },
        child: Icon(
          isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
          key: ValueKey(isDarkMode),
          color: context.primaryColor,
          size: iconSize ?? 24.sp,
        ),
      ),
      tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
    );
  }
}
