import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPostCard extends StatefulWidget {
  final String videoUrl;
  final String userName;
  final String userPhotoUrl;
  final String caption;

  const VideoPostCard({
    super.key,
    required this.videoUrl,
    required this.userName,
    required this.userPhotoUrl,
    required this.caption,
  });

  @override
  State<VideoPostCard> createState() =>
      _VideoPostCardState();
}

class _VideoPostCardState
    extends State<VideoPostCard> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    )..initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  widget.userPhotoUrl.isNotEmpty
                      ? NetworkImage(
                          widget.userPhotoUrl,
                        )
                      : null,
              child:
                  widget.userPhotoUrl.isEmpty
                      ? const Icon(Icons.person)
                      : null,
            ),
            title: Text(
              widget.userName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          if (widget.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                12,
              ),
              child: Text(
                widget.caption,
              ),
            ),

          if (_controller.value.isInitialized)
            Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio:
                      _controller.value.aspectRatio,
                  child: VideoPlayer(
                    _controller,
                  ),
                ),
                GestureDetector(
                  onTap: _togglePlay,
                  child: CircleAvatar(
                    radius: 30,
                    child: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 35,
                    ),
                  ),
                ),
              ],
            )
          else
            const AspectRatio(
              aspectRatio: 16 / 9,
              child: Center(
                child:
                    CircularProgressIndicator(),
              ),
            ),

          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.favorite_border,
                ),
              ),
              const Text('Like'),

              const SizedBox(width: 10),

              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.comment_outlined,
                ),
              ),
              const Text('Comment'),

              const Spacer(),

              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.share_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
