import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sandwich_shop/state/navigation_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editMode = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _enterEdit(Profile profile) {
    _nameCtrl.text = profile.displayName;
    _emailCtrl.text = profile.email;
    _phoneCtrl.text = profile.phone;
    _addressCtrl.text = profile.address;
    setState(() => _editMode = true);
  }

  Future<void> _save(ProfileProvider provider) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final updated = Profile(
      displayName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
    );
    await provider.saveProfile(updated);
    setState(() {
      _saving = false;
      _editMode = false;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Profile saved'), duration: Duration(seconds: 2)),
    );
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(v.trim())) return 'Enter a valid email';
    return null;
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Name is required';
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.isEmpty) return null;
    final regex = RegExp(r'^\d+$');
    if (!regex.hasMatch(v)) return 'Digits only';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        final profile = provider.profile;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            leading: MediaQuery.of(context).size.width < 1024
                ? IconButton(
                    icon: const Icon(Icons.menu),
                    tooltip: 'Open navigation',
                    onPressed: () =>
                        Provider.of<NavigationProvider>(context, listen: false)
                            .openDrawer(),
                  )
                : null,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _editMode
                ? Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        Semantics(
                          label: 'Display name field',
                          child: TextFormField(
                            key: const Key('nameField'),
                            controller: _nameCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Display name'),
                            validator: _validateName,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Semantics(
                          label: 'Email field',
                          child: TextFormField(
                            key: const Key('emailField'),
                            controller: _emailCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Email'),
                            validator: _validateEmail,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Semantics(
                          label: 'Phone field',
                          child: TextFormField(
                            key: const Key('phoneField'),
                            controller: _phoneCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Phone'),
                            validator: _validatePhone,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Semantics(
                          label: 'Address field',
                          child: TextFormField(
                            key: const Key('addressField'),
                            controller: _addressCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Address'),
                            minLines: 2,
                            maxLines: 4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  key: const Key('saveButton'),
                                  onPressed:
                                      _saving ? null : () => _save(provider),
                                  child: _saving
                                      ? const CircularProgressIndicator()
                                      : const Text('Save'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              height: 48,
                              child: OutlinedButton(
                                key: const Key('cancelButton'),
                                onPressed: _saving
                                    ? null
                                    : () {
                                        setState(() => _editMode = false);
                                      },
                                child: const Text('Cancel'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : ListView(
                    children: [
                      ListTile(
                        title: const Text('Display name'),
                        subtitle: Text(profile.displayName),
                      ),
                      ListTile(
                        title: const Text('Email'),
                        subtitle: Text(profile.email),
                      ),
                      if (profile.phone.isNotEmpty)
                        ListTile(
                          title: const Text('Phone'),
                          subtitle: Text(profile.phone),
                        ),
                      if (profile.address.isNotEmpty)
                        ListTile(
                          title: const Text('Address'),
                          subtitle: Text(profile.address),
                        ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          key: const Key('editButton'),
                          onPressed: () => _enterEdit(profile),
                          child: const Text('Edit'),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
