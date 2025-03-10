import 'package:flutter/material.dart';  
import 'package:logger/logger.dart';  
import '../../models/user_data.dart';  
import '../../services/authentication_serice.dart';  
import '../../services/notification_service.dart';
import '../../services/userdata_services.dart';
import '../add_records/add_records_screen.dart';  
import '../profile/profile_screen.dart';  
import 'package:flutter_local_notifications/flutter_local_notifications.dart';  



class HomeScreen extends StatefulWidget {  
  const HomeScreen({super.key});  

  @override  
  _HomeScreenState createState() => _HomeScreenState();  
}  

class _HomeScreenState extends State<HomeScreen> {  
  UserLicenseData userLicenseData = UserLicenseData();  
  int _selectedIndex = 0;  
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();  


  @override  
  void initState() {  
    super.initState();  
    FirebaseService().addOrUpdateLicenseData();  
    FirebaseService().getUserLicenseData().then((data) {  
      setState(() {  
        userLicenseData = data;  
      });  
NotificationService.scheduleNotifications(userLicenseData);
      _showExpiringNotifications(); // Check expiring items  
    });  
  }  
bool isExpiringSoon(String? expiryDate, {int thresholdDays = 7}) {
  if (expiryDate == null || expiryDate.isEmpty) return false;

  try {
    DateTime expiry = DateTime.parse(expiryDate);
    final now = DateTime.now();
    return expiry.difference(now).inDays <= thresholdDays;
  } catch (e) {
    debugPrint("Invalid date format: $expiryDate"); // Log for debugging
    return false;
  }
}


  // Show SnackBar Alerts for each expiring item
  void _showExpiringNotifications() {
    List<String> expiringAlerts = [];

    if (userLicenseData.licenseDetails != null && isExpiringSoon(userLicenseData.licenseDetails!.dOE.toString())) {
      expiringAlerts.add("License is expiring soon on ${userLicenseData.licenseDetails!.dOE.toString()}");
    }
    if (userLicenseData.insuranceDetails != null && isExpiringSoon(userLicenseData.insuranceDetails!.dateOfExpiry.toString())) {
      expiringAlerts.add("Insurance is expiring soon on ${userLicenseData.insuranceDetails!.dateOfExpiry.toString()}");
    }
    if (userLicenseData.pUC != null && isExpiringSoon(userLicenseData.pUC!.dateOfExpiry.toString())) {
      expiringAlerts.add("PUC is expiring soon on ${userLicenseData.pUC!.dateOfExpiry.toString()}");
    }

    for (var alert in expiringAlerts) {
      Future.delayed(const Duration(milliseconds: 500), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(alert),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      });
    }
  }

  // Show Material Banner for Expiring Items
Widget _buildBannerIfExpiring() {
  List<String> expiringAlerts = [];

   if (userLicenseData.licenseDetails != null && isExpiringSoon(userLicenseData.licenseDetails!.dOE.toString())) {
    expiringAlerts.add("License is expiring soon on ${userLicenseData.licenseDetails!.dOE.toString()}");
  }
  if (userLicenseData.insuranceDetails != null && isExpiringSoon(userLicenseData.insuranceDetails!.dateOfExpiry.toString())) {
    expiringAlerts.add("Insurance is expiring soon on ${userLicenseData.insuranceDetails!.dateOfExpiry.toString()}");
  }
  if (userLicenseData.pUC != null && isExpiringSoon(userLicenseData.pUC!.dateOfExpiry.toString())) {
    expiringAlerts.add("PUC is expiring soon on ${userLicenseData.pUC!.dateOfExpiry.toString()}");
  }

  if (expiringAlerts.isEmpty) return const SizedBox.shrink();
  return Column(
    children: expiringAlerts.map((alert) {
      return MaterialBanner(
        content: Text(alert, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        leading: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
        backgroundColor: Colors.yellow[100],
        actions: [
          TextButton(
            onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: const Text("DISMISS", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    }).toList(),
  );
}
  
  void _onItemTapped(int index) {  
    setState(() {  
      _selectedIndex = index;  
    });  
  }  

  @override  
  Widget build(BuildContext context) {  
    final List<Widget> pages = <Widget>[  
      Scaffold(  
        appBar: AppBar(  
          automaticallyImplyLeading: false,
          backgroundColor: Colors.lightBlueAccent,  
          elevation: 0,  
          title: const Column(  
            crossAxisAlignment: CrossAxisAlignment.start,  
            children: [  
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
              return Center(  
      // If there is an error, handle it here
    child:  Column(
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
      ));  
            } else if (snapshot.hasData) {  
              UserLicenseData data = snapshot.data!;  
              return SingleChildScrollView(  
                child: Column(  
                  children: [  
                    _buildBannerIfExpiring(),
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
                    isExpiring:false,
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
                      'PUC Number: ${data.pUC?.certificateNumber ?? "N/A"}',
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
     
       const HelpPage(), 
        const ProfilePage(),   
    ];  

    return Scaffold(  
      body: pages[_selectedIndex],  
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
            icon: Icon(Icons.edit_document),  
            label: 'Documents',  
          ), 
          BottomNavigationBarItem(  
            icon: Icon(Icons.account_circle),  
            label: 'Profile',  
          ),  
           
        ],  
      ),  
    );  
  }  

   Widget _buildVirtualCard(String title, String dlNo, String certificateNumber) {
    return Container(
      width: 180,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.lightBlue.shade400, Colors.blue.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(
              title == "My Virtual DL" ? Icons.card_membership : Icons.assignment,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          if (title == "My Virtual DL")
            Text(
              "DL No: $dlNo",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          if (title == "My Virtual PUC")
            Text(
              "PUC No: $certificateNumber",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
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
            ...details.map((detail) => Text(detail)),  
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
class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  UserLicenseData userLicenseData = UserLicenseData();
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchUserLicenseData();
  }

  void _fetchUserLicenseData() async {
    setState(() => isLoading = true); // Show loading indicator
    final data = await FirebaseService().getUserLicenseData();
    setState(() {
      userLicenseData = data;
      isLoading = false; // Hide loading indicator
    });
  }

  void navigateToForm(Widget formScreen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => formScreen))
        .then((_) => _fetchUserLicenseData()); // Refresh data after returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vehicle Documents"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading bar
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDocumentSection(
                    title: "License",
                    exists: userLicenseData.licenseDetails?.address != null,
                    dateOfExpiry: userLicenseData.licenseDetails?.dOE,
                    onPressed: () => navigateToForm(const AddLicenseForm()),
                  ),
                  _buildDocumentSection(
                    title: "PUC",
                    exists: userLicenseData.pUC?.certificateNumber != null,
                    dateOfExpiry: userLicenseData.pUC?.dateOfExpiry,
                    onPressed: () => navigateToForm(const AddPUCForm()),
                  ),
                  _buildDocumentSection(
                    title: "Insurance",
                    exists: userLicenseData.insuranceDetails?.insuranceCompany != null,
                    dateOfExpiry: userLicenseData.insuranceDetails?.dateOfExpiry,
                    onPressed: () => navigateToForm(const AddInsuranceForm()),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDocumentSection({
    required String title,
    required bool exists,
    String? dateOfExpiry,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(Icons.description, color: exists ? Colors.green : Colors.blue, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Expiry Date: ${dateOfExpiry ?? 'N/A'}",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: isLoading ? null : onPressed, // Disable button while loading
              icon: Icon(exists ? Icons.edit : Icons.add),
              label: Text(exists ? "Update" : "Create"),
              style: ElevatedButton.styleFrom(
                backgroundColor: exists ? Colors.green : Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}