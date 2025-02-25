import 'package:flutter/material.dart';
import 'scan_qr.dart';
import 'redeem_page.dart';
import 'records_page.dart';
import 'chatbot_page.dart'; // Import your chatbot screen
import 'package:google_fonts/google_fonts.dart';

class MainPage extends StatelessWidget {
  final dynamic userData;

  const MainPage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> parsedUserData;

    if (userData is List) {
      parsedUserData = {
        "user_id": userData[0],
        "username": userData[1],
        "name": userData[2],
        "cc_point": userData[3],
        "demerits": userData[4],
      };
    } else if (userData is Map<String, dynamic>) {
      parsedUserData = userData;
    } else {
      parsedUserData = {};
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Main Page"),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              // Navigate to profile page
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.green,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Username at the top
            Text(
              "Welcome ${parsedUserData['username'] ?? 'N/A'}",
              style: GoogleFonts.pacifico(fontSize: 24, color: Colors.black),
            ),
            SizedBox(height: 20),

            // User information
            Text(
              "EC Points: ${parsedUserData['cc_point'] ?? 0}",
              style: GoogleFonts.pacifico(fontSize: 18, color: Colors.black),
            ),
            SizedBox(height: 10),
            Text(
              "Demerit Points: ${parsedUserData['demerits'] ?? 0}",
              style: GoogleFonts.pacifico(fontSize: 18, color: Colors.black),
            ),
            SizedBox(height: 20),

            // Leaderboard Section with Scrollable List
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Leaderboard",
                    style: GoogleFonts.pacifico(
                      fontSize: 20,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 30),

                  // Scrollable List
                  SizedBox(
                    height: 400, // Fixed height for scrollable leaderboard
                    child: Scrollbar(
                      thumbVisibility: true, // Make scrollbar always visible
                      child: SingleChildScrollView(
                        child: Column(
                          children: List.generate(15, (index) {
                            return ListTile(
                              title: Text(
                                "User ${index + 1}",
                                style: GoogleFonts.pacifico(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              trailing: Text(
                                "${10 * (index + 1)} Points",
                                style: GoogleFonts.pacifico(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // **Bottom Navigation Bar**
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.redeem), label: 'Redeem'),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        RedeemPage(userId: parsedUserData['user_id'] ?? 0),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QRScanScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        RecordsPage(userId: parsedUserData['user_id'] ?? 0),
              ),
            );
          }
        },
      ),

      // **Floating Chatbot Button**
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EnergyChatbotApp(),
            ), // Open Chatbot
          );
        },
        backgroundColor: Colors.blue, // Button color
        child: Icon(Icons.chat, color: Colors.white), // Chatbot icon
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // Bottom right position
    );
  }
}
