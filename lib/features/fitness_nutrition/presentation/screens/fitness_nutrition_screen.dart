import 'package:flutter/material.dart';
import '../../../../core/models/life_stage.dart';
import '../../domain/models/nutrition_log.dart';
import '../../domain/models/workout_exercise.dart';
import '../../domain/repositories/i_fitness_nutrition_repository.dart';

class FitnessNutritionScreen extends StatefulWidget {
  final String userId;
  final LifeStage lifeStage;
  final IFitnessNutritionRepository repository;

  const FitnessNutritionScreen({
    super.key,
    required this.userId,
    required this.lifeStage,
    required this.repository,
  });

  @override
  State<FitnessNutritionScreen> createState() => _FitnessNutritionScreenState();
}

class _FitnessNutritionScreenState extends State<FitnessNutritionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late NutritionDailyTarget _nutritionTarget;
  List<WorkoutRoutine> _routines = [];
  List<MealEntry> _meals = [];
  int _waterMl = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _nutritionTarget = NutritionDailyTarget.forLifeStage(widget.lifeStage);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final routines = await widget.repository.getWorkoutRoutinesForStage(widget.lifeStage);
    final meals = await widget.repository.getTodayMeals(widget.userId);
    final water = await widget.repository.getTodayWaterMl(widget.userId);
    setState(() {
      _routines = routines;
      _meals = meals;
      _waterMl = water;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int get _totalCaloriesLogged =>
      _meals.fold(0, (sum, meal) => sum + meal.calories);
  int get _totalProteinLogged =>
      _meals.fold(0, (sum, meal) => sum + meal.protein);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'Fitness & Nutrition Planner',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF97316),
          tabs: const [
            Tab(text: 'Workouts & Mobility'),
            Tab(text: 'Nutrition & Hydration'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF97316)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildWorkoutsTab(),
                _buildNutritionTab(),
              ],
            ),
    );
  }

  Widget _buildWorkoutsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Life-stage training focus banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.lifeStage.badgeColor.withValues(alpha: 0.25),
                const Color(0xFF1E293B),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: widget.lifeStage.badgeColor.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(widget.lifeStage.icon, color: widget.lifeStage.badgeColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.lifeStage.name} Protocol (${widget.lifeStage.ageRange})',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.lifeStage.description,
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        ..._routines.map((routine) => _buildRoutineCard(routine)),
      ],
    );
  }

  Widget _buildRoutineCard(WorkoutRoutine routine) {
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    routine.title,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${routine.durationMinutes} min • ~${routine.estimatedCalories} kcal',
                    style: const TextStyle(fontSize: 11, color: Color(0xFFF97316), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Goal: ${routine.goal}',
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
            const Divider(color: Colors.white12, height: 24),
            const Text(
              'Exercises & Modifications',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 10),
            ...routine.exercises.map((ex) => _buildExerciseItem(ex)),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseItem(WorkoutExercise ex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ex.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  ex.durationSeconds > 0
                      ? '${ex.sets} sets × ${ex.durationSeconds}s'
                      : '${ex.sets} sets × ${ex.reps} reps',
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Target: ${ex.targetMuscles} • ${ex.category}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF38BDF8)),
          ),
          const SizedBox(height: 6),
          Text(
            ex.instructions,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.accessibility_new, size: 14, color: Color(0xFF10B981)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Modification: ${ex.mobilityModification}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF10B981), fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionTab() {
    final waterGoal = _nutritionTarget.targetWaterMl;
    final waterProgress = (_waterMl / waterGoal).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Rationale card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.restaurant, color: Color(0xFFF97316), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Clinical Nutrition Focus',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _nutritionTarget.clinicalRationale,
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Targets row
        Row(
          children: [
            Expanded(
              child: _buildMacroBox(
                title: 'Calories',
                value: '$_totalCaloriesLogged / ${_nutritionTarget.targetCalories}',
                unit: 'kcal',
                color: const Color(0xFFF97316),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMacroBox(
                title: 'Protein',
                value: '$_totalProteinLogged / ${_nutritionTarget.targetProteinGrams}',
                unit: 'g',
                color: const Color(0xFF38BDF8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMacroBox(
                title: 'Calcium Target',
                value: '${_nutritionTarget.targetCalciumMg}',
                unit: 'mg / day',
                color: const Color(0xFFA855F7),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMacroBox(
                title: 'Zinc (Hormone Support)',
                value: '${_nutritionTarget.targetZincMg}',
                unit: 'mg / day',
                color: const Color(0xFF10B981),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Hydration Card
        Card(
          color: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.water_drop, color: Color(0xFF0284C7)),
                        SizedBox(width: 8),
                        Text(
                          'Daily Hydration',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                    Text(
                      '$_waterMl / $waterGoal mL',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: waterProgress,
                  backgroundColor: Colors.white10,
                  color: const Color(0xFF0284C7),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('+250 mL (Glass)'),
                        style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF38BDF8)),
                        onPressed: () async {
                          await widget.repository.addWaterMl(widget.userId, 250);
                          _loadData();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('+500 mL (Bottle)'),
                        style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF38BDF8)),
                        onPressed: () async {
                          await widget.repository.addWaterMl(widget.userId, 500);
                          _loadData();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Meals logged list
        Card(
          color: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Meals Logged Today',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Color(0xFFF97316)),
                      onPressed: _showAddMealDialog,
                    ),
                  ],
                ),
                if (_meals.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        'No meals logged today yet. Tap + to record nutrition.',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ),
                  )
                else
                  ..._meals.map((m) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: Colors.white10,
                          child: Icon(Icons.lunch_dining, color: Color(0xFFF97316), size: 18),
                        ),
                        title: Text(m.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${m.calories} kcal • ${m.protein}g Protein • ${m.carbs}g Carbs • ${m.fat}g Fat',
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMacroBox({
    required String title,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.white60)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
          ),
          Text(unit, style: const TextStyle(fontSize: 10, color: Colors.white38)),
        ],
      ),
    );
  }

  void _showAddMealDialog() {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final protCtrl = TextEditingController();
    final carbCtrl = TextEditingController();
    final fatCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Log Meal / Food Item', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Meal description (e.g. Grilled Chicken & Quinoa)',
                    labelStyle: TextStyle(color: Colors.white60),
                  ),
                ),
                TextField(
                  controller: calCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Calories (kcal)',
                    labelStyle: TextStyle(color: Colors.white60),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: protCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Protein (g)',
                          labelStyle: TextStyle(color: Colors.white60),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: carbCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Carbs (g)',
                          labelStyle: TextStyle(color: Colors.white60),
                        ),
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: fatCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Fat (g)',
                    labelStyle: TextStyle(color: Colors.white60),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF97316)),
              onPressed: () async {
                final meal = MealEntry(
                  id: 'meal_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text.trim().isEmpty ? 'Quick Snack' : nameCtrl.text.trim(),
                  calories: int.tryParse(calCtrl.text) ?? 300,
                  protein: int.tryParse(protCtrl.text) ?? 20,
                  carbs: int.tryParse(carbCtrl.text) ?? 30,
                  fat: int.tryParse(fatCtrl.text) ?? 10,
                  timestamp: DateTime.now(),
                );
                await widget.repository.logMeal(widget.userId, meal);
                if (mounted) {
                  Navigator.pop(context);
                  _loadData();
                }
              },
              child: const Text('Add Meal'),
            ),
          ],
        );
      },
    );
  }
}
