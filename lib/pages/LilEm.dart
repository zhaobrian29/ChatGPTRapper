import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LilEmPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Lil\' Em'));
  }
}

class CohereChatPage extends StatefulWidget {
  @override
  _CohereChatPageState createState() => _CohereChatPageState();
}

class _CohereChatPageState extends State<CohereChatPage> {
  final TextEditingController _controller = TextEditingController();
  String responseText = "";

  Future<void> sendMessage(String message) async {
    const apiKey = "COHERE_API_KEY"; // if public put in .env file; if not stay cautious
    final url = Uri.parse("COHERE_BASE_URL");

    final res = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "command-r-plus", // or the model you used in Playground
        "message": message,
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        responseText = data["text"] ?? "No response";
      });
    } else {
      setState(() {
        responseText = "Error: ${res.body}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cohere Chat")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(child: SingleChildScrollView(child: Text(responseText))),
            TextField(controller: _controller),
            ElevatedButton(
              onPressed: () {
                sendMessage(_controller.text);
              },
              child: Text("Send"),
            ),
          ],
        ),
      ),
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:vapi/vapi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await VapiClient.platformInitialized.future;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vapi Voice Demo',
      home: const VoiceWidget(),
    );
  }
}

class VoiceWidget extends StatefulWidget {
  const VoiceWidget({super.key});

  @override
  State<VoiceWidget> createState() => _VoiceWidgetState();
}

class _VoiceWidgetState extends State<VoiceWidget> {
  late final VapiClient _vapi;
  VapiCall? _activeCall;
  bool _isLoading = false;

  static const String _publicKey = 'YOUR_PUBLIC_API_KEY';
  static const String _assistantId = 'YOUR_ASSISTANT_ID';

  @override
  void initState() {
    super.initState();
    _vapi = VapiClient(_publicKey);
  }

  @override
  void dispose() {
    _activeCall?.dispose();
    super.dispose();
  }

  void _listenToCallEvents(VapiCall call) {
    call.onEvent.listen((event) {
      if (event.label == 'call-start') {
        setState(() {
          _isLoading = false;
        });
      } else if (event.label == 'call-end') {
        setState(() {
          _activeCall = null;
          _isLoading = false;
        });
      } else if (event.label == 'message') {
        debugPrint('Message event: ${event.value}');
      }
    });
  }

  Future<void> _toggleCall() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      if (_activeCall == null) {
        final call = await _vapi.start(assistantId: _assistantId);
        _activeCall = call;
        _listenToCallEvents(call);
      } else {
        await _activeCall!.stop();
      }
    } catch (e) {
      debugPrint('Error with Vapi call: $e');
      setState(() {
        _activeCall = null;
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start/stop call: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCallActive = _activeCall != null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vapi Voice Widget'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _toggleCall,
          child: Text(_isLoading
              ? 'Loading...'
              : (isCallActive ? 'End Call' : 'Start Call')),
        ),
      ),
    );
  }
}*/

/*import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  bool _loading = false;

  void _sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _loading = true;
      _response = '';
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _response = 'Echo from ChatGPT: $input';
      _loading = false;
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4E9975),
        title: const Text('GPT Chat', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF2F7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Ask something:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              onSubmitted: (_) => _sendMessage(),
              textInputAction: TextInputAction.send,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Type your question...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF4E9975)),
                  onPressed: _sendMessage,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: _loading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF4E9975),
                  ),
                )
                    : _response.isNotEmpty
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Response:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4E9975),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _response,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ],
                )
                    : const Center(
                  child: Text(
                    'Your response will appear here.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
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