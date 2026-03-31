import 'package:flutter/material.dart';
import '../../data/models/ad_model.dart';
import '../../data/services/api_service.dart';
import '../ad_detail/detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Ad>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    setState(() {
      _favoritesFuture = _apiService.getFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saqlangan e\'lonlar', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<Ad>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
             WidgetsBinding.instance.addPostFrameCallback((_) {
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Baza bilan ulanishda xatolik!"), backgroundColor: Colors.red));
             });
            return Center(child: Text("Xatolik yuz berdi"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.heart_broken, size: 80, color: Colors.grey[300]),
                  SizedBox(height: 16),
                  Text("Hech narsa saqlanmagan", style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          final ads = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: ads.length,
            itemBuilder: (context, index) {
              final ad = ads[index];
              return Card(
                elevation: 3,
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),
                  leading: Hero(
                    tag: 'fav-image-${ad.id}',
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        image: ad.image != null
                            ? DecorationImage(image: NetworkImage(ad.image!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: ad.image == null ? Icon(Icons.pest_control_rodent, color: Colors.grey) : null,
                    ),
                  ),
                  title: Text(ad.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text(
                    "${ad.price} UZS\n${ad.city}",
                    style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, height: 1.5),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DetailScreen(ad: ad)),
                    ).then((_) => _loadFavorites());
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
