part of 'notes_bloc.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotesEvent extends NotesEvent {
  const LoadNotesEvent();
}

class CreateNoteEvent extends NotesEvent {
  final String title;
  final String content;

  const CreateNoteEvent({required this.title, required this.content});

  @override
  List<Object?> get props => [title, content];
}

class UpdateNoteEvent extends NotesEvent {
  final String id;
  final String title;
  final String content;

  const UpdateNoteEvent({
    required this.id,
    required this.title,
    required this.content,
  });

  @override
  List<Object?> get props => [id, title, content];
}

class DeleteNoteEvent extends NotesEvent {
  final String id;

  const DeleteNoteEvent({required this.id});

  @override
  List<Object?> get props => [id];
}
