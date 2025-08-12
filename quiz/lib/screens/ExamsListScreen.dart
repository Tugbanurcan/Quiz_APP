import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz/screens/QuestionsScreen.dart';

class ExamsListScreen extends StatelessWidget {
  final String category;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  ExamsListScreen({required this.category});

  PreferredSizeWidget buildCustomAppBar(String title) {
    return PreferredSize(
      preferredSize: Size.fromHeight(80),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF7DA3F5), // Açık pastel mavi
              Color(0xFF5477C4), // Koyu pastel mavi
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 8,
            ),
          ],
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black38,
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar('$category '),
      backgroundColor: Colors.blue.shade50, // Hafif pastel mavi arka plan
      body: StreamBuilder<QuerySnapshot>(
        stream: _db
            .collection('exams')
            .where('category', isEqualTo: category)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text('Hata: ${snapshot.error}'));
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final exams = snapshot.data!.docs;
          if (exams.isEmpty)
            return Center(
              child: Text(
                'Sınav bulunamadı',
                style: TextStyle(color: Colors.blue.shade700, fontSize: 18),
              ),
            );

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: exams.length,
            itemBuilder: (context, index) {
              final exam = exams[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                shadowColor: Colors.blue.shade100,
                child: ListTile(
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  title: Text(
                    exam['name'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  subtitle: Text(
                    'Süre: ${exam['duration']} dakika',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuestionsScreen(
                          examId: exam.id,
                          examName: exam['name'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
