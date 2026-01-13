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
      title: 'JS Integration Challenge',
      theme: ThemeData(useMaterial3: true),
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
  String currentTotal = '0';

  // Challenge HTML content
  final String htmlContent = r'''
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
      body { font-family: serif; padding: 20px; background-color: white; }
      h1 { font-size: 28px; margin-bottom: 20px; }
      .item { 
        display: flex; 
        justify-content: space-between; 
        align-items: center;
        border: 1px solid #ddd;
        border-radius: 8px;
        padding: 8px 12px;
        margin-bottom: 10px;
        font-size: 16px;
      }
      .add-btn {
        color: #448aff;
        border: 1px solid #ddd;
        background: white;
        border-radius: 15px;
        padding: 4px 15px;
        font-size: 14px;
        cursor: pointer;
      }
      .cart-section { margin-top: 30px; }
      .cart-title { font-size: 24px; font-weight: bold; }
      #total-display { font-size: 22px; margin-top: 10px; }
    </style>
</head>
<body>
    <h1>My Cart</h1>
    
    <div class="item">
      <span>Apple - $10</span>
      <button class="add-btn" onclick="addToTotal(10)">Add</button>
    </div>
    <div class="item">
      <span>Banana - $20</span>
      <button class="add-btn" onclick="addToTotal(20)">Add</button>
    </div>
    <div class="item">
      <span>Orange - $25</span>
      <button class="add-btn" onclick="addToTotal(25)">Add</button>
    </div>
    <div class="item">
      <span>Milk - $45</span>
      <button class="add-btn" onclick="addToTotal(45)">Add</button>
    </div>
    <div class="item">
      <span>Bread - $35</span>
      <button class="add-btn" onclick="addToTotal(35)">Add</button>
    </div>

    <div class="cart-section">
      <div class="cart-title">Cart</div>
      <p>Total:</p>
      <div id="total-display">0</div>
    </div>

    <script>
      let total = 0;

      function addToTotal(amount) {
        total += amount;
        document.getElementById('total-display').innerText = total;
        // Step 2: Send data to Flutter via FlutterChannel
        FlutterChannel.postMessage(total.toString());
      }

      // Step 3: JS function to be called from Flutter
      function updateTotalFromFlutter(newTotal) {
        total = parseInt(newTotal);
        document.getElementById('total-display').innerText = total;
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
          // Step 2: Retrieve total data and show on Flutter part
          setState(() {
            currentTotal = message.message;
          });
        },
      )
      ..loadHtmlString(htmlContent);
  }

  // Step 3: Send data from Flutter to JS
  Future<void> _sendTotalPlus100() async {
    if (_controller == null) return;
    
    // Calculate new total (current + 100)
    int total = int.tryParse(currentTotal) ?? 0;
    int newTotal = total + 100;
    
    // Send to JS via "updateTotalFromFlutter"
    await _controller!.runJavaScript("updateTotalFromFlutter('$newTotal')");
    
    // Update Flutter side to keep in sync
    setState(() {
      currentTotal = newTotal.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('WebView JS Example'),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFF5F9),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. Show HTML inside webview
          Expanded(
            child: _controller != null
                ? WebViewWidget(controller: _controller!)
                : const Center(child: CircularProgressIndicator()),
          ),
          
          // 2. Received from JS display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFEEEEEE),
              border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Received from JS: $currentTotal',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                // 3. Send +100 total from Flutter to JS button
                Center(
                  child: ElevatedButton(
                    onPressed: _sendTotalPlus100,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                      elevation: 0,
                      side: const BorderSide(color: Colors.black12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Send +100 total from Flutter to JS'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
