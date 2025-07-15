class AppConstants {
  // API URLs
  static const String baseUrl = 'https://api.yourcompany.com';
  static const String apiVersion = '/v1';
  
  // Database
  static const String databaseName = 'sales_app.db';
  static const int databaseVersion = 1;
  
  // Cache
  static const Duration cacheTimeout = Duration(minutes: 30);
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Error messages
  static const String networkErrorMessage = 'Network connection failed';
  static const String serverErrorMessage = 'Server error occurred';
  static const String unknownErrorMessage = 'An unknown error occurred';
} 