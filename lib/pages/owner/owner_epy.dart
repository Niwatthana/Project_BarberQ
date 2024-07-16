import 'package:barberapp/pages/owner/owner_hair.dart';
import 'package:barberapp/pages/owner/ownerpage.dart';
import 'package:barberapp/pages/owner/ownershop.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class OwnerEmployee extends StatefulWidget {
  const OwnerEmployee({super.key});

  @override
  State<OwnerEmployee> createState() => _OwnerEmployeeState();
}

class _OwnerEmployeeState extends State<OwnerEmployee> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ช่างตัดผม"),
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
                SizedBox(height: 20),
                Text(
                  'ช่างตัดผมที่อยู่ในร้าน',
                  style: TextStyle(fontSize: 18),
                ),
                // SizedBox(height: 10),
                // TextField(
                //   // controller: _detailsController,
                //   maxLines: 4,
                //   decoration: InputDecoration(
                //     hintText: 'โปรดกรอกรายละเอียดของร้าน',
                //     border: OutlineInputBorder(),
                //   ),
                // ),
                Spacer(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => AddEmployee(),
            );
          },
          child: const Icon(Icons.add)),
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

  void _addEmployee(String haircut_name, String price) {
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

  void deleteHaircut(String docid) {
    FirebaseFirestore.instance
        .collection("Haircuts")
        .doc(docid)
        .delete()
        .then((value) {
      if (mounted) {}
    }).catchError((error) {
      print("เกิดข้อผิดพลาดในการลบช่างตัดผม: $error");
    });
  }
}

class AddEmployee extends StatefulWidget {
  const AddEmployee({Key? key}) : super(key: key);

  @override
  _AddEmployeeState createState() => _AddEmployeeState();
}

class _AddEmployeeState extends State<AddEmployee> {
  TextEditingController _haircut_nameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'เพิ่มช่าง',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: _haircut_nameController,
            decoration: InputDecoration(labelText: 'ชื่อช่าง'),
          ),
          // TextField(
          //   controller: _priceController,
          //   decoration: InputDecoration(labelText: 'ไม่มีอะไรค่อยคิดถ้าจะเพิ่ม'),
          // ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('ยกเลิก'),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  String haircut_name = _haircut_nameController.text.trim();
                  String price = _priceController.text.trim();
                  if (haircut_name.isNotEmpty && price.isNotEmpty) {
                    _OwnerEmployeeState()._addEmployee(haircut_name, price);
                    Navigator.pop(context);
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.success,
                      title: "สำเร็จ!",
                      text: 'เพิ่มข้อมูลทรงผมสำเร็จ',
                      confirmBtnText: 'ตกลง',
                      confirmBtnColor: Color.fromARGB(255, 28, 221, 14),
                    );
                  } else {
                    // แสดงข้อความเตือนหากข้อมูลไม่ครบ
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: 'ผิดพลาด!',
                      text: 'ไม่สามารถเพิ่มข้อมูลได้ กรุณาลองใหม่อีกครั้ง',
                      confirmBtnText: 'ตกลง',
                      confirmBtnColor: Color.fromARGB(255, 255, 0, 0),
                    );
                  }
                },
                child: Text('เพิ่ม'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
