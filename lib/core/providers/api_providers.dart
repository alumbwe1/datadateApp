import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/api_client.dart';
import '../network/websocket_service.dart';

/// Secure storage provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// API Client provider - singleton instance
final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return ApiClient(secureStorage: secureStorage);
});

/// Dio provider - provides the Dio instance from ApiClient
final dioProvider = Provider<Dio>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return apiClient.dio;
});

/// WebSocket service provider
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return WebSocketService(secureStorage: secureStorage);
});
