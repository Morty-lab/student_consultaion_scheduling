import 'package:flutter/material.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  // Mock data for demonstration purposes
  final List<Map<String, String?>> _data = [
    {
      "requestTitle": "Consultation 1",
      "requestDescription": "Description 1",
      "faculty": "Axl",
      "startDate": "05/26/2024 10:00AM",
      "endDate": "05/26/2024 11:00AM"
    },
    // Add more mock data as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Consultation History',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _data.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 16),
                    child: Material(
                      color: Colors.white,
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ListTile(
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _data[index]['requestTitle'] ?? "No Title",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      _data[index]['requestDescription'] ?? "No Description",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                        'Faculty: ${_data[index]['faculty'] ?? "Unknown"}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300)),
                                    Text(
                                        'Start Date: ${_data[index]['startDate'] ?? "Unknown"}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300)),
                                    Text(
                                        'End Date: ${_data[index]['endDate'] ?? "Unknown"}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300)),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

