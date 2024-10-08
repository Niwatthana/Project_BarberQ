import 'package:barberapp/loginpage.dart';
import 'package:barberapp/pages/owner/owner_barbersummaryreport.dart';
import 'package:barberapp/pages/owner/owner_hair.dart';
import 'package:barberapp/pages/owner/owner_summaryreport.dart';
import 'package:barberapp/pages/owner/ownerbarberpro.dart';
import 'package:barberapp/pages/owner/ownerpage.dart';
import 'package:barberapp/pages/owner/ownershop.dart';
import 'package:barberapp/pages/owner/profileowner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OwnerEmployee extends StatefulWidget {
  const OwnerEmployee({super.key});

  @override
  State<OwnerEmployee> createState() => _OwnerEmployeeState();
}

class _OwnerEmployeeState extends State<OwnerEmployee> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _barbers = [];

  @override
  void initState() {
    super.initState();
    getEmployee();
  }

  Future<void> getEmployee() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('No user logged in');
        return;
      }

      var employeeSnapshot = await FirebaseFirestore.instance
          .collection('Barbers')
          .where('barbershop_id', isEqualTo: currentUser.uid)
          .get();

      if (employeeSnapshot.docs.isEmpty) {
        print('No barber found for this user');
        // setState(() {
        //   _barbers = [
        //     {
        //       'name': 'ไม่พบช่างในร้าน',
        //       'feature': '',
        //       'imageUrl': '',
        //       'barberId': null,
        //     }
        //   ];
        // });
        return;
      }

      // วนลูปดึงข้อมูลช่างหลายคน
      List<Map<String, dynamic>> tempBarbers = [];
      for (var doc in employeeSnapshot.docs) {
        var data = doc.data();
        if (data.containsKey('barber_id1')) {
          var barberRef = data['barber_id1'] as DocumentReference?;
          if (barberRef != null) {
            DocumentSnapshot barberSnapshot = await barberRef.get();
            if (barberSnapshot.exists) {
              var barberData = barberSnapshot.data() as Map<String, dynamic>?;
              tempBarbers.add({
                'name': barberData?['name'] ?? 'ร้านยังไม่มีช่าง',
                'feature': barberData?['feature'] ?? 'ไม่มีคุณสมบัติ',
                'imageUrl': barberData?['imageUrl'] ?? '',
                'barberId': barberSnapshot.id,
              });
            }
          }
        }
      }

      setState(() {
        _barbers = tempBarbers;
      });
    } catch (e) {
      print('Error fetching barbers: $e');
      // setState(() {
      //   _barbers = [
      //     {
      //       'name': 'เกิดข้อผิดพลาดในการดึงข้อมูล',
      //       'feature': '',
      //       'imageUrl': '',
      //       'barberId': null,
      //     }
      //   ];
      // });
    }
  }

  Future<void> updateBarberStatus(String barberId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Barbers')
          .doc(barberId)
          .update({
        'status': false, // อัปเดตสถานะเป็น false
        'barbershop_id': '', // ลบค่าของ barbershop_id
        'barbershop_id1': '', // ลบค่าของ barbershop_id1
      });
      print('Barber status updated successfully');
      getEmployee(); // โหลดข้อมูลช่างอีกครั้ง
    } catch (e) {
      print('Error updating barber: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ช่างตัดผม"),
        actions: <Widget>[
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (String result) {
              switch (result) {
                case 'history':
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _barbers.isNotEmpty
            ? ListView.builder(
                itemCount: _barbers.length,
                itemBuilder: (context, index) {
                  final barber = _barbers[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OwnerbarberPro(
                            barberref: FirebaseFirestore.instance
                                .collection('Users')
                                .doc(barber[
                                    'barberId']), // Use barberId from the list
                          ),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            if (barber['imageUrl'].isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child: Image.network(
                                  barber['imageUrl'],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    barber['name'].isNotEmpty
                                        ? barber['name']
                                        : 'Loading...',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    barber['feature'].isNotEmpty
                                        ? barber['feature']
                                        : '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.bar_chart_rounded),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            OwnerBarberSummaryReport(
                                                barberid:
                                                    barber['barberId']!)));
                              },
                            ),
                            barber['barberId'] ==
                                    FirebaseAuth.instance.currentUser!.uid
                                ? Container()
                                : IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      showUpdateConfirmationDialog(
                                          context, barber['barberId']);
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
            : const Center(child: Text("ไม่มีข้อมูลช่างในร้าน")),
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
                    MaterialPageRoute(builder: (context) => const OwnerPage()));
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
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('รายงานสรุป'),
              selected: _selectedIndex == 5,
              onTap: () {
                setState(() {
                  _selectedIndex = 5;
                });
                Navigator.pop(
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

  void showUpdateConfirmationDialog(BuildContext context, String? barberId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการอัปเดต'),
          content: const Text(
              'คุณแน่ใจว่าต้องการอัปเดตสถานะของช่างตัดผมนี้หรือไม่?'),
          actions: <Widget>[
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('อัปเดต'),
              onPressed: () {
                if (barberId != null) {
                  updateBarberStatus(barberId); // เรียกใช้ฟังก์ชันอัปเดตสถานะ
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการออกจากระบบ'),
          content: const Text('คุณแน่ใจว่าต้องการออกจากระบบใช่หรือไม่?'),
          actions: <Widget>[
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('ออกจากระบบ'),
              onPressed: () {
                FirebaseAuth.instance.signOut().then((value) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()));
                });
              },
            ),
          ],
        );
      },
    );
  }
}
