import 'package:barberapp/loginpage.dart';
import 'package:barberapp/pages/barber/addhairbarber.dart';
import 'package:barberapp/pages/barber/barber_edithair.dart';
import 'package:barberapp/pages/barber/barberpage.dart';
import 'package:barberapp/pages/barber/profilebarber.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class BarberHair extends StatefulWidget {
  const BarberHair({Key? key}) : super(key: key);

  @override
  State<BarberHair> createState() => _BarberHairState();
}

class _BarberHairState extends State<BarberHair> {
  int _selectedIndex = 0;

  StreamBuilder showhaircut() {
    return StreamBuilder<QuerySnapshot>(
      // stream: FirebaseFirestore.instance.collection("Haircuts").where("ownerid").snapshots(),
      stream: FirebaseFirestore.instance
          .collection("BarberHaircuts")
          .where("barber_id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
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
                leading: Image.network(data['barber_img'],
                    width: 50, height: 50, fit: BoxFit.cover),
                title: Text(data['haircut_name']),
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
                                    EditBarberStyle(hairid: document.id)));
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
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => Addbarberhair()));
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
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => OwnerEmployee()));
              },
            ),
            ListTile(
              title: const Text('รายงานสรุป'),
              selected: _selectedIndex == 3,
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                });
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => BarberHair()));
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

  void _addhair(String haircut_name, String price) {
    FirebaseFirestore.instance.collection('BarberHaircuts').add({
      'haircut_name': haircut_name,
      // เพิ่มฟิลด์อื่น ๆ ตามต้องการ
    }).then((value) {
      if (mounted) {}
    }).catchError((error) {
      print("เกิดข้อผิดพลาดในการเพิ่มช่างตัดผม: $error");
    });
  }

  Future<void> deleteHaircut(String docid) async {
    FirebaseFirestore.instance
        .collection("BarberHaircuts")
        .doc(docid)
        .delete()
        .then((value) {
      if (mounted) {}
    }).catchError((error) {
      print("เกิดข้อผิดพลาดในการลบช่างตัดผม: $error");
    });
    await FirebaseStorage.instance
        .ref()
        .child("barberhair/${docid}.jpg")
        .delete();
  }
}

class HaircutCard extends StatelessWidget {
  final String imageUrl;
  final String haircutName;

  const HaircutCard({
    required this.imageUrl,
    required this.haircutName,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
