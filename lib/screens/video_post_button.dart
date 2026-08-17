import 'package:flutter/material.dart';

import 'create_video_post_screen.dart';

class VideoPostButton extends StatelessWidget {
  const VideoPostButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.video_call),
        ),
        title: const Text(
          'Create Video Post',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Text(
          'Gallery থেকে ভিডিও পোস্ট করুন',
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const CreateVideoPostScreen(),
            ),
          );
        },
      ),
    );
  }
}
