import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:magic_english_project/core/utils/toast_helper.dart';
import 'package:magic_english_project/project/database/database.dart';
import 'package:magic_english_project/project/dto/user.dart';
import 'package:magic_english_project/project/provider/userprovider.dart';
import 'package:provider/provider.dart';
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final Database _db = Database();
  final ImagePicker _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final List<String> _availableAvatars = [
    'assets/images/avt_boiroi.jpg',
    'assets/images/avt_convit.webp',
    'assets/images/avt_metmoi.jpg',
    'assets/images/avt_nam.jpg',
    'assets/images/avt_nu.jpg',
    'assets/images/avt_ngugat.jpg',
    'assets/images/avt_quyettam.jpg',
  ];

  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _phoneController;
  String? _selectedGender;
  String? _tempAssetPath;
  String? _tempNetworkUrl;

  Uint8List? _pickedAvatarBytes;
  String? _pickedAvatarFilename;

  Future<Uint8List> _fetchAvatarBytes(String url) async {
    final uri = Uri.parse(url);
    final res = await http.get(
      uri,
      headers: const {
        'ngrok-skip-browser-warning': 'true',
        'Accept': 'image/*,*/*;q=0.8',
      },
    );
    if (res.statusCode >= 200 && res.statusCode < 300 && res.bodyBytes.isNotEmpty) {
      return res.bodyBytes;
    }
    throw Exception('Không tải được ảnh (${res.statusCode})');
  }

  Widget _networkAvatar(String url) {
    return FutureBuilder<Uint8List>(
      future: _fetchAvatarBytes(url),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (snap.hasData) {
          return Image.memory(snap.data!, fit: BoxFit.cover, key: ValueKey(url));
        }

        // If web fetch fails (often due to CORS/preflight), fall back to <img>.
        if (kIsWeb) {
          return Image.network(
            url,
            fit: BoxFit.cover,
            key: ValueKey('fallback:$url'),
            errorBuilder: (_, __, ___) => Image.asset('assets/images/avt_boiroi.jpg', fit: BoxFit.cover),
          );
        }
        return Image.asset('assets/images/avt_boiroi.jpg', fit: BoxFit.cover);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    User? user = context.read<UserProvider>().user;
    _initFields(user);
  }

  void _initFields(User? userData) {
    _fullNameController = TextEditingController(text: userData?.name??"");
    _emailController = TextEditingController(text: userData?.email??"");
    _dateOfBirthController = TextEditingController(text: userData?.dateOfBirth??"");
    _phoneController = TextEditingController(text: userData?.phone??"");
    _selectedGender = User.normalizeGender(userData?.gender) ?? 'nam';
    final img = userData?.imagePath;
    _tempNetworkUrl = (img != null && img.startsWith('http')) ? img : null;
    _tempAssetPath = (img != null && img.startsWith('assets/')) ? img : 'assets/images/avt_boiroi.jpg';
    _pickedAvatarBytes = null;
    _pickedAvatarFilename = null;
  }

  Future<void> _pickAvatarFromGallery(BuildContext sheetContext) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _pickedAvatarBytes = bytes;
        _pickedAvatarFilename = picked.name;
        _tempNetworkUrl = null;
      });
      if (Navigator.of(sheetContext).canPop()) {
        Navigator.pop(sheetContext);
      }
    } catch (_) {
      if (!mounted) return;
      showTopNotification(
        context,
        type: ToastType.error,
        title: 'Lỗi',
        message: 'Không thể chọn ảnh từ thư viện',
      );
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateOfBirthController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 400,
          child: Column(
            children: [
              const Text('Chọn ảnh đại diện', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _pickAvatarFromGallery(context),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Chọn từ thư viện'),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15
                  ),
                  itemCount: _availableAvatars.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _tempAssetPath = _availableAvatars[index];
                          _tempNetworkUrl = null;
                          _pickedAvatarBytes = null;
                          _pickedAvatarFilename = null;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _tempAssetPath == _availableAvatars[index] ? Colors.blue : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(backgroundImage: AssetImage(_availableAvatars[index])),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveData(BuildContext parentContext) async{
    String message = '';
    if (_formKey.currentState!.validate()) {
      try {
        User user = User(
          name: _fullNameController.text,
          email: _emailController.text,
          dateOfBirth: _dateOfBirthController.text,
          phone: _phoneController.text,
          gender: User.normalizeGender(_selectedGender) ?? 'nam',
          imagePath: _tempAssetPath,
        );
        showLoading();
        final updated = await _db.updateUserData(
          user,
          avatarBytes: _pickedAvatarBytes,
          filename: _pickedAvatarFilename,
        );
        if (!parentContext.mounted) {
          return;
        }
        Navigator.of(parentContext,rootNavigator: true).pop();
        context.read<UserProvider>().setUser(updated);
        context.read<UserProvider>().stopEditing();
        showTopNotification(parentContext, type: ToastType.success,
            title: 'Thành công',
            message: 'Đã cập nhật thông tin.');
      }
      catch(err){
        if(!parentContext.mounted){
          return;
        }
        final navigator = Navigator.of(parentContext, rootNavigator: true);
        if(navigator.canPop()){
          Navigator.of(parentContext,rootNavigator: true).pop();
        }

        showTopNotification(parentContext, type: ToastType.success, title:
            'Lỗi', message: message);
      }
    }
  }
  void showLoading(){
    showDialog(context: context,
        barrierDismissible: false, builder: (dialogContext){
      return const Center(child: CircularProgressIndicator(),);
    });
  }

  @override
  Widget build(BuildContext context) {
    User? user = context.watch<UserProvider>().user;
    bool isEditing = context.watch<UserProvider>().isEditing;
    if(user == null){
      return const CircularProgressIndicator();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Chỉnh sửa thông tin' : 'Thông tin cá nhân'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (isEditing) {
              _initFields(user);
              context.read<UserProvider>().stopEditing();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: isEditing ? _buildEditView() : _buildDisplayView(user),
      ),
    );
  }

  Widget _buildDisplayView(User userData) {
    final img = User.normalizeAvatarUrl(userData.imagePath);
    final isNetwork = img != null && img.startsWith('http');
    return Column(
      children: [
        CircleAvatar(
          radius: 55,
          backgroundColor: Colors.blue.shade100,
          child: ClipOval(
            child: SizedBox(
              width: 100,
              height: 100,
              child: isNetwork
                  ? _networkAvatar(img!)
                  : Image.asset(
                      (img != null && img.startsWith('assets/')) ? img : 'assets/images/avt_boiroi.jpg',
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        _infoRow('Họ tên', userData.name??""),
        _infoRow('Email', userData.email??""),
        _infoRow('Ngày sinh', userData.dateOfBirth??""),
        _infoRow('Điện thoại', userData.phone??""),
        _infoRow('Giới tính', User.genderLabel(userData.gender)),
        const SizedBox(height: 50),
        _buildBtn('Chỉnh sửa', (){
          _initFields(userData);
          context.read<UserProvider>().startEditing();
        }),
      ],
    );
  }

  Widget _buildEditView() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: _pickedAvatarBytes != null
                    ? MemoryImage(_pickedAvatarBytes!)
                    : (_tempNetworkUrl != null
                        ? NetworkImage(_tempNetworkUrl!) as ImageProvider
                        : AssetImage(_tempAssetPath!)),
              ),
              Positioned(bottom: 0, right: 0,
                  child: GestureDetector(
                      onTap: _showAvatarPicker,
                      child: const CircleAvatar(radius: 18, backgroundColor: Colors.blue, child: Icon(Icons.camera_alt, color: Colors.white, size: 18)))),
            ],
          ),
          const SizedBox(height: 30),
          _inputField(_fullNameController, 'Họ tên'),
          _inputField(_emailController, 'Email', keyboardType: TextInputType.emailAddress,enable: false),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextFormField(
              controller: _dateOfBirthController,
              readOnly: true,
              onTap: _selectDate,
              decoration: _inputDecoration('Ngày sinh'),
            ),
          ),

          _inputField(_phoneController, 'Điện thoại', keyboardType: TextInputType.phone),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: _inputDecoration('Giới tính'),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(value: 'nam', child: Text('Nam')),
                DropdownMenuItem<String>(value: 'nữ', child: Text('Nữ')),
              ],
              onChanged: (newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
            ),
          ),

          const SizedBox(height: 40),
          _buildBtn('Lưu thay đổi',(){
            _saveData(context);
          }),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  Widget _inputField(TextEditingController ctrl, String label, {TextInputType keyboardType = TextInputType.text,bool enable = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        enabled: enable,
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: _inputDecoration(label),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ]),
    );
  }

  Widget _buildBtn(String text, VoidCallback press) {
    return SizedBox(width: double.infinity, height: 55,
        child: ElevatedButton(onPressed: press, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 18))));
  }
}