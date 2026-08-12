import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/bloc/mental_wellness/guided_exercise_bloc/guided_exercise_bloc.dart';
import '../../../core/models/mental_wellness/guided_exercise.dart';
import '../../../core/models/life_stage.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/exercise_card.dart';
import '../widgets/exercise_filter_bar.dart';

class GuidedExerciseLibraryScreen extends StatefulWidget {
  final LifeStage? userLifeStage;

  const GuidedExerciseLibraryScreen({super.key, this.userLifeStage});

  @override
  State<GuidedExerciseLibraryScreen> createState() => _GuidedExerciseLibraryScreenState();
}

class _GuidedExerciseLibraryScreenState extends State<GuidedExerciseLibraryScreen> {
  ExerciseType? _selectedType;
  LifeStage? _selectedAgeGroup;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  void _loadExercises() {
    context.read<GuidedExerciseBloc>().add(
      LoadGuidedExercisesEvent(
        type: _selectedType,
        ageGroup: _selectedAgeGroup ?? widget.userLifeStage,
      ),
    );
  }

  void _goBack() {
    context.go('/wellness');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Guided Exercises'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ExerciseSearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ExerciseFilterBar(
            selectedType: _selectedType,
            selectedAgeGroup: _selectedAgeGroup,
            onTypeChanged: (type) {
              setState(() {
                _selectedType = type;
                _loadExercises();
              });
            },
            onAgeGroupChanged: (ageGroup) {
              setState(() {
                _selectedAgeGroup = ageGroup;
                _loadExercises();
              });
            },
            onClearFilters: () {
              setState(() {
                _selectedType = null;
                _selectedAgeGroup = null;
                _loadExercises();
              });
            },
          ),
          Expanded(
            child: BlocBuilder<GuidedExerciseBloc, GuidedExerciseState>(
              builder: (context, state) {
                if (state is ExerciseLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ExerciseErrorState) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadExercises,
                          child: const Text('Retry'),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: _goBack,
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is ExerciseLibraryLoadedState) {
                  if (state.exercises.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.self_improvement, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No exercises found'),
                          Text(
                            'Try adjusting your filters',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = state.exercises[index];
                      final progress = state.progress[exercise.id] ?? 0;

                      return ExerciseCard(
                        exercise: exercise,
                        progress: progress,
                        onTap: () {
                          context.push(
                            '/exercise-player/${exercise.id}',
                            extra: exercise,
                          );
                        },
                      );
                    },
                  );
                }

                return const Center(child: Text('No exercises available'));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final state = context.read<GuidedExerciseBloc>().state;
    if (state is ExerciseLibraryLoadedState) {
      final results = state.exercises
          .where((e) => e.title.toLowerCase().contains(query.toLowerCase()) ||
              e.description.toLowerCase().contains(query.toLowerCase()))
          .toList();

      if (results.isEmpty) {
        return const Center(child: Text('No results found'));
      }

      return ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final exercise = results[index];
          return ExerciseCard(
            exercise: exercise,
            progress: 0,
            onTap: () {
              close(context, null);
              context.push(
                '/exercise-player/${exercise.id}',
                extra: exercise,
              );
            },
          );
        },
      );
    }
    return const Center(child: Text('Loading...'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final state = context.read<GuidedExerciseBloc>().state;
    if (state is ExerciseLibraryLoadedState) {
      final suggestions = state.exercises
          .where((e) => e.title.toLowerCase().contains(query.toLowerCase()))
          .take(5)
          .toList();

      return ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final exercise = suggestions[index];
          return ListTile(
            title: Text(exercise.title),
            subtitle: Text(exercise.type.displayName),
            onTap: () {
              query = exercise.title;
              showResults(context);
            },
          );
        },
      );
    }
    return const SizedBox.shrink();
  }
}