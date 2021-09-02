import 'package:chat/app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'package:chat/app/routes/app_pages.dart';
import '../controllers/search_controller.dart';

class SearchView extends GetView<SearchController> {
  final authC = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: AppBar(
          backgroundColor: Colors.red[900],
          title: Text('Search'),
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back),
          ),
          flexibleSpace: Padding(
            padding: const EdgeInsets.fromLTRB(30, 50, 30, 20),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: TextField(
                controller: controller.searchC,
                cursorColor: Colors.red[900],
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                  hintText: "Search new friend here...",
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 20,
                  ),
                  suffixIcon: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () {},
                    child: Icon(
                      Icons.search,
                      color: Colors.red[900],
                    ),
                  ),
                ),
                onChanged: (value) =>
                    controller.searchFriend(value, authC.user.value.email!),
              ),
            ),
          ),
        ),
        preferredSize: Size.fromHeight(140),
      ),
      body: Obx(
        () => controller.userSearch.length == 0
            ? Center(
                child: Container(
                  width: Get.width * 0.7,
                  height: Get.width * 0.7,
                  child: Lottie.asset("assets/lottie/empty.json"),
                ),
              )
            : ListView.builder(
                itemCount: controller.userSearch.length,
                itemBuilder: (context, index) => ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.black26,
                    child: Image.asset(
                      "assets/logo/noimage.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    "${controller.userSearch[index]["name"]}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    "${controller.userSearch[index]["email"]}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  trailing: GestureDetector(
                    onTap: () {
                      authC.addNewConnection(
                          controller.userSearch[index]["email"]);
                    },
                    child: Chip(
                      label: Text("Message"),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
