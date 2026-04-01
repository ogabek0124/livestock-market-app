import 'package:dio/dio.dart';
import '../models/ad_model.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, 127.0.0.1 for iOS/Web
  static const String _localBaseUrl = 'http://10.0.2.2:8000/api/v1'; // OR 'http://127.0.0.1:8000/api/v1'
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: _localBaseUrl, 
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<List<Ad>> fetchAds() async {
    try {
      final response = await _dio.get('/ads/');
      if (response.statusCode == 200 && response.data['success'] == true) {
        List data = response.data['data']['results'] ?? response.data['data'];
        return data.map((json) => Ad.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      // Handle error cleanly
      return [];
    }
  }

  Future<Ad?> getAdDetail(int id) async {
    try {
      final response = await _dio.get('/ads/$id/');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Ad.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      // Handle error cleanly
      return null;
    }
  }

  Future<bool> createAd({
    required String title,
    required String price,
    required String city,
    required String description,
    required String imagePath,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        "title": title,
        "price": price,
        "city": city,
        "description": description,
        "image": await MultipartFile.fromFile(imagePath),
      });

      // Passing Auth Token placeholder if authentication API token is stored later:
      // Options options = Options(headers: {'Authorization': 'Bearer YOUR_TOKEN'}); 

      final response = await _dio.post(
        '/ads/',
        data: formData,
        // options: options,
      );

      return response.statusCode == 201;
    } catch (e) {
      // Handle error cleanly
      return false;
    }
  }

  Future<bool> toggleFavorite(int adId, bool isAlreadyFavorite, {int? favoriteId}) async {
    try {
      if (isAlreadyFavorite && favoriteId != null) {
        // DELETE
        final response = await _dio.delete('/favorites/$favoriteId/');
        return response.statusCode == 204;
      } else {
        // POST
        final response = await _dio.post('/favorites/', data: {"ad_id": adId});
        return response.statusCode == 201;
      }
    } catch (e) {
      // Handle error cleanly
      return false;
    }
  }

  Future<List<Ad>> getFavorites() async {
    try {
      final response = await _dio.get('/favorites/');
      if (response.statusCode == 200 && response.data['success'] == true) {
        List data = response.data['data']['results'] ?? response.data['data'];
        return data.map<Ad>((json) => Ad.fromJson(json['ad_detail'])).toList();
      }
      return [];
    } catch (e) {
      // Handle error cleanly
      return [];
    }
  }
}
