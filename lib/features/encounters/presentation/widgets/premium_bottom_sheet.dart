import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/constants/app_style.dart';

class PremiumBottomSheet extends StatefulWidget {
  const PremiumBottomSheet({super.key});

  @override
  State<PremiumBottomSheet> createState() => _PremiumBottomSheetState();
}

class _PremiumBottomSheetState extends State<PremiumBottomSheet> {
  bool _isStandard = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          _buildDragHandle(),
          _buildHeader(),
          Expanded(child: _buildContent()),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Column(
        children: [
          Text(
            'Upgrade Plan',
            style: appStyle(
              24,
              Colors.black,
              FontWeight.w700,
            ).copyWith(letterSpacing: -0.3),
          ),
          const SizedBox(height: 16),
          _buildPlanToggle(),
        ],
      ),
    );
  }

  Widget _buildPlanToggle() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.48,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildToggleOption('Standard', true),
          _buildToggleOption('Premium', false),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, bool isStandard) {
    final isSelected = _isStandard == isStandard;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isStandard = isStandard),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: appStyle(
              15,
              isSelected ? Colors.white : Colors.black,
              FontWeight.w600,
            ).copyWith(letterSpacing: -0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlanTitle(),
          const SizedBox(height: 16),
          _buildPricing(),
          const SizedBox(height: 32),
          ..._buildFeatures(),
        ],
      ),
    );
  }

  Widget _buildPlanTitle() {
    return Row(
      children: [
        Text(
          _isStandard ? 'Standard' : 'Premium',
          style: appStyle(
            32,
            Colors.black,
            FontWeight.w900,
          ).copyWith(letterSpacing: -0.3),
        ),
        if (!_isStandard) ...[
          const SizedBox(width: 8),
          const Icon(Icons.verified, size: 24),
          const SizedBox(width: 4),
          const Icon(Iconsax.diamonds, color: Colors.purpleAccent, size: 24),
        ],
      ],
    );
  }

  Widget _buildPricing() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _isStandard ? 'K10' : 'K100',
          style: appStyle(48, Colors.black, FontWeight.bold),
        ),
        Text('/week', style: appStyle(16, Colors.grey[600]!, FontWeight.w400)),
      ],
    );
  }

  List<Widget> _buildFeatures() {
    final features = _isStandard
        ? [
            'Unlimited swipes',
            'See who likes you',
            'Rewind last swipe',
            '5 Super Likes per day',
          ]
        : [
            'Everything in Standard',
            'Unlimited Super Likes',
            'Tired of broke girlfriends or boyfriends? Meet Zambia\'s elite only',
            'Match with verified rich singles',
            'VIP badge on your profile',
            'Top priority in search results',
            'Access the exclusive rich community',
          ];

    return features
        .map(
          (feature) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    feature,
                    style: appStyle(15, Colors.black87, FontWeight.w400),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${_isStandard ? "Standard" : "Premium"} plan activated!',
                        style: appStyle(14, Colors.white, FontWeight.w600),
                      ),
                      backgroundColor: Colors.black,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                child: Text(
                  'Subscribe Now',
                  style: appStyle(16, Colors.white, FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Cancel anytime • Secure payment',
              style: appStyle(
                12,
                Colors.grey[500]!,
                FontWeight.w400,
              ).copyWith(letterSpacing: -0.2),
            ),
          ],
        ),
      ),
    );
  }
}
