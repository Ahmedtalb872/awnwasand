class StudentProfile {
  const StudentProfile({required this.id, required this.name, this.email = '', this.level = 'مبتدئ', this.bio = '', this.role = 'student'});
  final String id, name, email, level, bio, role;
  bool get isAdmin => role == 'admin';
  factory StudentProfile.fromJson(Map<String, dynamic> json) => StudentProfile(
    id: json['id'] as String, name: json['name'] as String,
    email: json['email'] as String? ?? '', level: json['level'] as String? ?? 'مبتدئ',
    bio: json['bio'] as String? ?? '', role: json['role'] as String? ?? 'student',
  );
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email, 'level': level, 'bio': bio, 'role': role};
}

class CourseMaterial {
  const CourseMaterial({required this.id, required this.courseId, required this.title, required this.fileName, required this.kind, required this.mime, required this.size, required this.path});
  final String id, courseId, title, fileName, kind, mime, path;
  final int size;
  bool get isVideo => kind == 'video';
  factory CourseMaterial.fromJson(Map<String, dynamic> json) => CourseMaterial(
    id: json['id'] as String, courseId: json['course_id'] as String, title: json['title'] as String,
    fileName: json['file_name'] as String, kind: json['kind'] as String,
    mime: json['mime'] as String, size: json['size'] as int, path: json['path'] as String,
  );
  Map<String, dynamic> toJson() => {'id': id, 'course_id': courseId, 'title': title, 'file_name': fileName, 'kind': kind, 'mime': mime, 'size': size, 'path': path};
}

class AcademyCourse {
  const AcademyCourse({required this.id, required this.title, required this.description, this.teacher = '', this.level = 'مبتدئ', this.published = false, this.materials = const []});
  final String id, title, description, teacher, level;
  final bool published;
  final List<CourseMaterial> materials;
  factory AcademyCourse.fromJson(Map<String, dynamic> json) => AcademyCourse(
    id: json['id'] as String, title: json['title'] as String, description: json['description'] as String,
    teacher: json['teacher'] as String? ?? '', level: json['level'] as String? ?? 'مبتدئ',
    published: json['published'] as bool? ?? false,
    materials: (json['course_materials'] as List? ?? []).map((m) => CourseMaterial.fromJson(Map<String, dynamic>.from(m as Map))).toList(),
  );
  Map<String, dynamic> toJson({bool withMaterials = false}) => {
    'id': id, 'title': title, 'description': description, 'teacher': teacher, 'level': level, 'published': published,
    if (withMaterials) 'course_materials': materials.map((m) => m.toJson()).toList(),
  };
  AcademyCourse withMaterials(List<CourseMaterial> items) => AcademyCourse(id: id, title: title, description: description, teacher: teacher, level: level, published: published, materials: items);
}

class Enrollment {
  const Enrollment({required this.studentId, required this.courseId, this.completed = const []});
  final String studentId, courseId;
  final List<String> completed;
  factory Enrollment.fromJson(Map<String, dynamic> json) => Enrollment(
    studentId: json['student_id'] as String, courseId: json['course_id'] as String,
    completed: List<String>.from(json['completed_materials'] as List? ?? []),
  );
  Map<String, dynamic> toJson() => {'student_id': studentId, 'course_id': courseId, 'completed_materials': completed};
}
