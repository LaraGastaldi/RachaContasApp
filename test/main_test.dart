import 'package:flutter_test/flutter_test.dart';
import 'package:rachacontas/providers.dart';
import 'package:rachacontas/screens/login_screen.dart';
import 'package:rachacontas/screens/register_screen.dart';

void main() {
  test('LoginScreen should have a LoginController', () {
    final loginScreen = LoginScreen();
    expect(loginScreen.loginController, isNotNull);
  });

  test('LoginController should have a loginFormKey', () {
    final loginScreen = LoginScreen();
    expect(loginScreen.loginController.loginFormKey, isNotNull);
  });

  test('LoginController should have a emailController', () {
    final loginScreen = LoginScreen();
    expect(loginScreen.loginController.emailController, isNotNull);
  });

  test('LoginController should have a passwordController', () {
    final loginScreen = LoginScreen();
    expect(loginScreen.loginController.passwordController, isNotNull);
  });

  test('LoginController should have a validator method', () {
    final loginScreen = LoginScreen();
    expect(loginScreen.loginController.validator(''), isNotNull);
  });

  test('RegisterScreen should have a RegisterController', () {
    final registerScreen = RegisterScreen();
    expect(registerScreen.registerController, isNotNull);
  });

  test('RegisterController should have a registerFormKey', () {
    final registerScreen = RegisterScreen();
    expect(registerScreen.registerController.registerFormKey, isNotNull);
  });

  test('RegisterController should have a nameController', () {
    final registerScreen = RegisterScreen();
    expect(registerScreen.registerController.nameController, isNotNull);
  });

  test('RegisterController should have a emailController', () {
    final registerScreen = RegisterScreen();
    expect(registerScreen.registerController.emailController, isNotNull);
  });

  test('RegisterController should have a passwordController', () {
    final registerScreen = RegisterScreen();
    expect(registerScreen.registerController.passwordController, isNotNull);
  });

  test('RegisterController should have a confirmPasswordController', () {
    final registerScreen = RegisterScreen();
    expect(registerScreen.registerController.confirmPasswordController, isNotNull);
  });

  test('RegisterController should have a validator method', () {
    final registerScreen = RegisterScreen();
    expect(registerScreen.registerController.validator(''), isNotNull);
  });
}