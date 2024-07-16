import 'package:barberapp/loginpage.dart';
import 'package:barberapp/pages/employee/profilebarber.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
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
              // print(result);
              switch (result) {
                case 'history':
                  // Navigate to customer booking history page
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BarberProfile(
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
              title: const Text('การจอง'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });

                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('ประวัติการจอง'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.pop(context);
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
              'assets/icons/hairstyle.png',
              width: 80,
              height: 80,
            ),
            label: 'รายละเอียดทรงผม',
            color: Colors.black,
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => BookingShop()),
              // );
            },
          ),
          MenuButton(
            icon: Image.asset(
              'assets/icons/booking.png',
              width: 80,
              height: 80,
            ),
            label: 'ข้อมูลการจองคิว',
            color: Colors.black,
            onPressed: () {
              // Handle the action for 'ประวัติการจอง'
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
              // Handle the action for 'ประวัติการจอง'
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

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text('ออกจากระบบ', style: TextStyle(color: Colors.red)),
        content: Text('ออกจากระบบแล้ว', style: TextStyle(color: Colors.black)),
        actions: <Widget>[
          TextButton(
            child: Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('ตกลง', style: TextStyle(color: Colors.green)),
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
