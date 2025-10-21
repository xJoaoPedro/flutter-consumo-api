import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MapaWebView extends StatefulWidget {
  final String pais;

  const MapaWebView({required this.pais, super.key});

  @override
  State<MapaWebView> createState() => _MapaWebViewState();
}

class _MapaWebViewState extends State<MapaWebView> {
  late final WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    final htmlContent = '''
    <!DOCTYPE html>
    <html>
      <body>
        <iframe
          width="100%"
          height="100%"
          style="border:0"
          loading="lazy"
          allowfullscreen
          src="https://www.google.com/maps?q=${widget.pais.toLowerCase()}&output=embed&hl=pt-BR">
        </iframe>
      </body>
    </html>
    ''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.dataFromString(
          htmlContent,
          mimeType: 'text/html',
        ),
      );

    return SizedBox.expand(
      child: WebViewWidget(controller: _controller),
    );
  }
}
