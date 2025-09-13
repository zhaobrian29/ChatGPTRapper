import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class CambAiTTS {
  final String apiKey=dotenv.env['CAMB_AI_API_KEY']??"";
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> speak({
    required String text,
    required int voiceId,
    required int language,
  }) async {
    final url = Uri.parse(
      dotenv.env['CAMB_AI_BASE_URL'] ?? "https://client.camb.ai/apis/tts",
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
        },
        body: jsonEncode({
          "text": text,
          "voice_id": voiceId,
          "language": language,
        }),
      );

      print("CambAI status: ${response.statusCode}");
      print("CambAI content-type: ${response.headers['content-type']}");

      if (response.statusCode == 200 &&
          response.headers['content-type']?.contains('audio') == true) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/CambAItextToSpeech.mp3');
        await file.writeAsBytes(response.bodyBytes);
        print("Audio saved at: ${file.path}, size=${await file.length()} bytes");

        await _audioPlayer.setVolume(1.0);
        await _audioPlayer.play(DeviceFileSource(file.path));
      } else {
        final body = utf8.decode(response.bodyBytes, allowMalformed: true);
        print("CambAI did not return audio. Body: $body");
      }
    } catch (e) {
      print("CambAI Exception occ. $e");
    }
  }
}

class LilEmPage extends StatefulWidget {
  const LilEmPage({Key? key}) : super(key: key);

  @override
  State<LilEmPage> createState() => _LilEmPageState();
}

class _LilEmPageState extends State<LilEmPage> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  bool _loading = false;

  Future<void> sendMessage(String message) async {
    final apiKey = dotenv.env['COHERE_API_KEY'];
    final baseUrl = dotenv.env['COHERE_BASE_URL'];

    if (apiKey == null || baseUrl == null) {
      setState(() {
        _response =
        "Missing COHERE_API_KEY or COHERE_BASE_URL in .env; so please add it so as to get this part of the program to work";
      });
      return;
    }

    setState(() {
      _loading = true;
      _response = '';
    });

    try {
      final res = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "command-r-plus",
          "message": message,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _response = data["text"] ??
              "No response received. The number of unused credits for the trial key likely may have all been depleted.";
        });
      } else {
        setState(() {
          _response = "Error: ${res.body}";
        });
      }
    } catch (e) {
      setState(() {
        _response = "Exception occ. $e";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4E9975);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Lil' Em (aka LLM)", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Text(
                "A fun-style method of learning lyrics and rhymes alike!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Enter Ideation Prompt for Lyrics",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        sendMessage(value.trim());
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Type your message . . .",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: const Color(0xFFF0F2F5),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send, color: primaryColor),
                        onPressed: () {
                          if (_controller.text.trim().isNotEmpty) {
                            sendMessage(_controller.text.trim());
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: _loading
                    ? const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                )
                    : _response.isEmpty
                    ? const Center(
                  child: Text(
                    "(Instructional a cappella music words will appear here)",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
                    : SingleChildScrollView(
                  child: Text(
                    _response,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class CambAiTTS {
  final String apiKey;
  final AudioPlayer _audioPlayer=AudioPlayer();

  CambAiTTS({required this.apiKey});

  Future<void> speak({
    required String text,
    required int voiceId,
    required int language,
  }) async {
    final url = Uri.parse(
      dotenv.env['CAMB_AI_BASE_URL'] ?? "https://client.camb.ai/apis/tts",
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
        },
        body: jsonEncode({
          "text": text,
          "voice_id": voiceId,
          "language": language,
        }),
      );

      if(response.statusCode==200) {
        final dir=await getTemporaryDirectory();
        final file=File('${dir.path}/CambAItextToSpeech.mp3');
        print("Audio saved at: ${file.path}");
        await file.writeAsBytes(response.bodyBytes);

        // Play
        await _audioPlayer.play(DeviceFileSource(file.path));
      } else {
        print("CambAI Error received, ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("CambAI Exception occ. $e");
    }
  }
}

class LilEmPage extends StatefulWidget {
  const LilEmPage({Key? key}) : super(key: key);

  @override
  State<LilEmPage> createState() => _LilEmPageState();
}

class _LilEmPageState extends State<LilEmPage> {
  final TextEditingController _controller=TextEditingController();
  String _response='';
  bool _loading=false;

  Future<void> sendMessage(String message) async {
    final apiKey=dotenv.env['COHERE_API_KEY'];
    final baseUrl=dotenv.env['COHERE_BASE_URL'];

    if(apiKey==null||baseUrl==null) {
      setState(() {
        _response="Missing COHERE_API_KEY or COHERE_BASE_URL in .env; so please add it so as to get this part of the program to work";
      });
      return;
    }

    setState(() {
      _loading=true;
      _response='';
    });

    try {
      final res=await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "command-r-plus",
          "message": message,
        }),
      );

      if(res.statusCode==200) {
        final data=jsonDecode(res.body);
        setState(() {
          _response=data["text"] ?? "No response received. The number of unused credits for the trial key likely may have all been depleted.";
        });
      } else {
        setState(() {
          _response="Error: ${res.body}";
        });
      }
    } catch (e) {
      setState(() {
        _response="Exception occ. $e";
      });
    } finally {
      setState(() {
        _loading=false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor=Color(0xFF4E9975);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Lil' Em (aka LLM)", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Text(
                "A fun-style method of learning lyrics and rhymes alike!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Enter Ideation Prompt for Lyrics",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (value) {
                      if(value.trim().isNotEmpty) {
                        sendMessage(value.trim());
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Type your message . . .",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: const Color(0xFFF0F2F5),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send,color: primaryColor),
                        onPressed: () {
                          if(_controller.text.trim().isNotEmpty) {
                            sendMessage(_controller.text.trim());
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Response Section
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0,5),
                    ),
                  ],
                ),
                child: _loading
                    ? const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                )
                    : _response.isEmpty
                    ? const Center(
                  child: Text(
                    "(Instructional a cappella music words will appear here)",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
                    : SingleChildScrollView(
                  child: Text(
                    _response,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/
