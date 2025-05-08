import 'package:flutter/material.dart';

/// A skeleton loading animation widget that can be used while content is loading
/// 
/// This widget creates a shimmering effect with a gradient animation
class SkeletonLoading extends StatefulWidget {
  /// The width of the skeleton
  final double? width;
  
  /// The height of the skeleton
  final double height;
  
  /// Border radius of the skeleton
  final double borderRadius;
  
  /// Whether the skeleton should be a circle
  final bool isCircle;

  const SkeletonLoading({
    Key? key,
    this.width,
    required this.height,
    this.borderRadius = 8,
    this.isCircle = false,
  }) : super(key: key);

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use isDarkMode to determine the appropriate color scheme
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.isCircle ? widget.height : widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              widget.isCircle ? widget.height / 2 : widget.borderRadius,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                _animation.value - 1,
                _animation.value,
                _animation.value + 1,
              ],
              colors: isDarkMode
                  ? [
                      Colors.grey.shade800,
                      Colors.grey.shade700,
                      Colors.grey.shade800,
                    ]
                  : [
                      Colors.grey.shade300,
                      Colors.grey.shade100,
                      Colors.grey.shade300,
                    ],
            ),
          ),
        );
      },
    );
  }
}

/// A skeleton card for health recovery items in the horizontal list
class RecoveryItemSkeleton extends StatelessWidget {
  const RecoveryItemSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      margin: EdgeInsets.only(right: 12, bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SkeletonLoading(height: 64, isCircle: true),
            ],
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SkeletonLoading(
              width: double.infinity,
              height: 14,
              borderRadius: 4,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SkeletonLoading(
              width: 40,
              height: 10,
              borderRadius: 4,
            ),
          ),
        ],
      ),
    );
  }
}

/// A skeleton for the health recovery detail screen
class RecoveryDetailSkeleton extends StatelessWidget {
  const RecoveryDetailSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Row(
            children: [
              SkeletonLoading(height: 64, isCircle: true),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoading(
                      width: 150,
                      height: 24,
                      borderRadius: 4,
                    ),
                    const SizedBox(height: 8),
                    SkeletonLoading(
                      width: double.infinity,
                      height: 16,
                      borderRadius: 4,
                    ),
                    const SizedBox(height: 4),
                    SkeletonLoading(
                      width: 100,
                      height: 16,
                      borderRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Progress section
          SkeletonLoading(
            width: 100,
            height: 24,
            borderRadius: 4,
          ),
          const SizedBox(height: 16),
          SkeletonLoading(
            width: double.infinity,
            height: 10,
            borderRadius: 5,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoading(
                width: 120,
                height: 16,
                borderRadius: 4,
              ),
              SkeletonLoading(
                width: 80,
                height: 16,
                borderRadius: 4,
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Science section
          SkeletonLoading(
            width: 160,
            height: 24,
            borderRadius: 4,
          ),
          const SizedBox(height: 16),
          SkeletonLoading(
            width: double.infinity,
            height: 16,
            borderRadius: 4,
          ),
          const SizedBox(height: 6),
          SkeletonLoading(
            width: double.infinity,
            height: 16,
            borderRadius: 4,
          ),
          const SizedBox(height: 6),
          SkeletonLoading(
            width: double.infinity,
            height: 16,
            borderRadius: 4,
          ),
          const SizedBox(height: 6),
          SkeletonLoading(
            width: 200,
            height: 16,
            borderRadius: 4,
          ),
          const SizedBox(height: 24),
          
          // Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoading(
                  width: 120,
                  height: 20,
                  borderRadius: 4,
                ),
                const SizedBox(height: 12),
                SkeletonLoading(
                  width: double.infinity,
                  height: 16,
                  borderRadius: 4,
                ),
                const SizedBox(height: 6),
                SkeletonLoading(
                  width: double.infinity,
                  height: 16,
                  borderRadius: 4,
                ),
                const SizedBox(height: 6),
                SkeletonLoading(
                  width: 180,
                  height: 16,
                  borderRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}