class InstalledAppModel {
  final String name;
  final String packageName;
  final double usageMinutes;
  bool selected;

  InstalledAppModel({
    required this.name,
    required this.packageName,
    this.usageMinutes = 0,
    this.selected = false,
  });

  InstalledAppModel copyWith({bool? selected}) {
    return InstalledAppModel(
      name: name,
      packageName: packageName,
      usageMinutes: usageMinutes,
      selected: selected ?? this.selected,
    );
  }
}
