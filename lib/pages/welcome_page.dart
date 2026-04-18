import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'login_page.dart';

class WelcomePage extends StatelessWidget {
  final UserModel user;

  const WelcomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 48,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Hello, ${user.name}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('You are registered as a blood donor.'),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _profileRow('Email', user.email),
                    _profileRow('Phone', user.phone),
                    _profileRow('Blood Group', user.bloodGroup),
                    _profileRow('Age', user.age.toString()),
                    _profileRow('Gender', user.gender),
                    _profileRow('City', user.city),
                    _profileRow('Division', user.division),
                    _profileRow('District', user.district),
                    _profileRow('Upazila', user.upazila),
                    _profileRow('Registered', user.createdAt.split('T').first),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
