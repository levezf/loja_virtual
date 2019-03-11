import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loja_virtual/datas/cart_product.dart';
import 'package:loja_virtual/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';

class CartModel extends Model {
  UserModel userModel;
  bool isLoading = false;
  List<CartProduct> products = [];
  String couponCode;
  int discountPercentage = 0;

  static CartModel of(BuildContext context) =>
      ScopedModel.of<CartModel>(context);

  CartModel(this.userModel) {
    if (userModel.isLoggedIn()) _loadcartItems();
  }

  void addCartItem(CartProduct cartProduct) {
    products.add(cartProduct);
    Firestore.instance
        .collection("users")
        .document(userModel.firebaseUser.uid)
        .collection("cart")
        .add(cartProduct.toMap())
        .then((doc) {
      cartProduct.cid = doc.documentID;
    });
    notifyListeners();
  }

  void removeCartItem(CartProduct cartProduct) {
    Firestore.instance
        .collection("users")
        .document(userModel.firebaseUser.uid)
        .collection("cart")
        .document(cartProduct.cid)
        .delete();
    products.remove(cartProduct);
    notifyListeners();
  }

  void incProduct(CartProduct cartProduct) {
    cartProduct.quantity++;
    Firestore.instance
        .collection("users")
        .document(userModel.firebaseUser.uid)
        .collection("cart")
        .document(cartProduct.cid)
        .updateData(cartProduct.toMap());
    notifyListeners();
  }

  void decProduct(CartProduct cartProduct) {
    cartProduct.quantity--;
    Firestore.instance
        .collection("users")
        .document(userModel.firebaseUser.uid)
        .collection("cart")
        .document(cartProduct.cid)
        .updateData(cartProduct.toMap());
    notifyListeners();
  }

  void setCoupon(String couponCode, int discountPercentage) {
    this.couponCode = couponCode;
    this.discountPercentage = discountPercentage;
  }

  void updatePrices() {
    notifyListeners();
  }

  double getProductsPrice() {
    double price = 0.0;

    for (CartProduct c in products) {
      if (c.productData != null) {
        price += c.quantity * c.productData.price;
      }
    }
    return price;
  }

  double getDiscount() {
    return getProductsPrice() * discountPercentage / 100;
  }

  double getShipPrice() {
    return 9.99;
  }

  Future<String> finishOrder() async {
    if (products.length == 0) return null;

    isLoading = true;
    notifyListeners();

    double price = getProductsPrice();
    double discount = getDiscount();
    double ship = getShipPrice();

    DocumentReference refOrder =
        await Firestore.instance.collection("orders").add({
      "clientId": userModel.firebaseUser.uid,
      "products": products.map((cartProduct) => cartProduct.toMap()).toList(),
      "shipPrice": ship,
      "productsPrice": price,
      "discount": discount,
      "totalPrice": price - discount + ship,
      "status": 1
    });

    await Firestore.instance
        .collection("users")
        .document(userModel.firebaseUser.uid)
        .collection("orders")
        .document(refOrder.documentID)
        .setData({"orderId": refOrder.documentID});

    QuerySnapshot query = await Firestore.instance
        .collection("users")
        .document(userModel.firebaseUser.uid)
        .collection("cart")
        .getDocuments();

    for (DocumentSnapshot doc in query.documents) {
      doc.reference.delete();
    }
    products.clear();
    couponCode = null;
    discountPercentage = 0;
    isLoading = false;
    notifyListeners();
    return refOrder.documentID;
  }

  void _loadcartItems() async {
    QuerySnapshot query = await Firestore.instance
        .collection("users")
        .document(userModel.firebaseUser.uid)
        .collection("cart")
        .getDocuments();

    products =
        query.documents.map((doc) => CartProduct.fromDocument(doc)).toList();
    notifyListeners();
  }
}
