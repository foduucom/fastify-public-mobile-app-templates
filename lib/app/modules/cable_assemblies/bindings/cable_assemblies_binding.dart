import 'package:get/get.dart';
import '../controllers/cable_assemblies_controller.dart';

class CableAssembliesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CableAssembliesController>(() => CableAssembliesController());
  }
}
