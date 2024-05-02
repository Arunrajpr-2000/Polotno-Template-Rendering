import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:polotno_template_editor/json_string.dart';
import 'package:saver_gallery/saver_gallery.dart';

class PolotnoRender extends StatefulWidget {
  const PolotnoRender({super.key});

  @override
  State<PolotnoRender> createState() => _PolotnoRenderState();
}

class _PolotnoRenderState extends State<PolotnoRender> {
  TextEditingController offerController = TextEditingController(text: '50');
  TextEditingController titleController =
      TextEditingController(text: 'Home For Sale');
  TextEditingController websiteController =
      TextEditingController(text: 'Your Website');
  TextEditingController xPositionController =
      TextEditingController(text: '565');
  TextEditingController yPositionController =
      TextEditingController(text: '650');
  TextEditingController imagePositionController =
      TextEditingController(text: '1');

  Uint8List? byteImage;
  String? apiKey = "BXvgtVzPXIg-GvJ6ENWu";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    renderImage(designJson("50", "Home For Sale", "Your Website",
        564.7405451626593, 648.7444016181228, 2.410012703966257e-12));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 222, 222, 222),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              isLoading
                  ? const CircularProgressIndicator()
                  : byteImage != null
                      ? Container(
                          height: 300,
                          width: 300,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: MemoryImage(byteImage!),
                                fit: BoxFit.contain,
                              )),
                        )
                      : const Text('No image available'),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  controller: offerController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Enter offer'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  controller: titleController,
                  decoration: const InputDecoration(hintText: 'Enter title'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  controller: websiteController,
                  decoration: const InputDecoration(hintText: 'Enter website'),
                ),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  controller: xPositionController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(hintText: 'Enter position x'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  controller: yPositionController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(hintText: 'Enter position y'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  controller: imagePositionController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(hintText: 'Enter image position'),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  // Update the JSON with new text
                  final updatedDesignJson = designJson(
                    offerController.text,
                    titleController.text,
                    websiteController.text,
                    double.parse(xPositionController.text),
                    double.parse(yPositionController.text),
                    double.parse(imagePositionController.text),
                  );

                  await renderImage(updatedDesignJson);
                },
                child: const Text('Render Image'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await downloadImage(context);
                  // downloadImage(context, byteImage);
                },
                child: const Text('Download Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> renderImage(Map<String, dynamic> designJson) async {
    final url = Uri.parse('https://api.polotno.com/api/render?KEY=$apiKey');
    final body = jsonEncode({
      'design': designJson,
      'outputFormat': 'dataURL',
      "exportOptions": {
        //   // you can pass options that you pass into `store.toDataURL()`
        //   "pixelRatio": 1,
        //   "ignoreBackground": false,
        //   "includeBleed": false,
        //   "htmlTextRenderEnabled": false,
        //   "textVerticalResizeEnabled": false,
        //   "skipFontError": true, // do no throw error if font is missing
        //   "textOverflow": "change-font-size"
      }
    });

    final response = await http.post(
      url,
      body: body,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // If the response contains a valid data URL, extract and decode it
      if (data['url'].toString().startsWith('data:image/png;base64,')) {
        final base64String = data['url'].split(',')[1];
        byteImage = base64Decode(base64String);
      } else {
        byteImage = null;
      }
      isLoading = false;
      setState(() {});
    } else {
      throw Exception(
          'Failed to render image. Status code: ${response.statusCode}');
    }
  }

  downloadImage(context) async {
    if (byteImage != null) {
      final result = await SaverGallery.saveImage(
          androidRelativePath: "Pictures/polotno/",
          androidExistNotSave: false,
          name: 'temp_${DateTime.now().millisecondsSinceEpoch}.png',
          Uint8List.fromList(byteImage!));
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image saved to gallery!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save image: ${result.errorMessage}'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No image to download'),
        ),
      );
    }
    setState(() {
      isLoading = false;
    });
  }
}
