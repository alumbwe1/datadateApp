import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import 'premium_bottom_sheet.dart';

class MessageOptionsSheet {
  static void show({
    required BuildContext context,
    required dynamic message,
    required bool isSent,
    required Function(dynamic) onEdit,
    required Function(dynamic) onDelete,
  }) {
    final options = <BottomSheetOption>[
      BottomSheetOption(
        icon: Iconsax.copy_copy,
        title: 'Copy Message',
        color: Colors.blue,
        onTap: () {
          Clipboard.setData(ClipboardData(text: message.content));
          CustomSnackbar.show(
            context,
            message: 'Message copied to clipboard',
            type: SnackbarType.info,
            duration: const Duration(seconds: 2),
          );
        },
      ),
      if (isSent) ...[
        BottomSheetOption(
          icon: Icons.edit_outlined,
          title: 'Edit Message',
          color: Colors.orange,
          onTap: () => onEdit(message),
        ),
        BottomSheetOption(
          icon: Icons.delete_outline,
          title: 'Delete Message',
          color: Colors.red,
          isDestructive: true,
          onTap: () => onDelete(message),
        ),
      ],
    ];

    PremiumBottomSheet.show(context: context, options: options);
  }
}
