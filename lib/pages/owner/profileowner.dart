import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class OwnerProfile extends StatefulWidget {
  const OwnerProfile({super.key, required this.docid});
  final String docid;

  @override
  State<OwnerProfile> createState() => _OwnerProfileState();
}

class _OwnerProfileState extends State<OwnerProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _telController = TextEditingController();
  final TextEditingController _ownerfeatureController = TextEditingController();

  File? _image;
  String? _imageUrl;

  Future<void> confirmSaveProfile() async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'ยืนยันการเปลี่ยนข้อมูล',
      text: 'คุณต้องการเปลี่ยนข้อมูลหรือไม่?',
      confirmBtnText: 'ตกลง',
      cancelBtnText: 'ยกเลิก',
      confirmBtnColor: Colors.green,
      onConfirmBtnTap: () {
        Navigator.of(context).pop(); // ปิด QuickAlert
        _saveProfile(); // เรียกฟังก์ชันบันทึกข้อมูลเมื่อผู้ใช้ยืนยัน
      },
    );
  }

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(widget.docid)
              .get();
      if (userSnapshot.exists) {
        var data = userSnapshot.data();
        setState(() {
          _nameController.text = data!['name'];
          _usernameController.text = data['username'];
          _telController.text = data['tel'];
          _imageUrl = data['imageUrl'];
          _ownerfeatureController.text = data['feature'];
        });
      } else {
        print("No such document!");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
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
          .child('profile_images/${widget.docid}.jpg');

      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
      );
      await storageRef.putFile(_image!, metadata);
      final url = await storageRef.getDownloadURL();
      setState(() {
        _imageUrl = url;
      });
      // Update Firestore with new image URL
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.docid)
          .update({'imageUrl': _imageUrl});

      await FirebaseFirestore.instance
          .collection('Barbers')
          .doc(widget.docid)
          .update({'imageUrl': _imageUrl});
    } catch (e) {
      throw ('Failed to upload image: $e');
    }
  }

  Future<void> _saveProfile() async {
    try {
      // Firestore update
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.docid)
          .update({
        'name': _nameController.text,
        'tel': _telController.text,
        'feature': _ownerfeatureController.text,
      });

      await FirebaseFirestore.instance
          .collection('Barbers')
          .doc(widget.docid)
          .update({
        'name': _nameController.text,
        'feature': _ownerfeatureController.text, // Save the feature
      });

      // Upload image if selected
      if (_image != null) {
        await uploadImage();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เปลี่ยนข้อมูลเรียบร้อย')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('โปรไฟล์ของคุณ'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : (_imageUrl != null
                                ? NetworkImage(_imageUrl!)
                                : const AssetImage('assets/images/logo1.png'))
                            as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.yellow,
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.black,
                        ),
                        onPressed: pickImage,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _telController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _ownerfeatureController,
                maxLines: 5, // Allows for a larger text box
                decoration: const InputDecoration(
                  labelText: 'คุณสมบัติ',
                  hintText:
                      'กรอกรายละเอียดเกี่ยวกับทักษะหรือคุณลักษณะของช่างตัดผม',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  confirmSaveProfile(); // เรียกฟังก์ชันยืนยันก่อนที่จะทำการบันทึก
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.yellow,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text('เปลี่ยนข้อมูล'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
