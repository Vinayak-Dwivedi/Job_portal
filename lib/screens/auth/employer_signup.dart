import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Standalone styles to ensure this exact UI remains intact
class _AppColors {
  static const primary = Color(0xFF1D4ED8);
  static const bg = Color(0xFF0A0F1A);
  static const surface = Color(0xFF151C2A);
}

class EmployerSignupScreen extends StatefulWidget {
  const EmployerSignupScreen({super.key});

  @override
  State<EmployerSignupScreen> createState() => _EmployerSignupScreenState();
}

class _EmployerSignupScreenState extends State<EmployerSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedIndustry = 'Select Industry';
  LatLng? _selectedLocation;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.push('/otp', extra: {
        'phone': _phoneController.text.trim(),
        'role': 'employer',
        'name': _nameController.text.trim(),
        'company': _companyController.text.trim(),
        'skill': _selectedIndustry == 'Select Industry' ? '' : _selectedIndustry,
        'experience': '',
        'latitude': _selectedLocation?.latitude.toString() ?? '',
        'longitude': _selectedLocation?.longitude.toString() ?? '',
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Widget _sectionLabel(String text, Color accentColor) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _textField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? prefixWidget,
    Widget? suffixIcon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            filled: true,
            fillColor: _AppColors.surface,
            prefixIcon: prefixWidget,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 16 : 0),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.bg,
      appBar: AppBar(
        backgroundColor: _AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blueAccent),
          onPressed: () => context.pop(),
        ),
        title: const Text('Establish Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: false,
        actions: const [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: Text(
                'Step 1 of 4',
                style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Company Identity ───────────────────────────────────────
              Row(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _AppColors.surface,
                          border: Border.all(color: Colors.grey.withOpacity(0.2), style: BorderStyle.none),
                        ),
                        // Dashed inner border effect
                        child: CustomPaint(
                          painter: _DashedCirclePainter(color: Colors.grey.withOpacity(0.4)),
                          child: const Center(
                            child: Icon(Icons.camera_alt_rounded, color: Colors.grey, size: 28),
                          ),
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: _AppColors.bg, width: 2),
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 12),
                      )
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Company Identity",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Upload your company logo to build immediate trust with skilled talent.",
                          style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: _AppColors.primary.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "Upload Company Logo",
                            style: TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // ── Company Details ────────────────────────────────────────
              _sectionLabel("Company Details", _AppColors.primary),
              const SizedBox(height: 20),

              _textField(
                label: "FULL NAME / EMPLOYER NAME",
                hint: "e.g. Rajesh Kumar",
                controller: _nameController,
                validator: (v) => (v == null || v.isEmpty) ? "Name is required" : null,
              ),
              const SizedBox(height: 20),

              _textField(
                label: "COMPANY NAME",
                hint: "e.g. RK Infrastructure Ltd.",
                controller: _companyController,
                validator: (v) => (v == null || v.isEmpty) ? "Company name is required" : null,
              ),
              const SizedBox(height: 20),

              _textField(
                label: "MOBILE NUMBER",
                hint: "98765 43210",
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixWidget: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("+91", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                ),
                suffixIcon: const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Phone is required';
                  if (v.length < 10) return 'Enter a valid phone number';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _textField(
                label: "COMPANY DESCRIPTION",
                hint: "Describe your business, values, and what\nyou look for in partners...",
                controller: _descController,
                maxLines: 4,
              ),
              const SizedBox(height: 36),

              // ── Operational Scope ──────────────────────────────────────
              _sectionLabel("Operational Scope", const Color(0xFFD94625)), // Orange/Red accent
              const SizedBox(height: 20),

              const Text(
                "INDUSTRY CATEGORY",
                style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: _AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedIndustry,
                    isExpanded: true,
                    dropdownColor: _AppColors.surface,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    items: ['Select Industry', 'Civil Construction', 'IT & Software', 'Manufacturing', 'Retail']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedIndustry = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "OFFICE/SITE LOCATION",
                style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),

              // Interactive Map
              Container(
                height: 160,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: _AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: const LatLng(19.0760, 72.8777), // Default initialization point
                    initialZoom: 11.0,
                    onTap: (tapPosition, point) {
                      setState(() {
                        _selectedLocation = point;
                      });
                    },
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom | InteractiveFlag.doubleTapZoom,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.kijobportal',
                    ),
                    if (_selectedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedLocation!,
                            width: 80,
                            height: 80,
                            child: const Icon(Icons.location_on, color: Colors.redAccent, size: 40),
                          ),
                        ],
                      )
                    else
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: const LatLng(19.0760, 72.8777),
                            width: 120,
                            height: 40,
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _AppColors.primary.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('Tap map to pin location', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  "Tap the map to pin your exact operational\nheadquarters",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 11, height: 1.4),
                ),
              ),
              const SizedBox(height: 48), // Padding before bottom actions
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: _AppColors.bg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("Complete Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.save_outlined, color: Colors.grey, size: 20),
                    SizedBox(height: 6),
                    Text("Save Progress", style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.help_outline, color: Colors.grey, size: 20),
                    SizedBox(height: 6),
                    Text("Help", style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// ── Custom Painters for design placeholders ─────────────────────────────────

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    // Very simple dashed circle simulation drawing arcs
    final rect = Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: size.width - 2, height: size.height - 2);
    for (int i = 0; i < 360; i += 15) {
      if (i % 30 == 0) {
        canvas.drawArc(rect, i * 3.14159 / 180, 10 * 3.14159 / 180, false, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


