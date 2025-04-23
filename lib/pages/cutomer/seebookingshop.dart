import 'package:barberapp/loginpage.dart';
import 'package:barberapp/pages/cutomer/bookinghistory.dart';
import 'package:barberapp/pages/cutomer/bookingshop.dart';
import 'package:barberapp/pages/cutomer/homecutomer.dart';
import 'package:barberapp/pages/cutomer/profilecutomer.dart';
import 'package:barberapp/pages/cutomer/seebookingbarber.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class SeeBookingShop extends StatefulWidget {
  const SeeBookingShop({super.key});

  @override
  State<SeeBookingShop> createState() => _SeeBookingShopState();
}

class _SeeBookingShopState extends State<SeeBookingShop> {
  int _selectedIndex =
      3; // เริ่มต้นที่ไอคอน "Explore" (index 3) ตาม Bottom Navigation Bar
  List<Map<String, dynamic>?> shopList = [];
  bool hasExistingBooking = false;
  bool isLoading = true; // ข้อ 2: Loading State

  final Color primaryColor = Color(0xFF1B4B4B);
  final Color accentColor = Colors.redAccent;

  @override
  void initState() {
    super.initState();
    getShop().then((_) => setState(() => isLoading = false));
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
      }
    } catch (e) {
      // ข้อ 8: Error Handling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)), // ข้อ 3: Card Design
          title: Text('ออกจากระบบ', style: TextStyle(color: accentColor)),
          content: Text('คุณต้องการออกจากระบบหรือไม่?',
              style: TextStyle(color: Colors.black)),
          actions: <Widget>[
            TextButton(
              child: Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0: // หน้าหลักนะจ๊ะ
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeCustomer()));
        break;
      case 1: // แน่นอนต่อๆกันไปอย่างง
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => BookingHistory()));
        break;
      case 2:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => BookingShop()));
        break;
      case 3:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SeeBookingShop()));
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CutomerProfile(docid: FirebaseAuth.instance.currentUser!.uid),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ข้อ 9: Gradient Background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, Colors.blueGrey.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ข้อ 10: Custom AppBar
              AppBar(
                title: Text("ตารางร้านตัดผม",
                    style: TextStyle(color: Colors.white, fontSize: 20)),
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, Colors.teal],
                    ),
                  ),
                ),
                actions: <Widget>[
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.account_circle),
                    onSelected: (String result) {
                      switch (result) {
                        case 'history':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BookingHistory()),
                          );
                          break;
                        case 'logout':
                          showLogoutDialog(context);
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                          value: 'history', child: Text('ประวัติของฉัน')),
                      const PopupMenuItem<String>(
                          value: 'logout', child: Text('ออกจากระบบ')),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: isLoading // ข้อ 2: Loading State
                      ? Center(
                          child: CircularProgressIndicator(color: accentColor))
                      : shopList.isEmpty
                          ? Center(
                              child: Text('ไม่พบร้าน',
                                  style: TextStyle(color: Colors.black87)))
                          : AnimationLimiter(
                              // ข้อ 11: Animation
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.8,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemCount: shopList.length,
                                itemBuilder: (context, index) {
                                  var shop = shopList[index];
                                  return AnimationConfiguration.staggeredGrid(
                                    position: index,
                                    duration: const Duration(milliseconds: 375),
                                    columnCount: 2,
                                    child: ScaleAnimation(
                                      child: FadeInAnimation(
                                        child: InkWell(
                                          splashColor: accentColor.withOpacity(
                                              0.3), // ข้อ 7: Feedback
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SeeBookingBarber(
                                                  barbershopname:
                                                      shop?['shop_name'],
                                                  barbershopid:
                                                      shop?['owner_id'],
                                                  barbershopopen_hour:
                                                      shop?['open_hour'],
                                                  barbershopopen_minute:
                                                      shop?['open_minute'],
                                                  barbershopclose_hour:
                                                      shop?['close_hour'],
                                                  barbershopclose_minute:
                                                      shop?['close_minute'],
                                                ),
                                              ),
                                            );
                                            print(
                                                'Selected shop: ${shop?['shop_name']}');
                                          },
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        15)), // ข้อ 3: Card Design
                                            elevation: 8,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    primaryColor,
                                                    Colors.blueGrey.shade100
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // ข้อ 5: Shop Image ด้วย CachedNetworkImage
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                    15)),
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          shop?['shop_img'] ??
                                                              '',
                                                      width: double.infinity,
                                                      height: 125,
                                                      fit: BoxFit.cover,
                                                      placeholder:
                                                          (context, url) =>
                                                              Container(
                                                        color: Colors.grey[300],
                                                        child: Center(
                                                            child:
                                                                CircularProgressIndicator()),
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(Icons.store,
                                                              size: 100),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // ข้อ 4: Typography
                                                          Text(
                                                            shop?['shop_name'] ??
                                                                'ไม่ทราบชื่อร้าน',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                          Text(
                                                            shop?['address'] ??
                                                                'ไม่มีที่อยู่',
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .white70),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                          Text(
                                                            shop?['tel'] ??
                                                                'ไม่มีเบอร์',
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .white70),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, Colors.teal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.person, size: 64, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    "Barber Shop",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 5, color: Colors.black)],
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
              selectedTileColor: Colors.grey[300],
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomeCustomer()));
              },
            ),
            ListTile(
              leading: Icon(Icons.book_online,
                  color: _selectedIndex == 1 ? accentColor : Colors.black),
              title: const Text('การจอง'),
              selected: _selectedIndex == 1,
              selectedTileColor: Colors.grey[300],
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => BookingShop()));
              },
            ),
            ListTile(
              leading: Icon(Icons.history,
                  color: _selectedIndex == 2 ? accentColor : Colors.black),
              title: const Text('ประวัติการจอง'),
              selected: _selectedIndex == 2,
              selectedTileColor: Colors.grey[300],
              onTap: () {
                setState(() => _selectedIndex = 2);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => BookingHistory()));
              },
            ),
            ListTile(
              leading: Icon(Icons.tab_outlined,
                  color: _selectedIndex == 3 ? accentColor : Colors.black),
              title: const Text('ดูตารางช่าง'),
              selected: _selectedIndex == 3,
              selectedTileColor: Colors.grey[300],
              onTap: () {
                setState(() => _selectedIndex = 3);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SeeBookingShop()));
              },
            ),
          ],
        ),
      ),
      // ข้อใหม่: Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'หน้าหลัก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'ประวัติ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'การจอง',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tab_outlined),
            label: 'ตารางช่าง',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black, // ไอคอนที่เลือก (เช่น Scissors)
        unselectedItemColor: Colors.grey, // ไอคอนที่ไม่เลือก
        backgroundColor: Colors.white,
        elevation: 20,
        selectedLabelStyle: TextStyle(color: Colors.black),
        unselectedLabelStyle: TextStyle(color: Colors.grey),
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}
