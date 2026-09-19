import 'package:flutter/material.dart';
import '../../../../core/models/life_stage.dart';
import '../../../../core/theme/app_theme.dart';
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
  List<WorkoutRoutine> _activeRoutines = [];
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
    final activeRoutines = await widget.repository.getUserActiveRoutines(widget.userId);
    final customTarget = await widget.repository.getNutritionTarget(widget.userId);
    final meals = await widget.repository.getTodayMeals(widget.userId);
    final water = await widget.repository.getTodayWaterMl(widget.userId);

    if (mounted) {
      setState(() {
        _routines = routines;
        _activeRoutines = activeRoutines;
        _nutritionTarget = customTarget ?? NutritionDailyTarget.forLifeStage(widget.lifeStage);
        _meals = meals;
        _waterMl = water;
        _isLoading = false;
      });
    }
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
  int get _totalCarbsLogged =>
      _meals.fold(0, (sum, meal) => sum + meal.carbs);
  int get _totalFatLogged =>
      _meals.fold(0, (sum, meal) => sum + meal.fat);

  bool _isEnrolled(String routineId) =>
      _activeRoutines.any((r) => r.id == routineId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.obsidianBase,
      appBar: AppBar(
        backgroundColor: AppTheme.obsidianCard,
        elevation: 0,
        title: const Text(
          'Fitness & Nutrition Planner',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.neonCyan,
          indicatorWeight: 3,
          labelColor: AppTheme.neonCyan,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Workouts & Mobility'),
            Tab(text: 'Nutrition & Targets'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.neonCyan))
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
                widget.lifeStage.badgeColor.withValues(alpha: 0.22),
                AppTheme.obsidianCard,
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
        const SizedBox(height: 20),

        // ===== MY ACTIVE ROUTINES (PER USER) =====
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt, color: AppTheme.neonCyan, size: 20),
                const SizedBox(width: 8),
                Text(
                  'My Active Routines (${_activeRoutines.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                ),
              ],
            ),
            OutlinedButton.icon(
              onPressed: _showAddCustomWorkoutDialog,
              icon: const Icon(Icons.add, size: 16, color: AppTheme.neonCyan),
              label: const Text('Custom Workout', style: TextStyle(color: AppTheme.neonCyan, fontSize: 12)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.neonCyan),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (_activeRoutines.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.obsidianCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Icon(Icons.fitness_center_outlined, color: Colors.white38, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'No active routines saved. Enroll in one of the clinical protocols below or tap "Custom Workout" to tailor your regimen.',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ],
            ),
          )
        else
          ..._activeRoutines.map((routine) => _buildRoutineCard(routine, isActive: true)),

        const SizedBox(height: 24),

        // ===== RECOMMENDED PROTOCOLS =====
        const Row(
          children: [
            Icon(Icons.medical_services_outlined, color: AppTheme.neonEmerald, size: 18),
            SizedBox(width: 8),
            Text(
              'Evidence-Based Clinical Protocols',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ..._routines.map((routine) => _buildRoutineCard(routine, isActive: false)),
      ],
    );
  }

  Widget _buildRoutineCard(WorkoutRoutine routine, {required bool isActive}) {
    final isEnrolled = _isEnrolled(routine.id);

    return Card(
      color: AppTheme.obsidianCard,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isActive ? AppTheme.neonCyan.withValues(alpha: 0.5) : Colors.white12,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isActive)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.neonCyan.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ACTIVE USER ROUTINE',
                            style: TextStyle(fontSize: 10, color: AppTheme.neonCyan, fontWeight: FontWeight.bold),
                          ),
                        ),
                      Text(
                        routine.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
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
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
            ),
            const SizedBox(height: 10),
            ...routine.exercises.map((ex) => _buildExerciseItem(ex)),
            const SizedBox(height: 12),

            // Action Buttons (Add to My Routine / Remove from My Routine)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isActive) ...[
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                    label: const Text('Remove Routine', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                    onPressed: () async {
                      await widget.repository.removeActiveRoutine(widget.userId, routine.id);
                      _loadData();
                    },
                  ),
                ] else ...[
                  if (isEnrolled)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.check_circle, size: 16, color: AppTheme.neonEmerald),
                      label: const Text('Enrolled', style: TextStyle(color: AppTheme.neonEmerald, fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.neonEmerald),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: null,
                    )
                  else
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 16, color: Colors.black),
                      label: const Text('Add to My Routine', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonCyan,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        await widget.repository.addActiveRoutine(widget.userId, routine);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added "${routine.title}" to My Active Routines!'),
                              backgroundColor: AppTheme.neonCyan,
                            ),
                          );
                        }
                        _loadData();
                      },
                    ),
                ],
              ],
            ),
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
        color: AppTheme.obsidianBase,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ex.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
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
            style: const TextStyle(fontSize: 11, color: Color(0xFF38BDF8)),
          ),
          const SizedBox(height: 6),
          Text(
            ex.instructions,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          if (ex.mobilityModification.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.accessibility_new, size: 14, color: AppTheme.neonEmerald),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Modification: ${ex.mobilityModification}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.neonEmerald, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNutritionTab() {
    final waterGoal = _nutritionTarget.targetWaterMl;
    final waterProgress = (waterGoal > 0 ? _waterMl / waterGoal : 0.0).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Rationale card with Goal Customization Button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.obsidianCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.neonCyan.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.track_changes_rounded, color: AppTheme.neonCyan, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Personal Nutrition Target',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: _showEditTargetDialog,
                    icon: const Icon(Icons.tune, size: 14, color: AppTheme.neonCyan),
                    label: const Text('Set Targets', style: TextStyle(color: AppTheme.neonCyan, fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.neonCyan),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _nutritionTarget.clinicalRationale,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Targets row (Calories & Protein)
        Row(
          children: [
            Expanded(
              child: _buildMacroBox(
                title: 'Calories Logged',
                value: '$_totalCaloriesLogged / ${_nutritionTarget.targetCalories}',
                unit: 'kcal target',
                color: const Color(0xFFF97316),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMacroBox(
                title: 'Protein Target',
                value: '$_totalProteinLogged / ${_nutritionTarget.targetProteinGrams}',
                unit: 'g target',
                color: const Color(0xFF38BDF8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Targets row (Carbs & Fats)
        Row(
          children: [
            Expanded(
              child: _buildMacroBox(
                title: 'Carbs Target',
                value: '$_totalCarbsLogged / ${_nutritionTarget.targetCarbsGrams}',
                unit: 'g target',
                color: const Color(0xFFA855F7),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMacroBox(
                title: 'Fats Target',
                value: '$_totalFatLogged / ${_nutritionTarget.targetFatGrams}',
                unit: 'g target',
                color: AppTheme.neonEmerald,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Hydration Card
        Card(
          color: AppTheme.obsidianCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Colors.white12),
          ),
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
                        label: const Text('+250 mL'),
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
                        label: const Text('+500 mL'),
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
          color: AppTheme.obsidianCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Colors.white12),
          ),
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
        color: AppTheme.obsidianCard,
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
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
          ),
          Text(unit, style: const TextStyle(fontSize: 10, color: Colors.white38)),
        ],
      ),
    );
  }

  // ===== DIALOG: EDIT / SET DIET TARGETS =====
  void _showEditTargetDialog() {
    final calCtrl = TextEditingController(text: _nutritionTarget.targetCalories.toString());
    final protCtrl = TextEditingController(text: _nutritionTarget.targetProteinGrams.toString());
    final carbCtrl = TextEditingController(text: _nutritionTarget.targetCarbsGrams.toString());
    final fatCtrl = TextEditingController(text: _nutritionTarget.targetFatGrams.toString());
    final waterCtrl = TextEditingController(text: _nutritionTarget.targetWaterMl.toString());
    final rationaleCtrl = TextEditingController(text: _nutritionTarget.clinicalRationale);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.obsidianCard,
          title: const Row(
            children: [
              Icon(Icons.tune, color: AppTheme.neonCyan),
              SizedBox(width: 8),
              Text('Set Daily Diet Target', style: TextStyle(color: Colors.white, fontSize: 17)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Presets',
                  style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildPresetChip('Hypertrophy (Bulk)', 2800, 160, 300, 85, 3200, 'Hypertrophy target: high protein & caloric surplus for muscular adaptation.', calCtrl, protCtrl, carbCtrl, fatCtrl, waterCtrl, rationaleCtrl),
                    _buildPresetChip('Lean Cut / Fat Loss', 2000, 150, 160, 60, 3000, 'Fat loss target: high protein preservation in a moderate caloric deficit.', calCtrl, protCtrl, carbCtrl, fatCtrl, waterCtrl, rationaleCtrl),
                    _buildPresetChip('Endurance / Cardio', 2500, 130, 320, 70, 3500, 'Cardio target: high carbohydrate fuel for glycogen replenishment & stamina.', calCtrl, protCtrl, carbCtrl, fatCtrl, waterCtrl, rationaleCtrl),
                    _buildPresetChip('Longevity & Balance', 2200, 120, 220, 70, 2800, 'Metabolic balance target: Mediterranean-aligned macro equilibrium.', calCtrl, protCtrl, carbCtrl, fatCtrl, waterCtrl, rationaleCtrl),
                  ],
                ),
                const Divider(color: Colors.white12, height: 24),
                TextField(
                  controller: calCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Target Daily Calories (kcal)',
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
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: fatCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Fats (g)',
                          labelStyle: TextStyle(color: Colors.white60),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: waterCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Water (mL)',
                          labelStyle: TextStyle(color: Colors.white60),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: rationaleCtrl,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: const InputDecoration(
                    labelText: 'Goal Focus / Notes',
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
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonCyan),
              onPressed: () async {
                final target = NutritionDailyTarget(
                  targetCalories: int.tryParse(calCtrl.text) ?? _nutritionTarget.targetCalories,
                  targetProteinGrams: int.tryParse(protCtrl.text) ?? _nutritionTarget.targetProteinGrams,
                  targetCarbsGrams: int.tryParse(carbCtrl.text) ?? _nutritionTarget.targetCarbsGrams,
                  targetFatGrams: int.tryParse(fatCtrl.text) ?? _nutritionTarget.targetFatGrams,
                  targetWaterMl: int.tryParse(waterCtrl.text) ?? _nutritionTarget.targetWaterMl,
                  targetCalciumMg: _nutritionTarget.targetCalciumMg,
                  targetZincMg: _nutritionTarget.targetZincMg,
                  clinicalRationale: rationaleCtrl.text.trim().isNotEmpty
                      ? rationaleCtrl.text.trim()
                      : 'Personalized user fitness target.',
                );
                await widget.repository.saveNutritionTarget(widget.userId, target);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Target nutrition goals updated & synced!'),
                      backgroundColor: AppTheme.neonCyan,
                    ),
                  );
                  _loadData();
                }
              },
              child: const Text('Save Goals', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPresetChip(
    String label,
    int cal,
    int prot,
    int carbs,
    int fat,
    int water,
    String rationale,
    TextEditingController calC,
    TextEditingController protC,
    TextEditingController carbC,
    TextEditingController fatC,
    TextEditingController waterC,
    TextEditingController ratC,
  ) {
    return ActionChip(
      backgroundColor: AppTheme.obsidianBase,
      side: const BorderSide(color: Colors.white24),
      label: Text(label, style: const TextStyle(color: AppTheme.neonCyan, fontSize: 11)),
      onPressed: () {
        calC.text = cal.toString();
        protC.text = prot.toString();
        carbC.text = carbs.toString();
        fatC.text = fat.toString();
        waterC.text = water.toString();
        ratC.text = rationale;
      },
    );
  }

  // ===== DIALOG: ADD CUSTOM WORKOUT ROUTINE =====
  void _showAddCustomWorkoutDialog() {
    final titleCtrl = TextEditingController();
    final goalCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '45');
    final calCtrl = TextEditingController(text: '350');
    final exNameCtrl = TextEditingController();
    final setsCtrl = TextEditingController(text: '3');
    final repsCtrl = TextEditingController(text: '12');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.obsidianCard,
          title: const Row(
            children: [
              Icon(Icons.fitness_center, color: AppTheme.neonCyan),
              SizedBox(width: 8),
              Text('Create Custom Routine', style: TextStyle(color: Colors.white, fontSize: 17)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Routine Title (e.g. Upper Body Hypertrophy)',
                    labelStyle: TextStyle(color: Colors.white60),
                  ),
                ),
                TextField(
                  controller: goalCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Training Goal (e.g. Chest & Triceps)',
                    labelStyle: TextStyle(color: Colors.white60),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: durationCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Duration (min)',
                          labelStyle: TextStyle(color: Colors.white60),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: calCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Calories (kcal)',
                          labelStyle: TextStyle(color: Colors.white60),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white12, height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Primary Exercise',
                    style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                TextField(
                  controller: exNameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Exercise Name (e.g. Incline Dumbbell Press)',
                    labelStyle: TextStyle(color: Colors.white60),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: setsCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Sets',
                          labelStyle: TextStyle(color: Colors.white60),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: repsCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Reps',
                          labelStyle: TextStyle(color: Colors.white60),
                        ),
                      ),
                    ),
                  ],
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
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonCyan),
              onPressed: () async {
                final title = titleCtrl.text.trim().isNotEmpty
                    ? titleCtrl.text.trim()
                    : 'Personal Workout';
                final exercise = WorkoutExercise(
                  id: 'ex_${DateTime.now().millisecondsSinceEpoch}',
                  name: exNameCtrl.text.trim().isNotEmpty
                      ? exNameCtrl.text.trim()
                      : 'Compound Lift',
                  category: 'Strength',
                  targetMuscles: goalCtrl.text.trim().isNotEmpty ? goalCtrl.text.trim() : 'Full Body',
                  sets: int.tryParse(setsCtrl.text) ?? 3,
                  reps: int.tryParse(repsCtrl.text) ?? 10,
                  instructions: 'Perform with controlled eccentric cadence and full contraction.',
                  mobilityModification: 'Scale load to maintain proper lumbar alignment.',
                );

                final routine = WorkoutRoutine(
                  id: 'routine_${DateTime.now().millisecondsSinceEpoch}',
                  title: title,
                  goal: goalCtrl.text.trim().isNotEmpty ? goalCtrl.text.trim() : 'Strength & Hypertrophy',
                  targetStage: widget.lifeStage,
                  durationMinutes: int.tryParse(durationCtrl.text) ?? 45,
                  estimatedCalories: int.tryParse(calCtrl.text) ?? 300,
                  exercises: [exercise],
                );

                await widget.repository.addActiveRoutine(widget.userId, routine);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Created & added "$title" to My Routines!'),
                      backgroundColor: AppTheme.neonCyan,
                    ),
                  );
                  _loadData();
                }
              },
              child: const Text('Save Routine', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
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
          backgroundColor: AppTheme.obsidianCard,
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
