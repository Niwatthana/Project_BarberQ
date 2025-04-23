import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class AddHairStyle extends StatefulWidget {
  const AddHairStyle({Key? key}) : super(key: key);

  @override
  State<AddHairStyle> createState() => _AddHairStyleState();
}

class _AddHairStyleState extends State<AddHairStyle> {
  final TextEditingController _haircutNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _timeController =
      TextEditingController(text: '30'); // Set default to 30
  File? selectedImage;
  bool _isLoading = false;

  Future<void> _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      selectedImage = File(pickedFile.path);
    });
  }

  Future<void> _uploadImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (selectedImage != null) {
        CollectionReference docRef =
            FirebaseFirestore.instance.collection('Haircuts');
        DocumentReference doc = await docRef.add({
          'haircut_name': _haircutNameController.text.trim(),
          'price': _priceController.text.trim(),
          'time':
              _timeController.text.trim(), // Use the time from the text field
          "owner_id": FirebaseAuth.instance.currentUser!.uid
        });

        // Generate a unique file name for each image
        String fileName = doc.id;
        Reference ref =
            FirebaseStorage.instance.ref().child('barbershop/$fileName.jpg');

        SettableMetadata metadata = SettableMetadata(
          contentType: 'image/jpeg',
        );
        UploadTask uploadTask = ref.putFile(selectedImage!, metadata);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

        // Get download URL
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        // Save data to Firestore
        await docRef.doc(doc.id).set({
          "shop_img": downloadUrl,
          'haircut_name': _haircutNameController.text.trim(),
          'price': _priceController.text.trim(),
          'time':
              _timeController.text.trim(), // Use the time from the text field
          "owner_id": FirebaseAuth.instance.currentUser!.uid
        });

        // Clear the input fields and reset the state
        _haircutNameController.clear();
        _priceController.clear();
        _timeController.clear();
        setState(() {
          selectedImage = null;
          _isLoading = false;
        });

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('บันทึกข้อมูลเรียบร้อยแล้ว'),
          duration: Duration(seconds: 2),
        ));

        // Return to the previous screen
        Navigator.pop(context);
      }
    } catch (error) {
      print('เกิดข้อผิดพลาดในการอัปโหลดรูปภาพ: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูล'),
        duration: Duration(seconds: 2),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> getHairStyleData() async {
    try {
      // Load some default or necessary data if needed
      // For example, getting some existing hairstyle data
      CollectionReference haircutsRef =
          FirebaseFirestore.instance.collection('Haircuts');
      QuerySnapshot snapshot = await haircutsRef.get();
      // Assuming you want to use the first hairstyle data in this example
      Map<String, dynamic> haircutData =
          snapshot.docs.first.data() as Map<String, dynamic>;
      return haircutData;
    } catch (error) {
      print('Error loading hairstyle data: $error');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("เพิ่มทรงผมใหม่"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getHairStyleData(), // Fetch the data before showing UI
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading indicator while fetching data
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show error message if there's an error
            return Center(child: Text('Error loading data: ${snapshot.error}'));
          } else {
            // When data is successfully fetched
            return ListView(
              shrinkWrap: true,
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selectedImage != null)
                          Image.file(
                            selectedImage!,
                            width: 350,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                        else
                          Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: Icon(Icons.image,
                                size: 100, color: Colors.grey),
                          ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _pickImageFromGallery,
                          child: Text('อัปโหลดรูปภาพ'),
                        ),
                        TextField(
                          controller: _haircutNameController,
                          decoration: InputDecoration(labelText: 'ชื่อทรงผม'),
                        ),
                        TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: 'ราคา'),
                        ),
                        TextField(
                          controller: _timeController,
                          enabled: false, // Prevent editing
                          decoration:
                              InputDecoration(labelText: 'เวลาในการตัด (นาที)'),
                        ),
                        SizedBox(height: 16),
                        if (_isLoading) CircularProgressIndicator(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('ยกเลิก'),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (selectedImage != null &&
                                    _haircutNameController.text
                                        .trim()
                                        .isNotEmpty &&
                                    _priceController.text.trim().isNotEmpty) {
                                  _uploadImage();
                                } else {
                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.error,
                                    title: 'ผิดพลาด!',
                                    text:
                                        'ไม่สามารถเพิ่มข้อมูลได้ กรุณาลองใหม่อีกครั้ง',
                                    confirmBtnText: 'ตกลง',
                                    confirmBtnColor:
                                        Color.fromARGB(255, 255, 0, 0),
                                  );
                                }
                              },
                              child: Text('เพิ่ม'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
