import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OwnerbarberPro extends StatefulWidget {
  const OwnerbarberPro({super.key, required this.barberref});

  final DocumentReference<Map<String, dynamic>> barberref;

  @override
  State<OwnerbarberPro> createState() => _OwnerbarberProState();
}

class _OwnerbarberProState extends State<OwnerbarberPro> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _telController = TextEditingController();
  final TextEditingController _featureController = TextEditingController();

  File? _image;
  String? _imageUrl;

  bool isLoading = true;

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> barberData =
          await widget.barberref.get();

      if (barberData.exists) {
        var data = barberData.data();
        setState(() {
          _nameController.text = data?['name'] ?? '';
          _usernameController.text = data?['username'] ?? '';
          _telController.text = data?['tel'] ?? '';
          _imageUrl = data?['imageUrl'];
          _featureController.text = data?['feature'] ?? '';
        });
      } else {
        print("No such document!");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? Center(child: LinearProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _image != null
                              ? FileImage(_image!) as ImageProvider
                              : (_imageUrl != null
                                      ? NetworkImage(_imageUrl!)
                                      : const AssetImage(
                                          'assets/icons/barber.png'))
                                  as ImageProvider,
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
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _telController,
                      readOnly: true,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _featureController,
                      readOnly: true,
                      maxLines: 5, // Allows for a larger text box
                      decoration: const InputDecoration(
                        labelText: 'คุณสมบัติ',
                        hintText:
                            'กรอกรายละเอียดเกี่ยวกับทักษะหรือคุณลักษณะของช่างตัดผม',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }
}
