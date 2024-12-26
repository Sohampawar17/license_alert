import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../models/user_data.dart';
import '../../services/authentication_serice.dart';
import '../../services/userdata_services.dart';
import '../add_records/add_records_screen.dart';
import '../profile/profile_screen.dart';

// Import Help Page
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
 UserLicenseData userLicenseData=UserLicenseData();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    FirebaseService().addOrUpdateLicenseData();
    FirebaseService().getUserLicenseData().then((data) {
      setState(() {
        userLicenseData = data;
      });
    });
    
  }

  bool isExpiringSoon(String expiryDate) {
    final expiry = DateTime.parse(expiryDate);
    final now = DateTime.now();
    return expiry.difference(now).inDays <= 30;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
// Check for missing data in license, insurance, and PUC
Widget _buildAddButton(UserLicenseData data) {
  if (data.licenseDetails == null) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddLicenseForm()),
        );
      },
      child: const Text('Add License'),
    );
  } else if (data.insuranceDetails == null) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddInsuranceForm()),
        );
      },
      child: const Text('Add Insurance'),
    );
  } else if (data.pUC == null) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddPUCForm()),
        );
      },
      child: const Text('Add PUC'),
    );
  } else {
    return const SizedBox(); // If all data is present, show nothing
  }
}

 @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = <Widget>[
      Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlueAccent,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "License Alert",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "One stop transport solution for citizen",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                AuthenticationService().signOut(context);
              },
              icon: const Icon(Icons.logout_outlined),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: FutureBuilder<UserLicenseData>(
  future: FirebaseService().getUserLicenseData(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
       UserLicenseData data = snapshot.data ?? UserLicenseData();
      // If there is an error, handle it here
      Logger().i(data.toJson());
      return Column(
        children: [
          ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddLicenseForm()),
        );
      },
      child: const Text('Add License'),
    ),
    ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddInsuranceForm()),
        );
      },
      child: const Text('Add Insurance'),
    ),
    ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddPUCForm()),
        );
      },
      child: const Text('Add PUC'),
    )
        ],
      );
    } else if (snapshot.hasData) {
      UserLicenseData data = snapshot.data!;
      return SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildVirtualCard("My Virtual DL", data.licenseDetails),
                _buildVirtualCard("My Virtual PUC", data.pUC),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Alerts"),
                  const SizedBox(height: 8),
                  _buildAlertCard(
                    "License Details",
                    [
                      'Name: ${data.licenseDetails?.name ?? "N/A"}',
                      'DL No: ${data.licenseDetails?.dLNO ?? "N/A"}',
                      'Date of Expiry: ${data.licenseDetails?.dOE ?? "N/A"}',
                    ],
                    isExpiring: isExpiringSoon(data.licenseDetails?.dOE.toString() ?? ""),
                  ),
                  const SizedBox(height: 8),
                  _buildAlertCard(
                    "Insurance Details",
                    [
                      'Policy Number: ${data.insuranceDetails?.policyNumber ?? "N/A"}',
                      'Insurance Company: ${data.insuranceDetails?.insuranceCompany ?? "N/A"}',
                      'Date of Expiry: ${data.insuranceDetails?.dateOfExpiry ?? "N/A"}',
                    ],
                    isExpiring: isExpiringSoon(data.insuranceDetails?.dateOfExpiry.toString() ?? ""),
                  ),
                  const SizedBox(height: 8),
                  _buildAlertCard(
                    "PUC Details",
                    [
                      'Certificate Number: ${data.pUC?.certificateNumber ?? "N/A"}',
                      'Date of Expiry: ${data.pUC?.dateOfExpiry ?? "N/A"}',
                    ],
                    isExpiring: isExpiringSoon(data.pUC?.dateOfExpiry.toString() ?? ""),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return const Center(child: Text('No data available'));
    }
  },
),

      ),
      ProfilePage(),
      HelpPage(),
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.lightBlueAccent,
        selectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help),
            label: 'Help',
          ),
        ],
      ),
    );
  }



  Widget _buildVirtualCard(String title, dynamic data) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(
            title == "My Virtual DL" ? Icons.card_membership : Icons.assignment,
            size: 40,
            color: Colors.lightBlue,
          ),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center),
          if (title == "My Virtual DL")
            Text("DL No: ${data.dlNo}"),
          if (title == "My Virtual PUC")
            Text("Certificate No: ${data.certificateNumber}"),
        ],
      ),
    );
  }

  Widget _buildAlertCard(String title, List<String> details, {required bool isExpiring}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...details.map((detail) => Text(detail)).toList(),
            Text(
              "We will notify you 3 days before expiry.",
              style: TextStyle(color: isExpiring ? Colors.red : Colors.blue),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.refresh,
          color: Colors.blue,
        ),
        onTap: () {
          // Add your onTap logic here
        },
      ),
    );
  }
}

// Help Page widget
class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: const Text("Help"),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.help, size: 100, color: Colors.lightBlue),
            SizedBox(height: 20),
            Text("Help Page", style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            Text("Here you can find help and support.", textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

