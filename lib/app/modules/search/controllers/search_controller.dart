import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SearchController extends GetxController {
  late TextEditingController searchC;

  var queryAll = [].obs;
  var tempSearch = [].obs;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void searchFriend(String data) async {
    if (data.length == 0) {
      queryAll.value = [];
      tempSearch.value = [];
    } else {
      var capitalized = data.substring(0, 1).toUpperCase() + data.substring(1);
      if (queryAll.length == 0 && data.length == 1) {
        CollectionReference temp = await firestore.collection("temp");
        final keyNameResult = await temp
            .where("keyName", isEqualTo: data.substring(0, 1).toUpperCase())
            .get();

        if (keyNameResult.docs.length > 0) {
          for (var i = 0; i < keyNameResult.docs.length; i++) {
            queryAll.add(keyNameResult.docs[i].data() as Map<String, dynamic>);
          }
        }
      }

      if (queryAll.length != 0) {
        tempSearch.value = [];
        print(queryAll);
        queryAll.forEach((element) {
          if (element["name"].startsWith(capitalized)) {
            tempSearch.add(element);
          }
        });
      }
    }
    queryAll.refresh();
    tempSearch.refresh();
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
