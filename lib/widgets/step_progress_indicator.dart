import 'package:flutter/material.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            final isCurrent = index == currentStep;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 3,
                      decoration: BoxDecoration(
                        color: isCompleted || isCurrent
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (index < totalSteps - 1) const SizedBox(width: 8),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStepLabel(
              context,
              'Pickup',
              0,
              Icons.location_on_outlined,
            ),
            _buildStepLabel(
              context,
              'Delivery',
              1,
              Icons.local_shipping_outlined,
            ),
            _buildStepLabel(
              context,
              'Review',
              2,
              Icons.rate_review_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepLabel(
    BuildContext context,
    String label,
    int step,
    IconData icon,
  ) {
    final isCompleted = step < currentStep;
    final isCurrent = step == currentStep;
    final color = isCompleted || isCurrent
        ? Theme.of(context).colorScheme.primary
        : Colors.grey;

    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: TextStyle(
        color: color,
        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
        fontSize: 14,
      ),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCompleted
                  ? Theme.of(context).colorScheme.primary
                  : isCurrent
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: isCompleted
                  ? Colors.white
                  : isCurrent
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}
