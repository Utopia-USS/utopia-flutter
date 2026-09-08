import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:utopia_widgets/utopia_widgets.dart';

class LoaderWrapperLayoutPage extends StatefulWidget {
  const LoaderWrapperLayoutPage({super.key});

  @override
  State<LoaderWrapperLayoutPage> createState() => _LoaderWrapperLayoutPageState();
}

class _LoaderWrapperLayoutPageState extends State<LoaderWrapperLayoutPage> {
  bool _isLoading = false;
  int _tapCount = 0;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("LoaderWrapperLayout")),
      body: LoaderWrapperLayout(
        isLoaderVisible: _isLoading,
        loaderUiOverlayStyle: SystemUiOverlayStyle.light,
        loaderBuilder: (context) =>
            Container(color: Colors.black54, alignment: Alignment.center, child: const CircularProgressIndicator()),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "This is a form-ish body. While the loader is up, taps on it are "
                "ignored and the AppBar's back button is blocked (PopScope.canPop is false).",
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(labelText: "Name", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => setState(() => _tapCount++), child: Text("Tapped $_tapCount times")),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: Text(_isLoading ? "Loading..." : "Submit (show loader for 2s)"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
