/*import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionsScreen extends StatefulWidget {
  final String examId;
  final String examName;

  QuestionsScreen({required this.examId, required this.examName});

  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<DocumentSnapshot> _questions = [];
  int _currentIndex = 0;
  int _remainingTime = 0;
  Timer? _timer;

  int? _selectedChoiceIndex;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() async {
    final snapshot = await _db
        .collection('exams')
        .doc(widget.examId)
        .collection('questions')
        .get();

    setState(() {
      _questions = snapshot.docs;
      if (_questions.isNotEmpty) {
        _startQuestion();
      }
    });
  }

  void _startQuestion() {
    final data = _questions[_currentIndex].data() as Map<String, dynamic>;
    _remainingTime = data['duration'] ?? 15;
    _selectedChoiceIndex = null;
    _answered = false;

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer?.cancel();
        _goToNextQuestion();
      }
    });
  }

  void _goToNextQuestion() {
    setState(() {
      _answered = true;
    });

    Future.delayed(Duration(milliseconds: 500), () {
      if (_currentIndex + 1 < _questions.length) {
        setState(() {
          _currentIndex++;
        });
        _startQuestion();
      } else {
        _showQuizFinishedDialog();
      }
    });
  }

  void _showQuizFinishedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Quiz Tamamlandı'),
        content: Text('Tebrikler! Tüm soruları tamamladınız.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _onChoiceSelected(int index) {
    if (_answered) return;

    setState(() {
      _selectedChoiceIndex = index;
      _answered = true;
    });

    _timer?.cancel();

    Future.delayed(Duration(seconds: 1), () {
      _goToNextQuestion();
    });
  }

  void _onNextPressed() {
    if (_answered) return;

    _timer?.cancel();
    _goToNextQuestion();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.examName} Soruları'),
          backgroundColor: Color(0xFF7DA3F5), // Pastel mavi koyu
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = _questions[_currentIndex];
    final data = currentQuestion.data() as Map<String, dynamic>;
    final choices = List<String>.from(data['choices'] ?? []);
    final totalDuration = data['duration'] ?? 15;
    final correctIndex = data['correctIndex'];

    double progress = _remainingTime / totalDuration;

    return Scaffold(
      appBar: AppBar(
        title:
        Text('${widget.examName} - Soru ${_currentIndex + 1}/${_questions.length}'),
        backgroundColor: Color(0xFF7DA3F5), // Pastel mavi koyu
      ),
      backgroundColor: Color(0xFFEAF2FF), // Çok açık pastel mavi
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 22,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Color(0xFFBDD7FF), // Açık mavi
                        ),
                      ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width:
                        MediaQuery.of(context).size.width * 0.8 * progress,
                        height: 22,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Color(0xFF7DA3F5), // Koyu pastel mavi
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Kalan Süre: $_remainingTime saniye',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5477C4), // Daha koyu mavi
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFDFF3FF), // Çok açık mavi
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF7DA3F5).withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                data['question'] ?? 'Soru yok',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B5998), // Orta koyulukta mavi
                ),
              ),
            ),

            SizedBox(height: 30),

            Expanded(
              child: ListView.builder(
                itemCount: choices.length,
                itemBuilder: (context, index) {
                  bool isSelected = _selectedChoiceIndex == index;
                  bool isCorrect = correctIndex == index;

                  Color bgColor = Colors.white;
                  Color borderColor = Color(0xFF7DA3F5);
                  Color textColor = Colors.black87;

                  if (_answered) {
                    if (isSelected && isCorrect) {
                      bgColor = Color(0xFFFFC28B); // Pastel turuncu (doğru seçim)
                      borderColor = Color(0xFFFFA726);
                      textColor = Colors.white;
                    } else if (isSelected && !isCorrect) {
                      bgColor = Colors.red.shade400;
                      borderColor = Colors.red.shade700;
                      textColor = Colors.white;
                    } else if (isCorrect) {
                      bgColor = Color(0xFFFFF3E0); // Çok açık turuncu (doğru cevap)
                    }
                  } else if (isSelected) {
                    bgColor = Color(0xFFCEE5FF); // Açık pastel mavi seçili
                    borderColor = Color(0xFF7DA3F5);
                  }

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          offset: Offset(0, 4),
                          blurRadius: 7,
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () => _onChoiceSelected(index),
                      borderRadius: BorderRadius.circular(14),
                      child: Text(
                        choices[index],
                        style: TextStyle(
                          fontSize: 18,
                          color: textColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _answered ? null : _onNextPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFA726), // Pastel turuncu buton
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
                child: Text(
                  'Sonraki Soru',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuestionsScreen extends StatefulWidget {
  final String examId;
  final String examName;

  QuestionsScreen({required this.examId, required this.examName});

  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<DocumentSnapshot> _questions = [];
  int _currentIndex = 0;
  int _remainingTime = 0;
  Timer? _timer;

  int? _selectedChoiceIndex;
  bool _answered = false;

  int _correctCount = 0;
  int _wrongCount = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() async {
    final snapshot = await _db
        .collection('exams')
        .doc(widget.examId)
        .collection('questions')
        .get();

    setState(() {
      _questions = snapshot.docs;
      if (_questions.isNotEmpty) {
        _startQuestion();
      }
    });
  }

  void _startQuestion() {
    final data = _questions[_currentIndex].data() as Map<String, dynamic>;
    _remainingTime = data['duration'] ?? 15;
    _selectedChoiceIndex = null;
    _answered = false;

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer?.cancel();
        _goToNextQuestion();
      }
    });
  }

  void _goToNextQuestion() {
    setState(() {
      _answered = true;
    });

    Future.delayed(Duration(milliseconds: 500), () {
      if (_currentIndex + 1 < _questions.length) {
        setState(() {
          _currentIndex++;
        });
        _startQuestion();
      } else {
        _showQuizFinishedDialog();
      }
    });
  }

  void _showQuizFinishedDialog() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await _db.collection('examResults').add({
        'userId': user.uid,
        'userName': user.displayName ??
            user.email?.split('@')[0] ??
            'Quiz Kahramanı',
        'examId': widget.examId,
        'correct': _correctCount,
        'wrong': _wrongCount,
        'date': Timestamp.now(),
      });
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Quiz Tamamlandı'),
        content: Text('Doğru: $_correctCount\nYanlış: $_wrongCount\nTebrikler!'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dialogu kapat
              Navigator.of(context).pop(); // Sınav ekranından çık
              Navigator.pushNamed(context, '/leaderboard',
                  arguments: widget.examId); // Leaderboard sayfasına git
            },
            child: Text('Sonuçları Gör'),
          ),
        ],
      ),
    );
  }

  void _onChoiceSelected(int index) {
    if (_answered) return;

    setState(() {
      _selectedChoiceIndex = index;
      _answered = true;
    });

    _timer?.cancel();

    final data = _questions[_currentIndex].data() as Map<String, dynamic>;
    final correctIndex = data['correctIndex'];

    if (index == correctIndex) {
      _correctCount++;
    } else {
      _wrongCount++;
    }

    Future.delayed(Duration(seconds: 1), () {
      _goToNextQuestion();
    });
  }

  void _onNextPressed() {
    if (_answered) return;

    _timer?.cancel();
    _goToNextQuestion();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.examName} Soruları'),
          backgroundColor: Color(0xFF7DA3F5),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = _questions[_currentIndex];
    final data = currentQuestion.data() as Map<String, dynamic>;
    final choices = List<String>.from(data['choices'] ?? []);
    final totalDuration = data['duration'] ?? 15;
    final correctIndex = data['correctIndex'];

    double progress = _remainingTime / totalDuration;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${widget.examName} - Soru ${_currentIndex + 1}/${_questions.length}'),
        backgroundColor: Color(0xFF7DA3F5),
      ),
      backgroundColor: Color(0xFFEAF2FF),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 22,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Color(0xFFBDD7FF),
                        ),
                      ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width:
                        MediaQuery.of(context).size.width * 0.8 * progress,
                        height: 22,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Color(0xFF7DA3F5),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Kalan Süre: $_remainingTime saniye',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5477C4),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFDFF3FF),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF7DA3F5).withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                data['question'] ?? 'Soru yok',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B5998),
                ),
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: choices.length,
                itemBuilder: (context, index) {
                  bool isSelected = _selectedChoiceIndex == index;
                  bool isCorrect = correctIndex == index;

                  Color bgColor = Colors.white;
                  Color borderColor = Color(0xFF7DA3F5);
                  Color textColor = Colors.black87;

                  if (_answered) {
                    if (isSelected && isCorrect) {
                      bgColor = Color(0xFFFFC28B);
                      borderColor = Color(0xFFFFA726);
                      textColor = Colors.white;
                    } else if (isSelected && !isCorrect) {
                      bgColor = Colors.red.shade400;
                      borderColor = Colors.red.shade700;
                      textColor = Colors.white;
                    } else if (isCorrect) {
                      bgColor = Color(0xFFFFF3E0);
                    }
                  } else if (isSelected) {
                    bgColor = Color(0xFFCEE5FF);
                    borderColor = Color(0xFF7DA3F5);
                  }

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          offset: Offset(0, 4),
                          blurRadius: 7,
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () => _onChoiceSelected(index),
                      borderRadius: BorderRadius.circular(14),
                      child: Text(
                        choices[index],
                        style: TextStyle(
                          fontSize: 18,
                          color: textColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _answered ? null : _onNextPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFA726),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
                child: Text(
                  'Sonraki Soru',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

