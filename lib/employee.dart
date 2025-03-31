enum ShiftPreference {
  morning(0),
  afternoon(1),
  evening(2);

  const ShiftPreference(this.value);
  final int value;

  static ShiftPreference fromValue(int value) {
    switch (value) {
      case 0:
        return ShiftPreference.morning;
      case 1:
        return ShiftPreference.afternoon;
      case 2:
        return ShiftPreference.evening;
      default:
        throw Exception('invalid value: $value');
    }
  }
}

enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;
}

class Employee {
  int id;
  String name;
  Map<DayOfWeek, ShiftPreference> preferences;
  Employee({
    required this.id,
    required this.name,
    required this.preferences,
  });

  @override
  String toString() {
    return 'Employee(name: $name, preferences: $preferences)';
  }
}
