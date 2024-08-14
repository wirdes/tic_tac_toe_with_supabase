import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tic_tac_toe_with_supabase/core/enum/enum.dart';
import 'package:tic_tac_toe_with_supabase/core/extensions/extensions.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isLoading,
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Welcome to Tic Tac Toe',
                  style: context.textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'Please enter your name to continue',
                  style: context.textTheme.labelMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final text = emailController.text;

                    if (text.isEmpty) {
                      context.showErrorSnackBar('Please enter your name');
                      return;
                    }
                    setState(() => isLoading = true);
                    final timer = Timer(const Duration(seconds: 15), () {
                      if (mounted) {
                        setState(() => isLoading = false);
                        context.showErrorSnackBar('Failed to login: Timeout');
                      }
                      return;
                    });
                    try {
                      await context.auth.signInAnonymously(
                        data: {'username': text},
                      );
                      if (context.mounted) {
                        setState(() => isLoading = false);
                        context.go(Paths.gameList);
                        timer.cancel();
                      }
                    } on AuthRetryableFetchException catch (e) {
                      timer.cancel();
                      setState(() {
                        isLoading = false;
                        context.showErrorSnackBar(e.message);
                      });
                    } on AuthApiException catch (e) {
                      timer.cancel();
                      setState(() {
                        isLoading = false;
                        context.showErrorSnackBar(e.message);
                      });
                    } catch (e) {
                      timer.cancel();
                      setState(() {
                        isLoading = false;
                        context.showErrorSnackBar(e.toString());
                      });
                    }
                  },
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
