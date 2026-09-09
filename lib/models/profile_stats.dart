/// إحصاءات تقدّم المستخدم في منصة "المحجة البيضاء" (تُعرض في شاشة حسابي).
class ProfileStats {
  const ProfileStats({
    this.completedCourses = 0,
    this.followedLessons = 0,
    this.knowledgePoints = 0,
  });

  factory ProfileStats.fromMap(Map<String, dynamic> map) {
    return ProfileStats(
      completedCourses: map['completed_courses'] as int? ?? 0,
      followedLessons: map['followed_lessons'] as int? ?? 0,
      knowledgePoints: map['knowledge_points'] as int? ?? 0,
    );
  }

  final int completedCourses;
  final int followedLessons;
  final int knowledgePoints;
}
