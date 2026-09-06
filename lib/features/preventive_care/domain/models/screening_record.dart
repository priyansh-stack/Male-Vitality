class ScreeningRecord {
  final String id;
  final String userId;
  final String guidelineId;
  final String title;
  final DateTime dueDate;
  final DateTime? completedDate;
  final bool isCompleted;
  final String? resultNotes;
  final String? documentUrl;

  const ScreeningRecord({
    required this.id,
    required this.userId,
    required this.guidelineId,
    required this.title,
    required this.dueDate,
    this.completedDate,
    this.isCompleted = false,
    this.resultNotes,
    this.documentUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'guidelineId': guidelineId,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'resultNotes': resultNotes,
      'documentUrl': documentUrl,
    };
  }

  factory ScreeningRecord.fromMap(Map<String, dynamic> map, String id) {
    return ScreeningRecord(
      id: id,
      userId: map['userId'] ?? '',
      guidelineId: map['guidelineId'] ?? '',
      title: map['title'] ?? 'Health Screening',
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : DateTime.now().add(const Duration(days: 30)),
      completedDate: map['completedDate'] != null ? DateTime.parse(map['completedDate']) : null,
      isCompleted: map['isCompleted'] ?? false,
      resultNotes: map['resultNotes'],
      documentUrl: map['documentUrl'],
    );
  }

  ScreeningRecord copyWith({
    String? id,
    String? userId,
    String? guidelineId,
    String? title,
    DateTime? dueDate,
    DateTime? completedDate,
    bool? isCompleted,
    String? resultNotes,
    String? documentUrl,
  }) {
    return ScreeningRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      guidelineId: guidelineId ?? this.guidelineId,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      completedDate: completedDate ?? this.completedDate,
      isCompleted: isCompleted ?? this.isCompleted,
      resultNotes: resultNotes ?? this.resultNotes,
      documentUrl: documentUrl ?? this.documentUrl,
    );
  }
}
