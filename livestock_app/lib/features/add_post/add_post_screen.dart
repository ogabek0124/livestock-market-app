import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/services/api_service.dart';

class AddPostScreen extends StatefulWidget {
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  
  File? _imageFile;
  bool _isLoading = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _submitPost() async {
    final title = _titleController.text.trim();
    final price = _priceController.text.trim();
    final city = _cityController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty || price.isEmpty || city.isEmpty || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Iltimos, barcha majburiy maydonlarni to'ldiring va rasm tanlang!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool success = await _apiService.createAd(
      title: title,
      price: price,
      city: city,
      description: desc,
      imagePath: _imageFile!.path,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("E'loningiz muvaffaqiyatli joylandi!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Go back to Home and indicate success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Xatolik yuz berdi. Iltimos qayta urinib ko'ring."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Yangi e'lon", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Picker UI
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 1.5, style: BorderStyle.dash),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: Offset(0, 5)),
                  ],
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 50, color: Colors.blue),
                          SizedBox(height: 10),
                          Text("Rasm qo'shish (Majburiy)", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 25),

            // Form Fields
            _buildTextField("Sarlavha", _titleController, Icons.title),
            SizedBox(height: 15),
            _buildTextField("Narxi (So'm)", _priceController, Icons.attach_money, isNumber: true),
            SizedBox(height: 15),
            _buildTextField("Shahar", _cityController, Icons.location_city),
            SizedBox(height: 15),
            _buildTextField("Batafsil ma'lumot", _descController, Icons.description, maxLines: 4),

            SizedBox(height: 30),

            // Submit Button
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("E'lonni joylash", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueAccent, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
    );
  }
}
