import 'dart:convert';
import 'package:http/http.dart' as http;
import './secret_key.dart';

class OpenAIServices {
  final List<Map<String, String>> messages = [];

  Future<String> isArtRequest(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $OPENAI_API_KEY"
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "user",
              "content": 
                  "Does this message want to generate or ask to provide an AI Image, art or picture or something similar? $prompt . Simply answer with yes or no"
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        String content =
            jsonDecode(response.body)['choices'][0]['message']['content'];
        content = content.trim();
        final String apiResponse;
        
        switch (content) {
          case 'Yes':
          case 'YES':
          case 'Yes.':
          case 'yes':
          case 'yes.':
            apiResponse = await dallEAPI(prompt);
          default:
            apiResponse = await chatGPTAPI(prompt);
        }
        return apiResponse;
      }
      

      return 'An internal Error Occured';
    } catch (err) {
      return 'An internal Error $err';
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    messages.add({"role": "user", "content": prompt});
    try {
      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $OPENAI_API_KEY"
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": messages,
        }),
      );

      if (response.statusCode == 200) {
        String content =
            jsonDecode(response.body)['choices'][0]['message']['content'];
        content = content.trim();
        messages.add({
          "role": 'assistant',
          "content": content,
        });

        return content;
      }

      return 'An internal Error Occured';
    } catch (err) {
      return 'An internal Error $err';
    }
  }

  Future<String> dallEAPI(String prompt) async {
    messages.add({"role": "user", "content": prompt});
    try {
      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/images/generations"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $OPENAI_API_KEY"
        },
        body: jsonEncode({
          "model": "dall-e-3",
          "prompt": prompt,
          "n": 1,
          "size": "1024x1024"
        }),
      );

      if (response.statusCode == 200) {
        String imageUrl =
            jsonDecode(response.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();

         messages.add({
          "role": 'assistant',
          "content": imageUrl,
        });

        return imageUrl;
      }

      return 'An internal Error Occured';
    } catch (err) {
      return 'An internal Error $err';
    }
  }
}
