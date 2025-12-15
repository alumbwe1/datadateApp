import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';
import '../utils/custom_logs.dart';
import '../widgets/adaptive_loading_state.dart';

class ImageCacheService {
  static final CacheManager _cacheManager = CacheManager(
    Config(
      'dating_app_images',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 200,
      repo: JsonCacheInfoRepository(databaseName: 'dating_app_images'),
      fileService: HttpFileService(),
    ),
  );

  /// Preload images for better performance
  static Future<void> preloadImages(List<String> imageUrls) async {
    try {
      final futures = imageUrls.map((url) => _cacheManager.downloadFile(url));
      await Future.wait(futures);

      CustomLogs.info(
        'Preloaded ${imageUrls.length} images',
        tag: 'IMAGE_CACHE',
      );
    } catch (e) {
      CustomLogs.error(
        'Failed to preload images: $e',
        tag: 'IMAGE_CACHE',
        error: e,
      );
    }
  }

  /// Clear image cache
  static Future<void> clearCache() async {
    try {
      await _cacheManager.emptyCache();
      CustomLogs.info('Image cache cleared', tag: 'IMAGE_CACHE');
    } catch (e) {
      CustomLogs.error(
        'Failed to clear image cache: $e',
        tag: 'IMAGE_CACHE',
        error: e,
      );
    }
  }

  /// Get cache size
  static Future<int> getCacheSize() async {
    try {
      final cacheInfo = await _cacheManager.getFileFromCache('');
      return cacheInfo?.file.lengthSync() ?? 0;
    } catch (e) {
      CustomLogs.error(
        'Failed to get cache size: $e',
        tag: 'IMAGE_CACHE',
        error: e,
      );
      return 0;
    }
  }

  /// Optimized cached network image widget
  static Widget buildCachedImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Widget? placeholder,
    Widget? errorWidget,
    bool enableMemoryCache = true,
    Duration? fadeInDuration,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        cacheManager: _cacheManager,
        memCacheWidth: width?.toInt(),
        memCacheHeight: height?.toInt(),
        fadeInDuration: fadeInDuration ?? const Duration(milliseconds: 300),
        placeholder: (context, url) =>
            placeholder ?? _buildPlaceholder(width, height),
        errorWidget: (context, url, error) =>
            errorWidget ?? _buildErrorWidget(width, height),
        imageBuilder: (context, imageProvider) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              image: DecorationImage(image: imageProvider, fit: fit),
            ),
          );
        },
      ),
    );
  }

  /// Profile image with optimized caching
  static Widget buildProfileImage({
    required String imageUrl,
    double size = 100,
    bool showBorder = true,
    Color? borderColor,
    double borderWidth = 2,
  }) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: borderColor ?? AppColors.primaryLight,
                width: borderWidth.w,
              )
            : null,
      ),
      child: ClipOval(
        child: buildCachedImage(
          imageUrl: imageUrl,
          width: size.w,
          height: size.w,
          fit: BoxFit.cover,
          placeholder: _buildProfilePlaceholder(size),
          errorWidget: _buildProfileErrorWidget(size),
        ),
      ),
    );
  }

  /// Gallery image with lazy loading
  static Widget buildGalleryImage({
    required String imageUrl,
    required double width,
    required double height,
    VoidCallback? onTap,
    bool showOverlay = false,
    Widget? overlayWidget,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          buildCachedImage(
            imageUrl: imageUrl,
            width: width,
            height: height,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(8.r),
          ),
          if (showOverlay && overlayWidget != null)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                  ),
                ),
                child: overlayWidget,
              ),
            ),
        ],
      ),
    );
  }

  static Widget _buildPlaceholder(double? width, double? height) {
    return Container(
      width: width?.w,
      height: height?.h,
      color: Colors.grey[300],
      child: const AdaptiveLoadingState(
        type: LoadingType.shimmer,
        showMessage: false,
      ),
    );
  }

  static Widget _buildErrorWidget(double? width, double? height) {
    return Container(
      width: width?.w,
      height: height?.h,
      color: Colors.grey[200],
      child: Icon(
        Icons.error_outline,
        size: (width != null && height != null)
            ? (width < height ? width : height) * 0.3
            : 24.w,
        color: Colors.grey[400],
      ),
    );
  }

  static Widget _buildProfilePlaceholder(double size) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey,
      ),
      child: Icon(Icons.person, size: size.w * 0.6, color: Colors.white),
    );
  }

  static Widget _buildProfileErrorWidget(double size) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
      ),
      child: Icon(Icons.person, size: size.w * 0.6, color: Colors.grey[600]),
    );
  }
}

/// Extension for easy image preloading
extension ImagePreloading on List<String> {
  Future<void> preloadImages() async {
    await ImageCacheService.preloadImages(this);
  }
}
