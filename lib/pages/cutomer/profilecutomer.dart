import 'dart:io';
import 'package:barberapp/pages/cutomer/bookinghistory.dart';
import 'package:barberapp/pages/cutomer/bookingshop%20copy.dart';
import 'package:barberapp/pages/cutomer/homecutomer.dart';
import 'package:barberapp/pages/cutomer/seebookingshop.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class CutomerProfile extends StatefulWidget {
  const CutomerProfile({super.key, required this.docid});
  final String docid;

  @override
  State<CutomerProfile> createState() => _CutomerProfileState();
}

class _CutomerProfileState extends State<CutomerProfile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _telController = TextEditingController();

  File? _image;
  String? _imageUrl;
  bool isLoading = true; // ข้อ 2: Loading State

  final Color primaryColor = Color(0xFF1B4B4B);
  final Color accentColor = Colors.redAccent;
  int _selectedIndex = 4; // เริ่มต้นที่ไอคอน "Account" (index 4) ตาม Bottom Navigation Bar

  @override
  void initState() {
    super.initState();
    fetchUserData().then((_) => setState(() => isLoading = false));
  }

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> username = await FirebaseFirestore
          .instance
          .collection('Users')
          .doc(widget.docid)
          .get();
      if (username.exists) {
        var data = username.data();
        setState(() {
          _nameController.text = data!['name'] ?? '';
          _usernameController.text = data['username'] ?? '';
          _telController.text = data['tel'] ?? '';
          _imageUrl = data['imageUrl'];
        });
      } else {
        print("No such document!");
      }
    } catch (e) {
      // ข้อ 8: Error Handling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> uploadImage() async {
    if (_image == null) return;
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('userprofile_images/${widget.docid}.jpg');

      SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');
      await storageRef.putFile(_image!, metadata);
      final url = await storageRef.getDownloadURL();
      setState(() {
        _imageUrl = url;
      });
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.docid)
          .update({'imageUrl': _imageUrl});
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')));
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0: // หน้าหลัก
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomeCustomer()));
        break;
      case 1: // ประวัติ
        Navigator.push(context, MaterialPageRoute(builder: (context) => BookingHistory()));
        break;
      case 2: // การจอง
        Navigator.push(context, MaterialPageRoute(builder: (context) => BookingShop()));
        break;
      case 3: // ตารางช่าง
        Navigator.push(context, MaterialPageRoute(builder: (context) => SeeBookingShop()));
        break;
      case 4: // Account (อยู่หน้าเดิม ไม่ต้อง push ซ้ำ)
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
              // ข้อ 10: Custom AppBar (แทน PopupMenuButton ด้วย Back Button)
              AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text('Profile', style: TextStyle(color: Colors.white, fontSize: 20)),
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, Colors.teal],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: isLoading
                      ? Center(child: CircularProgressIndicator(color: accentColor)) // ข้อ 2: Loading
                      : Form(
                          key: _formKey,
                          child: AnimationLimiter( // ข้อ 11: Animation
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  AnimationConfiguration.staggeredList(
                                    position: 0,
                                    duration: const Duration(milliseconds: 375),
                                    child: SlideAnimation(
                                      verticalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            CircleAvatar(
                                              radius: 60,
                                              backgroundImage: _image != null
                                                  ? FileImage(_image!)
                                                  : (_imageUrl != null
                                                      ? NetworkImage(_imageUrl!)
                                                      : const AssetImage('assets/icons/barber.png'))
                                                  as ImageProvider,
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: CircleAvatar(
                                                backgroundColor: accentColor,
                                                radius: 20,
                                                child: IconButton(
                                                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                                                  onPressed: pickImage, // ข้อ 7: Feedback
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  AnimationConfiguration.staggeredList(
                                    position: 1,
                                    duration: const Duration(milliseconds: 375),
                                    child: SlideAnimation(
                                      verticalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: TextFormField(
                                          controller: _usernameController,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            labelText: 'Username',
                                            prefixIcon: Icon(Icons.person, color: primaryColor),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: BorderSide(color: primaryColor),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: BorderSide(color: accentColor, width: 2),
                                            ),
                                          ),
                                          style: TextStyle(color: Colors.black87), // ข้อ 4: Typography
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  AnimationConfiguration.staggeredList(
                                    position: 2,
                                    duration: const Duration(milliseconds: 375),
                                    child: SlideAnimation(
                                      verticalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: TextFormField(
                                          controller: _nameController,
                                          validator: (value) {
                                            if (value!.trim().isEmpty) {
                                              return "กรุณากรอกข้อมูล";
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            labelText: 'Name',
                                            prefixIcon: Icon(Icons.person, color: primaryColor),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: BorderSide(color: primaryColor),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: BorderSide(color: accentColor, width: 2),
                                            ),
                                          ),
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  AnimationConfiguration.staggeredList(
                                    position: 3,
                                    duration: const Duration(milliseconds: 375),
                                    child: SlideAnimation(
                                      verticalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: TextFormField(
                                          controller: _telController,
                                          validator: (value) {
                                            if (value!.trim().isEmpty) {
                                              return "กรุณากรอกข้อมูล";
                                            }
                                            return null;
                                          },
                                          keyboardType: TextInputType.phone,
                                          decoration: InputDecoration(
                                            labelText: 'Phone',
                                            prefixIcon: Icon(Icons.phone, color: primaryColor),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: BorderSide(color: primaryColor),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: BorderSide(color: accentColor, width: 2),
                                            ),
                                          ),
                                          style: TextStyle(color: Colors.black87),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  AnimationConfiguration.staggeredList(
                                    position: 4,
                                    duration: const Duration(milliseconds: 375),
                                    child: SlideAnimation(
                                      verticalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            try {
                                              if (_formKey.currentState!.validate()) {
                                                await FirebaseFirestore.instance
                                                    .collection('Users')
                                                    .doc(widget.docid)
                                                    .update({
                                                  'name': _nameController.text,
                                                  'tel': _telController.text,
                                                });
                                                if (_image != null) {
                                                  await uploadImage();
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Profile updated successfully')),
                                                  );
                                                }
                                              }
                                            } catch (e) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Failed to update profile: $e')),
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor: accentColor, // ข้อ 1: Theme Color
                                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                          child: const Text('Edit Profile'),
                                        ),
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
            ],
          ),
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
            icon: Icon(Icons.explore),
            label: 'ประวัติ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cut),
            label: 'การจอง',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'ตารางช่าง',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black, // ไอคอนที่เลือก (เช่น Account)
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