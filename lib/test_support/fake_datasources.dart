import 'dart:typed_data';

import '../core/error/exceptions.dart';
import '../features/appointments/data/datasources/appointments_remote_datasource.dart';
import '../features/appointments/data/models/appointment_model.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/models/garage_service_item.dart';
import '../features/auth/data/models/registration_model.dart';
import '../features/auth/data/models/user_model.dart';
import '../features/availability/data/datasources/availability_remote_datasource.dart';
import '../features/availability/data/models/availability_slot_model.dart';
import '../features/notifications/data/datasources/notifications_remote_datasource.dart';
import '../features/notifications/data/models/notification_model.dart';
import '../features/notifications/domain/entities/notification_entity.dart';
import '../features/ratings/data/datasources/garage_ratings_remote_datasource.dart';
import '../features/ratings/data/models/garage_rating_model.dart';
import '../features/ratings/data/models/garage_reviews_response_model.dart';
import '../features/settings/data/datasources/garage_settings_remote_datasource.dart';

/// Credentials accepted by [FakeAuthRemoteDataSource] in E2E tests.
const kE2eTestEmail = 'e2e@test.garage';
const kE2eTestPassword = 'password123';

/// Shared fake garage user for integration tests.
UserModel get kE2eTestUser => const UserModel(
      id: 'garage-e2e-1',
      name: 'E2E Test Garage',
      email: kE2eTestEmail,
      phone: '+251911000000',
      address: 'Addis Ababa, Ethiopia',
      latitude: 9.03,
      longitude: 38.74,
      services: ['Oil Change', 'Brake Service'],
      garageStatus: 'ACTIVE',
    );

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  String? _token;
  UserModel _user = kE2eTestUser;
  final List<GarageServiceItem> _services = [
    const GarageServiceItem(id: 'svc-1', name: 'Oil Change'),
    const GarageServiceItem(id: 'svc-2', name: 'Brake Service'),
  ];

  @override
  String? get authToken => _token;

  @override
  void setAuthToken(String? token) => _token = token;

  @override
  void clearAuthToken() => _token = null;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (email == kE2eTestEmail && password == kE2eTestPassword) {
      _token = 'fake-e2e-token';
      return _user;
    }
    throw const ServerException('Invalid credentials');
  }

  @override
  Future<int?> requestGarageSignupOtp({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 30));
    return 123456;
  }

  @override
  Future<void> verifyGarageSignupOtp({
    required String email,
    required String code,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 30));
    if (code != '123456') throw const ServerException('Invalid OTP');
  }

  @override
  Future<UserModel> register(
    RegistrationModel registration, {
    Uint8List? licenseBytes,
    String? licenseFileName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    _user = UserModel(
      id: 'garage-new-1',
      name: registration.garageName,
      email: registration.email,
      phone: registration.phone,
      address: registration.address,
      services: registration.services,
      otherServices: registration.otherServices,
      garageStatus: 'PENDING',
    );
    _token = 'fake-e2e-token-new';
    return _user;
  }

  @override
  Future<UserModel?> getCurrentUser() async => _token == null ? null : _user;

  @override
  Future<UserModel> getProfile() async => _user;

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    _user = user;
    return _user;
  }

  @override
  Future<List<GarageServiceItem>> listGarageServices() async =>
      List.unmodifiable(_services);

  @override
  Future<GarageServiceItem> createGarageService(String name) async {
    final item = GarageServiceItem(id: 'svc-${_services.length + 1}', name: name);
    _services.add(item);
    return item;
  }

  @override
  Future<void> deleteGarageService(String serviceId) async {
    _services.removeWhere((s) => s.id == serviceId);
  }

  @override
  Future<void> replaceGarageServices(List<String> services) async {
    _services
      ..clear()
      ..addAll(
        services.asMap().entries.map(
              (e) => GarageServiceItem(id: 'svc-${e.key + 1}', name: e.value),
            ),
      );
    _user = UserModel(
      id: _user.id,
      name: _user.name,
      email: _user.email,
      phone: _user.phone,
      address: _user.address,
      latitude: _user.latitude,
      longitude: _user.longitude,
      placeId: _user.placeId,
      services: services,
      otherServices: _user.otherServices,
      garageStatus: _user.garageStatus,
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {}
}

class FakeAppointmentsRemoteDataSource implements AppointmentsRemoteDataSource {
  final List<AppointmentModel> _appointments = [
    AppointmentModel(
      id: 'appt-1',
      driverId: 'driver-1',
      garageId: 'garage-e2e-1',
      scheduledAt: DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      serviceDescription: 'Oil Change',
      status: 'PENDING',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      driverName: 'John Doe',
      driverPhone: '+251911111111',
      vehicleName: 'Toyota Corolla',
      plateNumber: 'AA-12345',
    ),
    AppointmentModel(
      id: 'appt-2',
      driverId: 'driver-2',
      garageId: 'garage-e2e-1',
      scheduledAt: DateTime.now().add(const Duration(days: 2)).toIso8601String(),
      serviceDescription: 'Brake Service',
      status: 'APPROVED',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      driverName: 'Jane Smith',
      driverPhone: '+251922222222',
      vehicleName: 'Honda Civic',
      plateNumber: 'BB-67890',
    ),
  ];

  @override
  Future<List<AppointmentModel>> listAppointments({
    String? status,
    String? search,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 30));
    var list = List<AppointmentModel>.from(_appointments);
    if (status != null && status.isNotEmpty) {
      list = list.where((a) => a.status.toUpperCase() == status.toUpperCase()).toList();
    }
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      list = list
          .where(
            (a) =>
                (a.driverName?.toLowerCase().contains(q) ?? false) ||
                a.serviceDescription.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  @override
  Future<AppointmentModel> getAppointment(String id) async {
    return _appointments.firstWhere((a) => a.id == id);
  }

  AppointmentModel _update(String id, String status) {
    final index = _appointments.indexWhere((a) => a.id == id);
    final current = _appointments[index];
    final updated = AppointmentModel(
      id: current.id,
      driverId: current.driverId,
      garageId: current.garageId,
      scheduledAt: current.scheduledAt,
      serviceDescription: current.serviceDescription,
      status: status,
      createdAt: current.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
      vehicleName: current.vehicleName,
      plateNumber: current.plateNumber,
      driverName: current.driverName,
      driverPhone: current.driverPhone,
      vehicles: current.vehicles,
    );
    _appointments[index] = updated;
    return updated;
  }

  @override
  Future<AppointmentModel> approveAppointment(String id) async =>
      _update(id, 'APPROVED');

  @override
  Future<AppointmentModel> rejectAppointment(String id) async =>
      _update(id, 'REJECTED');

  @override
  Future<AppointmentModel> updateStatus(String id, String status) async =>
      _update(id, status);
}

class FakeNotificationsRemoteDataSource implements NotificationsRemoteDataSource {
  final List<NotificationModel> _notifications = [
    NotificationModel(
      id: 'notif-1',
      type: NotificationType.general,
      title: 'New appointment request',
      body: 'John Doe requested an Oil Change',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      read: false,
    ),
    NotificationModel(
      id: 'notif-2',
      type: NotificationType.general,
      title: 'Appointment approved',
      body: 'Your appointment was confirmed',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      read: true,
    ),
  ];

  @override
  Future<List<NotificationModel>> listNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 30));
    return List.unmodifiable(_notifications);
  }

  @override
  Future<void> markNotificationRead(String notificationId) async {
    final i = _notifications.indexWhere((n) => n.id == notificationId);
    if (i >= 0) {
      final n = _notifications[i];
      _notifications[i] = NotificationModel(
        id: n.id,
        type: n.type,
        title: n.title,
        body: n.body,
        timestamp: n.timestamp,
        read: true,
      );
    }
  }

  @override
  Future<void> markAllNotificationsRead() async {
    for (var i = 0; i < _notifications.length; i++) {
      final n = _notifications[i];
      _notifications[i] = NotificationModel(
        id: n.id,
        type: n.type,
        title: n.title,
        body: n.body,
        timestamp: n.timestamp,
        read: true,
      );
    }
  }
}

