import 'package:flutter/material.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/services/notification_service.dart';
import 'package:nicotinaai_flutter/widgets/daily_motivation_card.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<Map<String, dynamic>>> _notificationsFuture;
  final NotificationService _notificationService = NotificationService();
  
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }
  
  void _loadNotifications() {
    _notificationsFuture = _notificationService.getUserNotifications();
  }
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.notifications),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _loadNotifications();
              });
            },
            tooltip: localizations.refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                '${localizations.errorLoadingNotifications}: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.noNotificationsYet,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.emptyNotificationsDescription,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          
          final notifications = snapshot.data!;
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final notificationType = notification['type'];
              final isRead = notification['is_read'] ?? false;
              final createdAt = DateTime.parse(notification['created_at']);
              final formattedDate = DateFormat('dd/MM/yyyy - HH:mm').format(createdAt);
              
              // Special handling for motivation notifications
              if (notificationType == 'motivation' && !(notification['viewed_at'] != null)) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DailyMotivationCard(
                    notification: notification,
                    onRewardClaimed: () {
                      // Recarrega as notificações após receber a recompensa
                      setState(() {
                        _loadNotifications();
                      });
                    },
                  ),
                );
              }
              
              // Regular notification item
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: isRead ? 1 : 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isRead
                        ? BorderSide.none
                        : BorderSide(
                            color: context.primaryColor,
                            width: 1.5,
                          ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: _buildNotificationIcon(notificationType),
                    title: Text(
                      notification['title'],
                      style: TextStyle(
                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(notification['message']),
                        const SizedBox(height: 8),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Marcar como lida se ainda não estiver
                      if (!isRead) {
                        _notificationService.markNotificationAsRead(notification['id']);
                        
                        // Atualizar a lista
                        setState(() {
                          notifications[index]['is_read'] = true;
                        });
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  Widget _buildNotificationIcon(String type) {
    switch (type) {
      case 'motivation':
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.psychology,
            color: Colors.blue,
          ),
        );
      case 'achievement':
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.emoji_events,
            color: Colors.amber,
          ),
        );
      case 'reminder':
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.notifications_active,
            color: Colors.purple,
          ),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.message,
            color: Colors.green,
          ),
        );
    }
  }
}