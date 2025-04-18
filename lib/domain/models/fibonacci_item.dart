import 'package:equatable/equatable.dart';

enum FibonacciType { circle, square, cross }

class FibonacciItem extends Equatable {
  final int number;
  final FibonacciType type;
  final bool isHighlighted;

  const FibonacciItem({
    required this.number,
    required this.type,
    this.isHighlighted = false,
  });

  FibonacciItem copyWith({
    int? number,
    FibonacciType? type,
    bool? isHighlighted,
  }) {
    return FibonacciItem(
      number: number ?? this.number,
      type: type ?? this.type,
      isHighlighted: isHighlighted ?? this.isHighlighted,
    );
  }

  @override
  List<Object?> get props => [number, type, isHighlighted];
}
