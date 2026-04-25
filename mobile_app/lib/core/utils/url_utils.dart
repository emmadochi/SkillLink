import '../constants/app_constants.dart';

class UrlUtils {
  static String resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return 'https://i.pravatar.cc/300'; // Default fallback
    }

    if (path.startsWith('http')) {
      return path;
    }

    // Standardize path: remove leading slashes if any
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    
    // The media root is generally the 'api/public' directory
    // We derive it from baseUrl which is '.../api/v1/'
    final apiRoot = AppConstants.baseUrl.replaceAll('/v1/', '');
    final mediaBase = '$apiRoot/public/';
    
    return '$mediaBase$cleanPath';
  }
}
