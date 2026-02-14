import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:flutter/material.dart';

import 'package:amplitude_experiment/experiment.dart';
import 'package:amplitude_experiment/src/experiment_config.dart';
import 'package:amplitude_experiment/src/experiment_client.dart';
import 'package:amplitude_experiment/src/providers.dart';
import 'package:amplitude_experiment/src/generated/amplitude_experiment_api.g.dart';

void main() {
  runApp(const MyApp());
}

// class CustomUserProvider implements UserProvider {
//   int _currentid = 1;

//   @override
//   ExperimentUser getUser() {
//     String userid = 'fluttertester$_currentid';
//     print(userid);
//     _currentid = _currentid + 1;
//     return ExperimentUser(userId: userid);
//   }
// }

// class CustomTrackingProvider implements ExposureTrackingProvider {
//   @override
//   void track(Exposure exposure) {
//     String output =
//         'tracking exposure: ${exposure.flagKey} ${exposure.variant} ${exposure.experimentKey} ${exposure.metadata?.toString()} ${exposure.time}';
//     print(output);
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Experiment Flutter Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginExamplePage(),
    );
  }
}

class LoginExamplePage extends StatefulWidget {
  const LoginExamplePage({super.key});

  @override
  State<LoginExamplePage> createState() => _LoginExamplePageState();
}

class _LoginExamplePageState extends State<LoginExamplePage> {
  // State variables
  bool _isInitializing = true;
  bool _isLoggedIn = false;
  String? _username;
  String _welcomeMessage = 'Welcome!';
  Amplitude? _amplitude;
  ExperimentClient? _experiment;
  final TextEditingController _usernameController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  /// Initialize Amplitude and Experiment instances
  Future<void> _initializeApp() async {
    try {
      // Initialize Amplitude
      _amplitude = Amplitude(
        Configuration(apiKey: 'API_KEY'),
      );
      await _amplitude!.isBuilt;

      // Initialize Experiment with Amplitude integration
      _experiment = Experiment.initializeWithAmplitude(
        DEPLOY_KEY,
        ExperimentConfig(
          // trackingProvider: CustomTrackingProvider(),
          // userProvider: CustomUserProvider(),
        ),
      );
      await _experiment!.isBuilt;

      if (!mounted) return;

      setState(() {
        _isInitializing = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isInitializing = false;
        _errorMessage = 'Failed to initialize: ${e.toString()}';
      });
    }
  }

  /// Handle login flow
  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();

    // Validate username length
    if (username.length < 8) {
      setState(() {
        _errorMessage = 'Username must be at least 8 characters long';
      });
      return;
    }

    if (_amplitude == null || _experiment == null) {
      setState(() {
        _errorMessage = 'App not initialized. Please restart the app.';
      });
      return;
    }

    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      // Update Amplitude user
      await _amplitude!.setUserId(username);

      // Fetch latest variants from Experiment
      await _experiment!.fetch(ExperimentUser(userId: username));

      // Get welcome message variant
      final variant = await _experiment!.variant('flutter-welcome-message');
      await _experiment!.exposure('flutter-welcome-message');

      // Extract welcome message from variant, with fallback
      String welcomeMessage;
      if (variant.value != null &&
          variant.value!.isNotEmpty &&
          variant.value == 'treatment') {
        welcomeMessage =
            "Hello, $username! You have been selected for the treatment!";
      } else {
        welcomeMessage = 'Welcome, $username!';
      }

      if (!mounted) return;

      setState(() {
        _isLoggedIn = true;
        _username = username;
        _welcomeMessage = welcomeMessage;
        _isInitializing = false;
        _errorMessage = null;
      });

      // Clear username input
      _usernameController.clear();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isInitializing = false;
        _errorMessage = 'Login failed: ${e.toString()}';
      });
    }
  }

  /// Handle logout flow
  Future<void> _handleLogout() async {
    if (_amplitude == null) {
      return;
    }

    try {
      // Clear Amplitude user identity
      await _amplitude!.setUserId(null);
      // Clear Experiment data
      await _experiment!.clear();
    } catch (e) {
      // Log error but continue with logout
      debugPrint('Error clearing Amplitude user: $e');
    }

    if (!mounted) return;

    setState(() {
      _isLoggedIn = false;
      _username = null;
      _welcomeMessage = 'Welcome!';
      _errorMessage = null;
    });

    // Clear username input
    _usernameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Experiment Flutter Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Show loading state during initialization
    if (_isInitializing && !_isLoggedIn) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initializing...'),
          ],
        ),
      );
    }

    // Show error state if initialization failed
    if (_errorMessage != null && !_isLoggedIn && !_isInitializing) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeApp,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Show logged-in view
    if (_isLoggedIn) {
      return _buildLoggedInView();
    }

    // Show logged-out view
    return _buildLoggedOutView();
  }

  Widget _buildLoggedOutView() {
    final usernameLength = _usernameController.text.length;
    final isValidUsername = usernameLength >= 8;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.login, size: 64, color: Colors.blue),
            const SizedBox(height: 24),
            Text(
              'Welcome! Please log in to continue.',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'Enter username (8+ characters)',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person),
                errorText: _errorMessage,
                helperText: 'Username must be at least 8 characters',
              ),
              onChanged: (value) {
                setState(() {
                  _errorMessage = null;
                });
              },
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleLogin(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isInitializing ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isInitializing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Log In', style: TextStyle(fontSize: 16)),
              ),
            ),
            if (!isValidUsername && usernameLength > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '${8 - usernameLength} more characters needed',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedInView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 64, color: Colors.green),
            const SizedBox(height: 24),
            Text(
              _welcomeMessage,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Logged in as: $_username',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Log Out', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
