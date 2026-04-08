class UploadStore {
  UploadStore._();
  static final UploadStore instance = UploadStore._();

  final List<UploadedReport> reports = [];

  void add(UploadedReport report) => reports.add(report);
  void remove(int index) => reports.removeAt(index);
}

class UploadedReport {
  final String name;
  final int sizeKB;
  final String url;

  UploadedReport({required this.name, required this.sizeKB, required this.url});

  String get ext => name.split('.').last.toUpperCase();
  bool get isImage => ['JPG', 'JPEG', 'PNG'].contains(ext);
}
