import 'package:flutter/material.dart';
import '../../data/models/ad_model.dart';
import '../../data/services/api_service.dart';
import '../ad_detail/detail_screen.dart';
import '../add_post/add_post_screen.dart';
import '../favorites/favorites_screen.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Ad>> _adsFuture;

  @override
  void initState() {
    super.initState();
    _adsFuture = _apiService.fetchAds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chorva Bozori', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            color: Colors.redAccent,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => FavoritesScreen()));
            },
          )
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              accountName: Text("Foydalanuvchi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              accountEmail: Text("+998 90 123 45 67"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.blueAccent),
              ),
            ),
            Spacer(),
            ListTile(
              leading: Icon(Icons.info_outline, color: Colors.grey),
              title: Text("Version 1.0"),
              subtitle: Text("🔥 Built with Flutter & Django\n👨‍💻 PRO Level Architecture"),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      body: FutureBuilder<List<Ad>>(
        future: _adsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          } else if (snapshot.hasError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Xatolik! Qayta urinib ko'ring."),
                backgroundColor: Colors.redAccent,
              ));
            });
            return Center(child: Text("Internet yoki serverda xatolik!", style: TextStyle(fontSize: 16)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("E'lonlar topilmadi"));
          }

          final ads = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: ads.length,
            itemBuilder: (context, index) {
              final ad = ads[index];
              return Card(
                elevation: 4,
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: Hero(
                    tag: 'ad-image-${ad.id}',
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
                      child: ad.image == null ? Icon(Icons.pets, color: Colors.grey) : null,
                    ),
                  ),
                  title: Text(ad.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text("${ad.price} UZS", style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(ad.city, style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Spacer(),
                          Icon(Icons.remove_red_eye, size: 14, color: Colors.grey),
                          SizedBox(width: 4),
                          Text("${ad.views}", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      )
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(ad: ad),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddPostScreen()),
          );
          if (result == true) {
            // Refresh ads if a new post was created successfully
            setState(() {
              _adsFuture = _apiService.fetchAds();
            });
          }
        },
        backgroundColor: Colors.blueAccent,
        icon: Icon(Icons.add),
        label: Text("E'lon berish"),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              height: 120,
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(width: 80, height: 80, color: Colors.white, padding: EdgeInsets.all(8)),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: double.infinity, height: 16, color: Colors.white),
                        SizedBox(height: 10),
                        Container(width: 100, height: 16, color: Colors.white),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
