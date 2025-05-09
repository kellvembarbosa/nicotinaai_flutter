abstract class SkeletonState {}

class SkeletonLoading extends SkeletonState {}

class SkeletonLoaded extends SkeletonState {
  final dynamic data;
  
  SkeletonLoaded({required this.data});
}

class SkeletonError extends SkeletonState {
  final String message;
  
  SkeletonError({required this.message});
}