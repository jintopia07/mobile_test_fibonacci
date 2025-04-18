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

  void _scrollToHighlightedItem(List<FibonacciItem> items) {
    final highlightedIndex = items.indexWhere((item) => item.isHighlighted);
    if (highlightedIndex != -1) {
      _scrollController.animateTo(
        highlightedIndex * 88.0, // Approximate height of each item
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showBottomSheet(BuildContext context, FibonacciState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Selected ${state.selectedType?.toString().split('.').last ?? ''} items',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.selectedItems.length,
            itemBuilder: (context, index) {
              final item = state.selectedItems[index];
              return FibonacciItemWidget(
                key: ValueKey(item.number),
                item: item,
                index: index,
                onTap: () {
                  context.read<FibonacciBloc>().add(ReturnItemToMain(item));
                  Navigator.pop(context);
                },
              );
            },
          ),
        ],
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
          if (state.mainItems.any((item) => item.isHighlighted)) {
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
              final item = state.mainItems[index];
              return FibonacciItemWidget(
                key: ValueKey(item.number),
                item: item,
                index: index,
                onTap: () {
                  context.read<FibonacciBloc>().add(SelectFibonacciItem(item));
                  _showBottomSheet(context, state);
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
