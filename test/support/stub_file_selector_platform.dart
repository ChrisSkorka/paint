import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

class StubFileSelectorPlatform extends FileSelectorPlatform {
  StubFileSelectorPlatform({this.openedFile, this.saveLocation});

  final XFile? openedFile;
  final FileSaveLocation? saveLocation;
  final openRequests = <List<String>?>[];
  final saveRequests = <List<Object?>>[];

  @override
  Future<XFile?> openFile({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    openRequests.add(acceptedTypeGroups?.single.extensions);
    return openedFile;
  }

  @override
  Future<FileSaveLocation?> getSaveLocation({
    List<XTypeGroup>? acceptedTypeGroups,
    SaveDialogOptions options = const SaveDialogOptions(),
  }) async {
    saveRequests.add([
      acceptedTypeGroups?.single.label,
      acceptedTypeGroups?.single.extensions,
      options.suggestedName,
    ]);
    return saveLocation;
  }
}
