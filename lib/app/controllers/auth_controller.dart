import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:chat/app/routes/app_pages.dart';
import 'package:chat/app/data/models/user_model.dart';

class AuthController extends GetxController {
  var isSkipIntro = false.obs;
  var isAuth = false.obs;

  GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _currentUser;
  UserCredential? _userCredential;

  UserModel user = UserModel();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> firstInitialized() async {
    await autoLogin().then((value) {
      if (value) {
        isAuth.value = true;
      }
    });
    await skipIntro().then((value) {
      if (value) {
        isSkipIntro.value = true;
      }
    });
  }

  Future<bool> autoLogin() async {
    try {
      final isSignIn = await _googleSignIn.isSignedIn();
      if (isSignIn) {
        await _googleSignIn
            .signInSilently()
            .then((value) => _currentUser = value);

        final googleAuth = await _currentUser?.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth?.idToken,
          accessToken: googleAuth?.accessToken,
        );

        await FirebaseAuth.instance
            .signInWithCredential(credential)
            .then((value) => _userCredential = value);

        CollectionReference users = firestore.collection("users");

        users.doc(_currentUser?.email).update({
          "lastSignInTime":
              _userCredential?.user?.metadata.lastSignInTime?.toIso8601String(),
        });

        final currUser = await users.doc(_currentUser?.email).get();
        final currUserData = currUser.data() as Map<String, dynamic>;

        user = UserModel(
          uid: currUserData["uid"],
          name: currUserData["name"],
          email: currUserData["email"],
          photoUrl: currUserData["photoUrl"],
          status: currUserData["status"],
          creationTime: currUserData["creationTime"],
          lastSignInTime: currUserData["lastSignInTime"],
          updateTime: currUserData["updateTime"],
        );

        return true;
      }
      return false;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<bool> skipIntro() async {
    final box = GetStorage();
    if (box.read("skipIntro") != null && box.read("skipIntro") == true) {
      return true;
    }
    return false;
  }

  Future<void> login() async {
    try {
      await _googleSignIn.signOut();
      await _googleSignIn.signIn().then((value) => _currentUser = value);

      final isSignIn = await _googleSignIn.isSignedIn();
      if (isSignIn) {
        print("200");
        final googleAuth = await _currentUser?.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth?.idToken,
          accessToken: googleAuth?.accessToken,
        );

        await FirebaseAuth.instance
            .signInWithCredential(credential)
            .then((value) => _userCredential = value);

        final box = GetStorage();
        if (box.read("skipIntro") != null) {
          box.remove("skipIntro");
        }
        box.write("skipIntro", true);

        CollectionReference users = firestore.collection("users");

        final checkUser = await users.doc(_currentUser?.email).get();
        if (checkUser.data() == null) {
          users.doc(_currentUser?.email).set({
            "uid": _userCredential?.user?.uid,
            "name": _currentUser?.displayName,
            "email": _currentUser?.email,
            "photoUrl": _currentUser?.photoUrl ?? "noimage",
            "status": "",
            "createdAt":
                _userCredential?.user?.metadata.creationTime?.toIso8601String(),
            "lastSignInTime": _userCredential?.user?.metadata.lastSignInTime
                ?.toIso8601String(),
            "updatedTime": DateTime.now().toIso8601String(),
          });
        } else {
          users.doc(_currentUser?.email).update({
            "lastSignInTime": _userCredential?.user?.metadata.lastSignInTime
                ?.toIso8601String(),
          });
        }

        final currUser = await users.doc(_currentUser?.email).get();
        final currUserData = currUser.data() as Map<String, dynamic>;

        user = UserModel(
          uid: currUserData["uid"],
          name: currUserData["name"],
          email: currUserData["email"],
          photoUrl: currUserData["photoUrl"],
          status: currUserData["status"],
          creationTime: currUserData["creationTime"],
          lastSignInTime: currUserData["lastSignInTime"],
          updateTime: currUserData["updateTime"],
        );

        isAuth.value = true;
        Get.offAllNamed(Routes.HOME);
      } else {
        print("404");
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> logout() async {
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }
}
