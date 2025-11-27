import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'premium_bottom_sheet.dart';

class ChatOptionsSheet {
  static void show({
    required BuildContext context,
    required VoidCallback onViewProfile,
    required VoidCallback onMuteNotifications,
    required VoidCallback onBlockUser,
    required VoidCallback onReportUser,
  }) {
    final options = <BottomSheetOption>[
      BottomSheetOption(
        icon: Iconsax.user_copy,
        title: 'View Profile',
        color: Colors.blue,
        onTap: onViewProfile,
      ),
      BottomSheetOption(
        icon: IconlyLight.notification,
        title: 'Mute Notifications',
        color: Colors.purple,
        onTap: onMuteNotifications,
      ),
      BottomSheetOption(
        icon: Icons.block_outlined,
        title: 'Block User',
        color: Colors.orange,
        onTap: onBlockUser,
      ),
      BottomSheetOption(
        icon: Icons.report_outlined,
        title: 'Report User',
        color: Colors.red,
        isDestructive: true,
        onTap: onReportUser,
      ),
    ];

    PremiumBottomSheet.show(context: context, options: options);
  }
}
