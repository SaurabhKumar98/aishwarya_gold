// screens/video_player_screen.dart
import 'dart:async';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl; // can be local asset or network URL
  final String title;
  
  const VideoPlayerScreen({
    super.key, 
    required this.videoUrl,
    required this.title
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    print("🎥 PLAYER → PLAYING URL: ${widget.videoUrl}");

  }

  void _initializeVideo() {
    // Check if URL is network or asset
    if (widget.videoUrl.startsWith('http://') || 
        widget.videoUrl.startsWith('https://')) {
      // Network video
      _controller = VideoPlayerController.network(widget.videoUrl);


    } else {
      // Asset video
      _controller = VideoPlayerController.asset(widget.videoUrl);
    }

    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = error.toString();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.backgroundWhite,
      ),
      body: Center(
        child: _hasError
            ? _buildErrorWidget()
            : _isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        VideoPlayer(_controller),
                        _ControlsOverlay(controller: _controller),
                        VideoProgressIndicator(
                          _controller, 
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: AppColors.primaryRed,
                            bufferedColor: Colors.grey,
                            backgroundColor: Colors.white24,
                          ),
                        ),
                      ],
                    ),
                  )
                : const CircularProgressIndicator(
                    color: AppColors.primaryRed,
                  ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load video',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isInitialized = false;
                _hasError = false;
              });
              _initializeVideo();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlsOverlay extends StatefulWidget {
  final VideoPlayerController controller;
  const _ControlsOverlay({required this.controller, super.key});

  @override
  State<_ControlsOverlay> createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<_ControlsOverlay> {
  bool _showOverlay = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_videoListener);
  }

  void _videoListener() {
    if (!mounted) return;
    if (!widget.controller.value.isPlaying) {
      // Show overlay when paused
      setState(() => _showOverlay = true);
      _hideTimer?.cancel();
    }
  }

  void _toggleOverlay() {
    if (_showOverlay) {
      // Hide overlay immediately
      setState(() => _showOverlay = false);
      _hideTimer?.cancel();
    } else {
      // Show overlay and hide after 3 seconds
      setState(() => _showOverlay = true);
      _hideTimer?.cancel();
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && widget.controller.value.isPlaying) {
          setState(() => _showOverlay = false);
        }
      });
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    widget.controller.removeListener(_videoListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _toggleOverlay();
        if (widget.controller.value.isPlaying) {
          widget.controller.pause();
        } else {
          widget.controller.play();
        }
      },
      child: AnimatedOpacity(
        opacity: _showOverlay ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          color: Colors.black26,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.controller.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}