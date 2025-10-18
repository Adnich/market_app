import 'package:injectable/injectable.dart';
import 'package:image_picker/image_picker.dart';

@module
abstract class UtilityModule {
 
  @lazySingleton
  ImagePicker get imagePicker => ImagePicker();
}
