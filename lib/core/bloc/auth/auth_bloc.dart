
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  
  //Track if we're in the process of signing out
  bool _isSigningOut = false;

  AuthBloc(this._authService) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    
    // Listen to auth state changes from the service
    _authService.addListener(_onAuthServiceChanged);
  }

  void _onAuthServiceChanged() {
    // Don't process auth changes during sign out
    if (_isSigningOut) {
      debugPrint('⏭Skipping auth change during sign out');
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
    // Don't emit auth changes during sign out
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

  Future<void> _onAuthSignUpRequested(AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authService.signUpWithEmail(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthSignInRequested(AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authService.signInWithEmail(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
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
    //  Set signing out flag
    _isSigningOut = true;
    
    // Emit loading state first
    emit(AuthLoading());
    
    try {
      debugPrint(' Signing out...');
      await _authService.signOut();
      
      //  Ensure we emit Unauthenticated after sign out
      emit(Unauthenticated());
      
      //  Reset the flag after a delay to prevent flickering
      // Firebase might emit auth state changes after sign out
      Future.delayed(const Duration(milliseconds: 500), () {
        _isSigningOut = false;
        debugPrint('✅ Sign out complete, flag reset');
        
        //  Force check auth state one more time
        add(AuthCheckRequested());
      });
    } catch (e) {
      debugPrint(' Sign out error: $e');
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