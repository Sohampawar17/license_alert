import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  String selectedAuthClass = 'Class A';

  final databaseRef = FirebaseFirestore.instance.collection('licenses_data');
@override
void initState() {
  super.initState();
  _fetchLicenseData();
}

Future<void> _fetchLicenseData() async {
  String user = FirebaseAuth.instance.currentUser!.uid;
  DocumentSnapshot docSnapshot = await databaseRef.doc(user).get();

  if (docSnapshot.exists) {
    var data = docSnapshot.data() as Map<String, dynamic>;
    if (data.containsKey('licenseDetails')) {
      var licenseData = data['licenseDetails'];
      setState(() {
        _dlNoController.text = licenseData['dlNo'] ?? '';
        _doeController.text = licenseData['doe'] ?? '';
        _doiController.text = licenseData['doi'] ?? '';
        _pinController.text = licenseData['pin'] ?? '';
        _addressController.text = licenseData['address'] ?? '';
        selectedAuthClass = licenseData['authorizationClass'] ?? 'Class A';
      });
    }
  }
}


  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      controller.text = "${pickedDate.toLocal()}".split(' ')[0];
    }
  }

  Widget _buildInputField(
      TextEditingController controller, String label, IconData icon,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: label,
              prefixIcon: Icon(icon, color: Colors.blueAccent),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Please enter $label' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            readOnly: true,
            onTap: () => _selectDate(context, controller),
            decoration: InputDecoration(
              hintText: label,
              prefixIcon: Icon(icon, color: Colors.blueAccent),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Please enter $label' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: selectedAuthClass,
        decoration: InputDecoration(
          labelText: 'Authorization Class',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
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
    );
  }
Future<void> _submitForm() async {
  if (_formKey.currentState?.validate() ?? false) {
    String user = FirebaseAuth.instance.currentUser!.uid;

    var licenseData = {
      'dlNo': _dlNoController.text,
      'doe': _doeController.text,
      'doi': _doiController.text,
      'pin': _pinController.text,
      'address': _addressController.text,
      'authorizationClass': selectedAuthClass,
    };

    DocumentReference userDoc = databaseRef.doc(user);

    // Check if document exists
    DocumentSnapshot docSnapshot = await userDoc.get();

    if (docSnapshot.exists) {
      // Update the document if it exists
      await userDoc.update({
        "licenseDetails": licenseData,
      });
    } else {
      // Create the document if it doesn’t exist
      await userDoc.set({
        "id": user,
        "licenseDetails": licenseData,
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('License saved successfully')),
    );

    Navigator.pop(context);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add License'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('* Required Field',
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      _buildInputField(
                          _dlNoController, 'DL Number*', Icons.credit_card),
                      _buildDateField(
                          _doiController, 'Date of Issue*', Icons.event),
                      _buildDateField(
                          _doeController, 'Date of Expiry*', Icons.event),
                      _buildInputField(_pinController, 'PIN Code*', Icons.pin,
                          isNumber: true),
                      _buildInputField(
                          _addressController, 'Address*', Icons.location_on),
                      _buildDropdownField(),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.lightBlueAccent,
                ),
                child: const Text(
                  'SAVE',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddInsuranceForm extends StatefulWidget {
  const AddInsuranceForm({super.key});

  @override
  _AddInsuranceFormState createState() => _AddInsuranceFormState();
}

class _AddInsuranceFormState extends State<AddInsuranceForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _insuranceCompanyController =
      TextEditingController();
  final TextEditingController _policyNumberController = TextEditingController();
  final TextEditingController _vehicleNameController = TextEditingController();
  final TextEditingController _vehicleModelController = TextEditingController();
  final TextEditingController _vehicleNumberController =
      TextEditingController();

  final databaseRef = FirebaseFirestore.instance.collection('licenses_data');
@override
void initState() {
  super.initState();
  _fetchInsuranceData();
}

Future<void> _fetchInsuranceData() async {
  String user = FirebaseAuth.instance.currentUser!.uid;
  DocumentSnapshot docSnapshot = await databaseRef.doc(user).get();

  if (docSnapshot.exists) {
    var data = docSnapshot.data() as Map<String, dynamic>;
    if (data.containsKey('insuranceDetails')) {
      var insuranceData = data['insuranceDetails'];
      setState(() {
        _insuranceCompanyController.text = insuranceData['insuranceCompany'] ?? '';
        _policyNumberController.text = insuranceData['policyNumber'] ?? '';
        _vehicleNameController.text = insuranceData['vehicleName'] ?? '';
        _vehicleModelController.text = insuranceData['vehicleModel'] ?? '';
        _vehicleNumberController.text = insuranceData['vehicleNumber'] ?? '';
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Insurance'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        const Text('* Required Field', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 16),

                      _buildTextField(_insuranceCompanyController,
                          'Insurance Company*', Icons.business),
                      _buildTextField(_policyNumberController, 'Policy Number*',
                          Icons.policy),
                      _buildTextField(_vehicleNameController, 'Vehicle Name*',
                          Icons.directions_car),
                      _buildTextField(_vehicleModelController, 'Vehicle Model*',
                          Icons.car_rental),
                      _buildTextField(_vehicleNumberController,
                          'Vehicle Number*', Icons.confirmation_number),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.lightBlueAccent,
                ),
                child: const Text(
                  'SAVE',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: label,
              prefixIcon: Icon(icon, color: Colors.blueAccent),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Please enter $label' : null,
          ),
        ],
      ),
    );
  }
Future<void> _submitForm() async {
  if (_formKey.currentState?.validate() ?? false) {
    String user = FirebaseAuth.instance.currentUser!.uid;

    var insuranceData = {
      'insuranceCompany': _insuranceCompanyController.text,
      'policyNumber': _policyNumberController.text,
      'vehicleName': _vehicleNameController.text,
      'vehicleModel': _vehicleModelController.text,
      'vehicleNumber': _vehicleNumberController.text,
    };

    DocumentReference userDoc = databaseRef.doc(user);

    // Check if document exists
    DocumentSnapshot docSnapshot = await userDoc.get();

    if (docSnapshot.exists) {
      // Update the document if it exists
      await userDoc.update({
        "insuranceDetails": insuranceData,
      });
    } else {
      // Create the document if it doesn’t exist
      await userDoc.set({
        "id": user,
        "insuranceDetails": insuranceData,
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Insurance saved successfully')),
    );

    Navigator.pop(context);
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
  final TextEditingController _certificateNumberController =
      TextEditingController();
  final TextEditingController _pucDateOfIssueController =
      TextEditingController();
  final TextEditingController _pucDateOfExpiryController =
      TextEditingController();

  final databaseRef = FirebaseFirestore.instance.collection('licenses_data');
  @override
void initState() {
  super.initState();
  _fetchPUCData();
}
Future<void> _fetchPUCData() async {
  String user = FirebaseAuth.instance.currentUser!.uid;
  DocumentSnapshot docSnapshot = await databaseRef.doc(user).get();

  if (docSnapshot.exists) {
    var data = docSnapshot.data() as Map<String, dynamic>;
    if (data.containsKey('PUC')) {
      var pucData = data['PUC'];
      setState(() {
        // Example fields for PUC (modify based on actual Firestore data)
        _certificateNumberController.text=pucData['certificateNumber'] ?? '';
        _pucDateOfIssueController.text = pucData['dateOfIssue'] ?? '';
        _pucDateOfExpiryController.text = pucData['dateOfExpiry'] ?? '';
      });
    }
  }
}

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add PUC'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('* Required Field',
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      _buildTextField(_certificateNumberController,
                          'PUC Certificate Number*', Icons.confirmation_number),
                      _buildDateField(_pucDateOfIssueController,
                          'PUC Date of Issue*', Icons.calendar_today),
                      _buildDateField(_pucDateOfExpiryController,
                          'PUC Date of Expiry*', Icons.calendar_today),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.lightBlueAccent,
                ),
                child: const Text(
                  'SAVE',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: label,
              prefixIcon: Icon(icon, color: Colors.blueAccent),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Please enter $label' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon, color: Colors.blueAccent),
              suffixIcon: IconButton(
                icon: const Icon(Icons.date_range, color: Colors.blueAccent),
                onPressed: () => _selectDate(context, controller),
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Please select $label' : null,
            readOnly: true,
            onTap: () => _selectDate(context, controller),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      var pucData = {
        'certificateNumber': _certificateNumberController.text,
        'dateOfIssue': _pucDateOfIssueController.text,
        'dateOfExpiry': _pucDateOfExpiryController.text,
      };

      try {
        String userId = FirebaseAuth.instance.currentUser!.uid;
        await databaseRef.doc(userId).set({
          "id": userId,
          "PUC": pucData,
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PUC added successfully')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
