import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:loja/datas/cart_product.dart';
import 'package:loja/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';

class CartModel extends Model {

  UserModel user;

  List<CartProduct> products = [];

  String couponCode;
  int descontoPorcentagem = 0;


  bool isLoading = false;

  CartModel(this.user) {
    if(user.isLoggedIn()) {
      _loadCartItens();
    }
  }

  static CartModel of(BuildContext context) =>
      ScopedModel.of<CartModel>(context);

  void addCartItem(CartProduct cartProduct){
    products.add(cartProduct);

    Firestore.instance.collection("users").document(user.firebaseUser.uid)
        .collection("cart").add(cartProduct.toMap()).then((doc) {
      cartProduct.cid = doc.documentID;
    });

    notifyListeners();
  }

  void removeCartItem(CartProduct cartProduct) {
    Firestore.instance.collection("users").document(user.firebaseUser.uid)
        .collection("cart").document(cartProduct.cid).delete();

    products.remove(cartProduct);

    notifyListeners();
  }

  void decProduct(CartProduct cartProduct) {
    cartProduct.quantity--;
    
    Firestore.instance.collection("users").document(user.firebaseUser.uid).
    collection("cart").document(cartProduct.cid).updateData(cartProduct.toMap());

    notifyListeners();
  }

  void incProduct(CartProduct cartProduct) {
    cartProduct.quantity++;

    Firestore.instance.collection("users").document(user.firebaseUser.uid).
    collection("cart").document(cartProduct.cid).updateData(cartProduct.toMap());

    notifyListeners();
  }

  void _loadCartItens() async{

    QuerySnapshot query = await Firestore.instance.collection("users").document(user.firebaseUser.uid).
    collection("cart").getDocuments();

    products = query.documents.map((doc) => CartProduct.fromDocument(doc)).toList();

    notifyListeners();

  }

  void setCupom(String couponCode, int descontoPorcentagem) {
      this.couponCode = couponCode;
      this.descontoPorcentagem = descontoPorcentagem;
  }

  double getProductsPrice() {
    double price = 0.0;
    for(CartProduct c in products) {
      if(c.productData != null) {
        price += c.quantity * c.productData.price;
      }
    }
    return price;
  }

  double getDesconto() {
    return getProductsPrice() * descontoPorcentagem / 100;
  }

  double getShipPrice() {
    return 10.00;
  }

  void updatePrices() {
    notifyListeners();
  }

  Future<String> finishOrder() async{
    if(products.length == 0) return null;

    isLoading = true;
    notifyListeners();

    double productsPrice = getProductsPrice();
    double shipPrice = getShipPrice();
    double desconto = getDesconto();

    DocumentReference refOrder = await Firestore.instance.collection("orders").add(
      {
        "clientId": user.firebaseUser.uid,
        "products": products.map((cartProduct)=>cartProduct.toMap()).toList(),
        "shipPrice": shipPrice,
        "productsPrice": productsPrice,
        "desconto": desconto,
        "totalPrice": productsPrice - desconto + shipPrice,
        "status": 1
      }
    );

    await Firestore.instance.collection("users").document(user.firebaseUser.uid).
    collection("orders").document(refOrder.documentID).setData(
      {
        "orderId": refOrder.documentID
      }
    );

    QuerySnapshot query = await Firestore.instance.collection("users").
    document(user.firebaseUser.uid).collection("cart").getDocuments();

    for(DocumentSnapshot doc in query.documents) {
      doc.reference.delete();
    }

    products.clear();

    descontoPorcentagem = 0;

    isLoading = false;
    notifyListeners();

    return refOrder.documentID;

  }

}