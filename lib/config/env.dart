/// Environment configuration for the Secret Vault App.
///
/// HOW TO SET UP:
/// 1. Get your free TMDB API key at https://www.themoviedb.org/settings/api
/// 2. Replace the value of [tmdbApiKey] with your actual API key.
/// 3. Never commit your real API key to public repositories.
///
/// SECRET CODE:
/// Change [calculatorSecretCode] to your preferred unlock code.
/// The default is "1234". Only numbers are supported.
class Env {
  Env._();

  /// TMDB API key - replace with your own from https://www.themoviedb.org/settings/api
  static const String tmdbApiKey = '110ca354640ec0a1c6cdefe92391ab97';

  /// TMDB API base URL
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';

  /// TMDB image base URL
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p';

  /// Calculator secret unlock code.
  /// Change this to any numeric string you want to use as the password.
  /// Example: '9876' or '42' or '112358'
  static const String calculatorSecretCode = '1234';
}
