import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class MediaPlayerWidget extends StatefulWidget {
  final String videoURL;
  MediaPlayerWidget({this.videoURL});

  @override
  _MediaPlayerWidgetState createState() => _MediaPlayerWidgetState();
}

class _MediaPlayerWidgetState extends State<MediaPlayerWidget> {
  VideoPlayerController videoPlayerController;
  ChewieController chewieController;
  var _youTubeController;
  bool YOUTUBE = false;

  @override
  Widget build(BuildContext context) {
    try {
      clearAll();
      initControllers();
      return Container(
        height: MediaQuery.of(context).size.height * 0.25,
        width: MediaQuery.of(context).size.width,
        color: Colors.black87,
        child: YOUTUBE ? getYoutubePlayer() : getChewiePlayer(),
      );
    } catch (Ex) {
      return Container();
    }
  }

  getChewiePlayer() {
    return Chewie(
      controller: chewieController,
    );
  }

  getYoutubePlayer() {
    return YoutubePlayerControllerProvider(
      controller: _youTubeController,
      child: YoutubePlayerIFrame(
        aspectRatio: 16 / 9,
      ),
    );
  }

  void initControllers() {
    YOUTUBE = (widget.videoURL.contains('.mp4') == false);

    if (YOUTUBE) {
      String videoId;
      videoId = YoutubePlayerController.convertUrlToId(widget.videoURL);

      _youTubeController = YoutubePlayerController(
        initialVideoId: videoId,
        params: YoutubePlayerParams(
          autoPlay: true,
          mute: false,
          loop: false,
        ),
      );
    } else {
      videoPlayerController = VideoPlayerController.network(widget.videoURL);
      chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        aspectRatio: 16 / 9,
        autoPlay: false,
        autoInitialize: true,
        looping: false,
        errorBuilder: (context, error) {
          return Container();
        },
      );
    }
  }

  void clearAll() {
    if (chewieController != null) {
      chewieController.dispose();
      chewieController = null;
    }
    if (videoPlayerController != null) {
      //videoPlayerController.dispose();
      videoPlayerController.pause();
      videoPlayerController = null;
    }

    if (_youTubeController != null) {
      _youTubeController = null;
    }
  }
}
