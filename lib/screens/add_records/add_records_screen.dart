import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../router.router.dart';

class AddLicenseForm extends StatefulWidget {
  const AddLicenseForm({super.key});

  @override
  _AddLicenseFormState createState() => _AddLicenseFormState();
}
class _AddLicenseFormState extends State<AddLicenseForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dlNoController = TextEditingController();
  final TextEditingController _doeController = TextEditingController();
  final TextEditingController _doiController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  List<String> authClass = ['Class A', 'Class B', 'Class C'];
  String selectedAuthClass = 'Class A'; // Default selection

  final databaseRef = FirebaseFirestore.instance.collection('licenses_data'); // Reference to the 'licenses' node

  // Function to open the date picker
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      controller.text = "${pickedDate.toLocal()}".split(' ')[0]; // Set the selected date
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add License'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // License Form Fields
              TextFormField(
                controller: _dlNoController,
                decoration: const InputDecoration(labelText: 'DL Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter DL number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _doeController,
                decoration: const InputDecoration(labelText: 'Date of Expiry'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter date of expiry';
                  }
                  return null;
                },
                onTap: () => _selectDate(context, _doeController),
                readOnly: true, // Make the text field read-only to show date picker
              ),
              TextFormField(
                controller: _doiController,
                decoration: const InputDecoration(labelText: 'Date of Issue'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter date of issue';
                  }
                  return null;
                },
                onTap: () => _selectDate(context, _doiController),
                readOnly: true, // Make the text field read-only to show date picker
              ),
              TextFormField(
                controller: _pinController,
                decoration: const InputDecoration(labelText: 'PIN Code'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter PIN code';
                  }
                  return null;
                },
                keyboardType: TextInputType.number, // Set the keyboard type to number
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),

              // Authorization Class Dropdown
              DropdownButtonFormField<String>(
                value: selectedAuthClass,
                decoration: const InputDecoration(labelText: 'Authorization Class'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedAuthClass = newValue!;
                  });
                },
                items: authClass.map((classItem) {
                  return DropdownMenuItem<String>(
                    value: classItem,
                    child: Text(classItem),
                  );
                }).toList(),
              ),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Gather the data
      var licenseData = {
        'dlNo': _dlNoController.text,
        'doe': _doeController.text,
        'doi': _doiController.text,
        'pin': _pinController.text,
        'address': _addressController.text,
        'authClass': selectedAuthClass,
      };
String user= FirebaseAuth.instance.currentUser!.uid;
      // Add data to Firebase Realtime Database
     await databaseRef.doc(user).update({
  "id": FirebaseAuth.instance.currentUser!.uid,
  "licenseDetails": licenseData,  // Directly passing the map
}); // Generate a new key for the license data

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('License added successfully')),
      );

      // Optionally, navigate back or reset the form
        Navigator.popAndPushNamed(context,Routes.homeScreen); // Go back to the previous screen after submission
    }
  }
}

class AddInsuranceForm extends StatefulWidget {
  const AddInsuranceForm({super.key});

  @override
  _AddInsuranceFormState createState() => _AddInsuranceFormState();
}

class _AddInsuranceFormState extends State<AddInsuranceForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _insuranceCompanyController = TextEditingController();
  final TextEditingController _policyNumberController = TextEditingController();
  final TextEditingController _vehicleNameController = TextEditingController();
  final TextEditingController _vehicleModelController = TextEditingController();
  final TextEditingController _vehicleNumberController = TextEditingController();
final databaseRef = FirebaseFirestore.instance.collection('licenses_data'); // Reference to the 'insurance' node

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Insurance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // Insurance Form Fields
              TextFormField(
                controller: _insuranceCompanyController,
                decoration: const InputDecoration(labelText: 'Insurance Company'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter insurance company';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _policyNumberController,
                decoration: const InputDecoration(labelText: 'Policy Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter policy number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _vehicleNameController,
                decoration: const InputDecoration(labelText: 'Vehicle Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _vehicleModelController,
                decoration: const InputDecoration(labelText: 'Vehicle Model'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle model';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _vehicleNumberController,
                decoration: const InputDecoration(labelText: 'Vehicle Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle number';
                  }
                  return null;
                },
              ),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Gather the data
      var insuranceData = {
        'insuranceCompany': _insuranceCompanyController.text,
        'policyNumber': _policyNumberController.text,
        'vehicleName': _vehicleNameController.text,
        'vehicleModel': _vehicleModelController.text,
        'vehicleNumber': _vehicleNumberController.text,
      };
String user= FirebaseAuth.instance.currentUser!.uid;

// Generate a new key for the insurance data
          // Add data to Firebase Realtime Database
     await databaseRef.doc(user).update({
  "id": FirebaseAuth.instance.currentUser!.uid,
"insuranceDetails": insuranceData,   // Directly passing the map
});

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insurance added successfully')),
      );

      // Optionally, navigate back or reset the form
        Navigator.popAndPushNamed(context,Routes.homeScreen); // Go back to the previous screen after submission
    }
  }
}

class AddPUCForm extends StatefulWidget {
  const AddPUCForm({super.key});

  @override
  _AddPUCFormState createState() => _AddPUCFormState();
}

class _AddPUCFormState extends State<AddPUCForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _certificateNumberController = TextEditingController();
  final TextEditingController _pucDateOfIssueController = TextEditingController();
  final TextEditingController _pucDateOfExpiryController = TextEditingController();
final databaseRef = FirebaseFirestore.instance.collection('licenses_data');  // Function to open the date picker
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      controller.text = "${pickedDate.toLocal()}".split(' ')[0]; // Set the selected date
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add PUC'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // PUC Form Fields
              TextFormField(
                controller: _certificateNumberController,
                decoration: const InputDecoration(labelText: 'PUC Certificate Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter certificate number';
                  }
                  return null;
                },
              ),
              TextFormField(
  controller: _pucDateOfIssueController,
  decoration: const InputDecoration(labelText: 'PUC Date of Issue'),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter date of issue';
    }
    return null;
  },
  onTap: () => _selectDate(context, _pucDateOfIssueController),
  readOnly: true, // Make the text field read-only to show date picker
),
TextFormField(
  controller: _pucDateOfExpiryController,
  decoration: const InputDecoration(labelText: 'PUC Date of Expiry'),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter date of expiry';
    }
    return null;
  },
  onTap: () => _selectDate(context, _pucDateOfExpiryController),
  readOnly: true, // Make the text field read-only to show date picker
),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Collect data from the form
      var pucData = {
        'certificateNumber': _certificateNumberController.text,
        'dateOfIssue': _pucDateOfIssueController.text,
        'dateOfExpiry': _pucDateOfExpiryController.text,
      };

      // Save data to Firebase Realtime Database
      try {
        // Generate a unique key for the PUC data
         // Add data to Firebase Realtime Database
      // Generate a new key for the insurance data
      String user= FirebaseAuth.instance.currentUser!.uid;

       await databaseRef.doc(user).update({
  "id": FirebaseAuth.instance.currentUser!.uid,
"PUC": pucData,    // Directly passing the map
});

        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PUC added successfully')),
        );

        // Optionally, navigate back or reset the form
        Navigator.popAndPushNamed(context,Routes.homeScreen); // Go back to the previous screen after submission
      } catch (e) {
        // Handle errors and show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
