import 'package:flutter/material.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/widgets/skeleton_loading.dart';

/// A skeleton loading widget for the home screen
class HomeScreenSkeleton extends StatelessWidget {
  const HomeScreenSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: SkeletonLoading(
          width: 120,
          height: 24,
          borderRadius: 4,
        ),
        backgroundColor: context.backgroundColor,
        elevation: 0,
        actions: [
          const SizedBox(width: 40),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with greeting and days counter
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoading(
                          width: 180,
                          height: 24,
                          borderRadius: 4,
                        ),
                        const SizedBox(height: 8),
                        SkeletonLoading(
                          width: 120,
                          height: 16,
                          borderRadius: 4,
                        ),
                        const SizedBox(height: 4),
                        SkeletonLoading(
                          width: 100,
                          height: 12,
                          borderRadius: 3,
                        ),
                      ],
                    ),
                    const SkeletonLoading(
                      height: 52,
                      isCircle: true,
                    ),
                  ],
                ),
              ),

              // Daily stats header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonLoading(
                      width: 120,
                      height: 20,
                      borderRadius: 4,
                    ),
                    SkeletonLoading(
                      width: 60,
                      height: 14,
                      borderRadius: 4,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Daily stat cards
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildDailyStatCardSkeleton(context),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDailyStatCardSkeleton(context),
                    ),
                  ],
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionButtonSkeleton(context),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButtonSkeleton(context),
                    ),
                  ],
                ),
              ),

              // Health recovery section
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkeletonLoading(
                          width: 140,
                          height: 20,
                          borderRadius: 4,
                        ),
                        SkeletonLoading(
                          width: 60,
                          height: 14,
                          borderRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  
                  // Health recovery cards
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return const RecoveryItemSkeleton();
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Statistics cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatisticCardSkeleton(context),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatisticCardSkeleton(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Money saved card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildMoneyStatisticCardSkeleton(context),
              ),

              const SizedBox(height: 24),

              // Next milestone
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildNextMilestoneSkeleton(context),
              ),

              const SizedBox(height: 24),

              // Recent achievements header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonLoading(
                      width: 160,
                      height: 20,
                      borderRadius: 4,
                    ),
                    SkeletonLoading(
                      width: 60,
                      height: 14,
                      borderRadius: 4,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Achievement cards
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return _buildAchievementCardSkeleton(context);
                  },
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyStatCardSkeleton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: context.isDarkMode 
            ? Border.all(color: context.borderColor)
            : null,
        boxShadow: context.isDarkMode 
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonLoading(
                height: 30,
                width: 30,
                borderRadius: 8,
              ),
              const Spacer(),
              SkeletonLoading(
                height: 14,
                width: 40,
                borderRadius: 4,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SkeletonLoading(
            width: 60,
            height: 24,
            borderRadius: 4,
          ),
          const SizedBox(height: 4),
          SkeletonLoading(
            width: 100,
            height: 12,
            borderRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonSkeleton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: context.isDarkMode 
            ? Colors.grey.withOpacity(0.1) 
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SkeletonLoading(
            height: 48,
            width: 48,
            borderRadius: 24,
          ),
          const SizedBox(height: 12),
          SkeletonLoading(
            width: 80,
            height: 16,
            borderRadius: 4,
          ),
          const SizedBox(height: 4),
          SkeletonLoading(
            width: 100,
            height: 12,
            borderRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticCardSkeleton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: context.isDarkMode 
            ? Border.all(color: context.borderColor)
            : null,
        boxShadow: context.isDarkMode 
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoading(
            height: 36,
            width: 36,
            borderRadius: 8,
          ),
          const SizedBox(height: 12),
          SkeletonLoading(
            width: 80,
            height: 24,
            borderRadius: 4,
          ),
          const SizedBox(height: 4),
          SkeletonLoading(
            width: 100,
            height: 12,
            borderRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyStatisticCardSkeleton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: context.isDarkMode 
            ? Border.all(color: context.borderColor)
            : null,
        boxShadow: context.isDarkMode 
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonLoading(
                height: 44,
                width: 44,
                borderRadius: 10,
              ),
              const Spacer(),
              SkeletonLoading(
                height: 14,
                width: 40,
                borderRadius: 4,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SkeletonLoading(
            width: 120,
            height: 28,
            borderRadius: 4,
          ),
          const SizedBox(height: 8),
          SkeletonLoading(
            width: 160,
            height: 12,
            borderRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildNextMilestoneSkeleton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          SkeletonLoading(
            height: 44,
            width: 44,
            borderRadius: 12,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoading(
                  width: 120,
                  height: 18,
                  borderRadius: 4,
                ),
                const SizedBox(height: 8),
                SkeletonLoading(
                  width: double.infinity,
                  height: 14,
                  borderRadius: 4,
                ),
                const SizedBox(height: 4),
                SkeletonLoading(
                  width: 100,
                  height: 14,
                  borderRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCardSkeleton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 160,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: context.isDarkMode 
            ? Border.all(color: context.borderColor)
            : null,
        boxShadow: context.isDarkMode 
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SkeletonLoading(
            width: 60,
            height: 18,
            borderRadius: 12,
          ),
          const SizedBox(height: 8),
          SkeletonLoading(
            width: 100,
            height: 16,
            borderRadius: 4,
          ),
          const SizedBox(height: 4),
          SkeletonLoading(
            width: 120,
            height: 12,
            borderRadius: 4,
          ),
          const SizedBox(height: 2),
          SkeletonLoading(
            width: 80,
            height: 12,
            borderRadius: 4,
          ),
        ],
      ),
    );
  }
}