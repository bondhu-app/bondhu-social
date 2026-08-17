import 'package:flutter/material.dart';
import '../services/video_service.dart';

class CreateVideoPostScreen extends StatefulWidget {
  const CreateVideoPostScreen({super.key});

  @override
  State<CreateVideoPostScreen> createState() =>
      _CreateVideoPostScreenState();
}

class _CreateVideoPostScreenState
    extends State<CreateVideoPostScreen> {
  final VideoService _videoService = VideoService();

  final TextEditingController _captionController =
      TextEditingController();

  bool _uploading = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _createPost() async {
    if (_uploading) return;

    setState(() {
      _uploading = true;
    });

    try {
      await _videoService.createVideoPostFromGallery(
        caption: _captionController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ভিডিও সফলভাবে পোস্ট হয়েছে।',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ভিডিও পোস্ট করা যায়নি:\n$e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Video Post',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              child: const Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_library,
                    size: 70,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Gallery থেকে Video নির্বাচন করুন',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _captionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'ভিডিও সম্পর্কে কিছু লিখুন...',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (_uploading)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text(
                    'ভিডিও Upload হচ্ছে...',
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: _createPost,
                icon: const Icon(
                  Icons.video_call,
                ),
                label: const Text(
                  'Select Video & Post',
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
