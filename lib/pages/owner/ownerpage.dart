import 'package:barberapp/pages/owner/owner_bookings.dart';
import 'package:barberapp/pages/owner/owner_bookinguser.dart';
import 'package:barberapp/pages/owner/owner_hair.dart';
import 'package:barberapp/pages/owner/owner_invite.dart';
import 'package:barberapp/pages/owner/owner_summaryreport.dart';
import 'package:barberapp/pages/owner/profileowner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:barberapp/loginpage.dart';
import 'package:barberapp/pages/owner/owner_epy.dart';
import 'package:barberapp/pages/owner/ownershop.dart';

class OwnerPage extends StatefulWidget {
  const OwnerPage({super.key});

  @override
  State<OwnerPage> createState() => _OwnerPageState();
}

class _OwnerPageState extends State<OwnerPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu"),
        actions: <Widget>[
          PopupMenuButton<String>(
            icon: Icon(Icons.account_circle),
            onSelected: (String result) {
              switch (result) {
                case 'history':
                  // Navigate to customer booking history page
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OwnerProfile(
                                docid: FirebaseAuth.instance.currentUser!.uid,
                              )));
                  break;
                case 'logout':
                  showLogoutDialog(context);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
      body: ListView(
        shrinkWrap: true,
        children: [
          Container(
            height: 700,
            padding: EdgeInsets.only(top: 15),
            decoration: BoxDecoration(
              color: Color(0xFFEDECF2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35),
                topRight: Radius.circular(35),
              ),
            ),
            child: Column(
              children: [
                MenuGrid(),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text("BarBer Shop"),
            ),
            ListTile(
              title: const Text('หน้าหลัก'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => OwnerPage()));
              },
            ),
            ListTile(
              title: const Text('ร้านตัดผมของฉัน'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Ownershop()));
              },
            ),
            ListTile(
              title: const Text('ช่างตัดผม'),
              selected: _selectedIndex == 2,
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => OwnerEmployee()));
              },
            ),
            ListTile(
              title: const Text('ทรงผม'),
              selected: _selectedIndex == 3,
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                });
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Ownerhair()));
              },
            ),
            ListTile(
              title: const Text('การจองของลูกค้า'),
              selected: _selectedIndex == 4,
              onTap: () {
                setState(() {
                  _selectedIndex = 4;
                });
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OwnerBookingUser()));
              },
            ),
            ListTile(
              title: const Text('การจองทั้งหมดของร้าน'),
              selected: _selectedIndex == 5,
              onTap: () {
                setState(() {
                  _selectedIndex = 5;
                });
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => OwnerBookings()));
              },
            ),
            ListTile(
              title: const Text('รายงานสรุป'),
              selected: _selectedIndex == 5,
              onTap: () {
                setState(() {
                  _selectedIndex = 5;
                });
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SummaryReproState()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MenuGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,
        children: <Widget>[
          MenuButton(
            icon: Image.asset(
              'assets/icons/barbershop.png',
              width: 80,
              height: 80,
            ),
            label: 'ร้านตัดผมของฉัน',
            color: Colors.black,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Ownershop()));
            },
          ),
          MenuButton(
            icon: Image.asset(
              'assets/icons/barber.png',
              width: 80,
              height: 80,
            ),
            label: 'ส่งคำเชิญ',
            color: Colors.black,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => OwnerInvite()));
            },
          ),
          MenuButton(
            icon: Image.asset(
              'assets/icons/barber.png',
              width: 80,
              height: 80,
            ),
            label: 'ช่างตัดผม',
            color: Colors.black,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => OwnerEmployee()));
            },
          ),
          MenuButton(
            icon: Image.asset(
              'assets/icons/hairstyle.png',
              width: 80,
              height: 80,
            ),
            label: 'ทรงผม',
            color: Colors.black,
            onPressed: () {
              // Handle the action for 'ทรงผม'
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Ownerhair()));
            },
          ),
          MenuButton(
            icon: Image.asset(
              'assets/icons/booking.png',
              width: 80,
              height: 80,
            ),
            label: 'การจองของลูกค้า',
            color: Colors.black,
            onPressed: () {
              // Handle the action for 'การจองของลูกค้า'
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => OwnerBookingUser()));
            },
          ),
          MenuButton(
            icon: Image.asset(
              'assets/icons/history.png',
              width: 80,
              height: 80,
            ),
            label: 'การจองทั้งหมดในร้าน',
            color: Colors.black,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => OwnerBookings()));
            },
          ),
          MenuButton(
            icon: Image.asset(
              'assets/icons/history.png',
              width: 80,
              height: 80,
            ),
            label: 'รายงานสรุป',
            color: Colors.black,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SummaryReproState()));
            },
          ),
        ],
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  MenuButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onPressed,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                child: icon,
                width: 80,
                height: 80,
              ),
              SizedBox(height: 8.0), // Reduced height for better spacing
              Text(
                label,
                style: TextStyle(
                  fontSize: 20.0,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Function to show logout dialog
void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white, // Background color of the AlertDialog
        title: Text('ออกจากระบบ',
            style: TextStyle(color: Colors.red)), // Title text color
        content: Text('ออกจากระบบแล้ว',
            style: TextStyle(color: Colors.black)), // Content text color
        actions: <Widget>[
          TextButton(
            child: Text('ยกเลิก',
                style:
                    TextStyle(color: Colors.grey)), // Cancel button text color
            onPressed: () {
              Navigator.of(context).pop(); // Close the AlertDialog
            },
          ),
          TextButton(
            child: Text('ตกลง',
                style: TextStyle(color: Colors.green)), // OK button text color
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      );
    },
  );
}
