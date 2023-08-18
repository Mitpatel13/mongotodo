import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongotodo/studentMOdel.dart';

import 'api.dart';


class DashboardController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final RxString selectedClass = 'Class A'.obs;
  final RxString selectedDivision = 'Division I'.obs;

  final List<String> classes = ['Class A', 'Class B', 'Class C'];
  final List<String> divisions = ['Division I', 'Division II', 'Division III'];

  final RxList<Student> students = <Student>[].obs;
  final RxBool addStudentSucees = false.obs;

  Future<void> addStudent() async {
    addStudentSucees.value = true;
    final name = nameController.text;

    final db = await Db.create(baseURL);
    await db.open();
    final studentsCollection = db.collection(studentsCol);

    final student = Student(name: name,
        className: selectedClass.value,
        division: selectedDivision.value);

    await studentsCollection.insert({
      'name': student.name,
      'class': student.className,
      'division': student.division,
    });


    students.add(student);

    addStudentSucees.value = false;
    await db.close();
  }

  Future<List<Student>> fetchStudents() async {
    final db = await Db.create(baseURL);
    await db.open();
    final studentsCollection = db.collection(studentsCol);

    final studentsData = await studentsCollection.find().toList();
    final students = studentsData.map((data) {
      return Student(name: data['name'],
          className: data['class'],
          division: data['division']);
    }).toList();

    await db.close();
    return students;
  }
}

class DashboardPage extends StatelessWidget {
  final controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Student',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(controller: controller.nameController,
                decoration: InputDecoration(labelText: 'Name')),
            Obx(() {
              return DropdownButton<String>(
                value: controller.selectedClass.value,
                onChanged: (newValue) {
                  controller.selectedClass.value = newValue!;
                },
                items: controller.classes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              );
            }),
            Obx(() {
              return DropdownButton<String>(
                value: controller.selectedDivision.value,
                onChanged: (newValue) {
                  controller.selectedDivision.value = newValue!;
                },
                items: controller.divisions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              );
            }),
            Obx(() {
              return controller.addStudentSucees == false ? ElevatedButton(
                  onPressed: () {
                    controller.addStudent();
                    controller.fetchStudents();
                  }, child: Text('Add Student')) : CircularProgressIndicator();
            }),
            SizedBox(height: 20),
            Text('Students List',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Expanded(
          child: FutureBuilder<List<Student>>(
            future: controller.fetchStudents(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return
                const Text("PLease wait!");
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No students added yet.');
              } else {
                controller.students.value = snapshot.data!;
                return Obx(
                      () => ListView.builder(
                    itemCount: controller.students.length,
                    itemBuilder: (context, index) {
                      final student = controller.students[index];
                      return ListTile(
                        title: Text('Student name: ${student.name}'),
                        subtitle: Text('${student.className} - ${student.division}'),
                      );
                    },
                  ),
                );
              }
            },
          ),)
          ],
        ),
      ),
    );
  }
}
