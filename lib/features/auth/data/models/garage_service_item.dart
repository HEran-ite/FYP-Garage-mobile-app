/// One garage service from backend GET /garages/me/services.
class GarageServiceItem {
  const GarageServiceItem({required this.id, required this.name});

  final String id;
  final String name;

  static GarageServiceItem fromJson(Map<String, dynamic> json) {
    return GarageServiceItem(
      id: (json['id']?.toString() ?? '').toString(),
      name: (json['name'] as String? ?? '').trim(),
    );
  }
}
