import '../../domain/entities/registration_entity.dart';

/// Registration model for API/serialization.
/// Backend expects multipart: garage_name, phone_number, email, password, confirm_password,
/// garage_location (JSON), services_offered (slugs), other_services?, business_license_document (file).
class RegistrationModel extends RegistrationEntity {
  const RegistrationModel({
    required super.garageName,
    required super.phone,
    required super.email,
    required super.password,
    required super.confirmPassword,
    required super.address,
    required super.services,
    super.otherServices,
    super.businessLicensePath,
    super.latitude,
    super.longitude,
    super.placeId,
  });

  factory RegistrationModel.fromEntity(RegistrationEntity entity) {
    return RegistrationModel(
      garageName: entity.garageName,
      phone: entity.phone,
      email: entity.email,
      password: entity.password,
      confirmPassword: entity.confirmPassword,
      address: entity.address,
      services: List.from(entity.services),
      otherServices: entity.otherServices,
      businessLicensePath: entity.businessLicensePath,
      latitude: entity.latitude,
      longitude: entity.longitude,
      placeId: entity.placeId,
    );
  }
}
