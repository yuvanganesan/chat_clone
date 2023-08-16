import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import '../../main.dart';
import '../../logic/UserProfileData.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as sysPath;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './register_with_phone.dart';

class ProfileInfo extends StatefulWidget {
  const ProfileInfo(
      {super.key, required this.phoneNo, required this.isThisFirstScreen});
  final String? phoneNo;
  final bool isThisFirstScreen;

  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  final _name = TextEditingController();
  bool _validator = false;
  String? _imgUrl = '';
  File? _pickedImage;
  File? _storedImage;

  Future<void> takePicture(ImageSource source) async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(source: source, maxWidth: 600);
    if (imageFile == null) {
      _storedImage = null;
      _pickedImage = null;
      // ignore: use_build_context_synchronously
      // Provider.of<UserProfileData>(context, listen: false)
      //     .setImageFile(_pickedImage);
      return;
    }

    _storedImage = File(imageFile.path);
    // ignore: use_build_context_synchronously
    Provider.of<UserProfileData>(context, listen: false)
        .setImageFile(_pickedImage);
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();

    final appDir = await sysPath.getApplicationDocumentsDirectory();
    final fileName = path.basename(imageFile.path);
    _pickedImage = await _storedImage!.copy("${appDir.path}/$fileName");
  }

  void modalBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  "Profile Photo",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(children: [
                  Column(
                    children: [
                      InkWell(
                        onTap: () => takePicture(ImageSource.camera),
                        child: const CircleAvatar(
                          backgroundColor: Color(0xfff2c40f),
                          child: Icon(
                            Icons.camera_alt_outlined,
                            color: Color(0xff263b43),
                          ),
                        ),
                      ),
                      const Text(
                        'Camara',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Column(
                    children: [
                      InkWell(
                        onTap: () => takePicture(ImageSource.gallery),
                        child: const CircleAvatar(
                          backgroundColor: Color(0xfff2c40f),
                          child: Icon(
                            Icons.photo_outlined,
                            color: Color(0xff263b43),
                          ),
                        ),
                      ),
                      const Text(
                        'Gallery',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  )
                ]),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    return false; //<-- SEE HERE
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          body: FutureBuilder(
        future: Provider.of<UserProfileData>(context, listen: false)
            .fetchUserData(widget.phoneNo!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xfff2c40f),
              ),
            );
          }
          if (snapshot.error != null) {
            FirebaseAuth.instance.signOut();
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const RegisterWithPhoneNumber(),
            ));
          }

          final user =
              Provider.of<UserProfileData>(context, listen: false).user;

          _imgUrl = user.imageUrl!;

          _name.text = user.name!;

          return SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: (MediaQuery.of(context).padding.top) * 2),
                    const Text(
                      "Profile Info",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Color(0xfff2c40f)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 20),
                      child: Text(
                        "Please provide your name and an optional profile photo",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade700),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: modalBottomSheet,
                      child: Consumer<UserProfileData>(
                        builder: (context, value, _) => CircleAvatar(
                          radius: (MediaQuery.of(context).size.width) / 7,
                          backgroundColor: _imgUrl != '' || _storedImage != null
                              ? null
                              : Colors.grey.shade300,
                          backgroundImage: _storedImage != null
                              ? FileImage(_storedImage!) as ImageProvider
                              : (_imgUrl != '')
                                  ? NetworkImage(_imgUrl!)
                                  : null,
                          child: _imgUrl != '' || _storedImage != null
                              ? null
                              : Icon(
                                  Icons.add_a_photo,
                                  color: Colors.grey.shade700,
                                  size: (MediaQuery.of(context).size.width) / 9,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, right: 40),
                      child: TextField(
                        decoration: InputDecoration(
                            hintText: 'Type your name here',
                            focusColor: const Color(0xfff2c40f),
                            errorText:
                                _validator ? 'Enter a valid name' : null),
                        keyboardType: TextInputType.name,
                        controller: _name,
                        maxLength: 20,
                      ),
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_name.text.trim().isEmpty) {
                          setState(() {
                            _validator = true;
                          });
                          return;
                        }
                        FocusScope.of(context).unfocus();

                        // save name and photo in both local and firebase
                        try {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return WillPopScope(
                                  onWillPop: _onWillPop,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xfff2c40f),
                                    ),
                                  ));
                            },
                          );
                          await Provider.of<UserProfileData>(context,
                                  listen: false)
                              .createUser(_name.text, _pickedImage);
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();
                          if (widget.isThisFirstScreen) {
                            // ignore: use_build_context_synchronously
                            Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                              builder: (context) => const AuthenticationState(),
                            ));
                          } else {
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pop();
                          }
                        } catch (error) {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error.toString())));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xfff2c40f)),
                      child: const Text('Next'),
                    )
                  ]),
            ),
          );
        },
      )),
    );
  }
}
