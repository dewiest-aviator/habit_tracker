enum AppEnv { dev, staging, prod }

class AppConfig {
  static const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  static const contentBaseUrl = String.fromEnvironment(
    'CONTENT_BASE_URL',
    defaultValue: 'https://dewiest-aviator.github.io/habit_tracker',
  );
  static const appStoreUrl = String.fromEnvironment(
    'APP_STORE_URL',
    defaultValue: 'https://apps.apple.com/app/id0000000000',
  );
  static const playStoreUrl = String.fromEnvironment(
    'PLAY_STORE_URL',
    defaultValue: 'https://play.google.com/store/apps/details?id=com.example.habit',
  );
  static const supportEmail = String.fromEnvironment(
    'SUPPORT_EMAIL',
    defaultValue: 'support@habittracker.app',
  );

  static AppEnv get environment {
    switch (flavor) {
      case 'prod':
        return AppEnv.prod;
      case 'staging':
        return AppEnv.staging;
      default:
        return AppEnv.dev;
    }
  }

  static String get nameSuffix {
    switch (environment) {
      case AppEnv.prod:
        return '';
      case AppEnv.staging:
        return ' • STG';
      case AppEnv.dev:
        return ' • DEV';
    }
  }
}
