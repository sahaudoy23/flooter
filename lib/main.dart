import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'runpod.dart';

void main() => runApp(const MaterialApp(home: MyImageWidget()));

class MyImageWidget extends StatefulWidget {
  const MyImageWidget({Key? key}) : super(key: key);

  @override
  _MyImageWidgetState createState() => _MyImageWidgetState();
}

class _MyImageWidgetState extends State<MyImageWidget> {
  String? _imageBytes; // comment out if using replicate
  //String? _imageUrl; //comment out if using runpod
  String? _errorMessage;
  final TextEditingController _queryController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  late SharedPreferences _prefs;
  double _sharpness = 10;

  @override
  void initState() {
    super.initState();
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    String? savedSeed = _prefs.getString('seed');
    if (savedSeed != null) {
      _urlController.text = savedSeed;
    } else {
      _urlController.text = "-1";
    }
  }

  Future<void> _saveSettings() async {
    String seed = _urlController.text.trim();
    if (seed.isNotEmpty) {
      await _prefs.setString('seed', seed);
    }
  }

  Future<void> _generateImage(String query, int sharpness) async {
    String? seed = _urlController.text.trim();
    await _saveSettings();

    setState(() {
      //_imageurl = null; // comment out if using runpod
      _imageBytes = null; // comment out if using replicate
      _errorMessage = null;
    });

    try {
      //String modelVersion = "a7e8fa2f96b01d02584de2b3029a8452b9bf0c8fa4127a6d1cfd406edfad54fb"; // comment out if using runpod
      //String apiKey = "r8_2QsFXKi8ujufno8DHnuQRV67I94uESA2fUPxm"; // comment out if using runpod

      String modelVersion = "mhwg0w51p0ew5s"; // comment out if using replicate
      String apiKey =
          "ILI4MIZKZR45KE226BODAD5ENT9CNQZA735EEFX7"; // comment out if using replicate

      Map<String, Object> input = {
        "prompt": query,
        "cn_type1": "ImagePrompt",
        "cn_type2": "ImagePrompt",
        "cn_type3": "ImagePrompt",
        "cn_type4": "ImagePrompt",
        "sharpness": sharpness,
        "image_seed": int.parse(seed),
        "uov_method": "Disabled",
        "image_number": 1,
        "guidance_scale": 4,
        "refiner_switch": 0.5,
        "negative_prompt": "",
        "style_selections": "Fooocus V2,Fooocus Enhance,Fooocus Sharp",
        "uov_upscale_value": 0,
        "outpaint_selections": "",
        "outpaint_distance_top": 0,
        "performance_selection": "Speed",
        "outpaint_distance_left": 0,
        "aspect_ratios_selection": "1152*896",
        "outpaint_distance_right": 0,
        "outpaint_distance_bottom": 0,
        "inpaint_additional_prompt": ""
      };

      String jsonString = await createGetJson(
          // comment out for replicate use
          modelVersion,
          apiKey,
          input); // comment out for replicate use

      //String jsonString = await createGetJson(modelVersion, apiKey, input); //comment out for runpod

      var responseJson =
          jsonDecode(jsonString); //converts string to json object
      String output = responseJson['output'][0];

      List splitted = output.split(','); // comment out if using replicate
      String base64String = splitted[1]; // comment out if using replicate

      setState(() {
        //_imageUrl = output; // comment out if using runpod
        _imageBytes = base64String; // comment out if using replicate
      });
    } catch (e) {
      setState(() {
        print(e);
        _errorMessage = 'Failed to generate image: $e';
      });
    }
  }

  Future<void> _showSettingsDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Settings'),
          content: TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'Enter Img Seed, -1 is random',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _generateImage(
                    _queryController.text.trim(), _sharpness.toInt());
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Price X Saha'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                _showSettingsDialog();
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _queryController,
                decoration: const InputDecoration(
                  labelText: 'Enter Query',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sharpness: $_sharpness',
                style: const TextStyle(fontSize: 16),
              ),
              Slider(
                value: _sharpness,
                min: 0,
                max: 30,
                divisions: 30,
                onChanged: (newValue) {
                  setState(() {
                    _sharpness = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  String query = _queryController.text.trim();
                  if (query.isNotEmpty) {
                    _generateImage(query, _sharpness.toInt());
                  }
                },
                child: const Text('Generate'),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  //child: _imageUrl != null // comment if using runpod
                  child: _imageBytes != null // comment if using replicate
                      //? Image.network(_imageUrl!)//comment if using runpod
                      ? Image.memory(base64Decode(
                          _imageBytes!)) // comment if using replicate
                      : _errorMessage != null
                          ? Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            )
                          : const CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
