import 'package:barberapp/loginpage.dart';
import 'package:barberapp/pages/barber/barber_hair.dart';
import 'package:barberapp/pages/barber/barberpage.dart';
import 'package:barberapp/pages/barber/profilebarber.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BarberInvite extends StatefulWidget {
  const BarberInvite({Key? key}) : super(key: key);

  @override
  State<BarberInvite> createState() => _BarberInviteState();
}

class _BarberInviteState extends State<BarberInvite> {
  int _selectedIndex = 0;

  List<Map<String, dynamic>?> shopList = [];

  @override
  void initState() {
    super.initState();
    getInvite();
  }

  Future<void> getInvite() async {
    try {
      var inviteSnapshot = await FirebaseFirestore.instance
          .collection('Invites')
          .where("barber_id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where("inviteStatus", isNull: true)
          .get();
      print('ร้าน: ${inviteSnapshot.docs.length} ');

      if (mounted) {
        // setState(() {
        //   shopList = userSnapshot.docs.map((doc) => doc.data()).toList();
        // });
        inviteSnapshot.docs.map(
          (doc) async {
            var invitedata = doc.data();
            print(invitedata);
            DocumentSnapshot<Map<String, dynamic>> barbershopSnapshot =
                await FirebaseFirestore.instance
                    .collection("BarberShops")
                    .doc(invitedata['shop_id'])
                    .get();
            var barbershopdata =
                barbershopSnapshot.data() as Map<String, dynamic>;

            print(barbershopdata['shop_name']);
            setState(() {
              shopList.add({
                "docid": doc.id,
                "invite": invitedata,
                "barbershop": barbershopdata
              });
            });
          },
        ).toList();
      }
    } catch (e) {}
  }

//  void

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("คำเชิญ"),
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
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: shopList.length,
                    itemBuilder: (context, index) {
                      // var docid = shopList[index]!['docid'];
                      var invite = shopList[index]!['invite'];
                      var barbershop = shopList[index]!['barbershop'];
                      bool isInvited = invite['inviteStatus'] == 'sent';
                      // print('ร้านชื่อ: ${shopList[index]!['shop_name']}');

                      // print(shopList[index]!['docid']);
                      // print(shopList[index]!['invite']);
                      // print(shopList[index]!['barbershop']);

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: barbershop['shop_img'] != null
                                ? Image.network(
                                    barbershop['shop_img'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(Icons.person, size: 50),
                            title: Text(barbershop['shop_name']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection("Barbers")
                                        .doc(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .update({
                                      'barbershop_id': invite['shop_id'],
                                      'barbershop_id1': FirebaseFirestore
                                          .instance
                                          .collection('BarberShops')
                                          .doc(invite['shop_id']),
                                      'status': true,
                                    });

                                    await FirebaseFirestore.instance
                                        .collection("Invites")
                                        .where('barber_id',
                                            isEqualTo: FirebaseAuth
                                                .instance.currentUser!.uid)
                                        .get()
                                        .then(
                                      (querySnapshot) {
                                        querySnapshot.docs.forEach(
                                          (doc) async {
                                            await FirebaseFirestore.instance
                                                .collection("Invites")
                                                .doc(doc.id)
                                                .delete();
                                          },
                                        );
                                      },
                                    );

                                    setState(() {
                                      shopList.removeAt(index);
                                    });
                                  },
                                  icon: Icon(Icons.check),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    // อัปเดตสถานะคำเชิญเป็น "ปฏิเสธ"
                                    await FirebaseFirestore.instance
                                        .collection("Invites")
                                        .where('barber_id',
                                            isEqualTo: FirebaseAuth
                                                .instance.currentUser!.uid)
                                        .where('shop_id',
                                            isEqualTo: invite['shop_id'])
                                        .get()
                                        .then((querySnapshot) {
                                      querySnapshot.docs.forEach((doc) async {
                                        await FirebaseFirestore.instance
                                            .collection("Invites")
                                            .doc(doc.id)
                                            .update({'inviteStatus': 'ปฏิเสธ'});

                                        // ลบคำเชิญออกจากฐานข้อมูล
                                        await FirebaseFirestore.instance
                                            .collection("Invites")
                                            .doc(doc.id)
                                            .delete();
                                      });
                                    });

                                    // อัปเดต UI หลังจากการลบคำเชิญ
                                    setState(() {
                                      shopList.removeAt(index);
                                    });
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: isInvited ? Colors.red : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
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
                //     MaterialPageRoute(builder: (context) => BarberInvite()));
              },
            ),
            ListTile(
              title: const Text('คำเชิญ'),
              selected: _selectedIndex == 4,
              onTap: () {
                setState(() {
                  _selectedIndex = 4;
                });
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => BarberInvite()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

getShopDetail(String shopId) async {
  DocumentSnapshot<Map<String, dynamic>> shopDetail = await FirebaseFirestore
      .instance
      .collection("BarberShops")
      .doc(shopId)
      .get();

  // // print(shopDetail.data());
  var data = shopDetail.data();
  // // print(data);

  return data!;
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
