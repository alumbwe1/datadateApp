import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
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
        icon: IconlyLight.notification,
        title: 'Mute Notifications',

        onTap: onMuteNotifications,
      ),
      BottomSheetOption(
        icon: Icons.block_outlined,
        title: 'Block User',

        onTap: onBlockUser,
      ),
      BottomSheetOption(
        icon: Icons.report_outlined,
        title: 'Report User',

        isDestructive: true,
        onTap: onReportUser,
      ),
    ];

    PremiumBottomSheet.show(context: context, options: options);
  }
}
