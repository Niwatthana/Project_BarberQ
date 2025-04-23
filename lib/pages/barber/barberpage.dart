import 'package:barberapp/loginpage.dart';
import 'package:barberapp/pages/barber/barber_bookinghistory.dart';
import 'package:barberapp/pages/barber/barber_bookinguser.dart';
import 'package:barberapp/pages/barber/barber_hairshop.dart';
import 'package:barberapp/pages/barber/barber_invite.dart';
import 'package:barberapp/pages/barber/barber_hair.dart';
import 'package:barberapp/pages/barber/barber_summaryreport.dart';
import 'package:barberapp/pages/barber/profilebarber.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BarberPage extends StatefulWidget {
  const BarberPage({super.key});

  @override
  State<BarberPage> createState() => _BarberPageState();
}

class _BarberPageState extends State<BarberPage> {
  int _selectedIndex = 0;
  String _shopName = 'ท่านยังไม่มีสังกัดร้านตัดผม';

  @override
  void initState() {
    super.initState();
    getAffiliationBarber();
    print(FirebaseAuth.instance.currentUser!.uid);
  }

  Future<void> getAffiliationBarber() async {
    try {
      var barberSnapshot = await FirebaseFirestore.instance
          .collection('Barbers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      var data = barberSnapshot.data(); //วิธีการเรียกใช้ ref
      print(data!['barber_id1']);

      DocumentSnapshot shopSnapshot = await data['barbershop_id1'].get();

      if (shopSnapshot.exists) {
        var data = shopSnapshot.data() as Map<String, dynamic>?;
        setState(() {
          _shopName = data?['shop_name'] ?? 'ท่านยังไม่มีสังกัดร้านตัดผม';
        });
      } else {
        print('ร้านไม่พบในระบบ');
      }

      print(shopSnapshot.data());
    } catch (e) {
      print('Error fetching barbers: $e');
    }
  }

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
                Text('สังกัดร้านชื่อ: $_shopName',
                    style: TextStyle(fontSize: 20)),
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
                    MaterialPageRoute(builder: (context) => BarberPage()));
              },
            ),
            ListTile(
              title: const Text('รายละเอียดทรงผม'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });

                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => BarberHair()));
              },
            ),
            ListTile(
              title: const Text('ข้อมูลการจองคิว'),
              selected: _selectedIndex == 2,
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BarberBookingHistoryPage()));
              },
            ),
            ListTile(
              title: const Text('รายงานสรุป'),
              selected: _selectedIndex == 3,
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                });
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BarberSummaryReport()));
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
            label: 'จัดการข้อมูลทรงผม',
            color: Colors.black,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BarberHair()),
              );
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BarberBookingUser()),
              );
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BarberSummaryReport()));
            },
          ),
          MenuButton(
            icon: Image.asset(
              'assets/icons/history.png',
              width: 80,
              height: 80,
            ),
            label: 'คำเชิญ',
            color: Colors.black,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BarberInvite()),
              );
            },
          ),
          MenuButton(
            icon: Image.asset(
              'assets/icons/history.png',
              width: 80,
              height: 80,
            ),
            label: 'ทรงผมของร้าน',
            color: Colors.black,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BarberHairShop()),
              );
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
