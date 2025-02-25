import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';

class EnergyChatbotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatbotScreen(),
    );
  }
}

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  List<Map<String, String>> messages = [];
  List<dynamic> energyTips = [];
  List<dynamic> rewardInfo = [];
  List<String> categories = [];
  List<Map<String, dynamic>> highestImpactTasks = [];
  List<Map<String, dynamic>> highestRewardTasks = [];

  @override
  void initState() {
    super.initState();
    loadJson();
  }

  Future<void> loadJson() async {
    String data = await rootBundle.loadString(
      'assets/rec_logical_energy_rewards.json',
    );
    Map<String, dynamic> jsonData = jsonDecode(data);
    energyTips = jsonData['energy_saving_tips'];
    rewardInfo = jsonData['reward_information'];
    categories =
        energyTips.map((tip) => tip['category'].toString()).toSet().toList();

    // Get the top 3 highest impact tips
    highestImpactTasks = List.from(energyTips);
    highestImpactTasks.sort(
      (a, b) => b['impact_score'].compareTo(a['impact_score']),
    );
    highestImpactTasks = highestImpactTasks.take(3).toList();

    // Get the top 3 highest reward points
    highestRewardTasks = List.from(rewardInfo);
    highestRewardTasks.sort((a, b) => b['points'].compareTo(a['points']));
    highestRewardTasks = highestRewardTasks.take(3).toList();

    setState(() {});
  }

  void sendMessage(String category) {
    var tip = energyTips.firstWhere(
      (t) => t['category'] == category,
      orElse: () => null,
    );
    if (tip != null) {
      var reward = rewardInfo.firstWhere(
        (r) => r['id'] == tip['id'],
        orElse: () => null,
      );
      String rewardText =
          reward != null
              ? "\n\n🎉 Reward: ${reward['reward']}\n🏆 Points: ${reward['points']}"
              : "\n\n⚠️ No reward available for this tip.";
      setState(() {
        messages.add({'sender': 'User', 'text': category});
        messages.add({
          'sender': 'Bot',
          'text': "💡 Tip: ${tip['tip']}" + rewardText,
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Energy Saver Chatbot")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                bool isUser = message['sender'] == 'User';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message['text']!,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Wrap(
                  children: [
                    ...categories.map((category) {
                      return Padding(
                        padding: EdgeInsets.all(5),
                        child: ElevatedButton(
                          onPressed: () => sendMessage(category),
                          child: Text(category),
                        ),
                      );
                    }).toList(),
                    ...highestImpactTasks.map((task) {
                      return Padding(
                        padding: EdgeInsets.all(5),
                        child: ElevatedButton(
                          onPressed: () => sendMessage(task['category']),
                          child: Text("Top Task: ${task['tip']}"),
                        ),
                      );
                    }).toList(),
                    ...highestRewardTasks.map((task) {
                      return Padding(
                        padding: EdgeInsets.all(5),
                        child: ElevatedButton(
                          onPressed: () => sendMessage(task['action']),
                          child: Text(
                            "High Reward: ${task['action']} (${task['points']} pts)",
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
