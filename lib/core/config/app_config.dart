enum AppEnv { dev, staging, prod }

class AppConfig {
  static const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  static const contentBaseUrl = String.fromEnvironment(
    'CONTENT_BASE_URL',
    defaultValue: 'https://dewiest-aviator.github.io/habit_tracker',
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
