import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class EditBarberStyle extends StatefulWidget {
  const EditBarberStyle({super.key, required this.hairid});

  final String hairid;

  @override
  State<EditBarberStyle> createState() => _EditBarberStyleState();
}

class _EditBarberStyleState extends State<EditBarberStyle> {
  final TextEditingController _haircutNameController = TextEditingController();
  File? selectedImage;
  String? urlImage;
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
        // Generate a unique file name for each image
        String fileName = widget.hairid;
        Reference ref =
            FirebaseStorage.instance.ref().child('barberhair/$fileName.jpg');

        SettableMetadata metadata = SettableMetadata(
          contentType: 'image/jpeg',
        );
        UploadTask uploadTask = ref.putFile(selectedImage!, metadata);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

        // Get download URL
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        // Save data to Firestore
        CollectionReference docRef =
            FirebaseFirestore.instance.collection('BarberHaircuts');
        await docRef.doc(widget.hairid).update({
          'barber_img': downloadUrl,
          'haircut_name': _haircutNameController.text.trim(),
        });

        // Clear the input fields and reset the state
        _haircutNameController.clear();

        setState(() {
          selectedImage = null;
          _isLoading = false;
        });

        // Show a success message or navigate to another screen
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('บันทึกข้อมูลเรียบร้อยแล้ว'),
          duration: const Duration(seconds: 2),
        ));
      } else {
        CollectionReference docRef =
            FirebaseFirestore.instance.collection('BarberHaircuts');
        await docRef.doc(widget.hairid).update({
          'haircut_name': _haircutNameController.text.trim(),
        });

        // Clear the input fields and reset the state
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('บันทึกข้อมูลเรียบร้อยแล้ว'),
          duration: const Duration(seconds: 2),
        ));
      }
    } catch (error) {
      // Handle any errors that occur during the upload process
      print('เกิดข้อผิดพลาดในการอัปโหลดรูปภาพ: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('เกิดข้อผิดพลาดในการบันทึกข้อมูล'),
        duration: const Duration(seconds: 2),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    DocumentSnapshot<Map<String, dynamic>> haircut = await FirebaseFirestore
        .instance
        .collection("BarberHaircuts")
        .doc(widget.hairid)
        .get();

    var data = haircut.data();
    setState(() {
      _haircutNameController.text = data!['haircut_name'];
      urlImage = data['barber_img'];
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("แก้ไขทรงผมใหม่"),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Container(
            height: 700,
            padding: const EdgeInsets.only(top: 15),
            decoration: const BoxDecoration(
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
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _pickImageFromGallery,
                    child: const Text('อัปโหลดรูปภาพ'),
                  ),
                  TextField(
                    controller: _haircutNameController,
                    decoration: const InputDecoration(labelText: 'ชื่อทรงผม'),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading) const CircularProgressIndicator(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('ยกเลิก'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (_haircutNameController.text.trim().isNotEmpty) {
                            _uploadImage();
                          } else {
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.error,
                              title: 'ผิดพลาด!',
                              text: 'ไม่สามารถแก้ไขข้อมูลได้ กรุณาลองใหม่อีกครั้ง',
                              confirmBtnText: 'ตกลง',
                              confirmBtnColor: const Color.fromARGB(255, 255, 0, 0),
                            );
                          }
                        },
                        child: const Text('แก้ไข'),
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
