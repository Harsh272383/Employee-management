import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const EmployeeApp());
}

class EmployeeApp extends StatelessWidget {
  const EmployeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Employee Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const EmployeeHomePage(title: 'Employee Management Home Page'),
    );
  }
}

class EmployeeHomePage extends StatefulWidget {
  const EmployeeHomePage({super.key, required this.title});
  final String title;

  @override
  _EmployeeHomePageState createState() => _EmployeeHomePageState();
}

class _EmployeeHomePageState extends State<EmployeeHomePage> {
  List<Map<String, dynamic>> _employees = <Map<String, dynamic>>[];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  _loadEmployees() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      List<String>? employeeStrings = prefs.getStringList('employees');
      _employees = employeeStrings?.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList() ?? [];
    });
  }

  _addEmployee(String name, String position, DateTime dateOfBirth) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _employees.add({'name': name, 'position': position, 'dateOfBirth': _dateFormat.format(dateOfBirth)});
      _nameController.clear();
      _positionController.clear();
    });
    prefs.setStringList('employees', _employees.map((e) => jsonEncode(e)).toList());
  }

  _deleteEmployee(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> employeeList = _employees;
    employeeList.removeAt(index);
    prefs.setStringList('employees', employeeList.map((e) => jsonEncode(e)).toList());
    _loadEmployees();
  }
  _updateEmployee(int index, String name, String position, DateTime dateOfBirth) {
    setState(() {
      _employees[index]['name'] = name;
      _employees[index]['position'] = position;
      _employees[index]['dateOfBirth'] = _dateFormat.format(dateOfBirth);
    });
  }

  _onAddEmployeePressed() {
    if (_nameController.text.isNotEmpty && _positionController.text.isNotEmpty) {
      DateTime dateOfBirth = DateTime.now();
      _addEmployee(_nameController.text, _positionController.text, dateOfBirth);
    }
  }

  _onCancelPressed() {
    _nameController.clear();
    _positionController.clear();
  }

  _showEditEmployeeDialog(int index) async {
    _nameController.text = _employees[index]['name'];
    _positionController.text = _employees[index]['position'];
    DateTime dateOfBirth = _dateFormat.parse(_employees[index]['dateOfBirth']);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Employee'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Name'),
              ),
              TextField(
                controller: _positionController,
                decoration: const InputDecoration(hintText: 'Position'),
              ),
              SizedBox(
                height: 70,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: dateOfBirth,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      dateOfBirth = newDate;
                    });
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                _updateEmployee(index, _nameController.text, _positionController.text, dateOfBirth);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'Name'),
          ),
          TextField(
            controller: _positionController,
            decoration: const InputDecoration(hintText: 'Position'),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: _onAddEmployeePressed,
                child: const Text('Add Employee'),
              ),
              ElevatedButton(
                onPressed: _onCancelPressed,
                child: const Text('Cancel'),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _employees.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_employees[index]['name']),
                  subtitle: Text(_employees[index]['position']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showEditEmployeeDialog(index);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteEmployee(index);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DateFormat {
  static final DateFormat _instance = DateFormat._internal();

  factory DateFormat(String s) {
    return _instance;
  }

  DateFormat._internal();

  String format(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime parse(String dateString) {
    List<String> parts = dateString.split('-');
    int year = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int day = int.parse(parts[2]);
    return DateTime.utc(year, month, day);
  }
}