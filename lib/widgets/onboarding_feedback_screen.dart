import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/app_feedback/app_feedback_bloc.dart';
import 'package:nicotinaai_flutter/blocs/app_feedback/app_feedback_event.dart';
import 'package:nicotinaai_flutter/blocs/app_feedback/app_feedback_state.dart';
import 'package:nicotinaai_flutter/services/app_feedback_service.dart';
import 'package:url_launcher/url_launcher.dart';

class OnboardingFeedbackScreen extends StatelessWidget {
  final VoidCallback onComplete;

  const OnboardingFeedbackScreen({
    Key? key, 
    required this.onComplete,
  }) : super(key: key);

  void _launchAppStore(BuildContext context) async {
    // Replace with your actual app store links
    final Uri appStoreUrl = Uri.parse('https://apps.apple.com/your-app-id');
    final Uri playStoreUrl = Uri.parse('https://play.google.com/store/apps/details?id=your.app.id');
    
    // Choose the right URL based on platform
    final Uri url = Theme.of(context).platform == TargetPlatform.iOS
        ? appStoreUrl
        : playStoreUrl;

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppFeedbackBloc, AppFeedbackState>(
      listener: (context, state) {
        if (state is FeedbackCompleted || state is FeedbackDismissed) {
          onComplete();
        }
      },
      builder: (context, state) {
        if (state is SatisfactionSubmitted) {
          return state.isSatisfied
              ? _buildRatingScreen(context)
              : _buildFeedbackFormScreen(context);
        } else if (state is RatingSubmitted) {
          return _buildReviewRequestScreen(context);
        } else if (state is FeedbackError) {
          return _buildErrorScreen(context, state.message);
        }
        
        // Default (initial) screen
        return _buildSatisfactionScreen(context);
      },
    );
  }

  Widget _buildSatisfactionScreen(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.thumb_up_alt_outlined,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'Como está sendo sua experiência?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Estamos trabalhando continuamente para melhorar o app. '
              'Você está gostando do Nicotina.AI?',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      context.read<AppFeedbackBloc>().add(
                            const SubmitSatisfaction(isSatisfied: false),
                          );
                    },
                    child: const Text('Não muito'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      context.read<AppFeedbackBloc>().add(
                            const SubmitSatisfaction(isSatisfied: true),
                          );
                    },
                    child: const Text('Sim, estou gostando!'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                context.read<AppFeedbackBloc>().add(DismissFeedbackPrompt());
              },
              child: const Text('Pular'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingScreen(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.star_outline,
              size: 80,
              color: Colors.amber,
            ),
            const SizedBox(height: 24),
            const Text(
              'Como você avaliaria o app?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Sua opinião é muito importante para nós.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [1, 2, 3, 4, 5].map((rating) {
                return _buildRatingStar(
                  context,
                  rating, 
                  onTap: () {
                    context.read<AppFeedbackBloc>().add(
                          SubmitRating(
                            rating: AppRating.values[rating - 1],
                          ),
                        );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            TextButton(
              onPressed: () {
                context.read<AppFeedbackBloc>().add(DismissFeedbackPrompt());
              },
              child: const Text('Mais tarde'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStar(BuildContext context, int rating, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            Icons.star,
            size: 40,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            rating.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackFormScreen(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();
    
    return StatefulBuilder(
      builder: (context, setState) {
        String selectedCategory = 'Interface';
        
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Icon(
                    Icons.feedback_outlined,
                    size: 80,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'Poderia nos dizer o que não está bom?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Ajude-nos a melhorar contando o que podemos fazer melhor:',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Categoria do feedback:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    'Interface',
                    'Funcionalidades',
                    'Desempenho',
                    'Precisão das estatísticas',
                    'Notificações',
                    'Outro',
                  ].map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Seu feedback:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: feedbackController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Descreva o que podemos melhorar...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          context.read<AppFeedbackBloc>().add(DismissFeedbackPrompt());
                        },
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          if (feedbackController.text.trim().isNotEmpty) {
                            context.read<AppFeedbackBloc>().add(
                                  SubmitFeedbackText(
                                    feedbackText: feedbackController.text.trim(),
                                    feedbackCategory: selectedCategory,
                                  ),
                                );
                          }
                        },
                        child: const Text('Enviar feedback'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewRequestScreen(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.rate_review_outlined,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            const Text(
              'Que bom que você está gostando!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Seu feedback positivo nos motiva a continuar melhorando. '
              'Você gostaria de avaliar o app na loja?',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              onPressed: () {
                // Launch app store and mark as reviewed
                _launchAppStore(context);
                context.read<AppFeedbackBloc>().add(MarkAppReviewed());
              },
              child: const Text('Avaliar agora'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                context.read<AppFeedbackBloc>().add(MarkAppReviewed());
              },
              child: const Text('Já avaliei'),
            ),
            TextButton(
              onPressed: () {
                context.read<AppFeedbackBloc>().add(DismissFeedbackPrompt());
              },
              child: const Text('Mais tarde'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String message) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            const Text(
              'Ops, algo deu errado',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Não foi possível salvar seu feedback: $message',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              onPressed: () {
                context.read<AppFeedbackBloc>().add(DismissFeedbackPrompt());
              },
              child: const Text('Entendi'),
            ),
          ],
        ),
      ),
    );
  }
}