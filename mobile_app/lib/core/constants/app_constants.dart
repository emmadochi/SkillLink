abstract class AppConstants {
  static const String appName    = 'SkillLink';
  static const String baseUrl    = 'https://skilllink.gulfmexicooffshorerig.com/api/v1/'; // Production with trailing slash
  // static const String baseUrl = 'http://192.168.100.62/SkillLink/api/v1'; // Local Dev
  static const String apiVersion = 'v1';

  // Shared Pref Keys
  static const String keyToken        = 'auth_token';
  static const String keyUserRole     = 'user_role';
  static const String keyOnboarded    = 'is_onboarded';
  static const String keyUserId       = 'user_id';

  // Artisan ratings
  static const int maxRating = 5;

  // Pagination
  static const int defaultPageSize = 20;

  // Animation durations
  static const int splashDuration   = 2500; // ms
  static const int defaultAnimMs    = 300;

  // Service categories
  static const List<String> serviceCategories = [
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Cleaning',
    'Painting',
    'Tiling',
    'Welding',
    'AC Repair',
    'Landscaping',
    'Moving',
  ];
}
