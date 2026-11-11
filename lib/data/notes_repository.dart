
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';

class NotesRepository {
  final FirebaseFirestore _firestore;

  NotesRepository([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userNotesCollection(
      String uid) {
    return _firestore.collection('users').doc(uid).collection('notes');
  }

  Stream<List<Note>> watchNotes(String uid) {
    return _userNotesCollection(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Note.fromFirestore(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> addNote(String uid, String title, String body) async {
    final trimmedTitle = title.trim();

    if (trimmedTitle.isEmpty || trimmedTitle.length > 100) {
      throw ArgumentError('Title must be between 1 and 100 characters.');
    }

    final note = Note(
      id: '',
      title: trimmedTitle,
      body: body.trim(),
    );

    await _userNotesCollection(uid).add(note.toFirestore());
  }

  Future<void> deleteNote(String uid, String noteId) async {
    await _userNotesCollection(uid).doc(noteId).delete();
  }
}
