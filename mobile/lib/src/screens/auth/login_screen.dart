import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/session_provider.dart';
import '../../routing/app_router.dart';
import '../../utils/format.dart';

/// Server URL + email/password + API key entry, mirroring the official app's
/// login form including the `/.well-known/immich` endpoint discovery.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serverController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiKeyController = TextEditingController();

  bool _useApiKey = false;
  bool _obscure = true;

  @override
  void dispose() {
    _serverController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final server = _serverController.text.trim();
    try {
      if (_useApiKey) {
        await ref.read(sessionProvider.notifier).loginWithApiKey(
              serverUrl: server,
              apiKey: _apiKeyController.text.trim(),
            );
      } else {
        await ref.read(sessionProvider.notifier).login(
              serverUrl: server,
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
      }
      if (mounted) context.go(AppRoutes.timeline);
    } catch (e) {
      if (!mounted) return;
      showMessage(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final caps = session.capabilities;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    Icon(
                      Icons.photo_library_rounded,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Immich Z',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sign in to your photo server',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _serverController,
                      decoration: const InputDecoration(
                        labelText: 'Server URL',
                        hintText: 'https://photos.example.com',
                        prefixIcon: Icon(Icons.dns_outlined),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.url,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Server URL is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          icon: Icon(Icons.person_outline),
                          label: Text('Password'),
                        ),
                        ButtonSegment(
                          value: true,
                          icon: Icon(Icons.key_outlined),
                          label: Text('API key'),
                        ),
                      ],
                      selected: {_useApiKey},
                      onSelectionChanged: (s) =>
                          setState(() => _useApiKey = s.first),
                    ),
                    const SizedBox(height: 16),
                    if (_useApiKey)
                      TextFormField(
                        controller: _apiKeyController,
                        decoration: const InputDecoration(
                          labelText: 'API key',
                          prefixIcon: Icon(Icons.vpn_key_outlined),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: _obscure,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'API key is required'
                            : null,
                      )
                    else ...[
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || !v.contains('@'))
                            ? 'Enter a valid email'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        obscureText: _obscure,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Password is required'
                            : null,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: session.isLoading ? null : _submit,
                      child: session.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Sign in'),
                    ),
                    if (caps?.oauthEnabled == true) ...[
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => showMessage(
                          context,
                          'OAuth is configured on this server; sign in with '
                              '${caps?.oauthButtonText ?? 'OAuth'} from the '
                              'web UI and paste an API key here.',
                        ),
                        icon: const Icon(Icons.login),
                        label: Text(caps?.oauthButtonText ?? 'Sign in with OAuth'),
                      ),
                    ],
                    if (caps?.loginPageMessage?.isNotEmpty == true) ...[
                      const SizedBox(height: 24),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(caps!.loginPageMessage!),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
