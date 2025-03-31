import 'dart:io';
import 'dart:math';

import 'package:employee_scheduling/employee.dart';

void main(List<String> arguments) {
  EmployeeScheduling employeeScheduling = EmployeeScheduling();
  // employeeScheduling.startApp();
  employeeScheduling.readCsvPreferences();
}

class EmployeeScheduling {
  Map<int, Employee> employees = {};

  /// This will act as a table for storing the assigned employee using thier ID
  /// 7 rows => 7 days of a week, 3 columns => 3 shifts in a day, and each shift
  /// having two employess
  ///
  /// Keeping growable=false to keep it a fixed size array
  List<List<List<int>>> schedule = List.generate(
    7,
    (_) => List.generate(3, (_) => <int>[]),
  );

  /// Tracks the number of days each employee is working
  Map<int, int> employeeWorkingDays = {};
  void startApp() {
    print('====Welcome to Employee Scheduling!=====');
    print(
        'You are required to enter the employee name and their preference for 7 days');
    print(
        'Since the company runs for 7 days, you need to enter 12 employees. (2 per shift)');
    print('You should enter it like so : `Santhosh,0,1,1,2,1,0,1`');
    print('numbers represent the shift (0=>Morning,1=>Afternoon,2=>Evening),'
        ' make sure its exactly 7 separated by comma without spaces');
    print('if you prefer that the application autopopulate it, enter `auto`');
    int count = 1;
    while (employees.length < 12) {
      stdout.writeln(
          'please enter the name and preference for employee #$count: ');
      final employeeStr = stdin.readLineSync();

      if (employeeStr != null) {
        // if user wants to populate it at any point of receiving input
        if (employeeStr == 'auto') {
          readCsvPreferences();
        } else {
          final splitRes = employeeStr.split(',');
          if (splitRes.length != 8) {
            stdout.writeln('please enter valid value');
            continue;
          } else {
            for (int i = 1; i < splitRes.length; i++) {
              int? preference = int.tryParse(splitRes[i]);
              if (preference == null || (preference < 0 || preference > 2)) {
                stdout.writeln('please enter valid value');
              } else {
                addEmployeesToList(splitRes);
              }
            }
          }
        }

        computeSchedule();
      } else {
        stdout.writeln('please enter valid value');
      }
    }
  }

  void computeSchedule() {
    // To provide a fair chance to all employee, iterating day wise to fill the schedule
    for (int i = 0; i < DayOfWeek.values.length; i++) {
      final day = DayOfWeek.values[i];
      for (var e in employees.values) {
        final preference = e.preferences[day];
        if (preference != null && employeeWorkingDays.containsKey(e.id)) {
          if (schedule[i][preference.value].length < 2) {
            addWorkingDay(i, preference.value, e.id);
          } else {
            for (int j = 0; j < schedule[i].length; j++) {
              if (schedule[i][j].length < 2 &&
                  !_identifyEmployeeIsAlreadyWorking(e.id, i)) {
                addWorkingDay(i, j, e.id);
                break;
              }
            }

            final nextDay = i % 6;
            for (int j = 0; j < schedule[nextDay].length; j++) {
              if (schedule[nextDay][j].length < 2 &&
                  !_identifyEmployeeIsAlreadyWorking(e.id, nextDay)) {
                addWorkingDay(i, j, e.id);
                break;
              }
            }
          }
        }
      }
    }

    for (int i = 0; i < DayOfWeek.values.length; i++) {
      addRandomEmployee(i, ShiftPreference.morning);
      addRandomEmployee(i, ShiftPreference.afternoon);
      addRandomEmployee(i, ShiftPreference.evening);
    }
    printSchedule(employees, schedule);
  }

  void printSchedule(
      Map<int, Employee> employees, List<List<List<int>>> schedule) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    print('--------------------------------------------------------------');
    print(
        '| Day       | Morning            | Afternoon         | Evening           |');
    print('--------------------------------------------------------------');

    for (int day = 0; day < 7; day++) {
      String row = '| ${days[day].padRight(10)}';
      for (int shift = 0; shift < 3; shift++) {
        List<String> empNames = schedule[day][shift]
            .map((id) => employees[id]?.name ?? 'Unknown')
            .toList();
        row += '| ${empNames.join(", ").padRight(18)}';
      }
      print('$row|');
      print('--------------------------------------------------------------');
    }
  }

  Random random = Random();

  void addRandomEmployee(int dayOfWeek, ShiftPreference preference) {
    final workers = schedule[dayOfWeek][preference.value];
    final remainingEmployees = employeeWorkingDays.entries.toList();
    while (workers.length < 2) {
      int randomIdx = random.nextInt(employeeWorkingDays.length);
      while (_identifyEmployeeIsAlreadyWorking(
          remainingEmployees[randomIdx].key, dayOfWeek)) {
        randomIdx = random.nextInt(employeeWorkingDays.length);
      }
      final randomEmp = remainingEmployees[randomIdx];
      addWorkingDay(dayOfWeek, preference.value, randomEmp.key);
    }
  }

  bool _identifyEmployeeIsAlreadyWorking(int empId, int dayOfWeek) {
    for (var preference in schedule[dayOfWeek]) {
      if (preference.contains(empId)) {
        return true;
      }
    }

    return false;
  }

  void addWorkingDay(int dayIndex, int preference, int employeeId) {
    (schedule[dayIndex][preference]).add(employeeId);
    employeeWorkingDays[employeeId] =
        (employeeWorkingDays[employeeId] ?? 0) + 1;

    /// Removing when an employee is already working for 5 days.
    if (employeeWorkingDays[employeeId]! >= 5) {
      employeeWorkingDays.remove(employeeId);
    }
  }

  void readCsvPreferences() {
    employees.clear();
    File file = File('./lib/preference.txt');
    List<String> rows = file.readAsStringSync().split('\n');
    for (var row in rows) {
      addEmployeesToList(row.trim().split(','));
    }
  }

  int idCounter = 1;

  void addEmployeesToList(List<dynamic> splitRes) {
    final emp = Employee(
      id: idCounter,
      name: splitRes[0],
      preferences: {
        DayOfWeek.monday: ShiftPreference.fromValue(
            splitRes[1] is int ? splitRes[1] : int.parse(splitRes[1])),
        DayOfWeek.tuesday: ShiftPreference.fromValue(
            splitRes[2] is int ? splitRes[2] : int.parse(splitRes[2])),
        DayOfWeek.wednesday: ShiftPreference.fromValue(
            splitRes[3] is int ? splitRes[3] : int.parse(splitRes[3])),
        DayOfWeek.thursday: ShiftPreference.fromValue(
            splitRes[4] is int ? splitRes[4] : int.parse(splitRes[4])),
        DayOfWeek.friday: ShiftPreference.fromValue(
            splitRes[5] is int ? splitRes[5] : int.parse(splitRes[5])),
        DayOfWeek.saturday: ShiftPreference.fromValue(
            splitRes[6] is int ? splitRes[6] : int.parse(splitRes[6])),
        DayOfWeek.sunday: ShiftPreference.fromValue(
            splitRes[7] is int ? splitRes[7] : int.parse(splitRes[7])),
      },
    );
    employees[emp.id] = (emp);
    employeeWorkingDays[emp.id] = 0;
    idCounter++;
  }
}
