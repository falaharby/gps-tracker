import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/tracking_controller.dart';

class SearchResultsWidget extends StatelessWidget {
  final Function(double, double, String) onResultSelected;

  const SearchResultsWidget({
    Key? key,
    required this.onResultSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TrackingController>(
      builder: (context, controller, _) {
        final state = controller.searchState;

        // Show error
        if (state.error != null && state.results.isEmpty) {
          return Container(
            margin: const EdgeInsets.only(top: 8.0),
            child: Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text(state.error!)),
                  ],
                ),
              ),
            ),
          );
        }

        // Show results
        if (state.results.isNotEmpty) {
          return Container(
            margin: const EdgeInsets.only(top: 8.0),
            constraints: const BoxConstraints(maxHeight: 250),
            child: Card(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: state.results.length,
                itemBuilder: (context, index) {
                  final result = state.results[index];
                  return ListTile(
                    title: Text(result.displayName),
                    onTap: () {
                      onResultSelected(result.latitude, result.longitude, result.displayName);
                      controller.clearSearchResults();
                    },
                  );
                },
              ),
            ),
          );
        }

        return SizedBox.shrink();
      },
    );
  }
}
