import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/user_model.dart';
import '../services/db_helper.dart';
import 'welcome_page.dart';

class District {
  final String id;
  final String nameEn;
  final String divisionId;

  District({required this.id, required this.nameEn, required this.divisionId});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'] as String,
      nameEn: json['name_en'] as String,
      divisionId: json['division_id'] as String,
    );
  }
}

class Upazila {
  final String districtId;
  final String nameEn;

  Upazila({required this.districtId, required this.nameEn});

  factory Upazila.fromJson(Map<String, dynamic> json) {
    return Upazila(
      districtId: json['district_id'] as String,
      nameEn: json['name_en'] as String,
    );
  }
}

class Division {
  final String id;
  final String nameEn;

  Division({required this.id, required this.nameEn});

  factory Division.fromJson(Map<String, dynamic> json) {
    return Division(
      id: json['id'] as String,
      nameEn: json['name_en'] as String,
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  String? _selectedBloodType;
  String? _selectedGender;
  String? _selectedDivision;
  String? _selectedDistrict;
  String? _selectedUpazila;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  bool _geoLoaded = false;
  String? _geoError;

  final List<String> bloodTypes = [
    'O+',
    'O-',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
  ];
  final List<String> genders = ['Male', 'Female', 'Bolbo na'];

  List<Division> _divisions = [];
  List<District> _districts = [];
  List<Upazila> _upazilas = [];

  String? get _selectedDivisionId {
    if (_selectedDivision == null) return null;
    try {
      return _divisions
          .firstWhere((division) => division.nameEn == _selectedDivision)
          .id;
    } catch (_) {
      return null;
    }
  }

  List<String> get _districtOptions {
    if (_selectedDivisionId == null) return [];
    return _districts
        .where((district) => district.divisionId == _selectedDivisionId)
        .map((district) => district.nameEn)
        .toList();
  }

  List<String> get _upazilaOptions {
    if (_selectedDistrict == null) return [];
    final districtId = _districts
        .firstWhere((district) => district.nameEn == _selectedDistrict)
        .id;
    return _upazilas
        .where((upazila) => upazila.districtId == districtId)
        .map((upazila) => upazila.nameEn)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadGeoData();
  }

  Future<void> _loadGeoData() async {
    try {
      final divisionJson = await rootBundle.loadString(
        'assets/geodata/divisions.json',
      );
      final districtJson = await rootBundle.loadString(
        'assets/geodata/districts.json',
      );
      final upazilaJson = await rootBundle.loadString(
        'assets/geodata/upazilas.json',
      );

      final List<dynamic> divisionData = json.decode(divisionJson);
      final List<dynamic> districtData = json.decode(districtJson);
      final List<dynamic> upazilaData = json.decode(upazilaJson);

      _divisions = divisionData
          .map((item) => Division.fromJson(item as Map<String, dynamic>))
          .toList();
      _districts = districtData
          .map((item) => District.fromJson(item as Map<String, dynamic>))
          .toList();
      _upazilas = upazilaData
          .map((item) => Upazila.fromJson(item as Map<String, dynamic>))
          .toList();

      setState(() {
        _geoLoaded = true;
      });
    } catch (error) {
      setState(() {
        _geoError = error.toString();
      });
    }
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final ageText = _ageController.text.trim();
    final city = _cityController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        ageText.isEmpty ||
        city.isEmpty ||
        _selectedBloodType == null ||
        _selectedGender == null ||
        _selectedDivision == null ||
        _selectedDistrict == null ||
        _selectedUpazila == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid phone number'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final age = int.tryParse(ageText);
    if (age == null || age < 18 || age > 65) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Age must be between 18 and 65'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to terms and conditions'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final exists = await DBHelper.instance.emailExists(email);
    if (!mounted) return;

    if (exists) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email already registered'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final user = UserModel(
      name: name,
      email: email,
      password: password,
      phone: phone,
      age: age,
      city: city,
      gender: _selectedGender!,
      division: _selectedDivision!,
      district: _selectedDistrict!,
      upazila: _selectedUpazila!,
      bloodGroup: _selectedBloodType!,
      createdAt: DateTime.now().toIso8601String(),
    );

    final id = await DBHelper.instance.insertUser(user);
    setState(() => _isLoading = false);
    if (!mounted) return;

    if (id > 0) {
      final savedUser = UserModel(
        id: id,
        name: user.name,
        email: user.email,
        password: user.password,
        phone: user.phone,
        age: user.age,
        city: user.city,
        gender: user.gender,
        division: user.division,
        district: user.district,
        upazila: user.upazila,
        bloodGroup: user.bloodGroup,
        createdAt: user.createdAt,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => WelcomePage(user: savedUser)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registration failed'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Join Our Community',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create account and help save lives',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your name',
                icon: Icons.person_outline,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'Enter your email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: 'Enter your phone number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _ageController,
                      label: 'Age',
                      hint: 'Your age',
                      icon: Icons.calendar_today_outlined,
                      keyboardType: TextInputType.number,
                      enabled: !_isLoading,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gender',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          onChanged: _isLoading
                              ? null
                              : (value) {
                                  setState(() => _selectedGender = value);
                                },
                          items: genders
                              .map(
                                (gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ),
                              )
                              .toList(),
                          decoration: InputDecoration(
                            hintText: 'Select gender',
                            prefixIcon: const Icon(Icons.wc, color: Colors.red),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _cityController,
                label: 'City',
                hint: 'Enter your city',
                icon: Icons.location_city_outlined,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              if (!_geoLoaded && _geoError == null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(color: Colors.red),
                  ),
                ),
              if (_geoError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Location data failed to load',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              _buildDropdownField(
                label: 'Division',
                value: _selectedDivision,
                hint: 'Select division',
                icon: Icons.public_outlined,
                items: _divisions.map((d) => d.nameEn).toList(),
                onChanged: !_geoLoaded || _isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _selectedDivision = value;
                          _selectedDistrict = null;
                          _selectedUpazila = null;
                        });
                      },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'District',
                value: _selectedDistrict,
                hint: 'Select district',
                icon: Icons.map_outlined,
                items: _districtOptions,
                onChanged: !_geoLoaded || _isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _selectedDistrict = value;
                          _selectedUpazila = null;
                        });
                      },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Upazila',
                value: _selectedUpazila,
                hint: 'Select upazila',
                icon: Icons.location_pin,
                items: _upazilaOptions,
                onChanged: !_geoLoaded || _isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _selectedUpazila = value;
                        });
                      },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Blood Group',
                value: _selectedBloodType,
                hint: 'Select your blood group',
                icon: Icons.bloodtype_outlined,
                items: bloodTypes,
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() => _selectedBloodType = value);
                      },
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Create a password',
                obscure: _obscurePassword,
                onToggle: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                hint: 'Confirm your password',
                obscure: _obscureConfirmPassword,
                onToggle: () {
                  setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  );
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreeToTerms,
                      onChanged: _isLoading
                          ? null
                          : (value) {
                              setState(() => _agreeToTerms = value ?? false);
                            },
                      activeColor: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'I agree to Terms of Service and Privacy Policy',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: Colors.red.shade200,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: Colors.black87),
                  ),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                    child: const Text(
                      'Sign in here',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: Colors.red),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 12,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Enter your $label';
            }
            if (label == 'Email Address' && !value.contains('@')) {
              return 'Enter a valid email';
            }
            if (label == 'Phone Number' && value.length < 10) {
              return 'Enter a valid phone number';
            }
            if (label == 'Age' && int.tryParse(value) == null) {
              return 'Enter a valid age';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required IconData icon,
    required List<String> items,
    required String? value,
    required ValueChanged<String?>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.red),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: const Icon(Icons.lock_outlined, color: Colors.red),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.red,
              ),
              onPressed: onToggle,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 12,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Enter your $label';
            }
            if (value.length < 6) {
              return 'Use 6+ characters';
            }
            return null;
          },
        ),
      ],
    );
  }
}
