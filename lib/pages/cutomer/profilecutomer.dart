import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

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

  StreamBuilder<QuerySnapshot> shownameuser() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("Users").snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }

        return Column(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            print(data['username']);
            return ListTile(
              title: Text(data['username']),
              subtitle: Text(data['tel'].toString()),
              trailing: const SizedBox.shrink(),
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
          .child('userprofile_images/${widget.docid}.jpg');

      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
      );
      await storageRef.putFile(_image!, metadata);
      final url = await storageRef.getDownloadURL();
      setState(() {
        _imageUrl = url;
      });
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.docid)
          .update({'imageUrl': _imageUrl});
      // await FirebaseFirestore.instance
      //     .collection('Cutomers')
      //     .doc(widget.docid)
      //     .update({'imageUrl': _imageUrl});
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
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
                                  : const AssetImage('assets/icons/barber.png'))
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
                TextFormField(
                  controller: _usernameController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return "กรุณากรอกข้อมูล";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _telController,
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return "กรุณากรอกข้อมูล";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 30),
                ElevatedButton(
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
                        // await FirebaseFirestore.instance
                        //     .collection('Cutomers')
                        //     .doc(widget.docid)
                        //     .update({
                        //   'name': _nameController.text,
                        // });
                        if (_image != null) {
                          await uploadImage();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Profile updated successfully')),
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
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.yellow,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                  ),
                  child: const Text('Edit Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
