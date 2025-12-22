import 'package:flutter/material.dart';
import 'package:magic_english_project/core/utils/toast_helper.dart';
class UserData {
  String fullName;
  String email;
  String dateOfBirth;
  String phone;
  String gender;
  String imagePath;
  UserData({
    required this.fullName,
    required this.email,
    required this.dateOfBirth,
    required this.phone,
    required this.gender,
    required this.imagePath,
  });
}

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}
class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
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

  late UserData userData;
  bool isEditing = false;

  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _phoneController;
  String? _selectedGender;
  String? _tempAssetPath;

  @override
  void initState() {
    super.initState();
    userData = UserData(
      fullName: 'Nguyễn Văn A',
      email: 'abc@gmail.com',
      dateOfBirth: '10/11/2004',
      phone: '0987654321',
      gender: 'Nam',
      imagePath: 'assets/images/avt_boiroi.jpg',
    );
    _initFields();
  }

  void _initFields() {
    _fullNameController = TextEditingController(text: userData.fullName);
    _emailController = TextEditingController(text: userData.email);
    _dateOfBirthController = TextEditingController(text: userData.dateOfBirth);
    _phoneController = TextEditingController(text: userData.phone);
    _selectedGender = userData.gender;
    _tempAssetPath = userData.imagePath;
  }

  // Mở danh sách chọn ảnh
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
                        setState(() => _tempAssetPath = _availableAvatars[index]);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Chỉnh sửa thông tin' : 'Thông tin cá nhân'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (isEditing) {
              setState(() {
                _initFields();
                isEditing = false;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: isEditing ? _buildEditView() : _buildDisplayView(),
      ),
    );
  }

  Widget _buildDisplayView() {
    return Column(
      children: [
        CircleAvatar(radius: 55, backgroundColor: Colors.blue.shade100,
            child: CircleAvatar(radius: 50, backgroundImage: AssetImage(userData.imagePath))),
        const SizedBox(height: 30),
        _infoRow('Họ tên', userData.fullName),
        _infoRow('Email', userData.email),
        _infoRow('Ngày sinh', userData.dateOfBirth),
        _infoRow('Điện thoại', userData.phone),
        _infoRow('Giới tính', userData.gender),
        const SizedBox(height: 50),
        _buildBtn('Chỉnh sửa', () => setState(() => isEditing = true)),
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
              CircleAvatar(radius: 50, backgroundImage: AssetImage(_tempAssetPath!)),
              Positioned(bottom: 0, right: 0,
                  child: GestureDetector(
                      onTap: _showAvatarPicker,
                      child: const CircleAvatar(radius: 18, backgroundColor: Colors.blue, child: Icon(Icons.camera_alt, color: Colors.white, size: 18)))),
            ],
          ),
          const SizedBox(height: 30),
          _inputField(_fullNameController, 'Họ tên', Icons.person),
          _inputField(_emailController, 'Email', Icons.email),
          _inputField(_phoneController, 'Điện thoại', Icons.phone),
          const SizedBox(height: 40),
          _buildBtn('Lưu thay đổi', _saveData),
        ],
      ),
    );
  }

  void _saveData() {
    setState(() {
      userData.fullName = _fullNameController.text;
      userData.imagePath = _tempAssetPath!;
      isEditing = false;
    });
    showTopNotification(context, type: ToastType.success, title: 'Thành công', message: 'Đã cập nhật thông tin.');
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

  Widget _inputField(TextEditingController ctrl, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildBtn(String text, VoidCallback press) {
    return SizedBox(width: double.infinity, height: 55,
        child: ElevatedButton(onPressed: press, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 18))));
  }
}