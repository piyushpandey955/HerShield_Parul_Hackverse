
// import 'package:flutter/material.dart';

// class PersonalityTestScreen extends StatefulWidget {
//   final Function(int) onTestComplete;

//   const PersonalityTestScreen({super.key, required this.onTestComplete});

//   @override
//   State<PersonalityTestScreen> createState() => _PersonalityTestScreenState();
// }

// class _PersonalityTestScreenState extends State<PersonalityTestScreen> {
//   final Map<String, int> _responses = {};
//   final List<Map<String, dynamic>> _questions = [
//     {
//       "question":
//           "You see a woman visibly distressed in a crowded area. She is being followed by someone. What do you do?",
//       "options": [
//         {"text": "Ask her if she needs help.", "points": 4},
//         {"text": "Call security immediately.", "points": 3},
//         {"text": "Wait and observe the situation.", "points": 2},
//         {"text": "Ignore it to avoid getting involved.", "points": 0},
//       ]
//     },
//     {
//       "question":
//           "A user reports harassment through the app. She seems very anxious. How do you respond?",
//       "options": [
//         {
//           "text": "Reassure her, listen carefully, and provide help.",
//           "points": 4
//         },
//         {"text": "Tell her to stay calm and wait while you investigate.", "points": 3},
//         {"text": "Advise her to block the harasser and move on.", "points": 1},
//         {"text": "Suggest she report it elsewhere, as you are busy.", "points": 0},
//       ]
//     },
//     {
//       "question":
//           "You receive a report of suspicious activity in your neighborhood. What do you do?",
//       "options": [
//         {"text": "Report it immediately to local authorities.", "points": 4},
//         {"text": "Wait to see if the situation escalates.", "points": 2},
//         {"text": "Discuss it with others first before acting.", "points": 1},
//         {"text": "Ignore the report.", "points": 0},
//       ]
//     },
//     {
//       "question":
//           "While using the app, you come across sensitive information about another user’s safety incident. What do you do?",
//       "options": [
//         {
//           "text": "Keep the information confidential and report it to the app administrators.",
//           "points": 4
//         },
//         {"text": "Share it with friends for advice.", "points": 1},
//         {"text": "Post about it on social media to raise awareness.", "points": 0},
//         {"text": "Ignore it and take no action.", "points": 0},
//       ]
//     },
//     {
//       "question": "I am willing to intervene when I witness harassment or suspicious behavior.",
//       "options": [
//         {"text": "Strongly Agree", "points": 4},
//         {"text": "Agree", "points": 3},
//         {"text": "Neutral", "points": 2},
//         {"text": "Disagree", "points": 1},
//         {"text": "Strongly Disagree", "points": 0},
//       ]
//     },
//     {
//       "question": "I remain calm and composed in stressful situations.",
//       "options": [
//         {"text": "Strongly Agree", "points": 4},
//         {"text": "Agree", "points": 3},
//         {"text": "Neutral", "points": 2},
//         {"text": "Disagree", "points": 1},
//         {"text": "Strongly Disagree", "points": 0},
//       ]
//     },
//     {
//       "question":
//           "I believe providing emotional support is important when helping someone in distress.",
//       "options": [
//         {"text": "Strongly Agree", "points": 4},
//         {"text": "Agree", "points": 3},
//         {"text": "Neutral", "points": 2},
//         {"text": "Disagree", "points": 1},
//         {"text": "Strongly Disagree", "points": 0},
//       ]
//     },
//     {
//       "question":
//           "I handle sensitive information with confidentiality and care.",
//       "options": [
//         {"text": "Strongly Agree", "points": 4},
//         {"text": "Agree", "points": 3},
//         {"text": "Neutral", "points": 2},
//         {"text": "Disagree", "points": 1},
//         {"text": "Strongly Disagree", "points": 0},
//       ]
//     },
//     {
//       "question":
//           "A friend shares that they are being harassed but are too afraid to report it. What would you do?",
//       "options": [
//         {"text": "Encourage and support them to report it while respecting their pace.", "points": 4},
//         {"text": "Insist they report it immediately.", "points": 2},
//         {"text": "Tell them they are overreacting.", "points": 0},
//         {"text": "Do nothing because it's their personal matter.", "points": 0},
//       ]
//     },
//     {
//       "question":
//           "You receive multiple requests for help at the same time. Which task do you prioritize first?",
//       "options": [
//         {"text": "A report of someone being followed late at night.", "points": 4},
//         {"text": "A request for safety tips from a new user.", "points": 2},
//         {"text": "A request to fix a technical issue in the app.", "points": 1},
//         {"text": "Attending a scheduled team meeting.", "points": 0},
//       ]
//     },
//   ];

//   int _currentQuestionIndex = 0;

//   void _selectOption(int points) {
//     setState(() {
//       _responses[_currentQuestionIndex.toString()] = points;
//       if (_currentQuestionIndex < _questions.length - 1) {
//         _currentQuestionIndex++;
//       } else {
//         _submitTest();
//       }
//     });
//   }

//   void _submitTest() {
//     final totalScore = _responses.values.reduce((a, b) => a + b);
//     widget.onTestComplete(totalScore);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentQuestion = _questions[_currentQuestionIndex];
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Personality Test"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Q${_currentQuestionIndex + 1}: ${currentQuestion['question']}",
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             ...List.generate(
//               (currentQuestion['options'] as List).length,
//               (index) => ListTile(
//                 title: Text(currentQuestion['options'][index]['text']),
//                 leading: Radio<int>(
//                   value: currentQuestion['options'][index]['points'],
//                   groupValue: _responses[_currentQuestionIndex.toString()],
//                   onChanged: (value) => _selectOption(value!),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class PersonalityTestScreen extends StatefulWidget {
  final Function(int) onTestComplete;

  const PersonalityTestScreen({super.key, required this.onTestComplete});

  @override
  State<PersonalityTestScreen> createState() => _PersonalityTestScreenState();
}

