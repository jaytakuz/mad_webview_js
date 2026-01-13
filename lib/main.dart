import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter to JS Workshop',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  WebViewController? _controller;

  // HTML content with JS function to receive data from Flutter
  final String htmlContent = r'''
<!DOCTYPE html>
<html>
<head>
    <title>JS from Flutter</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
      body { font-family: serif; padding: 20px; }
      h1 { font-size: 28px; }
      p { font-size: 18px; color: #555; }
    </style>
</head>
<body>
    <h1>Web Page</h1>
    <p id="msg">No message yet</p>

    <script>
      function showMessageFromFlutter(msg) {
        document.getElementById('msg').innerText = "Flutter says: " + msg;
        return "Message received: " + msg;
      }
    </script>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(htmlContent);
  }

  // Method to send message to JavaScript
  Future<void> _sendMessage() async {
    if (_controller == null) return;

    // Option 1: Just run JS, no return value
    await _controller!.runJavaScript(
      "showMessageFromFlutter('Hello from Flutter!')",
    );

    // Option 2: Get return value from JS
    final Object result = await _controller!.runJavaScriptReturningResult(
      "showMessageFromFlutter('Hello from Flutter with return value!')",
    );
    
    debugPrint("JS returned: $result");
    
    // Optional: Show result in a snackbar to verify
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('JS returned: $result')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flutter to JS',
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFF5F9),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.send, color: Colors.black87),
            onPressed: _sendMessage,
          ),
        ],
      ),
      body: _controller != null
          ? WebViewWidget(controller: _controller!)
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
