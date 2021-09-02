import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:chat/app/routes/app_pages.dart';
import 'package:chat/app/data/models/users_model.dart';

class AuthController extends GetxController {
  var isSkipIntro = false.obs;
  var isAuth = false.obs;

  GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _currentUser;
  UserCredential? _userCredential;

  var user = UsersModel().obs;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Authentication

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

        await users.doc(_currentUser?.email).update({
          "lastSignInTime":
              _userCredential?.user?.metadata.lastSignInTime?.toIso8601String(),
        });

        final currUser = await users.doc(_currentUser?.email).get();
        final currUserData = currUser.data() as Map<String, dynamic>;

        user(UsersModel.fromJson(currUserData));

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
          await users.doc(_currentUser?.email).set({
            "uid": _userCredential?.user?.uid,
            "name": _currentUser?.displayName,
            "keyName": _currentUser?.displayName?.substring(0, 1).toUpperCase(),
            "email": _currentUser?.email,
            "photoUrl": _currentUser?.photoUrl ?? "noimage",
            "status": "",
            "createdAt":
                _userCredential?.user?.metadata.creationTime?.toIso8601String(),
            "lastSignInTime": _userCredential?.user?.metadata.lastSignInTime
                ?.toIso8601String(),
            "updatedTime": DateTime.now().toIso8601String(),
            "chats": []
          });
        } else {
          await users.doc(_currentUser?.email).update({
            "lastSignInTime": _userCredential?.user?.metadata.lastSignInTime
                ?.toIso8601String(),
          });
        }

        final currUser = await users.doc(_currentUser?.email).get();
        final currUserData = currUser.data() as Map<String, dynamic>;

        user(UsersModel.fromJson(currUserData));

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

  // Profile

  void changeProfile(String name, String status) {
    String date = DateTime.now().toIso8601String();
    CollectionReference users = firestore.collection("users");
    users.doc(_currentUser?.email).update({
      "name": name,
      "keyName": name.substring(0, 1).toUpperCase(),
      "status": status,
      "lastSignInTime":
          _userCredential?.user?.metadata.lastSignInTime?.toIso8601String(),
      "updatedTime": date,
    });

    user.update((user) {
      user?.name = name;
      user?.keyName = name.substring(0, 1).toUpperCase();
      user?.status = status;
      user?.lastSignInTime =
          _userCredential?.user?.metadata.lastSignInTime?.toIso8601String();
      user?.updateTime = date;
    });

    user.refresh();
    Get.defaultDialog(
      title: "Success",
      middleText: "Change Profile Successful",
    );
  }

  void updateStatus(String status) {
    String date = DateTime.now().toIso8601String();
    CollectionReference users = firestore.collection("users");
    users.doc(_currentUser?.email).update({
      "status": status,
      "lastSignInTime":
          _userCredential?.user?.metadata.lastSignInTime?.toIso8601String(),
      "updatedTime": date,
    });

    user.update((user) {
      user?.status = status;
      user?.lastSignInTime =
          _userCredential?.user?.metadata.lastSignInTime?.toIso8601String();
      user?.updateTime = date;
    });

    user.refresh();
    Get.defaultDialog(
      title: "Success",
      middleText: "Update Status Successful",
    );
  }

  // Chat

  void addNewConnection(String friendEmail) async {
    bool flagNewConnection = false;
    var chat_id;
    String date = DateTime.now().toIso8601String();
    CollectionReference chats = firestore.collection("chats");
    CollectionReference users = firestore.collection("users");

    final docUser = await users.doc(_currentUser!.email).get();
    final docChats = (docUser.data() as Map<String, dynamic>)["chats"] as List;

    if (docChats.length != 0) {
      // user sudah pernah chat dengan siapapun

      docChats.forEach((singleChat) {
        if (singleChat["connection"] == friendEmail) {
          chat_id = singleChat["chat_id"];
        }
      });

      if (chat_id != null) {
        // sudah pernah buat koneksi dengan => friendEmail
        flagNewConnection = false;
      } else {
        // blm pernah buat koneksi dengan => friendEmail
        // buat koneksi ....
        flagNewConnection = true;
      }
    } else {
      // blm pernah chat dengan siapapun
      // buat koneksi ....
      flagNewConnection = true;
    }

    if (flagNewConnection) {
      // cek dari chats collection => connections => mereka berdua...
      final chatsDocs = await chats.where(
        "connections",
        whereIn: [
          [
            _currentUser!.email,
            friendEmail,
          ],
          [
            friendEmail,
            _currentUser!.email,
          ],
        ],
      ).get();

      if (chatsDocs.docs.length != 0) {
        // terdapat data chats (sudah ada koneksi antara mereka berdua)
        final chatDataId = chatsDocs.docs[0].id;
        final chatsData = chatsDocs.docs[0].data() as Map<String, dynamic>;

        docChats.add({
          "connection": friendEmail,
          "chat_id": chatDataId,
          "lastTime": chatsData["lastTime"],
        });

        await users.doc(_currentUser!.email).update({"chats": docChats});

        user.update((user) {
          user!.chats = docChats as List<ChatUser>;
        });

        chat_id = chatDataId;

        user.refresh();
      } else {
        // buat baru , mereka berdua benar2 belum ada koneksi
        final newChatDoc = await chats.add({
          "connections": [
            _currentUser!.email,
            friendEmail,
          ],
          "total_chats": 0,
          "total_read": 0,
          "total_unread": 0,
          "chat": [],
          "lastTime": date,
        });

        docChats.add({
          "connection": friendEmail,
          "chat_id": newChatDoc.id,
          "lastTime": date,
        });

        await users.doc(_currentUser!.email).update({"chats": docChats});

        user.update((user) {
          user!.chats = docChats as List<ChatUser>;
        });

        chat_id = newChatDoc.id;

        user.refresh();
      }
    }

    print(chat_id);

    Get.toNamed(Routes.CHAT_ROOM, arguments: chat_id);
  }
}
