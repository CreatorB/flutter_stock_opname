import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConfigView extends StatefulWidget {
  const ConfigView({super.key});

  @override
  State<ConfigView> createState() => _ConfigViewState();
}

class _ConfigViewState extends State<ConfigView> {

  late final TextEditingController _urlController;

  @override
  void initState() {
    super.initState();

    _urlController = TextEditingController(text: "banghasyim.net/POSKASIR/api/");
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Konfigurasi Server"),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              const Icon(
                Icons.dns,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 40),

              CupertinoTextField(
                controller: _urlController,
                placeholder: 'Masukkan URL Server',
                clearButtonMode: OverlayVisibilityMode.editing,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 32),

              CupertinoButton.filled(
                child: const Text('SAVE'),
                onPressed: () {

                  context.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}