import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/skeleton/skeleton_bloc.dart';
import '../blocs/skeleton/skeleton_event.dart';
import '../blocs/skeleton/skeleton_state.dart';
import 'skeleton_loading.dart';

/// A generic skeleton loading widget that uses BLoC to manage loading states
class SkeletonWidget<T> extends StatelessWidget {
  /// Function to fetch data
  final Future<T> Function() fetchData;
  
  /// Widget to display when data is loaded
  final Widget Function(BuildContext, T) builder;
  
  /// Loading widget to display
  final Widget loadingWidget;
  
  /// Error widget to display
  final Widget Function(BuildContext, String)? errorWidget;
  
  /// Whether to automatically load data on initialization
  final bool autoLoad;

  const SkeletonWidget({
    Key? key,
    required this.fetchData,
    required this.builder,
    required this.loadingWidget,
    this.errorWidget,
    this.autoLoad = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = SkeletonBloc(fetchData: fetchData);
        if (autoLoad) {
          bloc.add(LoadData());
        }
        return bloc;
      },
      child: BlocBuilder<SkeletonBloc, SkeletonState>(
        builder: (context, state) {
          if (state is SkeletonLoading) {
            return loadingWidget;
          } else if (state is SkeletonLoaded) {
            return builder(context, state.data as T);
          } else if (state is SkeletonError) {
            return errorWidget != null
                ? errorWidget!(context, state.message)
                : Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  );
          }
          return loadingWidget;
        },
      ),
    );
  }
}

/// Example usage of SkeletonWidget with health recovery items
class HealthRecoveryListSkeleton extends StatelessWidget {
  final Future<List<dynamic>> Function() fetchHealthRecoveries;

  const HealthRecoveryListSkeleton({
    Key? key,
    required this.fetchHealthRecoveries,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SkeletonWidget<List<dynamic>>(
      fetchData: fetchHealthRecoveries,
      loadingWidget: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            4,
            (_) => const RecoveryItemSkeleton(),
          ),
        ),
      ),
      builder: (context, healthRecoveries) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: healthRecoveries.map((recovery) {
              // Replace with your actual health recovery widget
              return Text(recovery.toString());
            }).toList(),
          ),
        );
      },
    );
  }
}