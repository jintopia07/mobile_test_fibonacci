import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/fibonacci/fibonacci_bloc.dart';
import '../widgets/fibonacci_item_widget.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FibonacciBloc, FibonacciState>(
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              ListView.builder(
                itemCount: state.mainItems.length,
                itemBuilder: (context, index) {
                  final item = state.mainItems[index];
                  return FibonacciItemWidget(
                    item: item,
                    index: index,
                    onTap: () {
                      context
                          .read<FibonacciBloc>()
                          .add(SelectFibonacciItem(item));
                    },
                  );
                },
              ),
              if (state.selectedItems.isNotEmpty)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
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
                              item: item,
                              index: index,
                              onTap: () {}, // Disabled tap in bottom sheet
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
