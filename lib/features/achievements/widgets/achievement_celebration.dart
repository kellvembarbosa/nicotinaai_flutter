import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';

import '../models/user_achievement.dart';

/// Particle for confetti animation
class Particle {
  Offset position;
  final Color color;
  final double size;
  final double speed;
  final double horizontalDirection;
  final double rotationSpeed;
  double rotation = 0;
  
  Particle({
    required this.position,
    required this.color,
    required this.size,
    required this.speed,
    required this.horizontalDirection,
    required this.rotationSpeed,
  });
}

/// Custom painter for confetti animation
class ConfettiPainter extends CustomPainter {
  final List<Particle> particles;
  final double opacityAnimation;
  
  ConfettiPainter({
    required this.particles,
    required this.opacityAnimation,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      if (particle.position.dy > 0 && particle.position.dy < size.height) {
        final paint = Paint()
          ..color = particle.color.withOpacity(opacityAnimation)
          ..style = PaintingStyle.fill;
          
        // Update rotation
        particle.rotation += particle.rotationSpeed;
        
        // Save canvas state before rotation
        canvas.save();
        
        // Translate to particle position and rotate
        canvas.translate(particle.position.dx, particle.position.dy);
        canvas.rotate(particle.rotation);
        
        // Draw the particle shapes (mix of shapes for variety)
        final particleType = particles.indexOf(particle) % 3;
        
        switch (particleType) {
          case 0: // Rectangle
            canvas.drawRect(
              Rect.fromCenter(
                center: Offset.zero,
                width: particle.size,
                height: particle.size * 0.5,
              ),
              paint,
            );
            break;
          case 1: // Circle
            canvas.drawCircle(
              Offset.zero,
              particle.size / 2,
              paint,
            );
            break;
          case 2: // Triangle
            final path = Path()
              ..moveTo(0, -particle.size / 2)
              ..lineTo(particle.size / 2, particle.size / 2)
              ..lineTo(-particle.size / 2, particle.size / 2)
              ..close();
            canvas.drawPath(path, paint);
            break;
        }
        
        // Restore canvas state
        canvas.restore();
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) => true;
}

/// A celebration animation for unlocked achievements
class AchievementCelebration extends StatefulWidget {
  final UserAchievement achievement;
  final VoidCallback onDismiss;
  
  const AchievementCelebration({
    Key? key, 
    required this.achievement,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<AchievementCelebration> createState() => _AchievementCelebrationState();
}

class _AchievementCelebrationState extends State<AchievementCelebration> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _opacityAnimation;
  
  // For particle animations
  final List<Particle> _particles = [];
  final Random _random = Random();
  
  @override
  void initState() {
    super.initState();
    
    // Animation controller for scaling and particles
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Scale animation with bounce effect
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    
    // Rotation animation
    _rotateAnimation = Tween<double>(begin: 0, end: 0.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    // Opacity animation for particles
    _opacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );
    
    // Generate confetti particles
    _generateParticles();
    
    // Start animations
    _controller.forward();
    
    // Repeat shake animation
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse(from: 0.2);
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward(from: 0.1);
      }
    });
  }
  
  // Generate random particles as confetti
  void _generateParticles() {
    for (int i = 0; i < 100; i++) {
      _particles.add(
        Particle(
          position: Offset(_random.nextDouble() * 400 - 200, -50),
          color: _getRandomColor(),
          size: _random.nextDouble() * 10 + 5,
          speed: _random.nextDouble() * 5 + 2,
          horizontalDirection: _random.nextDouble() * 2 - 1,
          rotationSpeed: _random.nextDouble() * 0.2 - 0.1,
        ),
      );
    }
  }
  
  // Get a random color for particles
  Color _getRandomColor() {
    final colors = [
      Colors.amber,
      Colors.green,
      Colors.blue,
      Colors.pink,
      Colors.purple,
      Colors.orange,
    ];
    return colors[_random.nextInt(colors.length)];
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Custom confetti animation
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            _updateParticles();
            return CustomPaint(
              painter: ConfettiPainter(
                particles: _particles,
                opacityAnimation: _opacityAnimation.value,
              ),
              size: Size.infinite,
            );
          },
        ),
        
        // Achievement card with animation
        Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: sin(_controller.value * 10) * _rotateAnimation.value,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildAchievementCard(context),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  // Update particles position for animation
  void _updateParticles() {
    for (var particle in _particles) {
      particle.position = Offset(
        particle.position.dx + particle.horizontalDirection * 2,
        particle.position.dy + particle.speed,
      );
      
      // Reset particle if it goes off screen
      if (particle.position.dy > MediaQuery.of(context).size.height) {
        particle.position = Offset(
          _random.nextDouble() * MediaQuery.of(context).size.width,
          -50,
        );
      }
    }
  }
  
  Widget _buildAchievementCard(BuildContext context) {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      color: context.cardColor,
      child: Container(
        padding: const EdgeInsets.all(24),
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trophy icon with glow
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: Colors.amber,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            
            // Achievement unlocked header
            Text(
              'Achievement Unlocked!',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: context.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            // Achievement name and description
            Text(
              widget.achievement.definition.name,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: context.contentColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.achievement.definition.description,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: context.subtitleColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // XP reward
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.green.withOpacity(0.5),
                ),
              ),
              child: Text(
                '+${widget.achievement.definition.xpReward} XP',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onDismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}