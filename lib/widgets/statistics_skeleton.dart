import 'package:flutter/material.dart';
import 'package:nicotinaai_flutter/widgets/skeleton_loading.dart';

class StatisticsDashboardSkeleton extends StatelessWidget {
  const StatisticsDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key stats header
          const SizedBox(height: 16),
          SkeletonLoading(
            width: 180,
            height: 24,
            borderRadius: 4,
          ),
          const SizedBox(height: 16),
          
          // Main Stats Card
          _buildStatsCardSkeleton(context),
          
          const SizedBox(height: 16),
          
          // Dual stats row
          Row(
            children: [
              Expanded(
                child: _buildStatsCardSkeleton(context, height: 130),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatsCardSkeleton(context, height: 130),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Section header
          SkeletonLoading(
            width: 160,
            height: 22,
            borderRadius: 4,
          ),
          const SizedBox(height: 16),
          
          // Another stats card
          _buildStatsCardSkeleton(context),
          
          const SizedBox(height: 16),
          
          // Money stats card
          _buildStatsCardSkeleton(context),
          
          const SizedBox(height: 24),
          
          // Chart section
          SkeletonLoading(
            width: 140,
            height: 22,
            borderRadius: 4,
          ),
          const SizedBox(height: 16),
          
          // Chart skeleton
          Container(
            height: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Center(
              child: SkeletonLoading(
                width: double.infinity,
                height: 200,
                borderRadius: 12,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Legend row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItemSkeleton(),
              const SizedBox(width: 24),
              _buildLegendItemSkeleton(),
              const SizedBox(width: 24),
              _buildLegendItemSkeleton(),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatsCardSkeleton(BuildContext context, {double height = 160}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonLoading(height: 36, width: 36, borderRadius: 8),
              const Spacer(),
              SkeletonLoading(height: 16, width: 60, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 12),
          SkeletonLoading(
            width: 120,
            height: 28,
            borderRadius: 4,
          ),
          const Spacer(),
          SkeletonLoading(
            width: 160,
            height: 16,
            borderRadius: 4,
          ),
        ],
      ),
    );
  }
  
  Widget _buildLegendItemSkeleton() {
    return Row(
      children: [
        SkeletonLoading(height: 12, width: 12, isCircle: true),
        const SizedBox(width: 8),
        SkeletonLoading(height: 12, width: 50, borderRadius: 4),
      ],
    );
  }
}