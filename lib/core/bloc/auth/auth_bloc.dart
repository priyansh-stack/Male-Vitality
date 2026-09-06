import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  bool _isSigningOut = false;

  AuthBloc(this._authService) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    
    // Listen to auth state changes from the service
    _authService.addListener(_onAuthServiceChanged);
  }

  void _onAuthServiceChanged() {
    if (_isSigningOut) {
      debugPrint('⚡ [AuthBloc] Skipping auth change during sign out');
      return;
    }
    
    final user = _authService.currentUser;
    if (user != null) {
      add(AuthCheckRequested());
    } else {
      add(AuthSignOutRequested());
    }
  }

  void _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) {
    if (_isSigningOut) {
      emit(Unauthenticated());
      return;
    }
    
    final user = _authService.currentUser;
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onAuthGoogleSignInRequested(AuthGoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authService.signInWithGoogle();
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthSignOutRequested(AuthSignOutRequested event, Emitter<AuthState> emit) async {
    _isSigningOut = true;
    emit(AuthLoading());
    
    try {
      debugPrint('⚡ [AuthBloc] Signing out...');
      await _authService.signOut();
      emit(Unauthenticated());
      
      Future.delayed(const Duration(milliseconds: 500), () {
        _isSigningOut = false;
        add(AuthCheckRequested());
      });
    } catch (e) {
      debugPrint('⚡ [AuthBloc] Sign out error: $e');
      _isSigningOut = false;
      emit(AuthFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authService.removeListener(_onAuthServiceChanged);
    return super.close();
  }
}