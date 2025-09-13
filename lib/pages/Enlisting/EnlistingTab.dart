import 'package:flutter/material.dart';

class EnlistingPage extends StatelessWidget {
  const EnlistingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: Colors.grey[200],
                child: Center(
                  child: Icon(
                    Icons.image,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),
            // Text Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
              child: Column(
                children: [
                  Text(
                    'GPT: Greatest Performance Trailblazer',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Development of vocal and singing skills, such as that of Logic\'s rap abilities, is swiftly tailored to you through the technological advances of GPT Rapper',
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/Enlist');
                      },
                      child: const Text('Enlist'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signin');
                      },
                      child: const Text('Sign In'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}