class FakeAvailabilityRemoteDataSource implements AvailabilityRemoteDataSource {
  final List<AvailabilitySlotModel> _slots = [
    const AvailabilitySlotModel(
      id: 'slot-1',
      garageId: 'garage-e2e-1',
      dayOfWeek: 'MONDAY',
      startMinute: 540,
      endMinute: 1020,
      startTime: '09:00',
      endTime: '17:00',
    ),
    const AvailabilitySlotModel(
      id: 'slot-2',
      garageId: 'garage-e2e-1',
      dayOfWeek: 'WEDNESDAY',
      startMinute: 540,
      endMinute: 1020,
      startTime: '09:00',
      endTime: '17:00',
    ),
  ];

  @override
  Future<List<AvailabilitySlotModel>> listSlots({String? dayOfWeek}) async {
    await Future<void>.delayed(const Duration(milliseconds: 30));
    if (dayOfWeek == null) return List.unmodifiable(_slots);
    return _slots.where((s) => s.dayOfWeek == dayOfWeek).toList();
  }

  @override
  Future<AvailabilitySlotModel> createSlot({
    required String dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    final slot = AvailabilitySlotModel(
      id: 'slot-${_slots.length + 1}',
      garageId: 'garage-e2e-1',
      dayOfWeek: dayOfWeek,
      startMinute: 540,
      endMinute: 1020,
      startTime: startTime,
      endTime: endTime,
    );
    _slots.add(slot);
    return slot;
  }

  @override
  Future<AvailabilitySlotModel> updateSlot(
    String id, {
    String? dayOfWeek,
    String? startTime,
    String? endTime,
  }) async {
    final index = _slots.indexWhere((s) => s.id == id);
    final current = _slots[index];
    final updated = AvailabilitySlotModel(
      id: current.id,
      garageId: current.garageId,
      dayOfWeek: dayOfWeek ?? current.dayOfWeek,
      startMinute: current.startMinute,
      endMinute: current.endMinute,
      startTime: startTime ?? current.startTime,
      endTime: endTime ?? current.endTime,
    );
    _slots[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteSlot(String id) async {
    _slots.removeWhere((s) => s.id == id);
  }
}

class FakeGarageSettingsRemoteDataSource implements GarageSettingsRemoteDataSource {
  final Map<String, dynamic> _settings = {
    'onsiteServiceEnabled': false,
    'notificationsEnabled': true,
  };

  @override
  Future<Map<String, dynamic>> getSettings() async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return Map<String, dynamic>.from(_settings);
  }

  @override
  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> patch) async {
    _settings.addAll(patch);
    return Map<String, dynamic>.from(_settings);
  }
}

class FakeGarageRatingsRemoteDataSource implements GarageRatingsRemoteDataSource {
  @override
  Future<GarageReviewsResponseModel> getMyReviews() async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return GarageReviewsResponseModel(
      averageRating: 4.5,
      totalRatings: 2,
      reviews: [
        GarageRatingModel(
          id: 'rating-1',
          rating: 5,
          comment: 'Great service',
          driverName: 'John Doe',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        GarageRatingModel(
          id: 'rating-2',
          rating: 4,
          comment: 'Fast and professional',
          driverName: 'Jane Smith',
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
      ],
    );
  }
}
