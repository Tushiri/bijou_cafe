import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bijou_cafe/models/online_order_model.dart';
import 'package:bijou_cafe/models/order_model.dart';
import 'package:bijou_cafe/utils/firestore_database.dart';
import 'package:bijou_cafe/constants/colors.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ManageSales extends StatefulWidget {
  const ManageSales({Key? key}) : super(key: key);

  @override
  State<ManageSales> createState() => ManageSalesState();
}

class ManageSalesState extends State<ManageSales> {
  FirestoreDatabase firestore = FirestoreDatabase();
  late List<OnlineOrderModel> refreshedOrders;
  List<OnlineOrderModel> orders = [];

  @override
  void initState() {
    super.initState();
    _getInitialOrders();
  }

  Future<void> _getInitialOrders() async {
    List<OnlineOrderModel>? initialOrders = await firestore.getAllOrder("");
    if (initialOrders != null) {
      setState(() {
        refreshedOrders = initialOrders;
        orders = refreshedOrders; // Display all orders initially
      });
    }
  }

  Future<void> _searchSales() async {
    // Implement your search logic if needed
  }

  void _generateAndShowSalesReport() async {
    final pdf = pdfLib.Document();
    double totalSales = 0;

    pdf.addPage(
      pdfLib.Page(
        build: (context) {
          // Title
          pdfLib.Widget titleWidget = pdfLib.Column(
            crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
            children: [
              pdfLib.Text('Sales Report',
                  style: pdfLib.TextStyle(
                    fontWeight: pdfLib.FontWeight.bold,
                    fontSize: 20,
                  )),
              pdfLib.SizedBox(height: 10),
            ],
          );

          // Table Header
          final tableHeaders = [
            'Order ID',
            'Date',
            'Total Price',
            'Delivery Charge'
          ];

          final tableData = orders.map<List<dynamic>>((order) {
            final orderId = order.orderId;
            final date = DateFormat('yyyy-MM-dd').format(order.dateOrdered);
            final totalPrice = order.totalPrice;
            final deliveryCharge = order.deliveryCharge;

            // Accumulate the total sales
            totalSales += totalPrice;

            return [orderId, date, totalPrice, deliveryCharge];
          }).toList();

          // Table
          pdfLib.Widget tableWidget = pdfLib.Table.fromTextArray(
            headers: tableHeaders,
            data: tableData,
            border: null,
            cellHeight: 30,
            cellAlignments: {
              0: pdfLib.Alignment.centerLeft,
              1: pdfLib.Alignment.centerLeft,
              2: pdfLib.Alignment.centerRight,
              3: pdfLib.Alignment.centerRight,
            },
          );

          // Total Sales
          pdfLib.Widget totalSalesWidget = pdfLib.Column(
            crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
            children: [
              pdfLib.SizedBox(height: 20),
              pdfLib.Text('Total Sales: PHP ${totalSales.toStringAsFixed(2)}',
                  style: pdfLib.TextStyle(
                    fontWeight: pdfLib.FontWeight.bold,
                    fontSize: 18,
                  )),
            ],
          );

          return pdfLib.Column(
            children: [titleWidget, tableWidget, totalSalesWidget],
          );
        },
      ),
    );

    // Save the PDF to a file
    final directory = await getExternalStorageDirectory();
    final file = File("${directory!.path}/sales_report.pdf");
    await file.writeAsBytes(await pdf.save());

    // Open the generated PDF
    OpenFile.open(file.path);

    // Show a notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sales Report saved to ${file.path}'),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Sales Inventory',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        OnlineOrderModel order = orders[index];
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text('Order ID: ${order.orderId}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Date: ${DateFormat('yyyy-MM-dd').format(order.dateOrdered)}'),
                                Text(
                                    'Total Price: ${order.totalPrice.toString()}'),
                                Text(
                                    'Delivery Charge: ${order.deliveryCharge.toString()}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Total Sales: ${_calculateTotalSales().toString()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Top 3 Selling Items:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildTopSellingItems(),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                _generateAndShowSalesReport();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Generate Report",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSellingItems() {
    Map<String, int> productCountMap = {};

    for (OnlineOrderModel order in orders) {
      for (OrderModel orderItem in order.orders) {
        String productKey = '${orderItem.productName} - ${orderItem.variant}';
        productCountMap.update(
            productKey, (value) => value + orderItem.quantity,
            ifAbsent: () => orderItem.quantity);
      }
    }

    List<MapEntry<String, int>> sortedProducts = productCountMap.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    List<Widget> topSellingItems = [];
    for (int i = 0; i < sortedProducts.length && i < 3; i++) {
      String productKey = sortedProducts[i].key;
      List<String> productInfo = productKey.split(' - ');

      topSellingItems.add(
        Column(
          children: [
            Text(
              '${productInfo[0]} - ${productInfo[1]}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Quantity Sold: ${sortedProducts[i].value}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    }

    return Column(children: topSellingItems);
  }

  double _calculateTotalSales() {
    double totalSales = 0;
    for (OnlineOrderModel order in orders) {
      totalSales += order.totalPrice;
    }
    return totalSales;
  }
}
