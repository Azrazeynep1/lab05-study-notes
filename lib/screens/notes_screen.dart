

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/auth_repository.dart';
import '../data/notes_repository.dart';
import '../models/note.dart';
import 'add_note_dialog.dart';

class NotesScreen extends StatelessWidget {
  final String uid;

  const NotesScreen({
    super.key,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    final notesRepository = context.read<NotesRepository>();
    final authRepository = context.read<AuthRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authRepository.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Note>>(
        stream: notesRepository.watchNotes(uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Could not load notes.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final notes = snapshot.data ?? [];

          if (notes.isEmpty) {
            return const Center(
              child: Text('No notes yet'),
            );
          }

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];

              return Dismissible(
                key: Key(note.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (_) async {
                  await notesRepository.deleteNote(uid, note.id);
                },
                child: ListTile(
                  title: Text(note.title),
                  subtitle: Text(note.body),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add note',
        onPressed: () async {
          final result = await showDialog<Map<String, String>>(
            context: context,
            builder: (context) => const AddNoteDialog(),
          );

          if (result != null && context.mounted) {
            try {
              await notesRepository.addNote(
                uid,
                result['title'] ?? '',
                result['body'] ?? '',
              );
            } catch (e) {
              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
