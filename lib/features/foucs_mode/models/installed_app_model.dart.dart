import 'dart:typed_data';

class InstalledAppModel {
  final String name;
  final String packageName;
  final Uint8List? icon;
  bool selected;

  InstalledAppModel({
    required this.name,
    required this.packageName,
    this.icon,
    this.selected = false,
  });

  InstalledAppModel copyWith({bool? selected}) {
    return InstalledAppModel(
      name: name,
      packageName: packageName,
      icon: icon,
      selected: selected ?? this.selected,
    );
  }
}
