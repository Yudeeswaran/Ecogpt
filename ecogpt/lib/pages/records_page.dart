import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import 'package:google_fonts/google_fonts.dart';

class RecordsPage extends StatelessWidget {
  final int userId;

  const RecordsPage({super.key, required this.userId});

  Future<List<Map<String, dynamic>>> _fetchRecords() async {
    List<Map<String, dynamic>> mockData = [
      {"productClaimed": "Water Bottle", "ecPoint": 10, "date": "2024-06-01"},
      {"productClaimed": "Notebook", "ecPoint": 15, "date": "2024-06-02"},
      {"productClaimed": "Water Bottle", "ecPoint": 10, "date": "2024-06-03"},
      {"productClaimed": "Pen", "ecPoint": 5, "date": "2024-06-04"},
      {"productClaimed": "Notebook", "ecPoint": 15, "date": "2024-06-05"},
    ];

    final response = await http.get(
      Uri.parse("${AppConfig.baseUrl}/view_reports/$userId"),
    );

    if (response.statusCode == 200) {
      List<dynamic> apiData = jsonDecode(response.body)["records"];
      return apiData
          .map(
            (record) => {
              "productClaimed": record["productClaimed"] ?? "Unknown Product",
              "ecPoint": record["ecPoint"] ?? 0,
              "date": record["date"] ?? "2024-06-01",
            },
          )
          .toList()
        ..addAll(mockData);
    } else {
      throw Exception("Failed to load records");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Transaction History",
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E1E), Color(0xFF424242)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchRecords(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  "No records found",
                  style: GoogleFonts.roboto(color: Colors.white),
                ),
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final record = snapshot.data![index];
                  return _AnimatedRecordCard(record: record);
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class _AnimatedRecordCard extends StatefulWidget {
  final Map<String, dynamic> record;

  const _AnimatedRecordCard({required this.record});

  @override
  State<_AnimatedRecordCard> createState() => _AnimatedRecordCardState();
}

class _AnimatedRecordCardState extends State<_AnimatedRecordCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform:
            _isHovered ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: _isHovered ? Colors.blueGrey[800] : Colors.grey[900],
          borderRadius: BorderRadius.circular(15),
          boxShadow:
              _isHovered
                  ? [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                  : [],
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: const Icon(Icons.history, color: Colors.white),
          ),
          title: Text(
            widget.record["productClaimed"],
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            "EC Points: ${widget.record["ecPoint"]}\nDate: ${widget.record["date"]}",
            style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[400]),
          ),
          trailing: const Icon(Icons.check_circle, color: Colors.greenAccent),
        ),
      ),
    );
  }
}
