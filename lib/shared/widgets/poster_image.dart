import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:secret_vault_app/core/constants/app_constants.dart';

/// Reusable cached poster/backdrop image widget with loading shimmer and error fallback.
class PosterImage extends StatelessWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool isBackdrop;

  const PosterImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.isBackdrop = false,
  });

  @override
  Widget build(BuildContext context) {
    final url = isBackdrop
        ? AppConstants.backdropUrl(imagePath)
        : AppConstants.posterUrl(imagePath);

    if (url.isEmpty) {
      return _buildPlaceholder();
    }

    final image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => _buildShimmer(),
      errorWidget: (context, url, error) => _buildPlaceholder(),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF2A2A2A),
      highlightColor: const Color(0xFF3A3A3A),
      child: Container(
        width: width,
        height: height,
        color: const Color(0xFF2A2A2A),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFF2A2A2A),
      child: const Center(
        child: Icon(Icons.movie_outlined, color: Color(0xFF505050), size: 40),
      ),
    );
  }
}
