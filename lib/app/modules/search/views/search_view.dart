import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'package:chat/app/routes/app_pages.dart';
import '../controllers/search_controller.dart';

class SearchView extends GetView<SearchController> {
  final List<Widget> friends = List.generate(20, (index) {
    return ListTile(
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.black26,
        child: Image.asset(
          "assets/logo/noimage.png",
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        "Person ${index + 1}",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        "email${index + 1}@gmail.com",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      trailing: GestureDetector(
        onTap: () => Get.toNamed(Routes.CHAT_ROOM),
        child: Chip(
          label: Text("Message"),
        ),
      ),
    );
  });
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
              ),
            ),
          ),
        ),
        preferredSize: Size.fromHeight(140),
      ),
      body: friends.length == 0
          ? Center(
              child: Container(
                width: Get.width * 0.7,
                height: Get.width * 0.7,
                child: Lottie.asset("assets/lottie/empty.json"),
              ),
            )
          : ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) => friends[index]),
    );
  }
}
