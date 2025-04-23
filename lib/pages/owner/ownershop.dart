import 'dart:io';
import 'package:barberapp/loginpage.dart';
import 'package:barberapp/pages/owner/owner_epy.dart';
import 'package:barberapp/pages/owner/owner_hair.dart';
import 'package:barberapp/pages/owner/ownerpage.dart';
import 'package:barberapp/pages/owner/profileowner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class Ownershop extends StatefulWidget {
  const Ownershop({super.key});

  @override
  State<Ownershop> createState() => _OwnershopState();
}

class _OwnershopState extends State<Ownershop> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _telController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();

  final List<String> hours =
      List.generate(15, (index) => (index + 8).toString().padLeft(2, '0'));
  final List<String> minutes = ['00', '30'];

  String? selectedOpenHour;
  String? selectedOpenMinute;
  String? selectedCloseHour;
  String? selectedCloseMinute;
  String errorMessage = '';

  Uint8List? _image;
  File? selectedImage;
  int _selectedIndex = 0;
  bool _isLoading = false;
  String? _imageUrl; // Variable to store the image URL
  double lat = 0, long = 0;

  // void validateTime() {
  //   try {
  //     if (selectedOpenHour != null &&
  //         selectedOpenMinute != null &&
  //         selectedCloseHour != null &&
  //         selectedCloseMinute != null) {
  //       int openHour = int.parse(selectedOpenHour!);
  //       int openMinute = int.parse(selectedOpenMinute!);
  //       int closeHour = int.parse(selectedCloseHour!);
  //       int closeMinute = int.parse(selectedCloseMinute!);

  //       // ตรวจสอบว่าเวลาเปิดต้องน้อยกว่าเวลาปิด
  //       if (openHour < closeHour ||
  //           (openHour == closeHour && openMinute < closeMinute)) {
  //         setState(() {
  //           errorMessage = ''; // ไม่มีปัญหา
  //         });
  //       } else {
  //         setState(() {
  //           errorMessage = 'เวลาเปิดต้องน้อยกว่าเวลาปิด';
  //         });
  //       }
  //     } else {
  //       setState(() {
  //         errorMessage = 'กรุณาเลือกเวลาเปิดและเวลาปิดให้ครบถ้วน';
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       errorMessage = 'กรุณาเลือกเวลาให้ถูกต้อง';
  //     });
  //   }
  // }

  Future<void> fetchOwnerShopData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> ownershop = await FirebaseFirestore
          .instance
          .collection('BarberShops')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (ownershop.exists) {
        var data = ownershop.data();
        setState(() {
          _shopNameController.text = data!['shop_name'];
          _telController.text = data['tel'];
          _addressController.text = data['address'];
          _imageUrl = data['shop_img'];
          lat = double.parse(data['latitude']);
          long = double.parse(data['longitude']);
          _latController.text = lat.toString();
          _longController.text = long.toString();
          selectedOpenHour = data['open_hour'];
          selectedOpenMinute = data['open_minute'];
          selectedCloseHour = data['close_hour'];
          selectedCloseMinute = data['close_minute'];
        });
      } else {
        getPosition();
        print("No such document!");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  void initialize() async {
    await fetchOwnerShopData();
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  // void getPosition() async {
  //   Position position = await _determinePosition();
  //   print(position.latitude);
  //   setState(() {
  //     lat = position.latitude;
  //     long = position.longitude;
  //     _latController.text = lat.toString();
  //     _longController.text = long.toString();
  //   });
  // }
  void getPosition() async {
    try {
      Position position = await _determinePosition();
      setState(() {
        lat = position.latitude;
        long = position.longitude;
        _latController.text = lat.toString();
        _longController.text = long.toString();
      });
    } catch (error) {
      // Show user-friendly error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('ไม่สามารถดึงตำแหน่งปัจจุบันได้: $error'),
      ));
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ร้านตัดผมของฉัน"),
        actions: <Widget>[
          PopupMenuButton<String>(
            icon: Icon(Icons.account_circle),
            onSelected: (String result) {
              switch (result) {
                case 'history':
                  // Navigate to customer booking history page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OwnerProfile(
                        docid: FirebaseAuth.instance.currentUser!.uid,
                      ),
                    ),
                  );
                  break;
                case 'logout':
                  showLogoutDialog(context);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'history',
                child: Text('ประวัติของฉัน'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('ออกจากระบบ'),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(top: 15),
        decoration: BoxDecoration(
          color: Color(0xFFEDECF2),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Center(
              child: GestureDetector(
                onTap: () {
                  showImagePickerOption(context);
                },
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Color(0xffFDCF09),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.memory(
                            _image!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                      : _imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.network(
                                _imageUrl!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(50),
                              ),
                              width: 100,
                              height: 100,
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.grey[800],
                              ),
                            ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'เลือกเวลาเปิดร้าน',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<String>(
                  hint: Text('เลือกเวลา'),
                  value: selectedOpenHour,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedOpenHour = newValue;
                    });
                  },
                  items: hours.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                DropdownButton<String>(
                  hint: Text('เลือกนาที'),
                  value: selectedOpenMinute,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedOpenMinute = newValue;
                    });
                  },
                  items: minutes.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'เลือกเวลาปิดร้าน',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<String>(
                  hint: Text('เลือกเวลา'),
                  value: selectedCloseHour,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCloseHour = newValue;
                    });
                  },
                  items: hours.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                DropdownButton<String>(
                  hint: Text('เลือกนาที'),
                  value: selectedCloseMinute,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCloseMinute = newValue;
                    });
                  },
                  items: minutes.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'ชื่อร้าน',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _shopNameController,
              decoration: InputDecoration(
                hintText: 'กรุณากรอกชื่อร้าน',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'เบอร์โทร',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _telController,
              decoration: InputDecoration(
                hintText: 'กรุณากรอกเบอร์โทร',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'รายละเอียดร้าน',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'โปรดกรอกรายละเอียดของร้าน',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ตำแหน่งที่ตั้ง',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                ElevatedButton.icon(
                  onPressed: getPosition,
                  label: Text("ตำแหน่งปัจจุบัน"),
                  icon: Icon(Icons.location_on_outlined),
                )
              ],
            ),
            SizedBox(height: 5),
            TextFormField(
              controller: _latController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(label: Text("ละติจูด")),
            ),
            TextFormField(
              controller: _longController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(label: Text("ลองจิจูด")),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: Size(150, 50),
                  ),
                  child: Text(
                    'ยกเลิก',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _uploadImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: Size(150, 50),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text(
                          'บันทึก',
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text("BarBer Shop"),
            ),
            ListTile(
              title: const Text('หน้าหลัก'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });

                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => OwnerPage()));
              },
            ),
            ListTile(
              title: const Text('ร้านตัดผมของฉัน'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });

                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Ownershop()));
              },
            ),
            ListTile(
              title: const Text('ช่างตัดผม'),
              selected: _selectedIndex == 2,
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => OwnerEmployee()));
              },
            ),
            ListTile(
              title: const Text('ทรงผม'),
              selected: _selectedIndex == 3,
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                });

                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Ownerhair()));
              },
            ),
            ListTile(
              title: const Text('การจองของลูกค้า'),
              selected: _selectedIndex == 4,
              onTap: () {
                setState(() {
                  _selectedIndex = 4;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('รายงานสรุป'),
              selected: _selectedIndex == 5,
              onTap: () {
                setState(() {
                  _selectedIndex = 5;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void showImagePickerOption(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.blue[100],
      context: context,
      builder: (builder) {
        return Padding(
          padding: const EdgeInsets.all(18.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 4.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _pickImageFromGallery();
                    },
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image,
                          size: 70,
                        ),
                        Text("Gallery"),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _pickImageFromCamera();
                    },
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 70,
                        ),
                        Text("Camera"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    setState(() {
      selectedImage = File(pickedFile.path);
      _image = File(pickedFile.path).readAsBytesSync();
    });
    Navigator.of(context).pop(); // Close the modal sheet
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;
    setState(() {
      selectedImage = File(pickedFile.path);
      _image = File(pickedFile.path).readAsBytesSync();
    });
    Navigator.of(context).pop(); // Close the modal sheet
  }

  Future<void> _uploadImage() async {
    print("is in _upload Image");
    setState(() {
      _isLoading = true;
    });

    try {
      // ตรวจสอบเวลาเปิด-ปิด
      if (selectedOpenHour != null &&
          selectedOpenMinute != null &&
          selectedCloseHour != null &&
          selectedCloseMinute != null) {
        int openHour = int.parse(selectedOpenHour!);
        int openMinute = int.parse(selectedOpenMinute!);
        int closeHour = int.parse(selectedCloseHour!);
        int closeMinute = int.parse(selectedCloseMinute!);

        // เช็คว่าเวลาเปิดต้องน้อยกว่าเวลาปิด
        if (!(openHour < closeHour ||
            (openHour == closeHour && openMinute < closeMinute))) {
          // ถ้าเงื่อนไขไม่ผ่าน ให้แสดงข้อความแจ้งเตือนแล้วหยุดการบันทึก
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('เวลาเปิดต้องน้อยกว่าเวลาปิด'),
            duration: Duration(seconds: 2),
          ));
          return;
        }
      } else {
        // ถ้าเวลาเปิด-ปิดไม่ถูกเลือกครบ ให้แสดงข้อความแจ้งเตือน
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('กรุณาเลือกเวลาเปิดและเวลาปิดให้ครบถ้วน'),
          duration: Duration(seconds: 2),
        ));
        return;
      }

      // ดำเนินการบันทึกรูปภาพและข้อมูลต่อไป
      if (selectedImage != null) {
        print('check selected image');
        // Upload image to Firebase Storage
        String fileName = FirebaseAuth.instance.currentUser!.uid;
        Reference ref =
            FirebaseStorage.instance.ref().child('images/$fileName.jpg');

        SettableMetadata metadata = SettableMetadata(
          contentType: 'image/jpeg',
        );

        UploadTask uploadTask = ref.putFile(selectedImage!, metadata);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        // Save data to Firestore
        DocumentReference docRef = FirebaseFirestore.instance
            .collection('BarberShops')
            .doc(FirebaseAuth.instance.currentUser!.uid);
        await docRef.set({
          'shop_name': _shopNameController.text,
          'owner_id': FirebaseAuth.instance.currentUser!.uid,
          'tel': _telController.text,
          'shop_img': downloadUrl,
          'address': _addressController.text,
          'latitude': _latController.text,
          'longitude': _longController.text,
          'open_hour': selectedOpenHour,
          'open_minute': selectedOpenMinute,
          'close_hour': selectedCloseHour,
          'close_minute': selectedCloseMinute,
        });

        setState(() {
          _imageUrl = downloadUrl;
        });
      } else {
        DocumentReference docRef = FirebaseFirestore.instance
            .collection('BarberShops')
            .doc(FirebaseAuth.instance.currentUser!.uid);
        await docRef.update({
          'shop_name': _shopNameController.text,
          'tel': _telController.text,
          'address': _addressController.text,
          'latitude': _latController.text,
          'longitude': _longController.text,
          'open_hour': selectedOpenHour,
          'open_minute': selectedOpenMinute,
          'close_hour': selectedCloseHour,
          'close_minute': selectedCloseMinute, // เพิ่มเวลาปิดร้าน
        });
      }

      setState(() {
        selectedImage = null;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('บันทึกข้อมูลเรียบร้อยแล้ว'),
        duration: Duration(seconds: 2),
      ));
    } catch (error) {
      print('เกิดข้อผิดพลาดในการอัปโหลดรูปภาพ: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูล'),
        duration: Duration(seconds: 2),
      ));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Background color of the AlertDialog
          title: Text('ออกจากระบบ',
              style: TextStyle(color: Colors.red)), // Title text color
          content: Text('ออกจากระบบแล้ว',
              style: TextStyle(color: Colors.black)), // Content text color
          actions: <Widget>[
            TextButton(
              child: Text('ยกเลิก',
                  style: TextStyle(
                      color: Colors.grey)), // Cancel button text color
              onPressed: () {
                Navigator.of(context).pop(); // Close the AlertDialog
              },
            ),
            TextButton(
              child: Text('ตกลง',
                  style:
                      TextStyle(color: Colors.green)), // OK button text color
              onPressed: () {
                Navigator.push(
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
}
