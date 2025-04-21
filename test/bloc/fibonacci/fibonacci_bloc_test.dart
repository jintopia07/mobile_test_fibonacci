import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_7_solutions/bloc/fibonacci/fibonacci_bloc.dart';
import 'package:flutter_test_7_solutions/domain/models/fibonacci_item.dart';

void main() {
  late FibonacciBloc fibonacciBloc;

  setUp(() {
    fibonacciBloc = FibonacciBloc();
  });

  tearDown(() {
    fibonacciBloc.close();
  });

  test('initial state should be empty', () {
    expect(fibonacciBloc.state.mainItems, isEmpty);
    expect(fibonacciBloc.state.selectedItems, isEmpty);
    expect(fibonacciBloc.state.selectedType, isNull);
    expect(fibonacciBloc.state.shouldShowBottomSheet, isFalse);
  });

  group('InitializeFibonacci', () {
    test('should generate correct Fibonacci sequence', () {
      // Act
      fibonacciBloc.add(InitializeFibonacci());

      // Assert
      expectLater(
        fibonacciBloc.stream,
        emits(predicate<FibonacciState>((state) {
          final items = state.mainItems;
          expect(items.length, equals(41));
          expect(items[0].value.number, equals(0));
          expect(items[1].value.number, equals(1));
          expect(items[2].value.number, equals(1));
          expect(items[3].value.number, equals(2));
          expect(items[4].value.number, equals(3));
          return true;
        })),
      );
    });

    test('should assign correct types to numbers', () {
      // Act
      fibonacciBloc.add(InitializeFibonacci());

      // Assert
      expectLater(
        fibonacciBloc.stream,
        emits(predicate<FibonacciState>((state) {
          final items = state.mainItems;
          // Check type for number divisible by 3 (circle)
          expect(items[4].value.type, equals(FibonacciType.circle)); // 3
          // Check type for number with remainder 1 (square)
          expect(items[1].value.type, equals(FibonacciType.square)); // 1
          // Check type for number with remainder 2 (cross)
          expect(items[3].value.type, equals(FibonacciType.cross)); // 2
          return true;
        })),
      );
    });
  });

  group('SelectFibonacciItem', () {
    setUp(() {
      fibonacciBloc.add(InitializeFibonacci());
    });

    test('should select first item correctly', () async {
      // Wait for initialization
      await expectLater(fibonacciBloc.stream, emits(anything));

      // Select first item
      final firstItem = fibonacciBloc.state.mainItems[0];
      fibonacciBloc.add(SelectFibonacciItem(firstItem.value, firstItem.key));

      await expectLater(
        fibonacciBloc.stream,
        emits(predicate<FibonacciState>((state) {
          expect(state.selectedItems.length, equals(1));
          expect(state.selectedItems[0].value.isHighlighted, isTrue);
          expect(state.selectedType, equals(firstItem.value.type));
          expect(state.shouldShowBottomSheet, isTrue);
          return true;
        })),
      );
    });

    test('should add item of same type', () async {
      // Wait for initialization
      await expectLater(fibonacciBloc.stream, emits(anything));

      // Find two items of same type
      final items = fibonacciBloc.state.mainItems;
      final firstCircleItem =
          items.firstWhere((e) => e.value.type == FibonacciType.circle);
      final secondCircleItem = items.firstWhere((e) =>
          e.value.type == FibonacciType.circle && e.key != firstCircleItem.key);

      // Select first circle item
      fibonacciBloc
          .add(SelectFibonacciItem(firstCircleItem.value, firstCircleItem.key));
      await expectLater(fibonacciBloc.stream, emits(anything));

      // Select second circle item
      fibonacciBloc.add(
          SelectFibonacciItem(secondCircleItem.value, secondCircleItem.key));

      await expectLater(
        fibonacciBloc.stream,
        emits(predicate<FibonacciState>((state) {
          expect(state.selectedItems.length, equals(2));
          expect(state.selectedType, equals(FibonacciType.circle));
          expect(
            state.selectedItems
                .every((item) => item.value.type == FibonacciType.circle),
            isTrue,
          );
          return true;
        })),
      );
    });

    test('should start new selection when different type is selected',
        () async {
      // Wait for initialization
      await expectLater(fibonacciBloc.stream, emits(anything));

      // Select circle item
      final circleItem = fibonacciBloc.state.mainItems
          .firstWhere((e) => e.value.type == FibonacciType.circle);
      fibonacciBloc.add(SelectFibonacciItem(circleItem.value, circleItem.key));
      await expectLater(fibonacciBloc.stream, emits(anything));

      // Select square item
      final squareItem = fibonacciBloc.state.mainItems
          .firstWhere((e) => e.value.type == FibonacciType.square);
      fibonacciBloc.add(SelectFibonacciItem(squareItem.value, squareItem.key));

      await expectLater(
        fibonacciBloc.stream,
        emits(predicate<FibonacciState>((state) {
          expect(state.selectedItems.length, equals(1));
          expect(state.selectedType, equals(FibonacciType.square));
          expect(
              state.selectedItems[0].value.type, equals(FibonacciType.square));
          return true;
        })),
      );
    });
  });

  group('ReturnItemToMain', () {
    test('should return item to main list correctly', () async {
      // Initialize
      fibonacciBloc.add(InitializeFibonacci());
      await expectLater(fibonacciBloc.stream, emits(anything));

      // Get the first item to test with
      final firstItem = fibonacciBloc.state.mainItems[0];
      print(
          'Selected item: ${firstItem.value.number} at index ${firstItem.key}');

      // Select the item
      fibonacciBloc.add(SelectFibonacciItem(firstItem.value, firstItem.key));
      await expectLater(
        fibonacciBloc.stream,
        emits(predicate<FibonacciState>((state) {
          print(
              'Selection state - Selected items: ${state.selectedItems.length}');
          return state.selectedItems.length == 1 &&
              state.selectedItems[0].key == firstItem.key;
        })),
      );

      // Return the item
      fibonacciBloc.add(ReturnItemToMain(firstItem.value, firstItem.key));
      await expectLater(
        fibonacciBloc.stream,
        emits(predicate<FibonacciState>((state) {
          print(
              'Return state - Main items: ${state.mainItems.length}, Selected items: ${state.selectedItems.length}');

          // Verify conditions one by one for better error reporting
          if (state.selectedItems.isNotEmpty) {
            return false;
          }
          if (state.selectedType != null) {
            print('Selected type is not null: ${state.selectedType}');
            return false;
          }
          if (state.shouldShowBottomSheet) {
            return false;
          }

          final returnedItem = state.mainItems.firstWhere(
            (item) => item.key == firstItem.key,
            orElse: () =>
                throw StateError('Returned item not found in main items'),
          );

          return returnedItem.value.isHighlighted &&
              returnedItem.value.number == firstItem.value.number;
        })),
      );
    });
  });
}
