import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class BarberProfile extends StatefulWidget {
  const BarberProfile({super.key, required this.docid});
  final String docid;

  @override
  State<BarberProfile> createState() => _BarberProfileState();
}

class _BarberProfileState extends State<BarberProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _telController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // bool _isPasswordVisible = false;
  File? _image;
  String? _imageUrl;

  StreamBuilder shownameuser() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("Users").snapshots(),
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
            print(data['username']);
            return ListTile(
              title: Text(data['username']),
              subtitle: Text(data['tel'].toString()),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
              ),
            );
          }).toList(),
        );
      },
    );
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
          _nameController.text = data!['name'];
          _usernameController.text = data['username'];
          _telController.text = data['tel'];
          _passwordController.text = data['password'];
          _imageUrl = data['imageUrl'];
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

          
      await storageRef.putFile(_image!);
      final url = await storageRef.getDownloadURL();
      setState(() {
        _imageUrl = url;
      });
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.docid)
          .update({'imageUrl': _imageUrl});
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
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
                                : AssetImage('assets/profile.jpg'))
                            as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.yellow,
                      radius: 20,
                      child: IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.black,
                        ),
                        onPressed: pickImage,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 20),
              TextField(
                controller: _telController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              // TextField(
              //   controller: _passwordController,
              //   obscureText: !_isPasswordVisible,
              //   decoration: InputDecoration(
              //     labelText: 'Password',
              //     prefixIcon: Icon(Icons.lock),
              //     border: OutlineInputBorder(),
              //     suffixIcon: IconButton(
              //       icon: Icon(
              //         _isPasswordVisible
              //             ? Icons.visibility
              //             : Icons.visibility_off,
              //       ),
              //       onPressed: () {
              //         setState(() {
              //           _isPasswordVisible = !_isPasswordVisible;
              //         });
              //       },
              //     ),
              //   ),
              // ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  try {
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
                        SnackBar(content: Text('Profile updated successfully')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update profile: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.yellow, // สีตัวหนังสือในปุ่ม
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text('Edit Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
