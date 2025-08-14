class StudyArm {
  final String id;
  final String name;
  final String description;
  const StudyArm({required this.id, required this.name, this.description = ''});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'description': description};
  static StudyArm fromJson(Map<String, dynamic> j) => StudyArm(id: j['id'], name: j['name'], description: j['description'] ?? '');
}

class Assignment {
  final int dayIndex; // 0..N-1
  final String armId;
  const Assignment({required this.dayIndex, required this.armId});
  Map<String, dynamic> toJson() => {'day': dayIndex, 'armId': armId};
  static Assignment fromJson(Map<String, dynamic> j) => Assignment(dayIndex: j['day'], armId: j['armId']);
}

class Study {
  final String id;
  final String title;
  final List<StudyArm> arms;
  final List<Assignment> schedule; // length = days
  const Study({required this.id, required this.title, required this.arms, required this.schedule});

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title,
    'arms': arms.map((a)=> a.toJson()).toList(),
    'schedule': schedule.map((a)=> a.toJson()).toList(),
  };
  static Study fromJson(Map<String, dynamic> j) => Study(
    id: j['id'], title: j['title'],
    arms: (j['arms'] as List).map((x)=> StudyArm.fromJson(x)).toList(),
    schedule: (j['schedule'] as List).map((x)=> Assignment.fromJson(x)).toList(),
  );
}
