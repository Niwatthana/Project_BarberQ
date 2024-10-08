import 'package:barberapp/loginpage.dart';
import 'package:barberapp/pages/cutomer/bookinghistory.dart';
import 'package:barberapp/pages/cutomer/bookingshop.dart';
import 'package:barberapp/pages/cutomer/profilecutomer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeCustomer extends StatefulWidget {
  const HomeCustomer({super.key});

  @override
  State<HomeCustomer> createState() => _HomeCustomerState();
}

class _HomeCustomerState extends State<HomeCustomer> {
  int _selectedIndex = 0;
  bool hasExistingBooking = false;

  @override
  void initState() {
    super.initState();
    checkExistingBooking();
  }

  Future<void> checkExistingBooking() async {
    QuerySnapshot bookingSnapshot = await FirebaseFirestore.instance
        .collection('Bookings')
        .where('barberid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('status', isEqualTo: 'booked')
        .get();

    if (bookingSnapshot.docs.isNotEmpty) {
      setState(() {
        hasExistingBooking = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // กำหนดสีหลักสำหรับธีมร้านตัดผม
    const Color primaryColor = Color(0xFF1B4B4B);
    const Color accentColor = Color(0xFFD70000); // แดงทอง
    const Color backgroundColor = Color(0xFFF5F5F5); // เทาอ่อน

    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu"),
        backgroundColor: primaryColor,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (String result) {
              switch (result) {
                case 'history':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CutomerProfile(
                        docid: FirebaseAuth.instance.currentUser!.uid,
                      ),
                    ),
                  );
                  break;
                case 'logout':
                  showLogoutDialog(context);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'history',
                child: Text('ประวัติของฉัน'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('ออกจากระบบ'),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        color: backgroundColor,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16.0),
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  MenuGrid(hasExistingBooking: hasExistingBooking, primaryColor: primaryColor, accentColor: accentColor),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.person,
                    size: 64,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Barber Shop",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: _selectedIndex == 0 ? accentColor : Colors.black),
              title: const Text('หน้าหลัก'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomeCustomer()));
              },
            ),
            ListTile(
              leading: Icon(Icons.book_online, color: _selectedIndex == 1 && !hasExistingBooking ? accentColor : Colors.black),
              title: Text(
                'การจอง',
                style: TextStyle(
                  color: hasExistingBooking ? Colors.grey : Colors.black,
                ),
              ),
              selected: _selectedIndex == 1,
              onTap: hasExistingBooking
                  ? null
                  : () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BookingShop()));
                    },
            ),
            ListTile(
              leading: Icon(Icons.history, color: _selectedIndex == 2 ? accentColor : Colors.black),
              title: const Text('ประวัติการจอง'),
              selected: _selectedIndex == 2,
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => BookingHistory()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MenuGrid extends StatelessWidget {
  final bool hasExistingBooking;
  final Color primaryColor;
  final Color accentColor;

  const MenuGrid({
    required this.hasExistingBooking,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: 1,
      children: [
        MenuButton(
          icon: Icon(Icons.book_online, size: 50, color: accentColor),
          label: 'การจอง',
          color: hasExistingBooking ? Colors.grey : Colors.black,
          backgroundColor: hasExistingBooking ? Colors.grey[200]! : Colors.white,
          onPressed: hasExistingBooking
              ? null
              : () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => BookingShop()));
                },
        ),
        MenuButton(
          icon: Icon(Icons.history, size: 50, color: accentColor),
          label: 'ประวัติการจอง',
          color: Colors.black,
          backgroundColor: Colors.white,
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => BookingHistory()));
          },
        ),
      ],
    );
  }
}

class MenuButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final Color color;
  final Color backgroundColor;
  final VoidCallback? onPressed;

  const MenuButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              SizedBox(height: 10.0),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18.0,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('ออกจากระบบ', style: TextStyle(color: Colors.red)),
        content: const Text(
          'คุณต้องการออกจากระบบหรือไม่?',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('ตกลง', style: TextStyle(color: Colors.green)),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      );
    },
  );
}
