class AppConfig {
  static const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  static bool get isDev => flavor == 'dev';
  static bool get isStaging => flavor == 'staging';
  static bool get isProd => flavor == 'prod';

  static String get nameSuffix {
    if (isProd) return '';
    if (isStaging) return ' • STG';
    return ' • DEV';
  }
}