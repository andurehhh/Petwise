import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:petwise/providers/activity_provider.dart';
import 'package:petwise/data/models/activity_model.dart';
import 'package:petwise/presentation/widgets/petwise_dynamic_activity_card.dart';

class FadingActivityCard extends StatefulWidget {
  final ActivityModel activity;
  final VoidCallback onTap;

  const FadingActivityCard({
    super.key,
    required this.activity,
    required this.onTap,
  });

  @override
  State<FadingActivityCard> createState() => _FadingActivityCardState();
}

class _FadingActivityCardState extends State<FadingActivityCard> {
  bool _completing = false;

  void _handleComplete() async {
    setState(() => _completing = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      context.read<ActivityProvider>().toggleCompletion(widget.activity.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _completing ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 400),
      child: GestureDetector(
        onTap: widget.onTap,
        child: DynamicActivityCard(
          activity: widget.activity,
          onComplete: _handleComplete,
        ),
      ),
    );
  }
}