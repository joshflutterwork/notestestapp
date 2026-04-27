import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/widgets/app_gradient_background.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:frontend/features/notes/presentation/widgets/note_card.dart';
import 'package:frontend/features/notes/presentation/widgets/note_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<NotesBloc>().add(const LoadNotesEvent());
  }

  void _handleLogout() {
    context.read<AuthBloc>().add(const LogoutEvent());
  }

  void _showCreateNoteDialog() {
    showDialog(
      context: context,
      builder:
          (context) => NoteDialog(
            onSave: (title, content) {
              context.read<NotesBloc>().add(
                CreateNoteEvent(title: title, content: content),
              );
              Navigator.of(context).pop();
            },
          ),
    );
  }

  void _showEditNoteDialog(String id, String title, String content) {
    showDialog(
      context: context,
      builder:
          (context) => NoteDialog(
            initialTitle: title,
            initialContent: content,
            onSave: (newTitle, newContent) {
              context.read<NotesBloc>().add(
                UpdateNoteEvent(id: id, title: newTitle, content: newContent),
              );
              Navigator.of(context).pop();
            },
          ),
    );
  }

  void _handleDeleteNote(String id) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.glassWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: const BorderSide(color: AppColors.glassBorder),
            ),
            title: const Text(
              'Delete Note',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: const Text(
              'Are you sure you want to delete this note?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<NotesBloc>().add(DeleteNoteEvent(id: id));
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushReplacementNamed('/');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        body: AppGradientBackground(
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.glassWhite,
                    border: Border(
                      bottom: BorderSide(color: AppColors.glassBorder),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Notes',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.logout,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: _handleLogout,
                        tooltip: 'Logout',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: BlocConsumer<NotesBloc, NotesState>(
                    listener: (context, state) {
                      if (state is NotesError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Oops, something went wrong. Please try again.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is NotesLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.accentOrange,
                            ),
                          ),
                        );
                      }

                      if (state is NotesLoaded) {
                        if (state.notes.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.note_alt_outlined,
                                  size: 64,
                                  color: AppColors.textSecondary.withOpacity(
                                    0.5,
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                const Text(
                                  'Its quiet here.\nTap the plus button to write your first note.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: state.notes.length,
                          itemBuilder: (context, index) {
                            final note = state.notes[index];
                            return NoteCard(
                              note: note,
                              onEdit:
                                  () => _showEditNoteDialog(
                                    note.id,
                                    note.title,
                                    note.content,
                                  ),
                              onDelete: () => _handleDeleteNote(note.id),
                            );
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showCreateNoteDialog,
          backgroundColor: AppColors.accentOrange,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
