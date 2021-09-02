import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SearchController extends GetxController {
  late TextEditingController searchC;

  var queryAll = [].obs;
  var userSearch = [].obs;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void searchFriend(String data, String email) async {
    if (data.length == 0) {
      queryAll.value = [];
      userSearch.value = [];
    } else {
      var capitalized = data.substring(0, 1).toUpperCase() + data.substring(1);
      if (queryAll.length == 0 && data.length == 1) {
        CollectionReference user = await firestore.collection("users");
        final keyNameResult = await user
            .where("keyName", isEqualTo: data.substring(0, 1).toUpperCase())
            .where("email", isNotEqualTo: email)
            .get();

        if (keyNameResult.docs.length > 0) {
          for (var i = 0; i < keyNameResult.docs.length; i++) {
            queryAll.add(keyNameResult.docs[i].data() as Map<String, dynamic>);
          }
        }
      }

      if (queryAll.length != 0) {
        userSearch.value = [];
        print(queryAll);
        queryAll.forEach((element) {
          if (element["name"].startsWith(capitalized)) {
            userSearch.add(element);
          }
        });
      }
    }
    queryAll.refresh();
    userSearch.refresh();
  }

  @override
  void onInit() {
    searchC = TextEditingController();
    super.onInit();
  }

  @override
  void onClose() {
    searchC.dispose();
    super.onClose();
  }
}
