// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:hershield/services/panic_service.dart';

// class AudioPlayerScreen extends StatefulWidget {
//   final String filePath;

//   const AudioPlayerScreen({Key? key, required this.filePath}) : super(key: key);

//   @override
//   _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
// }

// class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
//   final PanicService _panicService = PanicService();
//   bool _isPlaying = false;

//   @override
//   void initState() {
//     super.initState();
//     _panicService.playRecording(widget.filePath).then((_) {
//       setState(() {
//         _isPlaying = true;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _panicService.stopPlaying();
//     super.dispose();
//   }

//   void _togglePlayPause() async {
//     if (_isPlaying) {
//       await _panicService.stopPlaying();
//     } else {
//       await _panicService.playRecording(widget.filePath);
//     }
//     setState(() {
//       _isPlaying = !_isPlaying;
//     });
//   }

//   void _deleteRecording() async {
//     final file = File(widget.filePath);
//     if (await file.exists()) {
//       await file.delete();
//       Navigator.pop(context); // Close the audio player screen after deletion
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Audio Player'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             IconButton(
//               icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
//               iconSize: 50,
//               onPressed: _togglePlayPause,
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _deleteRecording,
//               child: Text('Delete Recording'),
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }