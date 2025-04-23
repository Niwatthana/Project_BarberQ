import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/quickalert.dart';

class EditHairStyle extends StatefulWidget {
  final String hairid;

  const EditHairStyle({Key? key, required this.hairid}) : super(key: key);

  @override
  _EditHairStyleState createState() => _EditHairStyleState();
}

class _EditHairStyleState extends State<EditHairStyle> {
  TextEditingController _haircutNameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _timeController = TextEditingController(text: '30'); // ตั้งค่าเริ่มต้นเป็น 30
  File? selectedImage;
  String? urlImage;
  bool _isLoading = false; // กำหนดสถานะการอัปโหลด
  bool _isDataLoading = true; // กำหนดสถานะการโหลดข้อมูล

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
        // Generate a unique file name for each image
        String fileName = widget.hairid;
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
        CollectionReference docRef =
            FirebaseFirestore.instance.collection('Haircuts');
        await docRef.doc(widget.hairid).update({
          'shop_img': downloadUrl,
          'haircut_name': _haircutNameController.text.trim(),
          'price': double.parse(_priceController.text.trim()),
          'time': double.parse(_timeController.text.trim()),
        });

        // Clear the input fields and reset the state
        _haircutNameController.clear();
        _priceController.clear();
        _timeController.clear();
        setState(() {
          selectedImage = null;
          _isLoading = false;
        });

        // Show a success message or navigate to another screen
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('บันทึกข้อมูลเรียบร้อยแล้ว'),
          duration: Duration(seconds: 2),
        ));
      } else {
        CollectionReference docRef =
            FirebaseFirestore.instance.collection('Haircuts');
        await docRef.doc(widget.hairid).update({
          'haircut_name': _haircutNameController.text.trim(),
          'price': double.parse(_priceController.text.trim()),
          'time': double.parse(_timeController.text.trim()),
        });
        // Clear the input fields and reset the state
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('บันทึกข้อมูลเรียบร้อยแล้ว'),
          duration: Duration(seconds: 2),
        ));
      }
    } catch (error) {
      // Handle any errors that occur during the upload process
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

  Future<void> callData() async {
    DocumentSnapshot<Map<String, dynamic>> haircut = await FirebaseFirestore
        .instance
        .collection("Haircuts")
        .doc(widget.hairid)
        .get();
    var data = haircut.data();
    setState(() {
      _haircutNameController =
          TextEditingController(text: data!['haircut_name']);
      _priceController = TextEditingController(text: data['price'].toString());
      _timeController = TextEditingController(text: '30'); // ตั้งค่าเริ่มต้นเป็น 30
      urlImage = data['shop_img'];
      _isDataLoading = false; // เมื่อโหลดข้อมูลเสร็จแล้ว ตั้งค่าเป็น false
    });
  }

  @override
  void initState() {
    super.initState();
    callData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("แก้ไขทรงผมใหม่"),
      ),
      body: _isDataLoading // เช็คว่ากำลังโหลดข้อมูลอยู่หรือไม่
          ? Center(child: CircularProgressIndicator()) // แสดง loading ขณะข้อมูลกำลังโหลด
          : ListView(
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
                        else if (urlImage != null)
                          Image.network(
                            urlImage!,
                            width: 350,
                            height: 200,
                            fit: BoxFit.cover,
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
                        // ฟิลด์เวลาแบบไม่สามารถแก้ไขได้
                        TextField(
                          controller: _timeController,
                          enabled: false, // ไม่ให้ผู้ใช้แก้ไข
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
                                if (_haircutNameController.text.trim().isNotEmpty &&
                                    _priceController.text.trim().isNotEmpty) {
                                  _uploadImage();
                                } else {
                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.error,
                                    title: 'ผิดพลาด!',
                                    text: 'ไม่สามารถเพิ่มข้อมูลได้ กรุณาลองใหม่อีกครั้ง',
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
            ),
    );
  }
}
