class LocalNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime timestamp;
  final bool isRead;
  final bool isSynced;
  final int syncRetryCount;
  final DateTime? lastSyncAttempt;
  final Map<String, dynamic> metadata;

  LocalNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.isSynced = false,
    this.syncRetryCount = 0,
    this.lastSyncAttempt,
    required this.metadata,
  });

  factory LocalNotification.fromJson(Map<String, dynamic> json) {
    return LocalNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['is_read'] == true || json['is_read'] == 1,
      isSynced: json['is_synced'] == true || json['is_synced'] == 1,
      syncRetryCount: json['sync_retry_count'] as int? ?? 0,
      lastSyncAttempt: json['last_sync_attempt'] != null
          ? DateTime.tryParse(json['last_sync_attempt'].toString())
          : null,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'is_synced': isSynced,
      'sync_retry_count': syncRetryCount,
      'last_sync_attempt': lastSyncAttempt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  LocalNotification copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    DateTime? timestamp,
    bool? isRead,
    bool? isSynced,
    int? syncRetryCount,
    DateTime? lastSyncAttempt,
    Map<String, dynamic>? metadata,
  }) {
    return LocalNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isSynced: isSynced ?? this.isSynced,
      syncRetryCount: syncRetryCount ?? this.syncRetryCount,
      lastSyncAttempt: lastSyncAttempt ?? this.lastSyncAttempt,
      metadata: metadata ?? this.metadata,
    );
  }
}