class _PersonalityTestScreenState extends State<PersonalityTestScreen> {
  final Map<String, int> _responses = {};
  final List<Map<String, dynamic>> _questions = [
    {
      "question":
          "You see a woman visibly distressed in a crowded area. She is being followed by someone. What do you do?",
      "options": [
        {"text": "Ask her if she needs help.", "points": 4},
        {"text": "Call security immediately.", "points": 3},
        {"text": "Wait and observe the situation.", "points": 2},
        {"text": "Ignore it to avoid getting involved.", "points": 0},
      ]
    },
    {
      "question":
          "A user reports harassment through the app. She seems very anxious. How do you respond?",
      "options": [
        {
          "text": "Reassure her, listen carefully, and provide help.",
          "points": 4
        },
        {"text": "Tell her to stay calm and wait while you investigate.", "points": 3},
        {"text": "Advise her to block the harasser and move on.", "points": 1},
        {"text": "Suggest she report it elsewhere, as you are busy.", "points": 0},
      ]
    },
    {
      "question":
          "You receive a report of suspicious activity in your neighborhood. What do you do?",
      "options": [
        {"text": "Report it immediately to local authorities.", "points": 4},
        {"text": "Wait to see if the situation escalates.", "points": 2},
        {"text": "Discuss it with others first before acting.", "points": 1},
        {"text": "Ignore the report.", "points": 0},
      ]
    },
    {
      "question":
          "While using the app, you come across sensitive information about another user’s safety incident. What do you do?",
      "options": [
        {
          "text": "Keep the information confidential and report it to the app administrators.",
          "points": 4
        },
        {"text": "Share it with friends for advice.", "points": 1},
        {"text": "Post about it on social media to raise awareness.", "points": 0},
        {"text": "Ignore it and take no action.", "points": 0},
      ]
    },
    {
      "question": "I am willing to intervene when I witness harassment or suspicious behavior.",
      "options": [
        {"text": "Strongly Agree", "points": 4},
        {"text": "Agree", "points": 3},
        {"text": "Neutral", "points": 2},
        {"text": "Disagree", "points": 1},
        {"text": "Strongly Disagree", "points": 0},
      ]
    },
    {
      "question": "I remain calm and composed in stressful situations.",
      "options": [
        {"text": "Strongly Agree", "points": 4},
        {"text": "Agree", "points": 3},
        {"text": "Neutral", "points": 2},
        {"text": "Disagree", "points": 1},
        {"text": "Strongly Disagree", "points": 0},
      ]
    },
    {
      "question":
          "I believe providing emotional support is important when helping someone in distress.",
      "options": [
        {"text": "Strongly Agree", "points": 4},
        {"text": "Agree", "points": 3},
        {"text": "Neutral", "points": 2},
        {"text": "Disagree", "points": 1},
        {"text": "Strongly Disagree", "points": 0},
      ]
    },
    {
      "question":
          "I handle sensitive information with confidentiality and care.",
      "options": [
        {"text": "Strongly Agree", "points": 4},
        {"text": "Agree", "points": 3},
        {"text": "Neutral", "points": 2},
        {"text": "Disagree", "points": 1},
        {"text": "Strongly Disagree", "points": 0},
      ]
    },
    {
      "question":
          "A friend shares that they are being harassed but are too afraid to report it. What would you do?",
      "options": [
        {"text": "Encourage and support them to report it while respecting their pace.", "points": 4},
        {"text": "Insist they report it immediately.", "points": 2},
        {"text": "Tell them they are overreacting.", "points": 0},
        {"text": "Do nothing because it's their personal matter.", "points": 0},
      ]
    },
    {
      "question":
          "You receive multiple requests for help at the same time. Which task do you prioritize first?",
      "options": [
        {"text": "A report of someone being followed late at night.", "points": 4},
        {"text": "A request for safety tips from a new user.", "points": 2},
        {"text": "A request to fix a technical issue in the app.", "points": 1},
        {"text": "Attending a scheduled team meeting.", "points": 0},
      ]
    },
  ];

  int _currentQuestionIndex = 0;
  bool _testCompleted = false;
  int _totalScore = 0;

  void _selectOption(int points) {
    setState(() {
      _responses[_currentQuestionIndex.toString()] = points;
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _submitTest();
      }
    });
  }

  void _submitTest() {
    _totalScore = _responses.values.reduce((a, b) => a + b);
    setState(() {
      _testCompleted = true;
    });
  }

  void _retakeTest() {
    setState(() {
      _responses.clear();
      _currentQuestionIndex = 0;
      _testCompleted = false;
      _totalScore = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_testCompleted) {
      return Scaffold(
        appBar: AppBar(title: const Text("Personality Test Result")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Your Score: $_totalScore",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              if (_totalScore < 28)
                Column(
                  children: [
                    const Text(
                      "You did not pass the test. Please retake the test to proceed.",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _retakeTest,
                      child: const Text("Retake Test"),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: () => widget.onTestComplete(_totalScore),
                  child: const Text("Proceed"),
                ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personality Test"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Q${_currentQuestionIndex + 1}: ${currentQuestion['question']}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...List.generate(
              (currentQuestion['options'] as List).length,
              (index) => ListTile(
                title: Text(currentQuestion['options'][index]['text']),
                leading: Radio<int>(
                  value: currentQuestion['options'][index]['points'],
                  groupValue: _responses[_currentQuestionIndex.toString()],
                  onChanged: (value) => _selectOption(value!),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}