import 'package:flutter/material.dart';
import '../../data/models/ad_model.dart';
import '../../data/services/api_service.dart';

class DetailScreen extends StatefulWidget {
  final Ad ad;

  const DetailScreen({Key? key, required this.ad}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isFavorite = false;
  int currentViews = 0;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    currentViews = widget.ad.views;
    _incrementViewAndFetchDetails();
  }

  void _incrementViewAndFetchDetails() async {
    try {
      final updatedAd = await _apiService.getAdDetail(widget.ad.id);
      if (updatedAd != null && mounted) {
        setState(() {
          currentViews = updatedAd.views;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void _toggleFavorite() async {
    final success = await _apiService.toggleFavorite(widget.ad.id, isFavorite);
    if (success) {
      setState(() {
        isFavorite = !isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isFavorite ? "Saqlanganlarga qo'shildi!" : "Saqlanganlardan olib tashlandi."),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Baza bilan xatolik yuz berdi. Iltimos qayta urinib ko'ring."),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Batafsil', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.grey,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'ad-image-${widget.ad.id}',
              child: Container(
                width: double.infinity,
                height: 350,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  image: widget.ad.image != null
                      ? DecorationImage(
                          image: NetworkImage(widget.ad.image!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.ad.image == null
                    ? Icon(Icons.image_not_supported, size: 50, color: Colors.grey)
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.ad.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.remove_red_eye, size: 16, color: Colors.blue),
                            SizedBox(width: 5),
                            Text('$currentViews', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    "${widget.ad.price} UZS",
                    style: TextStyle(
                      fontSize: 26,
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text(widget.ad.city,
                          style: TextStyle(fontSize: 16, color: Colors.black87)),
                    ],
                  ),
                  Divider(height: 40, thickness: 1),
                  Text(
                    'Tavsif',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text(
                    widget.ad.description.isEmpty
                        ? "Sotuvchi qo'shimcha ma'lumot kiritmagan."
                        : widget.ad.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              // Action: Call User
            },
            icon: Icon(Icons.phone),
            label: Text("Bog'lanish", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
