import 'package:barberapp/loginpage.dart';
import 'package:barberapp/pages/cutomer/bookinghistory.dart';
import 'package:barberapp/pages/cutomer/bookingshop.dart';
import 'package:barberapp/pages/cutomer/profilecutomer.dart';
import 'package:barberapp/pages/cutomer/seebookingshop.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class HomeCustomer extends StatefulWidget {
  const HomeCustomer({super.key});

  @override
  State<HomeCustomer> createState() => _HomeCustomerState();
}

class _HomeCustomerState extends State<HomeCustomer> {
  int _selectedIndex = 0; // เปลี่ยนเป็น 0 (หน้าหลัก) แทน 2 (Scissors)
  bool hasExistingBooking = false;
  bool isLoading = true;

  final Color primaryColor = Color(0xFF1B4B4B);
  final Color accentColor = Color(0xFFD70000);

  @override
  void initState() {
    super.initState();
    checkExistingBooking().then((_) => setState(() => isLoading = false));
  }

  Future<void> checkExistingBooking() async {
    try {
      QuerySnapshot bookingSnapshot = await FirebaseFirestore.instance
          .collection('Bookings')
          .where('barberid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('status', isEqualTo: 'booked')
          .get();

      if (bookingSnapshot.docs.isNotEmpty) {
        setState(() {
          hasExistingBooking = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('ออกจากระบบ', style: TextStyle(color: accentColor)),
          content: Text('คุณต้องการออกจากระบบหรือไม่?'),
          actions: [
            TextButton(
              child: Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('ตกลง', style: TextStyle(color: Colors.green)),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pop();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const LoginPage()));
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
      case 0: // หน้าหลัก (อยู่หน้าเดิม ไม่ต้อง push ซ้ำ)
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeCustomer()));
        break;
      case 1: // ประวัติ
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => BookingHistory()));
        break;
      case 2: // การจอง
        if (!hasExistingBooking) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => BookingShop()));
        } else {
          // แสดงข้อความแจ้งเตือนว่ามีการจองอยู่แล้ว (ถ้าต้องการ)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('คุณมีคิวการจองอยู่แล้ว')),
          );
        }
        break;
      case 3: // ตารางช่าง
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SeeBookingShop()));
        break;
      case 4: // Account
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
              AppBar(
                title: Text("Menu",
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
                actions: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.account_circle),
                    onSelected: (String result) {
                      switch (result) {
                        case 'history':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CutomerProfile(
                                  docid:
                                      FirebaseAuth.instance.currentUser!.uid),
                            ),
                          );
                          break;
                        case 'logout':
                          showLogoutDialog(context);
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) => [
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
                  padding: const EdgeInsets.all(16.0),
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(color: accentColor))
                      : AnimationLimiter(
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(height: 20),
                                    MenuGrid(
                                      hasExistingBooking: hasExistingBooking,
                                      primaryColor: primaryColor,
                                      accentColor: accentColor,
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
        selectedItemColor: Colors.black, // ไอคอนที่เลือก (เช่น หน้าหลัก)
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

class MenuGrid extends StatelessWidget {
  final bool hasExistingBooking;
  final Color primaryColor;
  final Color accentColor;

  const MenuGrid({
    required this.hasExistingBooking,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 1,
        children: List.generate(3, (index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: MenuButton(
                  icon: index == 0
                      ? Icon(Icons.book_online, size: 50, color: accentColor)
                      : index == 1
                          ? Icon(Icons.history, size: 50, color: accentColor)
                          : Icon(Icons.tab_outlined,
                              size: 50, color: accentColor),
                  label: index == 0
                      ? 'การจอง'
                      : index == 1
                          ? 'ประวัติการจอง'
                          : 'ดูตารางช่าง',
                  color: index == 0 && hasExistingBooking
                      ? Colors.grey
                      : Colors.black,
                  backgroundColor: index == 0 && hasExistingBooking
                      ? Colors.grey[200]!
                      : Colors.white,
                  onPressed: index == 0 && hasExistingBooking
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => index == 0
                                  ? BookingShop()
                                  : index == 1
                                      ? BookingHistory()
                                      : SeeBookingShop(),
                            ),
                          );
                        },
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final Color color;
  final Color backgroundColor;
  final VoidCallback? onPressed;

  const MenuButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15),
        splashColor: Colors.redAccent.withOpacity(0.3),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              SizedBox(height: 10.0),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18.0,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
