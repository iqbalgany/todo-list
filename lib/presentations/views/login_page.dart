import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/core/themes/colors.dart';
import 'package:todo_list/presentations/cubits/auth/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _confirmationPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, authState) {
              if (authState.status == AuthStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.error,
                    content: Text(authState.errorMessage),
                  ),
                );
              }
              if (authState.status == AuthStatus.authenticated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.success,
                    content: Text('Login Success!'),
                  ),
                );
              }
            },
            builder: (context, authState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 32),
                  Text(
                    _isLogin ? 'Welcome Back!' : 'Create Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _isLogin
                        ? 'Sign in to continue managing your tasks'
                        : 'Join us and start orginizing life',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 48),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || !value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        if (!_isLogin) ...{
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmationPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Confirmation Password',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Confirmation is required';
                              }
                              if (value.trim() !=
                                  _passwordController.text.trim()) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        },
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  if (authState.status == AuthStatus.loading)
                    Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (_isLogin) {
                            context.read<AuthCubit>().signIn(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            );
                          } else {
                            context.read<AuthCubit>().signUp(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                              _confirmationPasswordController.text.trim(),
                            );
                          }
                        }
                      },
                      child: Text(
                        _isLogin ? 'Login' : 'Signup',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin
                            ? 'Don\'t have an account? '
                            : 'Already have an account ',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          _isLogin ? 'Signup' : 'Login',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
