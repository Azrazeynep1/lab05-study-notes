import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:lab05_study_notes/data/notes_repository.dart';
import 'package:lab05_study_notes/models/note.dart';

void main() {
  setUpAll(() {
    FakeFirebaseFirestore();
  });

  group('Own NotesRepository & Model Tests', () {
    test('addNote throws ArgumentError when title is empty', () async {
      final firestore = FakeFirebaseFirestore();
      final repository = NotesRepository(firestore);

      expect(
        () => repository.addNote('user123', '   ', 'Valid body'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Note.fromFirestore parses valid data correctly', () {
      final data = {
        'title': 'Test Title',
        'body': 'Test Body',
        'createdAt': null,
      };

      final note = Note.fromFirestore('note_1', data);

      expect(note.id, 'note_1');
      expect(note.title, 'Test Title');
      expect(note.body, 'Test Body');
    });
  });
}