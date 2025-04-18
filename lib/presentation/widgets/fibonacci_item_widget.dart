import 'package:flutter/material.dart';
import 'package:flutter_test_7_solutions/domain/models/fibonacci_item.dart';

class FibonacciItemWidget extends StatelessWidget {
  final FibonacciItem item;
  final VoidCallback onTap;
  final int index;

  const FibonacciItemWidget({
    super.key,
    required this.item,
    required this.onTap,
    required this.index,
  });

  Color _getBackgroundColor() {
    if (item.isHighlighted) {
      return Colors.yellow.shade200; // Highlight color
    }
    switch (item.type) {
      case FibonacciType.circle:
        return Colors.blue.shade100;
      case FibonacciType.square:
        return Colors.green.shade100;
      case FibonacciType.cross:
        return Colors.red.shade100;
    }
  }

  Widget _buildTypeIcon() {
    IconData iconData;
    Color iconColor;

    switch (item.type) {
      case FibonacciType.circle:
        iconData = Icons.circle_outlined;
        iconColor = Colors.blue;
        break;
      case FibonacciType.square:
        iconData = Icons.square_outlined;
        iconColor = Colors.green;
        break;
      case FibonacciType.cross:
        iconData = Icons.close;
        iconColor = Colors.red;
        break;
    }

    return Icon(
      iconData,
      color: iconColor,
      size: 24,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: item.isHighlighted ? 4 : 0, // เล่ม elevation เมื่อ highlight
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(12),
            border: item.isHighlighted
                ? Border.all(
                    color: Colors.orange, width: 2) // เล่มขอบเมื่อ highlight
                : null,
          ),
          child: Row(
            children: [
              Text(
                'Index: $index',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 24),
              Text(
                'Number: ${item.number}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              _buildTypeIcon(),
            ],
          ),
        ),
      ),
    );
  }
}
