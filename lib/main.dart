import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

void main() {
  runApp(const AssistantVirtualApp());
}

class AssistantVirtualApp extends StatelessWidget {
  const AssistantVirtualApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Asistan Vityèl',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List _messages = [];
  bool _isLoading = false;

  // Mete kle API ou a la a
  final String apiKey = 'AQ.Ab8RN6Ii1hKNHeQrPRar2_0mDo-4iqgGv0Ts_CRUrx6cs7WikQ';

  Future<void> _sendMessageToGemini(String prompt) async {
    if (prompt.isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "text": prompt});
      _isLoading = true;
    });

    _controller.clear();

    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.8-flash:generateContent?key=$apiKey',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['candidates'][0]['content']['parts'][0]['text'];

        setState(() {
          _messages.add({"sender": "assistant", "text": reply});
        });
      } else {
        setState(() {
          _messages.add({
            "sender": "assistant",
            "text": "Erè HTTP: ${response.statusCode}",
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({"sender": "assistant", "text": "Erè rezo: $e"});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asistan Vityèl - UniBTA')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message["sender"] == "user";
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      message["text"] ?? "",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ekri yon mesaj bay asistan an...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => _sendMessageToGemini(value),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessageToGemini(_controller.text),
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
