import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_test_7_solutions/domain/models/fibonacci_item.dart';

// Events
abstract class FibonacciEvent extends Equatable {
  const FibonacciEvent();

  @override
  List<Object> get props => [];
}

class InitializeFibonacci extends FibonacciEvent {}

class SelectFibonacciItem extends FibonacciEvent {
  final FibonacciItem item;
  const SelectFibonacciItem(this.item);

  @override
  List<Object> get props => [item];
}

class ReturnItemToMain extends FibonacciEvent {
  final FibonacciItem item;
  const ReturnItemToMain(this.item);

  @override
  List<Object> get props => [item];
}

class ClearHighlight extends FibonacciEvent {}

// State
class FibonacciState extends Equatable {
  final List<FibonacciItem> mainItems;
  final List<FibonacciItem> selectedItems;
  final FibonacciType? selectedType;

  const FibonacciState({
    this.mainItems = const [],
    this.selectedItems = const [],
    this.selectedType,
  });

  FibonacciState copyWith({
    List<FibonacciItem>? mainItems,
    List<FibonacciItem>? selectedItems,
    FibonacciType? selectedType,
  }) {
    return FibonacciState(
      mainItems: mainItems ?? this.mainItems,
      selectedItems: selectedItems ?? this.selectedItems,
      selectedType: selectedType ?? this.selectedType,
    );
  }

  @override
  List<Object?> get props => [mainItems, selectedItems, selectedType];
}

// BLoC
class FibonacciBloc extends Bloc<FibonacciEvent, FibonacciState> {
  FibonacciBloc() : super(const FibonacciState()) {
    on<InitializeFibonacci>(_onInitialize);
    on<SelectFibonacciItem>(_onSelectItem);
    on<ReturnItemToMain>(_onReturnItem);
    on<ClearHighlight>(_onClearHighlight);
  }

  List<int> _generateFibonacci(int count) {
    List<int> fibonacci = [0, 1];
    for (int i = 2; i < count; i++) {
      fibonacci.add(fibonacci[i - 1] + fibonacci[i - 2]);
    }
    return fibonacci;
  }

  FibonacciType _getTypeForNumber(int number) {
    if (number % 3 == 0) return FibonacciType.circle;
    if (number % 3 == 1) return FibonacciType.square;
    return FibonacciType.cross; // remainder 2 should be cross
  }

  void _onInitialize(InitializeFibonacci event, Emitter<FibonacciState> emit) {
    final fibonacci = _generateFibonacci(41);
    final items = fibonacci.map((number) {
      return FibonacciItem(
        number: number,
        type: _getTypeForNumber(number),
      );
    }).toList();

    emit(state.copyWith(mainItems: items));
  }

  void _onSelectItem(SelectFibonacciItem event, Emitter<FibonacciState> emit) {
    // Find all items of the same type
    final itemsOfSameType =
        state.mainItems.where((item) => item.type == event.item.type).toList();

    // Remove selected items from main list
    final remainingItems =
        state.mainItems.where((item) => item.type != event.item.type).toList();

    emit(state.copyWith(
      mainItems: remainingItems,
      selectedItems: itemsOfSameType,
      selectedType: event.item.type,
    ));
  }

  void _onReturnItem(ReturnItemToMain event, Emitter<FibonacciState> emit) {
    // Remove item from selected items
    final newSelectedItems = state.selectedItems
        .where((item) => item.number != event.item.number)
        .toList();

    // Add item back to main items with highlight
    final highlightedItem = event.item.copyWith(isHighlighted: true);
    final newMainItems = [...state.mainItems, highlightedItem]
      ..sort((a, b) => a.number.compareTo(b.number)); // Keep sorted order

    emit(state.copyWith(
      mainItems: newMainItems,
      selectedItems: newSelectedItems,
      selectedType: newSelectedItems.isEmpty ? null : state.selectedType,
    ));

    // Clear highlight after a delay
    Future.delayed(const Duration(seconds: 2), () {
      add(ClearHighlight());
    });
  }

  void _onClearHighlight(ClearHighlight event, Emitter<FibonacciState> emit) {
    final updatedMainItems = state.mainItems
        .map((item) => item.copyWith(isHighlighted: false))
        .toList();

    emit(state.copyWith(mainItems: updatedMainItems));
  }
}
