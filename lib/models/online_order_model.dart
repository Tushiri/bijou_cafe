import 'package:bijou_cafe/models/order_model.dart';

class OnlineOrderModel {
  double voucherDiscount;
  final String orderId;
  final String address;
  double deliveryCharge;
  final List<OrderModel> orders;
  final PaymentModel payment;
  final String phoneNumber;
  String status;
  double totalPrice = 0;
  final String userID;
  DateTime dateOrdered = DateTime.now();

  OnlineOrderModel(
      {required this.voucherDiscount,
      required this.address,
      required this.deliveryCharge,
      required this.orders,
      required this.payment,
      required this.phoneNumber,
      required this.status,
      required this.userID,
      required this.orderId,
      required this.dateOrdered}) {
    for (int i = 0; i < orders.length; i++) {
      totalPrice = totalPrice + orders[i].totalPrice;
    }
    totalPrice = totalPrice - ((voucherDiscount / 100) * totalPrice);
  }

  Map<String, dynamic> toMap() {
    return {
      'voucherDiscount': voucherDiscount,
      'address': address,
      'deliveryCharge': deliveryCharge,
      'items': orders.map((order) => order.toMap()).toList(),
      'payment': payment.toMap(),
      'phoneNumber': phoneNumber,
      'status': status,
      'totalPrice': totalPrice,
      'userID': userID,
      'dateOrdered': dateOrdered
    };
  }
}

class PaymentModel {
  String paymentMethod;
  String status;
  String referenceId;

  PaymentModel(
      {required this.paymentMethod,
      required this.status,
      required this.referenceId});

  Map<String, dynamic> toMap() {
    return {
      'method': paymentMethod,
      'status': status,
    };
  }
}
