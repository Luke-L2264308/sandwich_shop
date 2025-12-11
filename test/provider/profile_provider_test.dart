import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/providers/profile_provider.dart';

void main() {
  test('ProfileProvider load and save', () async {
    final provider = ProfileProvider();
    final initial = await provider.loadProfile();
    expect(initial, isA<Profile>());

    final newProfile = Profile(
      displayName: 'Alice',
      email: 'alice@example.com',
      phone: '1234567890',
      address: '123 Main St',
    );
    await provider.saveProfile(newProfile);
    final loaded = await provider.loadProfile();
    expect(loaded.displayName, 'Alice');
    expect(loaded.email, 'alice@example.com');
    expect(loaded.phone, '1234567890');
    expect(loaded.address, '123 Main St');
  });
}
