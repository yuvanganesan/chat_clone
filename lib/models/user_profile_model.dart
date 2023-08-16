import 'dart:io';

class UserProfileModel {
  late String? name;
  late String? about;
  late String? imageUrl;
  late String pnone;
  late bool? isOnline;
  late String lastActive;
  late String pushToken;
  late File? image;

  UserProfileModel({
    required this.name,
    required this.about,
    required this.imageUrl,
    required this.pnone,
    required this.isOnline,
    required this.lastActive,
  });
}
