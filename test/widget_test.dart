// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:life_stage_health_app/main.dart';
// import 'package:life_stage_health_app/core/services/auth_service.dart';
// import 'package:life_stage_health_app/core/services/firestore_service.dart';
// import 'package:life_stage_health_app/core/services/health_sync_service.dart';
// import 'package:life_stage_health_app/core/bloc/auth/auth_bloc.dart';
// import 'package:life_stage_health_app/core/bloc/auth/auth_event.dart';
// import 'package:life_stage_health_app/core/bloc/onboarding/onboarding_bloc.dart';
// import 'package:life_stage_health_app/core/bloc/onboarding/onboarding_event.dart';
// import 'package:life_stage_health_app/core/bloc/health_sync/health_sync_bloc.dart';

// void main() {
//   testWidgets('App renders clean initial state test', (WidgetTester tester) async {
//     final firestoreService = FirestoreService(firestore: firebaseFirestore.instance);
//     final authService = AuthService();
//     final healthSyncService = HealthSyncService(firestoreService);

//     await tester.pumpWidget(
//       MultiRepositoryProvider(
//         providers: [
//           RepositoryProvider.value(value: authService),
//           RepositoryProvider.value(value: firestoreService),
//           RepositoryProvider.value(value: healthSyncService),
//         ],
//         child: MultiBlocProvider(
//           providers: [
//             BlocProvider(create: (_) => AuthBloc(authService)..add(AuthCheckRequested())),
//             BlocProvider(create: (_) => OnboardingBloc(firestoreService)..add(OnboardingStarted())),
//             BlocProvider(create: (_) => HealthSyncBloc(healthSyncService)),
//           ],
//           child: LifeStageHealthApp(),
//         ),
//       ),
//     );

//     expect(find.byType(LifeStageHealthApp), findsOneWidget);
//   });
// }

class LifeStageHealthApp {
}
