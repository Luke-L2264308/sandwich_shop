import 'package:flutter/foundation.dart';

class Profile {
  final String displayName;
  final String email;
  final String phone;
  final String address;

  Profile({
    required this.displayName,
    required this.email,
    this.phone = '',
    this.address = '',
  });

  Profile copyWith({
    String? displayName,
    String? email,
    String? phone,
    String? address,
  }) {
    return Profile(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }

  @override
  String toString() =>
      'Profile(displayName:$displayName,email:$email,phone:$phone,address:$address)';
}

class ProfileProvider extends ChangeNotifier {
  // make simulated delay configurable for faster tests
  final Duration simulatedDelay;

  ProfileProvider({Duration? simulatedDelay})
      : simulatedDelay = simulatedDelay ?? const Duration(milliseconds: 250);

  Profile _profile = Profile(displayName: 'Guest', email: 'guest@example.com');

  Profile get profile => _profile;

  Future<Profile> loadProfile() async {
    // Skip awaiting when delay is zero to avoid unnecessary scheduling
    if (simulatedDelay > Duration.zero) {
      await Future.delayed(simulatedDelay);
    }
    return _profile;
  }

  Future<void> saveProfile(Profile profile) async {
    // Skip awaiting when delay is zero to avoid unnecessary scheduling
    if (simulatedDelay > Duration.zero) {
      await Future.delayed(simulatedDelay);
    }
    _profile = profile;
    notifyListeners();
  }
}
