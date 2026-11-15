import 'package:http/http.dart' as http;

import 'dart:convert';

void main() async {
  // Cole aqui a chave completa copiada do Google AI Studio
  const apiKey = 'AQ.Ab8RN6Ii1hKNHeQrPRar2_0mDo-4iqgGv0Ts_CRUrx6cs7WikQ';

  final url = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.8-flash:generateContent?key=$apiKey',
  );

  print('Enviando requisição HTTP POST para a Nuvem (Passo 4)...');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": "Ola, responda com a frase: 'Conexao bem-sucedida'"},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      // Passo 5: Decodificação do payload JSON (JSON Parser)
      final data = jsonDecode(response.body);
      final reply = data['candidates'][0]['content']['parts'][0]['text'];
      print('RESPOSTA DA IA (200 OK): $reply');
    } else {
      print('Erro HTTP ${response.statusCode}: ${response.body}');
    }
  } catch (e) {
    print('Erro de rede: $e');
  }
}
