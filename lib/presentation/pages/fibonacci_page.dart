import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test_7_solutions/bloc/fibonacci/fibonacci_bloc.dart';
import 'package:flutter_test_7_solutions/domain/models/fibonacci_item.dart';
import 'dart:math' as math;

import '../widgets/fibonacci_item_widget.dart';

class FibonacciPage extends StatefulWidget {
  const FibonacciPage({super.key});

  @override
  State<FibonacciPage> createState() => _FibonacciPageState();
}

class _FibonacciPageState extends State<FibonacciPage> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToHighlightedItem(List<MapEntry<int, FibonacciItem>> items) {
    final highlightedIndex =
        items.indexWhere((entry) => entry.value.isHighlighted);
    if (highlightedIndex != -1) {
      final screenHeight = MediaQuery.of(context).size.height;
      final appBarHeight = AppBar().preferredSize.height;
      final itemHeight = 88.0;

      // Calculate position to center the item on visible screen area
      final visibleScreenHeight = screenHeight - appBarHeight;
      final offset = (highlightedIndex * itemHeight) -
          (visibleScreenHeight / 2) +
          (itemHeight / 2);

      _scrollController.animateTo(
        math.max(0, offset),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showBottomSheet(BuildContext context, FibonacciState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => BlocProvider.value(
        value: context.read<FibonacciBloc>(),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Selected ${state.selectedType?.toString().split('.').last ?? ''} items',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: state.selectedItems.length,
                  itemBuilder: (context, index) {
                    final entry = state.selectedItems[index];
                    return FibonacciItemWidget(
                      key: ValueKey('selected_${entry.key}'),
                      item: entry.value,
                      index: entry.key,
                      onTap: () {
                        //  bottomsheet ก่อน
                        Navigator.pop(bottomSheetContext);
                        // ส่ง event ย้ายรายการ
                        context
                            .read<FibonacciBloc>()
                            .add(ReturnItemToMain(entry.value, entry.key));
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fibonacci Numbers'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: BlocConsumer<FibonacciBloc, FibonacciState>(
        listener: (context, state) {
          // ตรวจสอบรายการ highlight และ scroll ตำแหน่ง
          final highlightedItem = state.mainItems.firstWhere(
              (entry) => entry.value.isHighlighted,
              orElse: () => state.mainItems.first);

          if (highlightedItem.value.isHighlighted) {
            final index = state.mainItems
                .indexWhere((entry) => entry.key == highlightedItem.key);
            if (index != -1) {
              _scrollController.animateTo(
                index * 88.0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }
          }

          // แสดง bottomsheet เฉพาะเมื่อ flag shouldShowBottomSheet เป็น true
          if (state.shouldShowBottomSheet && state.selectedItems.isNotEmpty) {
            _showBottomSheet(context, state);
          }
        },
        builder: (context, state) {
          if (state.mainItems.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.mainItems.length,
            itemBuilder: (context, index) {
              final entry = state.mainItems[index];
              return FibonacciItemWidget(
                key: ValueKey('main_${entry.key}'),
                item: entry.value,
                index: entry.key,
                onTap: () {
                  context
                      .read<FibonacciBloc>()
                      .add(SelectFibonacciItem(entry.value, entry.key));
                },
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
