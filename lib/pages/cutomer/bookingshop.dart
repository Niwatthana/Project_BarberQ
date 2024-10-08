import 'package:barberapp/loginpage.dart';
import 'package:barberapp/pages/cutomer/bookinghistory.dart';
import 'package:barberapp/pages/cutomer/homecutomer.dart';
import 'package:barberapp/pages/cutomer/timeslot.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookingShop extends StatefulWidget {
  const BookingShop({super.key});

  @override
  State<BookingShop> createState() => _BookingShopState();
}

class _BookingShopState extends State<BookingShop> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>?> shopList = [];
  bool hasExistingBooking = false; // Assuming you have this variable

  Color primaryColor = Colors.blue; // Set your primary color
  Color accentColor = Colors.red; // Set your accent color

  @override
  void initState() {
    super.initState();
    getShop();
  }

  Future<void> getShop() async {
    try {
      var userSnapshot =
          await FirebaseFirestore.instance.collection('BarberShops').get();

      if (userSnapshot.docs.isNotEmpty) {
        setState(() {
          shopList = userSnapshot.docs
              .map((doc) => doc.data())
              .where((shop) => _isShopDataComplete(shop))
              .toList();
          sortShopList();
        });
      } else {
        print('No shops found for this user.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  bool _isShopDataComplete(Map<String, dynamic>? shop) {
    return shop != null &&
        shop['shop_name'] != null &&
        shop['address'] != null &&
        shop['tel'] != null &&
        shop['shop_img'] != null;
  }

  void sortShopList() {
    shopList.sort((a, b) {
      String nameA = a?['shop_name']?.toString().toLowerCase() ?? '';
      String nameB = b?['shop_name']?.toString().toLowerCase() ?? '';
      return nameA.compareTo(nameB);
    });
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('ออกจากระบบ', style: TextStyle(color: Colors.red)),
          content: Text('คุณต้องการออกจากระบบหรือไม่?',
              style: TextStyle(color: Colors.black)),
          actions: <Widget>[
            TextButton(
              child: Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('ตกลง', style: TextStyle(color: Colors.green)),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pop();
                Navigator.pushReplacement(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ร้านตัดผม"),
        backgroundColor: Color(0xFF1B4B4B),
        actions: <Widget>[
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (String result) {
              switch (result) {
                case 'history':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BookingHistory()),
                  );
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF1B4B4B),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.person,
                    size: 64,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Barber Shop",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home,
                  color: _selectedIndex == 0 ? accentColor : Colors.black),
              title: const Text('หน้าหลัก'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomeCustomer()));
              },
            ),
            ListTile(
              leading: Icon(Icons.book_online,
                  color: _selectedIndex == 1 && !hasExistingBooking
                      ? accentColor
                      : Colors.black),
              title: Text(
                'การจอง',
                style: TextStyle(
                  color: hasExistingBooking ? Colors.grey : Colors.black,
                ),
              ),
              selected: _selectedIndex == 1,
              onTap: hasExistingBooking
                  ? null
                  : () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BookingShop()));
                    },
            ),
            ListTile(
              leading: Icon(Icons.history,
                  color: _selectedIndex == 2 ? accentColor : Colors.black),
              title: const Text('ประวัติการจอง'),
              selected: _selectedIndex == 2,
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => BookingHistory()));
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: shopList.isEmpty
            ? const Center(child: Text('ไม่พบร้าน'))
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: shopList.length,
                itemBuilder: (context, index) {
                  var shop = shopList[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TimeSlot(
                              barbershopname: shop?['shop_name'],
                              barbershopid: shop?['owner_id']),
                        ),
                      );
                      print('Selected shop: ${shop?['shop_name']}');
                    },
                    child: Card(
                      elevation: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          shop?['shop_img'] != null
                              ? Image.network(
                                  shop!['shop_img'],
                                  width: double.infinity,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(
                                  Icons.store,
                                  size: 100,
                                ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    shop?['shop_name'] != null
                                        ? shop!['shop_name']
                                        : 'ไม่ทราบชื่อร้าน',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    shop?['address'] != null
                                        ? shop!['address']
                                        : 'ไม่มีที่อยู่',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    shop?['tel'] != null
                                        ? shop!['tel']
                                        : 'ไม่มีเบอร์',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
