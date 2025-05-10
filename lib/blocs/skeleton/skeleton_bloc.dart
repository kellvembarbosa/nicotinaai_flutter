import 'package:flutter_bloc/flutter_bloc.dart';

import 'skeleton_event.dart';
import 'skeleton_state.dart';

class SkeletonBloc extends Bloc<SkeletonEvent, SkeletonState> {
  final Future<dynamic> Function() fetchData;
  
  SkeletonBloc({required this.fetchData}) : super(SkeletonLoading()) {
    on<LoadData>(_onLoadData);
    on<ReloadData>(_onReloadData);
  }
  
  Future<void> _onLoadData(LoadData event, Emitter<SkeletonState> emit) async {
    emit(SkeletonLoading());
    
    try {
      final data = await fetchData();
      emit(SkeletonLoaded(data: data));
    } catch (e) {
      emit(SkeletonError(message: e.toString()));
    }
  }
  
  Future<void> _onReloadData(ReloadData event, Emitter<SkeletonState> emit) async {
    // Keep current state visible while loading in background
    final currentState = state;
    
    try {
      final data = await fetchData();
      emit(SkeletonLoaded(data: data));
    } catch (e) {
      // Only show error if we're not already displaying data
      if (currentState is! SkeletonLoaded) {
        emit(SkeletonError(message: e.toString()));
      } else {
        // Keep showing old data but log error
        print('Error reloading data: ${e.toString()}');
      }
    }
  }
}