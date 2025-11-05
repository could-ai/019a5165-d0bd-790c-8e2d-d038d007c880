import 'dart:async';

import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _imageSelected = false;
  bool _isGenerating = false;
  bool _videoGenerated = false;
  double _progress = 0.0;
  Timer? _timer;

  void _uploadImage() {
    setState(() {
      _imageSelected = true;
      _videoGenerated = false;
      _progress = 0.0;
    });
  }

  void _generateVideo() {
    if (!_imageSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image first!')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _videoGenerated = false;
      _progress = 0.0;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _progress += 0.01;
        if (_progress >= 1.0) {
          _timer?.cancel();
          _isGenerating = false;
          _videoGenerated = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Image to Video',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMediaDisplay(),
              const SizedBox(height: 24),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Enter a prompt (e.g., "make it snow")',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isGenerating ? null : _generateVideo,
                child: Text(_isGenerating ? 'Generating...' : 'Generate Video'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaDisplay() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!, width: 1),
        ),
        child: Center(
          child: _buildMediaContent(),
        ),
      ),
    );
  }

  Widget _buildMediaContent() {
    if (_isGenerating) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(value: _progress, color: Colors.white),
          const SizedBox(height: 20),
          Text('Generating video... ${(_progress * 100).toInt()}%',
              style: const TextStyle(color: Colors.white)),
        ],
      );
    }

    if (_videoGenerated) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            color: Colors.black,
            child: const Center(
              child: Text('Video Preview',
                  style: TextStyle(color: Colors.white54)),
            ),
          ),
          Icon(Icons.play_circle_outline,
              color: Colors.white.withOpacity(0.7), size: 64),
        ],
      );
    }

    if (_imageSelected) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image:
                    NetworkImage('https://picsum.photos/seed/picsum/1280/720'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: TextButton.icon(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    foregroundColor: Colors.white),
                onPressed: _uploadImage,
                icon: const Icon(Icons.change_circle_outlined, size: 18),
                label: const Text('Change Image')),
          )
        ],
      );
    }

    return InkWell(
      onTap: _uploadImage,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined,
              size: 64, color: Colors.white70),
          SizedBox(height: 16),
          Text('Upload Image',
              style: TextStyle(color: Colors.white70, fontSize: 18)),
        ],
      ),
    );
  }
}
