import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/kolors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/blocking_provider.dart';

class BlockUserDialog extends ConsumerStatefulWidget {
  final int userId;
  final String username;

  const BlockUserDialog({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  ConsumerState<BlockUserDialog> createState() => _BlockUserDialogState();
}

class _BlockUserDialogState extends ConsumerState<BlockUserDialog> {
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _blockUser() async {
    setState(() => _isLoading = true);

    try {
      await ref
          .read(blockedUsersProvider.notifier)
          .blockUser(
            blockedUserId: widget.userId,
            reason: _reasonController.text.isEmpty
                ? null
                : _reasonController.text,
          );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.username} has been blocked'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.block, color: Colors.red, size: 32),
                const SizedBox(width: 12),
                const Text(
                  'Block User',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Are you sure you want to block ${widget.username}?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'They won\'t be able to see your profile or contact you.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _reasonController,
              label: 'Reason (optional)',
              maxLines: 3,
              prefixIcon: Icon(Icons.notes),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _isLoading
                      ? Container(
                          height: 58.h,
                          alignment: Alignment.center,
                          child: LottieLoadingIndicator(),
                        )
                      : CustomButton(
                          text: 'Block',
                          onTap: _isLoading ? null : _blockUser,
                          btnColor: Kolors.kRed,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
