import 'package:flutter/material.dart';
import 'package:magic_english_project/core/utils/toast_helper.dart';

class UserData {
  String fullName;
  String email;
  String dateOfBirth;
  String phone;
  String gender;
  UserData({
    required this.fullName,
    required this.email,
    required this.dateOfBirth,
    required this.phone,
    required this.gender,
  });

}
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  UserData userData = UserData(
    fullName: 'Nguyễn Văn A',
    email: 'abc@gmail.com',
    dateOfBirth: '10/11/2004',
    phone: '0987654321',
    gender: 'Nam',
  );
  bool isEditing = false;
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _phoneController;

  String? _selectedGender;
  final List<String> _genders = ['Nam', 'Nữ', 'Khác'];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: userData.fullName);
    _emailController = TextEditingController(text: userData.email);
    _dateOfBirthController = TextEditingController(text: userData.dateOfBirth);
    _phoneController = TextEditingController(text: userData.phone);
    _selectedGender = userData.gender;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _dateOfBirthController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  void _startEditing() {
    setState(() {
      isEditing = true;
    });
  }
  Future<void> _selectDateOfBirth(BuildContext context) async {
    DateTime initialDate;
    try {
      List<String> parts = userData.dateOfBirth.split('/');
      if (parts.length == 3) {
        initialDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      } else {
        initialDate = DateTime.now().subtract(const Duration(days: 365 * 20));
      }
    } catch (_) {
      initialDate = DateTime.now().subtract(const Duration(days: 365 * 20));
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Chọn Ngày sinh',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade600,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        String formattedDate = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
        _dateOfBirthController.text = formattedDate;
      });
    }
  }
  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        userData.fullName = _fullNameController.text;
        userData.email = _emailController.text;
        userData.dateOfBirth = _dateOfBirthController.text;
        userData.phone = _phoneController.text;
        userData.gender = _selectedGender ?? userData.gender;

        isEditing = false;
        showTopNotification(
          context,
          type: ToastType.success,
          title: 'Thành công',
          message: 'Thông tin cá nhân đã được lưu thành công.',
          duration: const Duration(seconds: 3),
        );
      });
    } else {
      showTopNotification(
        context,
        type: ToastType.error,
        title: 'Lỗi nhập liệu',
        message: 'Vui lòng kiểm tra lại các trường thông tin không hợp lệ.',
        duration: const Duration(seconds: 4),
      );
    }
  }

  void _cancelEditing() {
    setState(() {
      _fullNameController.text = userData.fullName;
      _emailController.text = userData.email;
      _dateOfBirthController.text = userData.dateOfBirth;
      _phoneController.text = userData.phone;
      _selectedGender = userData.gender;

      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing
            ? 'Chỉnh sửa thông tin cá nhân'
            : 'Thông tin cá nhân'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (isEditing) {
              _cancelEditing();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: isEditing ? _buildEditProfileView() : _buildDisplayProfileView(),
    );
  }
  Widget _buildDisplayProfileView() {
    const TextStyle labelStyle = TextStyle(
      fontSize: 16,
      color: Colors.grey,
    );
    const TextStyle valueStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    );
    Widget buildInfoRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: labelStyle),
            Text(value, style: valueStyle),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.lightBlue, width: 2),
            ),
            margin: const EdgeInsets.only(bottom: 50),
          ),
          buildInfoRow('Họ tên', userData.fullName),
          const Divider(height: 1),
          buildInfoRow('Email', userData.email),
          const Divider(height: 1),
          buildInfoRow('Ngày sinh', userData.dateOfBirth),
          const Divider(height: 1),
          buildInfoRow('Điện thoại', userData.phone),
          const Divider(height: 1),
          buildInfoRow('Giới tính', userData.gender),
          const Divider(height: 1),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _startEditing,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text('Chỉnh sửa', style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildEditProfileView() {
    Widget buildEditableField({
      required TextEditingController controller,
      required String hintText,
      required String? Function(String?) validator,
      bool isReadOnly = false,
      TextInputType keyboardType = TextInputType.text,
      VoidCallback? onTap,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          controller: controller,
          readOnly: isReadOnly || onTap != null,
          keyboardType: keyboardType,
          validator: validator,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            suffixIcon: onTap != null
                ? Icon(Icons.calendar_today, color: Colors.blue.shade600, size: 20)
                : null,
            errorStyle: const TextStyle(fontSize: 12, height: 0.8),
          ),
          style: const TextStyle(fontSize: 16),
        ),
      );
    }
    Widget buildGenderDropdown() {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: DropdownButtonFormField<String>(
          value: _selectedGender,
          items: _genders.map((String gender) {
            return DropdownMenuItem<String>(
              value: gender,
              child: Text(gender, style: const TextStyle(fontSize: 16)),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedGender = newValue;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
          ),
          hint: const Text('Chọn Giới tính'),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
        ),
      );
    }
    const Widget editAvatarIcon = Positioned(
      bottom: 0,
      right: 0,
      child: Card(
        color: Colors.white,
        elevation: 1,
        shape: CircleBorder(),
        child: Padding(
          padding: EdgeInsets.all(4.0),
          child: Icon(Icons.image_outlined, color: Colors.blue, size: 20),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.lightBlue, width: 2),
                  ),
                  margin: const EdgeInsets.only(bottom: 40),
                ),
                editAvatarIcon,
              ],
            ),

            buildEditableField(
              controller: _fullNameController,
              hintText: 'Họ tên',
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập Họ tên.';
                }
                return null;
              },
            ),
            buildEditableField(
              controller: _emailController,
              hintText: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập Email.';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Email không hợp lệ.';
                }
                return null;
              },
            ),
            buildEditableField(
              controller: _dateOfBirthController,
              hintText: 'Ngày sinh (DD/MM/YYYY)',
              keyboardType: TextInputType.text,
              onTap: () => _selectDateOfBirth(context),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng chọn Ngày sinh.';
                }
                return null;
              },
            ),
            buildEditableField(
              controller: _phoneController,
              hintText: 'Điện thoại',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập số điện thoại.';
                }
                if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                  return 'SĐT không hợp lệ (10 chữ số).';
                }
                return null;
              },
            ),
            buildGenderDropdown(),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Text('Lưu', style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
