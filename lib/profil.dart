import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Controller Form
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  // LIST DATA PROFILE
  List<Map<String, dynamic>> profileList = [];
  static const String prefsKey = "profileList";

  int? editingIndex;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(prefsKey);

    if (raw != null) {
      setState(() {
        profileList = raw
            .map((e) => jsonDecode(e))
            .cast<Map<String, dynamic>>()
            .toList();
      });
    }
  }

  Future<void> _saveProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final data = profileList.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList(prefsKey, data);
  }

  void _addOrUpdateProfile() {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final age = _ageController.text.trim();

    if (username.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username & Email wajib diisi")),
      );
      return;
    }

    final newProfile = {
      "username": username,
      "email": email,
      "phone": phone,
      "address": address,
      "age": age,
      "createdAt": DateTime.now().toIso8601String(),
    };

    if (editingIndex == null) {
      // CREATE
      setState(() {
        profileList.add(newProfile);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil berhasil ditambahkan")),
      );
    } else {
      // UPDATE
      setState(() {
        profileList[editingIndex!] = newProfile;
        editingIndex = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil berhasil diperbarui")),
      );
    }

    _saveProfiles();
    _clearForm();
  }

  void _clearForm() {
    _usernameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();
    _ageController.clear();

    setState(() => editingIndex = null);
  }

  void _editProfile(int index) {
    final item = profileList[index];

    _usernameController.text = item["username"];
    _emailController.text = item["email"];
    _phoneController.text = item["phone"];
    _addressController.text = item["address"];
    _ageController.text = item["age"];

    setState(() => editingIndex = index);
  }

  void _deleteProfile(int index) {
    setState(() {
      profileList.removeAt(index);
    });
    _saveProfiles();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Profil dihapus")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 56, 165, 209),
        title: const Text(
          "Profile Pasien",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // FORM INPUT
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: "Nama Lengkap",
                      prefixIcon: Icon(
                        Icons.person,
                        color: Color.fromARGB(255, 56, 165, 209),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(
                        Icons.email,
                        color: Color.fromARGB(255, 56, 165, 209),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: "Nomor Telepon",
                      prefixIcon: Icon(
                        Icons.phone,
                        color: Color.fromARGB(255, 56, 165, 209),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: "Umur",
                      prefixIcon: Icon(
                        Icons.calendar_today,
                        color: Color.fromARGB(255, 56, 165, 209),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: "Alamat",
                      prefixIcon: Icon(
                        Icons.home,
                        color: Color.fromARGB(255, 56, 165, 209),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addOrUpdateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          56,
                          165,
                          209,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        editingIndex == null
                            ? "Tambah Profil"
                            : "Update Profil",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  if (editingIndex != null)
                    TextButton(
                      onPressed: _clearForm,
                      child: const Text("Batal Edit"),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Daftar Profil Tersimpan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // LIST PROFILE
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: profileList.length,
              itemBuilder: (context, index) {
                final item = profileList[index];

                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(item["username"]),
                    subtitle: Text("${item["email"]}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _editProfile(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProfile(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
