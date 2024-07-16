import 'package:barberapp/pages/owner/owner_addhair.dart';
import 'package:barberapp/pages/owner/owner_edithair.dart';
import 'package:barberapp/pages/owner/owner_epy.dart';
import 'package:barberapp/pages/owner/ownerpage.dart';
import 'package:barberapp/pages/owner/ownershop.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class Ownerhair extends StatefulWidget {
  const Ownerhair({Key? key}) : super(key: key);

  @override
  State<Ownerhair> createState() => _OwnerhairState();
}

class _OwnerhairState extends State<Ownerhair> {
  int _selectedIndex = 0;

  StreamBuilder showhaircut() {
    return StreamBuilder<QuerySnapshot>(
      // stream: FirebaseFirestore.instance.collection("Haircuts").where("ownerid").snapshots(),
      stream: FirebaseFirestore.instance.collection("Haircuts").snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return Column(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            print(document.id);

            return Card(
              child: ListTile(
                leading: Image.network(data['shop_img'],
                    width: 50, height: 50, fit: BoxFit.cover),
                title: Text(data['haircut_name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price: ${data['price']}'),
                    Text('Time: ${data['time']}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        // edit by document.id
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    EditHairStyle(hairid: document.id)));
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        QuickAlert.show(
                          onCancelBtnTap: () {
                            Navigator.pop(context);
                          },
                          onConfirmBtnTap: () {
                            print("Delete");
                            deleteHaircut(document.id);
                            Navigator.pop(context);
                          },
                          context: context,
                          type: QuickAlertType.error,
                          title: 'ลบข้อมูล!',
                          text: 'ต้องการลบข้อมูล',
                          confirmBtnText: 'ตกลง',
                          cancelBtnText: 'ยกเลิก',
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
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
                // HaircutCard(
                //   imageUrl: 'assets/icons/barber_shop.png',
                //   haircutName: 'ทรงผม รองทรง',
                //   price: '50',
                //   time: '30',
                // ),
                showhaircut()
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddHairStyle()));
        },
        child: const Icon(Icons.add),
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
                Navigator.pop(context);
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
          title: Text("ออกจากระบบ"),
          content: Text("คุณแน่ใจหรือว่าต้องการออกจากระบบ?"),
          actions: <Widget>[
            TextButton(
              child: Text("ยกเลิก"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("ตกลง"),
              onPressed: () {
                Navigator.of(context).pop();
                // Perform logout operation
              },
            ),
          ],
        );
      },
    );
  }

  void _addhair(String haircut_name, String price) {
    FirebaseFirestore.instance.collection('Haircuts').add({
      'haircut_name': haircut_name,
      'price': price,
      // เพิ่มฟิลด์อื่น ๆ ตามต้องการ
    }).then((value) {
      if (mounted) {}
    }).catchError((error) {
      print("เกิดข้อผิดพลาดในการเพิ่มช่างตัดผม: $error");
    });
  }

  Future<void> deleteHaircut(String docid) async {
    FirebaseFirestore.instance
        .collection("Haircuts")
        .doc(docid)
        .delete()
        .then((value) {
      if (mounted) {}
    }).catchError((error) {
      print("เกิดข้อผิดพลาดในการลบช่างตัดผม: $error");
    });
    await FirebaseStorage.instance
        .ref()
        .child("barbershop/${docid}.jpg")
        .delete();
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
            Image.asset(
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
          ],
        ),
      ),
    );
  }
}
