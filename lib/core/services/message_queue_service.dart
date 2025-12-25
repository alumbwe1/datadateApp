// import 'dart:async';

// import 'package:datadate/core/utils/custom_logs.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../features/chat/data/datasources/chat_remote_datasource.dart';
// import '../../features/chat/data/models/message_model.dart';
// import '../../features/chat/data/services/chat_local_storage_service.dart';
// import '../../features/chat/presentation/providers/chat_provider.dart';
// import '../providers/connectivity_provider.dart';

// class MessageQueueService {
//   static MessageQueueService? _instance;
//   static MessageQueueService get instance =>
//       _instance ??= MessageQueueService._();

//   MessageQueueService._();

//   Timer? _processingTimer;
//   bool _isProcessing = false;
//   late Ref _ref;

//   void initialize(Ref ref) {
//     _ref = ref;
//     _startPeriodicProcessing();

//     // Listen to connectivity changes
//     _ref.listen(connectionInfoProvider, (previous, next) {
//       next.whenData((connectionInfo) {
//         if (connectionInfo.isConnected && !_isProcessing) {
//           _processQueue();
//         }
//       });
//     });
//   }

//   void _startPeriodicProcessing() {
//     _processingTimer?.cancel();
//     _processingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
//       if (!_isProcessing) {
//         _processQueue();
//       }
//     });
//   }

//   Future<void> _processQueue() async {
//     if (_isProcessing) return;

//     _isProcessing = true;
//     CustomLogs.info('📤 Processing message queue...');

//     try {
//       final pendingMessages =
//           await ChatLocalStorageService.getPendingMessagesAll();

//       if (pendingMessages.isEmpty) {
//         CustomLogs.info('📤 No pending messages to process');
//         return;
//       }

//       CustomLogs.info('📤 Found ${pendingMessages.length} pending messages');

//       // Check connectivity
//       final connectionInfo = await _ref.read(connectionInfoProvider.future);
//       if (!connectionInfo.isConnected) {
//         CustomLogs.info('📤 No internet connection, skipping queue processing');
//         return;
//       }

//       final chatRemoteDataSource = _ref.read(chatRemoteDataSourceProvider);

//       for (final message in pendingMessages) {
//         if (message.status == MessageStatus.pending ||
//             message.status == MessageStatus.failed) {
//           await _sendPendingMessage(chatRemoteDataSource, message);

//           // Small delay between sends to avoid overwhelming the server
//           await Future.delayed(const Duration(milliseconds: 500));
//         }
//       }
//     } catch (e) {
//       CustomLogs.error('📤 Error processing message queue: $e');
//     } finally {
//       _isProcessing = false;
//     }
//   }

//   Future<void> _sendPendingMessage(
//     ChatRemoteDataSource chatRemoteDataSource,
//     MessageModel message,
//   ) async {
//     try {
//       CustomLogs.info('📤 Sending pending message: ${message.localId}');

//       // Update status to sending
//       await ChatLocalStorageService.updatePendingMessageStatus(
//         message.localId!,
//         MessageStatus.sending,
//       );

//       // Send message to server
//       final response = await chatRemoteDataSource.sendMessage(
//         roomId: message.room,
//         content: message.content,
//       );

//       // The response is directly a MessageModel, not wrapped in ApiResponse
//       CustomLogs.info(
//         '📤 Message sent successfully: ${message.localId} -> ${response.id}',
//       );

//       // Remove from pending queue
//       await ChatLocalStorageService.removePendingMessage(message.localId!);

//       // Add to regular cache with server ID
//       await ChatLocalStorageService.addMessageToCache(message.room, response);

//       // Notify UI about successful send
//       _notifyMessageSent(message.localId!, response);
//     } catch (e) {
//       CustomLogs.error(
//         '📤 Failed to send pending message ${message.localId}: $e',
//       );

//       // Update retry count and status
//       final newRetryCount = (message.retryCount ?? 0) + 1;

//       if (newRetryCount >= 3) {
//         // Max retries reached, mark as failed permanently
//         await ChatLocalStorageService.updatePendingMessageStatus(
//           message.localId!,
//           MessageStatus.failed,
//         );
//         CustomLogs.error(
//           '📤 Message ${message.localId} failed permanently after 3 retries',
//         );
//       } else {
//         // Mark as failed but will retry
//         await ChatLocalStorageService.updatePendingMessageStatus(
//           message.localId!,
//           MessageStatus.failed,
//         );
//       }
//     }
//   }

//   void _notifyMessageSent(String localId, MessageModel sentMessage) {
//     // This could trigger a provider refresh or use a stream controller
//     // For now, we'll rely on the periodic refresh in the chat detail provider
//     CustomLogs.info(
//       '📤 Notifying UI about sent message: $localId -> ${sentMessage.id}',
//     );
//   }

//   Future<void> queueMessage(MessageModel message) async {
//     CustomLogs.info(
//       '📤 Queuing message for offline sending: ${message.localId}',
//     );
//     await ChatLocalStorageService.addPendingMessage(message);

//     // Try to send immediately if online
//     final connectionInfo = await _ref.read(connectionInfoProvider.future);
//     if (connectionInfo.isConnected && !_isProcessing) {
//       _processQueue();
//     }
//   }

//   Future<void> retryFailedMessages() async {
//     CustomLogs.info('📤 Retrying failed messages...');

//     final pendingMessages =
//         await ChatLocalStorageService.getPendingMessagesAll();
//     final failedMessages = pendingMessages.where(
//       (msg) => msg.status == MessageStatus.failed,
//     );

//     for (final message in failedMessages) {
//       await ChatLocalStorageService.updatePendingMessageStatus(
//         message.localId!,
//         MessageStatus.pending,
//       );
//     }

//     if (failedMessages.isNotEmpty) {
//       _processQueue();
//     }
//   }

//   // Process queue immediately when connection is restored
//   Future<void> processQueueImmediately() async {
//     if (_isProcessing) return;

//     CustomLogs.info(
//       '📤 Processing queue immediately due to connection restore',
//     );
//     await _processQueue();
//   }

//   // Check if there are pending messages for a specific room
//   Future<bool> hasPendingMessages(int roomId) async {
//     final pendingMessages = await ChatLocalStorageService.getPendingMessages(
//       roomId,
//     );
//     return pendingMessages.isNotEmpty;
//   }

//   // Get count of pending messages for a specific room
//   Future<int> getPendingMessageCount(int roomId) async {
//     final pendingMessages = await ChatLocalStorageService.getPendingMessages(
//       roomId,
//     );
//     return pendingMessages.length;
//   }

//   void dispose() {
//     _processingTimer?.cancel();
//     _processingTimer = null;
//   }
// }

// // Provider for the message queue service
// final messageQueueServiceProvider = Provider<MessageQueueService>((ref) {
//   final service = MessageQueueService.instance;
//   service.initialize(ref);

//   ref.onDispose(() {
//     service.dispose();
//   });

//   return service;
// });
