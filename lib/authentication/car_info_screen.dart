import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../global/global.dart';
import '../splash/splash_screen.dart';

class CarInfoScreen extends StatefulWidget {
  const CarInfoScreen({Key? key}) : super(key: key);

  @override
  State<CarInfoScreen> createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> {
  TextEditingController carModelEditingController = TextEditingController();
  TextEditingController carNumberTextEditingController =
      TextEditingController();
  TextEditingController carColorEditingController = TextEditingController();
  List<String> carTypeList = ['Car-X', 'Car-go', 'Bike'];
  String? selectedCarType;

  saveCarInfo() {
    Map driverCarInfoMap = {
      'car_color': carColorEditingController.text.trim(),
      'car_number': carNumberTextEditingController.text.trim(),
      'car_model': carModelEditingController.text.trim(),
      'type': selectedCarType,
    };
    DatabaseReference driversRef =
        FirebaseDatabase.instance.ref().child('drivers');
    driversRef
        .child(currentFirebaseUser!.uid)
        .child('car_details')
        .set(driverCarInfoMap);
    Fluttertoast.showToast(msg: 'Car Details has been saved, Congratulations.');
    Navigator.push(
        context, MaterialPageRoute(builder: (c) => const SplashView()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset('assets/images/logo1.png'),
              ),
              const SizedBox(height: 10),
              const Text(
                'Drive car Details',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                controller: carModelEditingController,
                style: const TextStyle(color: Colors.grey),
                decoration: const InputDecoration(
                  labelText: 'Car Model',
                  hintText: 'Car Model',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                  labelStyle: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              TextField(
                controller: carNumberTextEditingController,
                style: const TextStyle(color: Colors.grey),
                decoration: const InputDecoration(
                  labelText: 'Car Number',
                  hintText: 'Car Number',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                  labelStyle: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              TextField(
                controller: carColorEditingController,
                style: const TextStyle(color: Colors.grey),
                decoration: const InputDecoration(
                  labelText: 'Car Color',
                  hintText: 'Car Color',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                  labelStyle: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              const SizedBox(height: 15),
              DropdownButton(
                dropdownColor: Colors.black,
                iconSize: 20,
                items: carTypeList.map((car) {
                  return DropdownMenuItem(
                      value: car,
                      child: Text(
                    car,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedCarType = newValue.toString();
                  });
                },
                hint: const Text(
                  'Please choose Car Type',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                value: selectedCarType,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (carColorEditingController.text.isNotEmpty &&
                      carNumberTextEditingController.text.isNotEmpty &&
                      carModelEditingController.text.isNotEmpty &&
                      selectedCarType != null) {
                    saveCarInfo();
                  }
                },
                style:
                    ElevatedButton.styleFrom(primary: Colors.lightGreenAccent),
                child: const Text(
                  'Save Now',
                  style: TextStyle(color: Colors.black54, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
