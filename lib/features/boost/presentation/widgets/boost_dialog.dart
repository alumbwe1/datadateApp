import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/boost_provider.dart';

class BoostDialog extends ConsumerStatefulWidget {
  const BoostDialog({super.key});

  @override
  ConsumerState<BoostDialog> createState() => _BoostDialogState();
}

class _BoostDialogState extends ConsumerState<BoostDialog> {
  final _amountController = TextEditingController();
  final _targetViewsController = TextEditingController();
  final _durationController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _targetViewsController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _createBoost() async {
    final amount = double.tryParse(_amountController.text);
    final targetViews = int.tryParse(_targetViewsController.text);
    final duration = int.tryParse(_durationController.text);

    if (amount == null || targetViews == null || duration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref
          .read(activeBoostProvider.notifier)
          .createBoost(
            amountPaid: amount,
            targetViews: targetViews,
            durationHours: duration,
          );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Boost created! Complete payment to activate.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pricingAsync = ref.watch(boostPricingProvider);

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
                const Icon(
                  Icons.rocket_launch,
                  color: AppColors.primaryLight,
                  size: 32,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Boost Your Profile',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            pricingAsync.when(
              data: (pricing) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Minimum: ${pricing.currency} ${pricing.minAmount}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    'Default Duration: ${pricing.defaultDurationHours} hours',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error loading pricing: $e'),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _amountController,
              label: 'Amount (ZMW)',
              keyboardType: TextInputType.number,
              prefixIcon: Icon(Icons.attach_money),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _targetViewsController,
              label: 'Target Views',
              keyboardType: TextInputType.number,
              prefixIcon: Icon(Icons.visibility),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _durationController,
              label: 'Duration (hours)',
              keyboardType: TextInputType.number,
              prefixIcon: Icon(Icons.timer),
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
                  child: CustomButton(
                    text: 'Create Boost',
                    onPressed: _isLoading ? null : _createBoost,
                    isLoading: _isLoading,
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
