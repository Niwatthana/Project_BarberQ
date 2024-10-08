import 'package:barberapp/pages/owner/ownerbarberpro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OwnerInvite extends StatefulWidget {
  const OwnerInvite({super.key});

  @override
  State<OwnerInvite> createState() => _OwnerInviteState();
}

class _OwnerInviteState extends State<OwnerInvite> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>?> barberList = [];
  List<Map<String, dynamic>?> inviteList = [];
  List<Map<String, dynamic>?> newInviteList = [];

  @override
  void initState() {
    super.initState();
    getBarber();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> getUserData(String barbername) async {
    try {
      var query = FirebaseFirestore.instance
          .collection('Barbers')
          .where("status", isEqualTo: false)
          .orderBy("name", descending: false);

      var invite = FirebaseFirestore.instance
          .collection('Invites')
          .where("shop_id", isEqualTo: FirebaseAuth.instance.currentUser!.uid);

      if (barbername.isNotEmpty) {
        query = query
            .where("name", isGreaterThanOrEqualTo: barbername)
            .where("name", isLessThanOrEqualTo: barbername + '\uf8ff');

        invite = invite
            .where("barber_name", isGreaterThanOrEqualTo: barbername)
            .where("barber_name", isLessThanOrEqualTo: barbername + '\uf8ff');
      }

      var userSnapshot = await query.get();
      var inviteSnapshot = await invite.get();

      if (mounted) {
        setState(() {
          barberList = userSnapshot.docs.map((doc) => doc.data()).toList();
          inviteList = inviteSnapshot.docs.map((doc) => doc.data()).toList();

          print(inviteList);

          newInviteList = [];

          inviteList.forEach(
            (el1) {
              int index = barberList.indexWhere(
                (el2) {
                  print(el1);
                  return el1!['barber_id'] == el2!['barber_id'];
                },
              );
              print(index);
              if (index >= 0) {
                newInviteList.add(barberList[index]);
                barberList.removeAt(index);
              }
            },
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching barber data')),
        );
      }
    }
  }

  Future<void> getBarber() async {
    try {
      var userSnapshot = await FirebaseFirestore.instance
          .collection('Barbers')
          .where("status", isEqualTo: false)
          .get();
      var inviteSnapshot = await FirebaseFirestore.instance
          .collection('Invites')
          .where("shop_id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      // print(userSnapshot.docs);
      // print(inviteSnapshot.docs);

      if (mounted) {
        barberList = userSnapshot.docs.map((doc) => doc.data()).toList();
        inviteList = inviteSnapshot.docs.map((doc) => doc.data()).toList();
        setState(() {
          barberList = barberList.where((barber) {
            return barber!['feature'] != null && barber['imageUrl'] != null;
          }).toList(); //ไม่แสดงช่างที่ข้อมูลไม่ครบ
          inviteList.forEach(
            (element1) {
              int ind = barberList.indexWhere(
                (element2) {
                  return element1!['barber_id'] == element2!['barber_id'];
                },
              );
              // print(ind);
              newInviteList.add(barberList[ind]);
              barberList.removeAt(ind);
            },
          );
        });

        // print(barberList);
        // print("-------------");
        // print(inviteList);
        // print("-------------");
        // print(newInviteList);

        // setState(() {});
      }
    } catch (e) {
      print('Error fetching barber list: $e');
    }
  }

  Future<void> _sendInvitation(String barberId, String barberName) async {
    try {
      var inviteSnapshot = await FirebaseFirestore.instance
          .collection('Invites')
          .where('barber_id', isEqualTo: barberId)
          .where('barber_id1', isEqualTo: barberId)
          .get();

      if (inviteSnapshot.docs.isNotEmpty) {
        var inviteData = inviteSnapshot.docs.first.data();
        var inviteStatus = inviteData['inviteStatus'];

        if (inviteStatus == 'rejected') {
          _createNewInvite(barberId, barberName);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ไม่สามารถส่งคำเชิญซ้ำได้')),
          );
        }
      } else {
        _createNewInvite(barberId, barberName);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการตรวจสอบสถานะการเชิญ')),
      );
    }
  }

  Future<void> _createNewInvite(String barberId, String barberName) async {
    try {
      await FirebaseFirestore.instance.collection('Invites').add({
        'barber_name': barberName,
        'barber_id': barberId,
        'inviteStatus': null,
        'shop_id': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        barberList = barberList.map((barber) {
          if (barber?['barber_id'] == barberId) {
            return {...barber!, 'inviteStatus': 'sent'};
          }
          return barber;
        }).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('คำเชิญถูกส่งไปยัง $barberName เรียบร้อยแล้ว')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการส่งคำเชิญ')),
      );
    }
  }

  void _showInvitationDialog(String barberId, String barberName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ส่งคำเชิญ'),
          content: Text(
              'คุณต้องการส่งคำเชิญให้ช่าง $barberName เป็นช่างในร้านคุณใช่หรือไม่'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _sendInvitation(barberId, barberName);
              },
              child: Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('คำเชิญ', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onEditingComplete: () =>
                        getUserData(_searchController.text),
                    decoration: InputDecoration(
                      hintText: 'กรอกชื่อช่าง',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => getUserData(_searchController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(
                    'ค้นหา',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              itemCount: barberList.length,
              itemBuilder: (context, index) {
                bool isInvited = barberList[index]!['inviteStatus'] == 'sent';
                bool isDataComplete = barberList[index]!['feature'] != null &&
                    barberList[index]!['imageUrl'] != null;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: barberList[index]!['imageUrl'] != null
                          ? Image.network(
                              barberList[index]!['imageUrl'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.person, size: 50),
                      title: Text(barberList[index]!['name']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () {
                                var document = barberList[
                                    index]; // ตรวจสอบให้แน่ใจว่า barberList[index] ใช้งานได้
                                print(document!['barber_id1']);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OwnerbarberPro(
                                        barberref: document['barber_id1']),
                                  ),
                                );
                              },
                              icon: Icon(Icons.description_rounded)),
                          TextButton(
                            onPressed: isInvited || !isDataComplete
                                ? null
                                : () {
                                    _showInvitationDialog(
                                        barberList[index]!["barber_id"],
                                        barberList[index]!['name']);
                                  },
                            child: Text(
                              isInvited
                                  ? "เชิญแล้ว"
                                  : !isDataComplete
                                      ? "ข้อมูลไม่ครบ"
                                      : "เชิญ",
                              style: TextStyle(
                                color: isInvited || !isDataComplete
                                    ? Colors.grey
                                    : Colors.blue,
                              ),
                            ),

                            //  Text(
                            //   "เชิญ",
                            //   style: TextStyle(
                            //     color: isInvited
                            //         ? Colors.grey
                            //         : Colors.blue,
                            //   ),
                            // ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            // --------------------
            // const Divider(),
            ListView.builder(
              shrinkWrap: true,
              itemCount: newInviteList.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: newInviteList[index]!['imageUrl'] != null
                          ? Image.network(
                              newInviteList[index]!['imageUrl'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.person, size: 50),
                      title: Text(newInviteList[index]!['name']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () {
                                var document = newInviteList[index];
                                print(document!['barber_id']);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OwnerbarberPro(
                                        barberref: document['barber_id1']),
                                  ),
                                );
                              },
                              icon: Icon(Icons.description_rounded)),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text("เชิญแล้ว"),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
