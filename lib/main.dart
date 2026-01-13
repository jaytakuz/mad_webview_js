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
      title: 'Flutter JS Integration',
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
  String totalFromJS = '';

  final String htmlContent = r'''
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
      body { 
        font-family: serif; 
        padding: 20px; 
        background-color: white;
      }
      h1 { font-size: 32px; margin-bottom: 30px; }
      p { font-size: 28px; font-weight: bold; margin-bottom: 40px; }
      .btn {
        background-color: #ebebeb;
        color: #448aff;
        border: none;
        border-radius: 25px;
        padding: 12px;
        font-size: 18px;
        width: 100%;
        cursor: pointer;
        text-align: center;
      }
    </style>
</head>
<body>
  <h1>My Cart</h1>
  <p id="total">Total: $120</p>
  <button class="btn" onclick="sendTotalToFlutter()">
    Send Total to Flutter
  </button>

  <script>
    function sendTotalToFlutter() {
      var totalPrice = document.getElementById('total').innerText;
      FlutterChannel.postMessage(totalPrice);
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
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          setState(() {
            totalFromJS = message.message;
          });
        },
      )
      ..loadHtmlString(htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'WebView JS Example',
          style: TextStyle(color: Colors.black87, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFF5F9), // Subtle pinkish/white background
        elevation: 0,
      ),
      body: Column(
        children: [
          // WebView takes the main space
          Expanded(
            child: _controller != null
                ? WebViewWidget(controller: _controller!)
                : const Center(child: CircularProgressIndicator()),
          ),
          // "Received from JS" bar at the bottom
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFEEEEEE), // Light gray background
              border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
            ),
            child: Text(
              'Received from JS: $totalFromJS',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
