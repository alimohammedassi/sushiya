import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}
// Removed duplicate NotificationsScreen class definition

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = false;
  bool _pushNotificationsEnabled = false;
  bool _orderUpdatesEnabled = true;
  bool _promotionsEnabled = true;
  bool _newsEnabled = false;

  // Mock notifications data
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Order Delivered! 🍣',
      'message':
          'Your sushi order #SUSHI001 has been delivered. Enjoy your meal!',
      'time': '2 minutes ago',
      'type': 'order',
      'read': false,
      'icon': Icons.delivery_dining,
      'color': Colors.green,
    },
    {
      'id': '2',
      'title': 'Special Offer! 🎉',
      'message': 'Get 20% off on all rolls today! Use code: SUSHI20',
      'time': '1 hour ago',
      'type': 'promotion',
      'read': false,
      'icon': Icons.local_offer,
      'color': Colors.orange,
    },
    {
      'id': '3',
      'title': 'Order Status Update',
      'message':
          'Your order #SUSHI002 is being prepared and will be ready in 15 minutes.',
      'time': '2 hours ago',
      'type': 'order',
      'read': true,
      'icon': Icons.restaurant,
      'color': Colors.blue,
    },
    {
      'id': '4',
      'title': 'New Menu Items! 🆕',
      'message':
          'Try our new Dragon Roll and Spicy Salmon Roll. Available now!',
      'time': '1 day ago',
      'type': 'news',
      'read': true,
      'icon': Icons.new_releases,
      'color': Colors.purple,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Simplified initialization
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _toggleNotificationType(String type, bool value) async {
    setState(() {
      switch (type) {
        case 'order':
          _orderUpdatesEnabled = value;
          break;
        case 'promotion':
          _promotionsEnabled = value;
          break;
        case 'news':
          _newsEnabled = value;
          break;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${type.toUpperCase()} notifications ${value ? 'enabled' : 'disabled'}',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final notification = _notifications.firstWhere(
        (n) => n['id'] == notificationId,
      );
      notification['read'] = true;
    });
  }

  void _deleteNotification(String notificationId) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == notificationId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification deleted'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 213, 134, 15),
      appBar: AppBar(
        title: Text(
          'profile.notifications'.tr(),
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 213, 134, 15),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mark all as read coming soon!')),
              );
            },
            icon: const Icon(Icons.done_all),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Notification Settings
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notification Settings',
                          style: GoogleFonts.lato(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Push Notifications Toggle
                        _buildSettingTile(
                          icon: Icons.notifications,
                          title: 'Push Notifications',
                          subtitle: 'Enable/disable all notifications',
                          value: _pushNotificationsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _pushNotificationsEnabled = value;
                            });
                            if (!value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Go to device settings to disable notifications',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          },
                        ),

                        const Divider(),

                        // Order Updates
                        _buildSettingTile(
                          icon: Icons.delivery_dining,
                          title: 'Order Updates',
                          subtitle: 'Get notified about your order status',
                          value: _orderUpdatesEnabled,
                          onChanged: (value) =>
                              _toggleNotificationType('order', value),
                        ),

                        const Divider(),

                        // Promotions
                        _buildSettingTile(
                          icon: Icons.local_offer,
                          title: 'Promotions & Offers',
                          subtitle: 'Receive special deals and discounts',
                          value: _promotionsEnabled,
                          onChanged: (value) =>
                              _toggleNotificationType('promotion', value),
                        ),

                        const Divider(),

                        // News
                        _buildSettingTile(
                          icon: Icons.new_releases,
                          title: 'News & Updates',
                          subtitle: 'Stay updated with new menu items',
                          value: _newsEnabled,
                          onChanged: (value) =>
                              _toggleNotificationType('news', value),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Notifications List
                  Expanded(
                    child: _notifications.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_none,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'No notifications yet',
                                  style: GoogleFonts.lato(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'You\'ll see your notifications here',
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: _notifications.length,
                            itemBuilder: (context, index) {
                              final notification = _notifications[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 15),
                                decoration: BoxDecoration(
                                  color: notification['read']
                                      ? Colors.grey[50]
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: notification['read']
                                        ? Colors.grey[200]!
                                        : notification['color'].withOpacity(
                                            0.3,
                                          ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: notification['color'].withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      notification['icon'],
                                      color: notification['color'],
                                      size: 24,
                                    ),
                                  ),
                                  title: Text(
                                    notification['title'],
                                    style: GoogleFonts.lato(
                                      fontWeight: notification['read']
                                          ? FontWeight.w500
                                          : FontWeight.bold,
                                      color: notification['read']
                                          ? Colors.grey[600]
                                          : Colors.black87,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 5),
                                      Text(
                                        notification['message'],
                                        style: GoogleFonts.lato(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        notification['time'],
                                        style: GoogleFonts.lato(
                                          color: Colors.grey[500],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: PopupMenuButton(
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'read',
                                        child: Text(
                                          notification['read']
                                              ? 'Mark as unread'
                                              : 'Mark as read',
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                    onSelected: (value) {
                                      if (value == 'read') {
                                        _markAsRead(notification['id']);
                                      } else if (value == 'delete') {
                                        _deleteNotification(notification['id']);
                                      }
                                    },
                                  ),
                                  onTap: () {
                                    if (!notification['read']) {
                                      _markAsRead(notification['id']);
                                    }
                                    // Handle notification tap
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Opening: ${notification['title']}',
                                        ),
                                        backgroundColor: notification['color'],
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color.fromARGB(255, 213, 134, 15),
        size: 24,
      ),
      title: Text(
        title,
        style: GoogleFonts.lato(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.lato(color: Colors.grey[600], fontSize: 12),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color.fromARGB(255, 213, 134, 15),
      ),
    );
  }
}
