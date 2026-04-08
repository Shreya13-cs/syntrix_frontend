import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/cloudinary_service.dart';
import '../home/home_screen.dart';

class _PendingFile {
  final String name;
  final Uint8List bytes;
  final int sizeKB;
  _PendingFile({required this.name, required this.bytes, required this.sizeKB});

  String get ext => name.split('.').last.toUpperCase();
  bool get isImage => ['JPG', 'JPEG', 'PNG'].contains(ext);
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  bool _isSaving = false;
  bool _showUploadOptions = false;
  final List<_PendingFile> _pendingFiles = [];

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const int _maxSizeKB = 1024;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickReport(bool isCamera) async {
    Uint8List? bytes;
    String? fileName;

    try {
      if (isCamera) {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.camera);
        if (pickedFile != null) {
          bytes = await pickedFile.readAsBytes();
          fileName = pickedFile.name;
        }
      } else {
        FilePickerResult? result = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
          withData: true,
        );
        if (result != null && result.files.single.bytes != null) {
          bytes = result.files.single.bytes;
          fileName = result.files.single.name;
        }
      }

      if (bytes == null || fileName == null) return;

      final sizeKB = bytes.length ~/ 1024;
      if (sizeKB > _maxSizeKB) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'File too large (${sizeKB}KB). Max is ${_maxSizeKB}KB.',
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }

      setState(() {
        _pendingFiles.add(
          _PendingFile(name: fileName!, bytes: bytes!, sizeKB: sizeKB),
        );
        _showUploadOptions = false;
      });
    } catch (e) {
      print('Pick error: $e');
    }
  }

  Future<void> _saveAllReports() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _pendingFiles.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      for (var file in _pendingFiles) {
        final url = await CloudinaryService.uploadFile(file.bytes, file.name);
        if (url != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('reports')
              .add({
                'name': file.name,
                'url': url,
                'sizeKB': file.sizeKB,
                'date': dateStr,
                'uploadedAt': FieldValue.serverTimestamp(),
              });
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reports saved!'),
            backgroundColor: Colors.teal,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // "Upload Report" Text at Center Top
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Upload Report',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E4A6B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Container(
                      width: 30,
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A6EA8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Color(0xFF2E4A6B),
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Health Reports',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2E4A6B),
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildMainCard(),
                  const SizedBox(height: 32),
                  if (_pendingFiles.isNotEmpty) _buildSaveButton(),
                  const SizedBox(height: 20),
                  const Text(
                    'Health Metrics View',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2B3C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMetricsGrid(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          if (_isSaving) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _isSaving ? null : _saveAllReports,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF2E4A6B),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E4A6B).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Save Reports',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_pendingFiles.isEmpty)
            _buildIdleState()
          else ...[
            ..._pendingFiles.asMap().entries.map(
              (e) => _buildFileRow(e.value, e.key),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _buildActionSwitcher(),
          ],
        ],
      ),
    );
  }

  Widget _buildActionSwitcher() {
    if (!_showUploadOptions) {
      return GestureDetector(
        onTap: () => setState(() => _showUploadOptions = true),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_circle_outline, color: Color(0xFF2E4A6B), size: 18),
            SizedBox(width: 8),
            Text(
              'Select More',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E4A6B),
              ),
            ),
          ],
        ),
      );
    }
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _pickReport(false),
            child: _uploadButton(Icons.description_outlined, 'File'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => _pickReport(true),
            child: _uploadButton(Icons.camera_alt, 'Camera'),
          ),
        ),
      ],
    );
  }

  Widget _buildFileRow(_PendingFile f, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: f.isImage
                  ? const Color(0xFF3A6EA8).withOpacity(0.1)
                  : const Color(0xFFB5616A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              f.isImage ? Icons.image : Icons.picture_as_pdf,
              color: f.isImage
                  ? const Color(0xFF3A6EA8)
                  : const Color(0xFFB5616A),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2B3C),
                  ),
                ),
                Text(
                  '${f.sizeKB} KB • Ready',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7A8FA6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _pendingFiles.removeAt(index)),
            icon: const Icon(Icons.close, color: Colors.red, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleState() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFFF4F6FA),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.upload_file,
            color: Color(0xFF2E4A6B),
            size: 30,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Select Report',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1F26),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'PDF or Images — Max 1MB.\nFiles saved when you press SAVE.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Color(0xFF7A8FA6), height: 1.5),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _pickReport(false),
                child: _uploadButton(Icons.description, 'File'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => _pickReport(true),
                child: _uploadButton(Icons.photo_camera, 'Camera'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _uploadButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF2E4A6B), size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E4A6B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _dataCard(
          'GLUCOSE',
          '98',
          'mg/dL',
          Icons.water_drop,
          const Color(0xFF3A6EA8),
        ),
        _dataCard(
          'HEMOGLOBIN',
          '13.2',
          'g/dL',
          Icons.bloodtype,
          const Color(0xFFB5616A),
        ),
      ],
    );
  }

  Widget _dataCard(
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2B3C),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(fontSize: 10, color: Color(0xFF7A8FA6)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const CircularProgressIndicator(
                  color: Color(0xFF2E4A6B),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Saving...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
