import 'package:datadate/core/constants/kolors.dart';
import 'package:datadate/core/widgets/loading_indicator.dart'
    show LottieLoadingIndicator;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/reporting_provider.dart';

class ReportUserDialog extends ConsumerStatefulWidget {
  final int userId;
  final String username;
  final String? messageId;

  const ReportUserDialog({
    super.key,
    required this.userId,
    required this.username,
    this.messageId,
  });

  @override
  ConsumerState<ReportUserDialog> createState() => _ReportUserDialogState();
}

class _ReportUserDialogState extends ConsumerState<ReportUserDialog> {
  final _descriptionController = TextEditingController();
  String _selectedReason = 'spam';
  String _selectedType = 'user';
  bool _isLoading = false;

  final List<Map<String, String>> _reasons = [
    {'value': 'spam', 'label': 'Spam'},
    {'value': 'harassment', 'label': 'Harassment'},
    {'value': 'inappropriate_content', 'label': 'Inappropriate Content'},
    {'value': 'fake_profile', 'label': 'Fake Profile'},
    {'value': 'scam', 'label': 'Scam'},
    {'value': 'other', 'label': 'Other'},
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a description')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref
          .read(myReportsProvider.notifier)
          .createReport(
            reportedUserId: widget.userId,
            reportType: widget.messageId != null ? 'message' : _selectedType,
            reason: _selectedReason,
            description: _descriptionController.text,
            messageId: widget.messageId,
          );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully'),
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
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.flag, color: Colors.orange, size: 32),
                  const SizedBox(width: 12),
                  const Text(
                    'Report User',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Report ${widget.username}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Text(
                'Reason',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedReason,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: _reasons.map((reason) {
                  return DropdownMenuItem(
                    value: reason['value'],
                    child: Text(reason['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedReason = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              if (widget.messageId == null) ...[
                const Text(
                  'Report Type',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('User')),
                    DropdownMenuItem(value: 'profile', child: Text('Profile')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 4,
                prefixIcon: Icon(Icons.description),
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
                            text: 'Submit',
                            onTap: _submitReport,
                            btnColor: Kolors.kDanger,
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
