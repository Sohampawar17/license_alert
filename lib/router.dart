import 'package:license_alert/screens/home/home_screen.dart';
import 'package:license_alert/screens/login_screen/login_screen.dart';
import 'package:license_alert/screens/profile/profile_screen.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'screens/sign_up/sign_up_screen.dart';
import 'screens/splash_screen.dart';

@StackedApp(
  routes: [
    MaterialRoute(page: SplashScreen, initial: true),
    MaterialRoute(page: LoginPage),
    MaterialRoute(page: HomeScreen),
    MaterialRoute(page:SignUpPage),
    MaterialRoute(page: ProfilePage)

  
  ],
  dependencies: [
    Singleton(classType: NavigationService),
  ],
)
class App {
  //empty class, will be filled after code generation
}
// flutter pub run build_runner build --delete-conflicting-outputs
