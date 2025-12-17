import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:magic_english_project/project/apikey.dart';
class  SendToAI{
  String api = ApiKey.api_key;
  String baseURL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent';
  Future<Map<String,dynamic>>  checkGrammar(String paragraph) async{
    String prompt = '''
      Act as a strict English grammar teacher.
      Analyze this text: """$paragraph""".
      Return ONLY a JSON object with these exact keys:
      - "point": integer (0-10). Be strict.
      - "mistakes": List of strings (short descriptions of mistakes),if this have no error then return empty list,Reply this in Vietnamese.
      - "suggests": string (what to change to make it smoother),Do not reply this in Vietnamese.
      Do not use Markdown. Do not add explanations.
    ''';
    try{
      final response = await http.post(
        Uri.parse("$baseURL?key=$api"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts":[
                {"text": prompt}
              ]
            }
          ],
          "generationConfig":{
            "temperature": 0,
            "responseMimeType": "application/json",
            "maxOutputTokens": 1000
          }
        })
      );
      if(response.statusCode==200){
        final data = jsonDecode(response.body);
        if (data['candidates'] == null || data['candidates'].isEmpty) {
          throw Exception("AI không trả về kết quả.");
        }
        String rawText = data['candidates'][0]['content']['parts'][0]['text'];
        rawText = rawText.replaceAll('```json', '').replaceAll('```', '').trim();
        return jsonDecode(rawText);
      }
      else{
        throw Exception("Lỗi API (${response.statusCode}): ${response.body}");
      }
    }
    catch(e){
      throw Exception("Lỗi kết nối: $e");
    }

  }
}