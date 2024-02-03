import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  late List<OnlineOrderModel> orders;

  @override
  void initState() {
    super.initState();
    _getInitialOrders();
  }

  Future<void> _getInitialOrders() async {
    // Sample order data for demonstration
    orders = [
      OnlineOrderModel(
        orderId: '1',
        dateOrdered: DateTime.now(),
        totalPrice: 50.0,
        orders: [
          OrderModel(
            productName: 'Product A',
            variant: 'Large',
            quantity: 2,
          ),
          OrderModel(
            productName: 'Product B',
            variant: 'Medium',
            quantity: 1,
          ),
        ],
      ),
      OnlineOrderModel(
        orderId: '2',
        dateOrdered: DateTime.now().subtract(const Duration(days: 1)),
        totalPrice: 30.0,
        orders: [
          OrderModel(
            productName: 'Product C',
            variant: 'Small',
            quantity: 3,
          ),
        ],
      ),
    ];

    setState(() {});
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
          ];

          final tableData = orders.map<List<dynamic>>((order) {
            final orderId = order.orderId;
            final date = DateFormat('yyyy-MM-dd').format(order.dateOrdered);
            final totalPrice = order.totalPrice;

            // Accumulate the total sales
            totalSales += totalPrice;

            return [orderId, date, totalPrice];
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.arrow_back),
                  ),
                  Text(
                    'Sales Inventory',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  OnlineOrderModel order = orders[index];
                  return SalesOrderCard(order: order);
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                _generateAndShowSalesReport();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 24.0),
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
}

class OnlineOrderModel {
  final String orderId;
  final DateTime dateOrdered;
  final double totalPrice;
  final List<OrderModel> orders;

  OnlineOrderModel({
    required this.orderId,
    required this.dateOrdered,
    required this.totalPrice,
    required this.orders,
  });
}

class OrderModel {
  final String productName;
  final String variant;
  final int quantity;

  OrderModel({
    required this.productName,
    required this.variant,
    required this.quantity,
  });
}

class SalesOrderCard extends StatelessWidget {
  final OnlineOrderModel order;

  const SalesOrderCard({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _buildInfoRow(IconData icon, String title, String content) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon,
                size: 20.0, color: Colors.white), // Updated color to white
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                '$title: $content',
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 18.0,
                  color: Colors.white, // Updated color to white
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: Colors.black, width: 2.0),
      ),
      child: InkWell(
        onLongPress: () {
          // Handle long press if needed
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shopping_cart,
                      color: Colors.white,
                      size: 36.0), // Updated color to white
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      'Order ID: ${order.orderId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.white, // Updated color to white
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              _buildInfoRow(Icons.date_range, 'Date',
                  '${DateFormat('yyyy-MM-dd').format(order.dateOrdered)}'),
              _buildInfoRow(Icons.money, 'Total Price',
                  'PHP ${order.totalPrice.toStringAsFixed(2)}'),
            ],
          ),
        ),
      ),
    );
  }
}
