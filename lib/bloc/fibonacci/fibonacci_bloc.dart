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
  final int index;

  const SelectFibonacciItem(this.item, this.index);

  @override
  List<Object> get props => [item, index];
}

class ReturnItemToMain extends FibonacciEvent {
  final FibonacciItem item;
  final int index;

  const ReturnItemToMain(this.item, this.index);

  @override
  List<Object> get props => [item, index];
}

class ClearHighlight extends FibonacciEvent {}

// State
class FibonacciState extends Equatable {
  final List<MapEntry<int, FibonacciItem>>
      mainItems; // Changed to store index with item
  final List<MapEntry<int, FibonacciItem>> selectedItems;
  final FibonacciType? selectedType;
  final bool shouldShowBottomSheet;

  const FibonacciState({
    this.mainItems = const [],
    this.selectedItems = const [],
    this.selectedType,
    this.shouldShowBottomSheet = false,
  });

  FibonacciState copyWith({
    List<MapEntry<int, FibonacciItem>>? mainItems,
    List<MapEntry<int, FibonacciItem>>? selectedItems,
    FibonacciType? selectedType,
    bool? shouldShowBottomSheet,
  }) {
    return FibonacciState(
      mainItems: mainItems ?? this.mainItems,
      selectedItems: selectedItems ?? this.selectedItems,
      selectedType: selectedType ?? this.selectedType,
      shouldShowBottomSheet:
          shouldShowBottomSheet ?? this.shouldShowBottomSheet,
    );
  }

  @override
  List<Object?> get props =>
      [mainItems, selectedItems, selectedType, shouldShowBottomSheet];
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
    final items = fibonacci.asMap().entries.map((entry) {
      return MapEntry(
        entry.key,
        FibonacciItem(
          number: entry.value,
          type: _getTypeForNumber(entry.value),
        ),
      );
    }).toList();

    emit(state.copyWith(mainItems: items));
  }

  void _onSelectItem(SelectFibonacciItem event, Emitter<FibonacciState> emit) {
    // ตรวจสอบว่า item อยู่ใน selectedItems ั้น
    final isInSelectedItems =
        state.selectedItems.any((entry) => entry.key == event.index);

    if (isInSelectedItems) {
      // ถ้าอยู่ใน selectedItems แล้ว เพียงแค่<lemmaท highlight
      final updatedSelectedItems = state.selectedItems.map((entry) {
        // ถ้าเป็น item <lemma <lemma ให้ highlight
        if (entry.key == event.index) {
          return MapEntry(entry.key, entry.value.copyWith(isHighlighted: true));
        }
        // ถ้าไม่ใช่ ให้ลบ highlight
        return MapEntry(entry.key, entry.value.copyWith(isHighlighted: false));
      }).toList();

      // เรียงลำ scouting ใหม่ให้ item <lemma highlight อยู่ในตำแหน่ง<lemma
      updatedSelectedItems.sort((a, b) => a.key.compareTo(b.key));

      emit(state.copyWith(
        selectedItems: updatedSelectedItems,
      ));
      return;
    }

    // ลบ item ใหม่จาก main list
    final currentSelectedItems = state.selectedItems
        .map((e) => MapEntry(e.key, e.value.copyWith(isHighlighted: false)))
        .toList();

    final selectedEntry =
        MapEntry(event.index, event.item.copyWith(isHighlighted: true));

    if (state.selectedItems.isEmpty) {
      final remainingItems =
          state.mainItems.where((entry) => entry.key != event.index).toList();

      emit(state.copyWith(
        mainItems: remainingItems,
        selectedItems: [selectedEntry],
        selectedType: event.item.type,
        shouldShowBottomSheet: true, // เernessการ seriousness
      ));
    } else {
      if (state.selectedType != event.item.type) {
        final updatedMainItems = [...state.mainItems];
        updatedMainItems.addAll(currentSelectedItems);
        updatedMainItems.sort((a, b) => a.key.compareTo(b.key));

        final newRemainingItems = updatedMainItems
            .where((entry) => entry.key != event.index)
            .toList();

        emit(state.copyWith(
          mainItems: newRemainingItems,
          selectedItems: [selectedEntry],
          selectedType: event.item.type,
        ));
      } else {
        final remainingItems =
            state.mainItems.where((entry) => entry.key != event.index).toList();

        final newSelectedItems = [...currentSelectedItems, selectedEntry];
        // เรียงลำ scouting ตาม index เลือก<lemmaลำ scouting แสดงผล
        newSelectedItems.sort((a, b) => a.key.compareTo(b.key));

        emit(state.copyWith(
          mainItems: remainingItems,
          selectedItems: newSelectedItems,
          selectedType: event.item.type,
        ));
      }
    }
  }

  void _onReturnItem(ReturnItemToMain event, Emitter<FibonacciState> emit) {
    final updatedMainItems = state.mainItems.map((entry) {
      return MapEntry(entry.key, entry.value.copyWith(isHighlighted: false));
    }).toList();

    final returningEntry =
        MapEntry(event.index, event.item.copyWith(isHighlighted: true));

    final newMainItems = [...updatedMainItems, returningEntry];
    newMainItems.sort((a, b) => a.key.compareTo(b.key));

    final remainingSelectedItems =
        state.selectedItems.where((entry) => entry.key != event.index).toList();

    emit(state.copyWith(
      mainItems: newMainItems,
      selectedItems: remainingSelectedItems,
      selectedType: remainingSelectedItems.isEmpty ? null : state.selectedType,
      shouldShowBottomSheet: false, // เปลี่ยนเป็น false  เมื่อ return item
    ));

    Future.delayed(const Duration(seconds: 2), () {
      add(ClearHighlight());
    });
  }

  void _onClearHighlight(ClearHighlight event, Emitter<FibonacciState> emit) {
    emit(state.copyWith(selectedType: null));
  }
}
