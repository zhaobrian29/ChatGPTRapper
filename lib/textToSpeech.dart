import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class CambAiTTS {
  final String? apiKey=dotenv.env['CAMB_AI_API_KEY'];
  final String baseUrl=
      dotenv.env['CAMB_AI_BASE_URL']??"https://client.camb.ai/apis/tts";
  final AudioPlayer _audioPlayer=AudioPlayer();

  Future<void> speak({
    required String text,
    required int voiceId,
    required int language,
  }) async {
    if(apiKey==null) {
      print("CambAiTTS: Missing CAMB_AI_API_KEY in .env");
      return;
    }

    final url=Uri.parse(baseUrl);

    try {
      print("Sending request to CambAI TTS . . .");
      final response=await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey!,
        },
        body: jsonEncode({
          "text": text,
          "voice_id": voiceId,
          "language": language,
        }),
      );

      print("CambAI status: ${response.statusCode}");
      print("CambAI content-type: ${response.headers['content-type']}");

      if(response.statusCode==200&&
          response.headers['content-type']?.contains('audio')==true) {
        final dir=await getTemporaryDirectory();
        final file=File('${dir.path}/CambAItextToSpeech.mp3');
        await file.writeAsBytes(response.bodyBytes);

        print("Audio saved at: ${file.path}");
        print("File size: ${await file.length()} bytes");

        await _audioPlayer.stop();
        await _audioPlayer.play(DeviceFileSource(file.path));
        print("Playing audio . . . ");
      } else {
        final body=utf8.decode(response.bodyBytes,allowMalformed: true);
        print("CambAI returned non-audio response: $body");
      }
    } catch (e) {
      print("CambAiTTS Exception: $e");
    }
  }
}
