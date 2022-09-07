import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_ordering_app/assistantMethods/assistant_methods.dart';
import 'package:food_ordering_app/global/global.dart';
import 'package:food_ordering_app/widgets/order_card.dart';
import 'package:food_ordering_app/widgets/progress_bar.dart';
import 'package:food_ordering_app/widgets/simple_app_bar.dart';

class MyOrdersScreen extends StatefulWidget {


  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: SimpleAppBar(title: "My Orders",),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(sharedPreferences!.getString("uid"))
              .collection("orders")
              .where("status", isEqualTo: "normal")
              .orderBy("orderTime", descending: true)
              .snapshots(),
          builder: (c, snapshot){
            return !snapshot.hasData
                ? Center(child: circularProgress(),)
                : ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (c, index){
                      return FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("items")
                            .where("itemID", whereIn: separateOrderItemIDs((snapshot.data!.docs[index].data()! as Map<String, dynamic>)["productIDs"]))
                            .where("orderBy", whereIn: (snapshot.data!.docs[index].data()! as Map<String, dynamic>)["uid"])
                            .orderBy("publishedDate", descending: true)
                            .get(),
                        builder: (c, snap){
                          return !snap.hasData
                              ? Center(child: circularProgress(),)
                              : OrderCard(
                                  itemCount: snap.data!.docs.length,
                                  data: snap.data!.docs,
                                  orderID: snapshot.data!.docs[index].id,
                                  separateQuantitiesList: separateOrderItemQuantities((snapshot.data!.docs[index].data()! as Map<String, dynamic>)["productIDs"]),
                                );
                        },
                      );
                    },
                  );
          },
        ),
      ),
    );
  }
}