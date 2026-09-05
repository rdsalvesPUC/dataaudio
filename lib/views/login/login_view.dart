import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/error/app_exceptions.dart';
import '../../core/navigation/app_routes.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_indicator.dart';

/// Tela de login (RF07). Guarda o acesso ao catalogo (RN01): so apos autenticar
/// o app avanca para a HomeShell, via `pushReplacement` (ADR-0007). Recupera a
/// sessao persistida na abertura — login sobrevive ao fechamento do app.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restore());
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _restore() async {
    final auth = context.read<AuthProvider>();
    await auth.restoreSession();
    if (auth.isAuthenticated && mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  Future<void> _submit({required bool register}) async {
    final l10n = AppLocalizations.of(context)!;
    final username = _userController.text.trim();
    final password = _passController.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = l10n.loginErrorEmpty);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final auth = context.read<AuthProvider>();
    try {
      if (register) {
        await auth.register(username, password);
      } else {
        await auth.login(username, password);
      }
      if (mounted) Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } on AuthException {
      if (mounted) {
        setState(() => _error =
            register ? l10n.loginErrorExists : l10n.loginErrorInvalid);
      }
    } catch (_) {
      if (mounted) setState(() => _error = l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();

    if (auth.isRestoring) {
      return const Scaffold(body: LoadingIndicator());
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.library_music,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 8),
                  Text(
                    l10n.appTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _userController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.loginUsername,
                      prefixIcon: const Icon(Icons.person_outline),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passController,
                    obscureText: true,
                    onSubmitted: (_) => _busy ? null : _submit(register: false),
                    decoration: InputDecoration(
                      labelText: l10n.loginPassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _busy ? null : () => _submit(register: false),
                    child: _busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator.adaptive(
                                strokeWidth: 2),
                          )
                        : Text(l10n.loginSignIn),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _busy ? null : () => _submit(register: true),
                    child: Text(l10n.loginRegister),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
