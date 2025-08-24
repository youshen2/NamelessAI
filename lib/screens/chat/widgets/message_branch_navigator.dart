import 'package:flutter/material.dart';

class MessageBranchNavigator extends StatelessWidget {
  final int branchCount;
  final int activeBranchIndex;
  final ValueChanged<int> onBranchChange;

  const MessageBranchNavigator({
    super.key,
    required this.branchCount,
    required this.activeBranchIndex,
    required this.onBranchChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed: activeBranchIndex > 0
                ? () => onBranchChange(activeBranchIndex - 1)
                : null,
            splashRadius: 18,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
          Text(
            '${activeBranchIndex + 1}/$branchCount',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            onPressed: activeBranchIndex < branchCount - 1
                ? () => onBranchChange(activeBranchIndex + 1)
                : null,
            splashRadius: 18,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
