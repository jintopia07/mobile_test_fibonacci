import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test_7_solutions/bloc/fibonacci/fibonacci_bloc.dart';
import 'package:flutter_test_7_solutions/domain/models/fibonacci_item.dart';

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            highlightedIndex * 88.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _showBottomSheet(BuildContext context, FibonacciState state) {
    if (!state.shouldShowBottomSheet) return;

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
        child: BlocListener<FibonacciBloc, FibonacciState>(
          listener: (context, state) {
            //  bottomsheet  เมื่อ  รายการ
            if (state.shouldShowBottomSheet == false) {
              Navigator.pop(bottomSheetContext);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
          // เล่มเงือนไขตรวจสอบและ bottomsheet
          if (state.selectedItems.isEmpty && state.mainItems.isNotEmpty) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }

          if (state.selectedItems.isNotEmpty && state.shouldShowBottomSheet) {
            _showBottomSheet(context, state);
          }
          if (state.mainItems.any((entry) => entry.value.isHighlighted)) {
            _scrollToHighlightedItem(state.mainItems);
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
                key: ValueKey(entry.key),
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
