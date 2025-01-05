import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var isLogin = true;
  final _formKey = GlobalKey<FormState>();
  String _enterEmail = '';
  String _enterpassword = '';

  void _onSubmit() {
    final bool isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
      print('enterEmail $_enterEmail');
      print(_enterpassword);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Form(
          key: _formKey,
          child: Card(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(9),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Welcome back',
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Email address'),
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      // controller: emailController,
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty ||
                            !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _enterEmail = newValue!;
                      },
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.trim().length < 6) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _enterpassword = newValue!;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Password',
                      ),
                      // controller: passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer),
                        onPressed: _onSubmit,
                        child: Text(isLogin ? 'Login' : 'Sign Up')),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isLogin = !isLogin;
                        });
                      },
                      child: Text(
                        isLogin ? 'New User? Sign up' : 'Already have account',
                      ),
                    ),
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
