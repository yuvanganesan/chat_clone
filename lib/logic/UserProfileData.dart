import 'package:flutter/material.dart';
import '../models/user_profile_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class UserProfileData with ChangeNotifier {
  // ignore: prefer_final_fields
  UserProfileModel _user = UserProfileModel(
      name: '',
      about: 'Hey there! I am using Chatclone',
      imageUrl: '',
      pnone: '',
      isOnline: true,
      lastActive: '');
  FirebaseAuth auth = FirebaseAuth.instance;

  UserProfileModel get user {
    return UserProfileModel(
        name: _user.name,
        about: _user.about,
        imageUrl: _user.imageUrl,
        pnone: _user.pnone,
        isOnline: _user.isOnline,
        lastActive: _user.lastActive);
  }

  void setUserDataNull() {
    _user = UserProfileModel(
        name: '',
        about: '',
        imageUrl: '',
        pnone: '',
        isOnline: true,
        lastActive: '');
  }

  void setImageFile(File? image) {
    _user.image = image;
    notifyListeners();
  }

  Future<void> fetchUserData(String phone) async {
    try {
      final userData =
          await FirebaseFirestore.instance.collection('users').doc(phone).get();

      if (userData.data() == null) {
        return;
      }

      _user = UserProfileModel(
          name: userData.data()!['name'],
          about: userData.data()!['about'],
          imageUrl: userData.data()!['imgUrl'],
          pnone: userData.data()!['phone'],
          isOnline: userData.data()!['isOnline'],
          lastActive: userData.data()!['lastActive']);
    } catch (error) {
      print("this is error $error");
    }
  }

  Future<void> createUser([String? name, File? image]) async {
    _user.name = name!;
    _user.image = image;
    _user.pnone = auth.currentUser!.phoneNumber!;
    try {
      if (image != null) {
        final imgReference = FirebaseStorage.instance
            .ref()
            .child("user_images")
            .child("${auth.currentUser!.uid}.jpg");
        await imgReference.putFile(image);
        _user.imageUrl = await imgReference.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser!.phoneNumber)
          .set({
        'name': _user.name,
        'about': _user.about,
        'phone': auth.currentUser!.phoneNumber,
        'isOnline': _user.isOnline,
        'lastActive': _user.lastActive,
        'imgUrl': _user.imageUrl
      });
      await auth.currentUser!.updateDisplayName(_user.name);
      // final pref = await SharedPreferences.getInstance();
      // final userData = json.encode({
      //   'phone': _user.pnone,
      //   'name': _user.name,
      //   'about': _user.about,
      //   'imgUrl': _user.imageUrl
      // });
      // pref.setString(_user.pnone, userData);
    } catch (error) {
      print(error.toString());
      rethrow;
    }
  }
}
