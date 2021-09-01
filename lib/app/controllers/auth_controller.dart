import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:chat/app/routes/app_pages.dart';

class AuthController extends GetxController {
  var isSkipIntro = false.obs;
  var isAuth = false.obs;

  GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _currentUser;

  void login() async {
    try {
      await _googleSignIn.signIn().then((value) => _currentUser = value);
      await _googleSignIn.isSignedIn().then((value) {
        if (value) {
          isAuth.value = true;
          Get.offAllNamed(Routes.HOME);
        } else {}
      });
    } catch (error) {
      print(error);
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }
}
