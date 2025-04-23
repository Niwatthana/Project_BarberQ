import 'package:barberapp/loginpage.dart';
import 'package:barberapp/pages/barber/barber_bookinghistory.dart';
import 'package:barberapp/pages/barber/barber_hair.dart';
import 'package:barberapp/pages/barber/barber_summaryreport.dart';
import 'package:barberapp/pages/barber/barberpage.dart';
import 'package:barberapp/pages/owner/profileowner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BarberHairShop extends StatefulWidget {
  const BarberHairShop({Key? key}) : super(key: key);

  @override
  State<BarberHairShop> createState() => _BarberHairShopState();
}

class _BarberHairShopState extends State<BarberHairShop> {
  int _selectedIndex = 0;
  String owner_id = "";

  StreamBuilder showhaircut() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Haircuts")
          .where("owner_id", isEqualTo: owner_id)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาดบางอย่าง'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('ไม่มีข้อมูลทรงผม'));
        }
        // print("----------------------");

        // print(snapshot.data);

        return ListView(
          shrinkWrap: true,
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            return HaircutCard(
              imageUrl: data['shop_img'],
              haircutName: data['haircut_name'],
              price: data['price'].toString(),
              time: data['time'].toString(),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getAffiliationBarber();
  }

  Future<void> getAffiliationBarber() async {
    try {
      var barberSnapshot = await FirebaseFirestore.instance
          .collection('Barbers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      var data = barberSnapshot.data(); //วิธีการเรียกใช้ ref

      // print(data!['barbershop_id']);

      setState(() {
        owner_id = data!['barbershop_id'] ?? "";
      });
    } catch (e) {
      print('Error fetching barbers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ข้อมูลทรงผม"),
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
        padding: EdgeInsets.all(16),
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
                showhaircut(),
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
                  style: TextStyle(
                      color: Colors.grey)), // Cancel button text color
              onPressed: () {
                Navigator.of(context).pop(); // Close the AlertDialog
              },
            ),
            TextButton(
              child: Text('ตกลง',
                  style:
                      TextStyle(color: Colors.green)), // OK button text color
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
}

class HaircutCard extends StatelessWidget {
  final String imageUrl;
  final String haircutName;
  final String price;
  final String time;

  const HaircutCard({
    required this.imageUrl,
    required this.haircutName,
    required this.price,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  haircutName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('ราคา $price บาท'),
                Text('เวลาในการตัด $time นาที'),
              ],
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
