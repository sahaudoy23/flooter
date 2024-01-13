/// Checks if you are awesome. Spoiler: you are.
//TODO: setup logging
//TODO: setup exceptions and error handling
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

Future<String> create(
    String model, String apiKey, Map<String, Object> input) async {
  /* returns a json string that is the response body */

  // Replace with your actual endpoint
  String apiUrl = "https://api.runpod.ai/v2/$model/run";

  // Replace with your actual JSON payload

  var payload = {
    "input": input,
  };
  var jsonPayload = jsonEncode(payload);
  Map<String, String> headers = {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };

  try {
    var response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonPayload,
    );

    //print('Response status: ${response.statusCode}');
    //print('Response body: ${response.body}');
    return response.body;
  } catch (error) {
    //print('Error: $error');
    return "Error";
  }
}

Future<String> getPng(String id, String apiKey) async {
  String apiUrl = "https://api.runpod.ai/v2/mhwg0w51p0ew5s/status/$id";
  Map<String, String> headers = {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };

  try {
    var response = await http.get(
      Uri.parse(apiUrl),
      headers: headers,
    );
    print('Response status: ${response.statusCode}');
    //print('Response body_1: ${response.body}');
    return response.body;
  } catch (error) {
    //print('Error: $error');
    return "Error";
  }
}

Future<String> createGetJson(
    String model, String apiKey, Map<String, Object> input) async {
  // creates a prediction and returns a json string once completed
  var response = await create(model, apiKey, input);
  var responseJson = jsonDecode(response);
  String id = responseJson['id'];
  while (
      !['canceled', 'COMPLETED', 'failed'].contains(responseJson['status'])) {
    await Future.delayed(Duration(milliseconds: 250));
    response = await getPng(id, apiKey);
    responseJson = jsonDecode(response);
  }
  final result = await getPng(id, apiKey);
  return result;
}

Future<void> main() async {
  Map<String, Object> input = {
    // input is specific to replicate model, adjust to fit your use
    "prompt": "a dog",
    "cn_type1": "ImagePrompt",
    "cn_type2": "ImagePrompt",
    "cn_type3": "ImagePrompt",
    "cn_type4": "ImagePrompt",
    "sharpness": 2,
    "image_seed": 1,
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
  String model = "mhwg0w51p0ew5s"; // model version for replicate api

  String apiKey =
      "ILI4MIZKZR45KE226BODAD5ENT9CNQZA735EEFX7"; //replace with your api key

  String jsonString = await createGetJson(
    model,
    apiKey,
    input,
  );
  //print(jsonString);
  var responseJson = jsonDecode(jsonString); //converts string to json object

  // then you can parse the json file to get whatever value you need
  // For this example, I want the 'output', which is a png link
  String base64img = responseJson['output'][0];
  List splitted = base64img.split(',');
  String justBase64 = splitted[0];

  //print('PNG Image Path: $imagePath');

  // Use imagePath as needed in your command-line application
}
