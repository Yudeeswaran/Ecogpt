import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import 'package:google_fonts/google_fonts.dart';

class RedeemPage extends StatefulWidget {
  final int userId;
  const RedeemPage({super.key, required this.userId});

  @override
  _RedeemPageState createState() => _RedeemPageState();
}

class _RedeemPageState extends State<RedeemPage> {
  List<dynamic> products = [];

  Future<void> _fetchProducts() async {
    final response = await http.get(
      Uri.parse("${AppConfig.baseUrl}/get_products"),
    );
    if (response.statusCode == 200) {
      setState(() {
        products = jsonDecode(response.body)["products"];
      });
    }
  }

  Future<void> _buyProduct(String productName) async {
    final response = await http.post(
      Uri.parse("${AppConfig.baseUrl}/make_transaction"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": widget.userId,
        "product_name": productName,
        "cc_points": 10,
      }),
    );

    final responseData = jsonDecode(response.body);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(responseData["message"])));
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Redeem")),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 190, 11, 89),
              Color.fromARGB(255, 55, 94, 201),
              Color.fromARGB(255, 145, 157, 15),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: ListTile(
                title: Text(
                  products[index]["product_name"],
                  style: GoogleFonts.pacifico(color: Colors.black),
                ),
                subtitle: Text(
                  "Cost: ${products[index]["cc_cost"]}",
                  style: GoogleFonts.pacifico(color: Colors.black54),
                ),
                trailing: ElevatedButton(
                  onPressed: () => _buyProduct(products[index]["product_name"]),
                  child: Text("Buy"),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
