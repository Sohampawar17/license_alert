import 'package:flutter/material.dart';  
import 'package:logger/logger.dart';  
import '../../models/user_data.dart';  
import '../../services/authentication_serice.dart';  
import '../../services/userdata_services.dart';  
import '../add_records/add_records_screen.dart';  
import '../profile/profile_screen.dart';  
import 'package:intl/intl.dart';  

class HomeScreen extends StatefulWidget {  
  const HomeScreen({super.key});  

  @override  
  _HomeScreenState createState() => _HomeScreenState();  
}  

class _HomeScreenState extends State<HomeScreen> {  
  UserLicenseData userLicenseData = UserLicenseData();  
  int _selectedIndex = 0;  

  @override  
  void initState() {  
    super.initState();  
    FirebaseService().addOrUpdateLicenseData();  
    FirebaseService().getUserLicenseData().then((data) {  
      setState(() {  
        userLicenseData = data;  
      });  
      _checkExpiryNotifications(data); // Check expiring items  
    });  
  }  

  bool isExpiringSoon(String expiryDate) {  
    try {  
      final formatter = DateFormat("yyyy-MM-dd");  
      final expiry = formatter.parse(expiryDate);  
      final now = DateTime.now();  
      return expiry.difference(now).inDays <= 30; // Alert if less than or equal to 30 days  
    } catch (e) {  
      Logger().e('Error parsing date: $expiryDate - $e');  
      return false;  
    }  
  }  

  void _checkExpiryNotifications(UserLicenseData data) {  
    // Check for expiring license  
    if (data.licenseDetails != null &&  
        isExpiringSoon(data.licenseDetails!.dOE.toString())) {  
      _showNotification("License Expiry Alert",  
          "Your driving license is expiring soon on ${data.licenseDetails!.dOE}.");  
    }  
    // Check for expiring insurance  
    if (data.insuranceDetails != null &&  
        isExpiringSoon(data.insuranceDetails!.dateOfExpiry.toString())) {  
      _showNotification("Insurance Expiry Alert",  
          "Your insurance policy is expiring soon on ${data.insuranceDetails!.dateOfExpiry}.");  
    }  
    // Check for expiring PUC  
    if (data.pUC != null &&  
        isExpiringSoon(data.pUC!.dateOfExpiry.toString())) {  
      _showNotification("PUC Expiry Alert",  
          "Your PUC certificate is expiring soon on ${data.pUC!.dateOfExpiry}.");  
    }  
  }  

  void _showNotification(String title, String message) {  
    showDialog(  
      context: context,  
      builder: (BuildContext context) {  
        return AlertDialog(  
          title: Text(title),  
          content: Text(message),  
          actions: [  
            TextButton(  
              onPressed: () {  
                Navigator.of(context).pop();  
              },  
              child: const Text("OK"),  
            ),  
          ],  
        );  
      },  
    );  
  }  

  void _onItemTapped(int index) {  
    setState(() {  
      _selectedIndex = index;  
    });  
  }  

  @override  
  Widget build(BuildContext context) {  
    final List<Widget> _pages = <Widget>[  
      Scaffold(  
        appBar: AppBar(  
          automaticallyImplyLeading: false,
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
              Logger().i("Error fetching user license data");  
              return Center(child: const Text('Error fetching data'));  
            } else if (snapshot.hasData) {  
              UserLicenseData data = snapshot.data!;  
              return SingleChildScrollView(  
                child: Column(  
                  children: [  
                    const SizedBox(height: 16),  
                    Row(  
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,  
                      children: [  
                        _buildVirtualCard("My Virtual DL",   
                          data.licenseDetails?.dLNO.toString() ?? "N/A",""),  
                        _buildVirtualCard("My Virtual PUC", "",  
                          data.pUC?.certificateNumber.toString() ?? "N/A"),  
                      ],  
                    ),  
                    const SizedBox(height: 16),  
                    Padding(  
                      padding: const EdgeInsets.symmetric(horizontal: 16),  
                      child: Column(  
                        crossAxisAlignment: CrossAxisAlignment.center,  
                        children: [  
                          const Text("Status"),  
                          const SizedBox(height: 8),  
                           data.licenseDetails?.dLNO !=null ?
                  _buildAlertCard(
                    "License Details",
                    [
                      'Name: ${data.licenseDetails?.name ?? "N/A"}',
                      'DL No: ${data.licenseDetails?.dLNO ?? "N/A"}',
                      'Date of Expiry: ${data.licenseDetails?.dOE ?? "N/A"}',
                    ],
                    isExpiring: isExpiringSoon(data.licenseDetails?.dOE.toString() ?? ""),
                  ):  ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddLicenseForm()),
          );
        },
        child: const Text('Add License'),
            ),
                  const SizedBox(height: 8),
                  data.insuranceDetails?.policyNumber !=null ? _buildAlertCard(
                    "Insurance Details",
                    [
                      'Policy Number: ${data.insuranceDetails?.policyNumber ?? "N/A"}',
                      'Insurance Company: ${data.insuranceDetails?.insuranceCompany ?? "N/A"}',
                      'Date of Expiry: ${data.insuranceDetails?.dateOfExpiry ?? "N/A"}',
                    ],
                    isExpiring: isExpiringSoon(data.insuranceDetails?.dateOfExpiry.toString() ?? ""),
                  ) :  ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddInsuranceForm()),
          );
        },
        child: const Text('Add Insurance'),
            ),
                 
                  const SizedBox(height: 8),
                data.pUC?.certificateNumber != null ?
                  _buildAlertCard(
                    "PUC Details",
                    [
                      'Certificate Number: ${data.pUC?.certificateNumber ?? "N/A"}',
                      'Date of Expiry: ${data.pUC?.dateOfExpiry ?? "N/A"}',
                    ],
                    isExpiring: isExpiringSoon(data.pUC?.dateOfExpiry.toString() ?? ""),
                  ):  ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPUCForm()),
          );
        },
        child: const Text('Add PUC'),
            ) 
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
      const ProfilePage(),  
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

  Widget _buildVirtualCard(String title, String dlNo, String certificateNumber) {  
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
            Text("DL No: ${dlNo}"),  
          if (title == "My Virtual PUC")  
            Text("Certificate No: ${certificateNumber}"),  
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
          // Add your onTap logic if needed  
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