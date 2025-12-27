import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/features/auth/pages/register_page.dart';
import 'package:flutter_inventory_app/features/auth/providers/session_controller.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final success = await ref.read(sessionControllerProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

      if (mounted) {
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login gagal. Periksa kembali email dan password Anda.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        // Navigation is handled by AuthChecker, no need to do anything on success.
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const neubrutalismAccent = Color(0xFFE84A5F);
    const neubrutalismBorder = Colors.black;
    const neubrutalismShadowOffset = Offset(4, 4);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    'Stoklog Login',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                NeuContainer(
                  borderColor: neubrutalismBorder,
                  shadowColor: neubrutalismBorder,
                  offset: neubrutalismShadowOffset,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: InputBorder.none,
                        icon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty || !value.contains('@')) {
                          return 'Mohon masukkan email yang valid';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                NeuContainer(
                  borderColor: neubrutalismBorder,
                  shadowColor: neubrutalismBorder,
                  offset: neubrutalismShadowOffset,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: InputBorder.none,
                        icon: Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Mohon masukkan password Anda';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : NeuTextButton(
                        onPressed: _submit,
                        enableAnimation: true,
                        buttonColor: neubrutalismAccent,
                        borderColor: neubrutalismBorder,
                        shadowColor: neubrutalismBorder,
                        offset: neubrutalismShadowOffset,
                        borderRadius: BorderRadius.circular(12),
                        text: const Text(
                          'Login',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                const SizedBox(height: 20),
                NeuTextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const RegisterPage()),
                    );
                  },
                  enableAnimation: true,
                  buttonColor: Colors.white,
                  borderColor: neubrutalismBorder,
                  shadowColor: neubrutalismBorder,
                  offset: neubrutalismShadowOffset,
                  borderRadius: BorderRadius.circular(12),
                  text: const Text(
                    'Belum punya akun? Daftar sekarang',
                     textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}