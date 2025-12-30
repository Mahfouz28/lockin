import 'package:flutter/material.dart';
import 'package:lockin/core/services/shared_prefs_service.dart';
import 'package:lockin/core/theme/colors.dart';
import 'package:lockin/features/noti/models/noti_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<SavedNotification>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _loadNotifications();
  }

  Future<List<SavedNotification>> _loadNotifications() async {
    final rawNotifications = await SharedPrefsService().getNotifications();
    return rawNotifications
        .map(
          (e) => SavedNotification(
            title: e['title'] ?? 'Unknown',
            body: e['body'] ?? '',
            dateTime: DateTime.tryParse(e['time'] ?? '') ?? DateTime.now(),
          ),
        )
        .toList();
  }

  void _clearNotifications() async {
    await SharedPrefsService().clearNotifications();
    setState(() {
      _notificationsFuture = _loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: theme.textTheme.displayMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearNotifications,
            tooltip: 'Clear all',
          ),
        ],
      ),
      body: FutureBuilder<List<SavedNotification>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!;
          if (notifications.isEmpty) {
            return Center(
              child: Text(
                'No notifications yet',
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              // Show newest first
              final n = notifications[index];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                color: theme.cardColor,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  title: Text(
                    n.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(n.body, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      Text(
                        '${n.dateTime.day.toString().padLeft(2, '0')}-${n.dateTime.month.toString().padLeft(2, '0')}-${n.dateTime.year} '
                        '${n.dateTime.hour.toString().padLeft(2, '0')}:${n.dateTime.minute.toString().padLeft(2, '0')}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  leading: const Icon(Icons.notifications, size: 36),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
