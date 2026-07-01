import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:secret_vault_app/core/theme/app_theme.dart';

// ─── Player settings model ────────────────────────────────────────────────────

/// Holds vidsrc.sbs URL customisation query parameters.
class VidsrcPlayerSettings {
  final bool autoplay;
  final String accentColor;
  final String subtitleLang;
  final int startAt;
  final bool showControls;

  const VidsrcPlayerSettings({
    this.autoplay = true,
    this.accentColor = 'e50914',
    this.subtitleLang = '',
    this.startAt = 0,
    this.showControls = true,
  });

  VidsrcPlayerSettings copyWith({
    bool? autoplay,
    String? accentColor,
    String? subtitleLang,
    int? startAt,
    bool? showControls,
  }) =>
      VidsrcPlayerSettings(
        autoplay: autoplay ?? this.autoplay,
        accentColor: accentColor ?? this.accentColor,
        subtitleLang: subtitleLang ?? this.subtitleLang,
        startAt: startAt ?? this.startAt,
        showControls: showControls ?? this.showControls,
      );

  String toQueryString() {
    final params = <String>[];
    if (autoplay) params.add('autoplay=1');
    if (accentColor.isNotEmpty) params.add('color=$accentColor');
    if (subtitleLang.isNotEmpty) params.add('sub=$subtitleLang');
    if (startAt > 0) params.add('t=$startAt');
    if (!showControls) params.add('controls=0');
    return params.isEmpty ? '' : '?${params.join('&')}';
  }
}

// ─── VidsrcPlayerPage ─────────────────────────────────────────────────────────

/// In-app streaming player powered by vidsrc.sbs.
/// Has a proper AppBar with back button and title so content stays below it.
///
/// ⚠️  This player embeds a third-party site. Content availability is not
///     guaranteed. The app does not host any media files.
class VidsrcPlayerPage extends StatefulWidget {
  final int tmdbId;
  final String title;
  final bool isMovie;
  final int season;
  final int episode;

  const VidsrcPlayerPage({
    super.key,
    required this.tmdbId,
    required this.title,
    this.isMovie = true,
    this.season = 1,
    this.episode = 1,
  });

  String get baseEmbedUrl {
    if (isMovie) return 'https://vidsrc.sbs/embed/movie/$tmdbId';
    return 'https://vidsrc.sbs/embed/tv/$tmdbId/$season/$episode';
  }

  @override
  State<VidsrcPlayerPage> createState() => _VidsrcPlayerPageState();
}

class _VidsrcPlayerPageState extends State<VidsrcPlayerPage> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  VidsrcPlayerSettings _settings = const VidsrcPlayerSettings();

  static const _chromeUA =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
      'AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/124.0.0.0 Safari/537.36';

  String get _embedUrl => '${widget.baseEmbedUrl}${_settings.toQueryString()}';

  String get _appBarTitle => widget.isMovie
      ? widget.title
      : '${widget.title}  S${widget.season}:E${widget.episode}';

  @override
  void initState() {
    super.initState();
    _buildController();
  }

  void _buildController() {
    late final PlatformWebViewControllerCreationParams params;

    if (Platform.isIOS) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const {},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setUserAgent(_chromeUA)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() { _isLoading = true; _hasError = false; });
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            if ((error.isForMainFrame ?? true) && mounted) {
              setState(() { _isLoading = false; _hasError = true; });
            }
          },
          onNavigationRequest: (request) {
            final host = Uri.tryParse(request.url)?.host ?? '';
            if (host.contains('vidsrc') || host.isEmpty) {
              return NavigationDecision.navigate;
            }
            if (!request.isMainFrame) return NavigationDecision.navigate;
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(_embedUrl));

    if (Platform.isAndroid) {
      final androidCtrl = _controller.platform as AndroidWebViewController;
      AndroidWebViewController.enableDebugging(false);
      androidCtrl.setMediaPlaybackRequiresUserGesture(false);
    }
  }

  void _reload() {
    setState(() { _isLoading = true; _hasError = false; });
    _controller.loadRequest(Uri.parse(_embedUrl));
  }

  void _applySettings(VidsrcPlayerSettings s) {
    setState(() => _settings = s);
    _reload();
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _PlayerSettingsSheet(
        current: _settings,
        onApply: (updated) {
          Navigator.pop(context);
          _applySettings(updated);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // ── Proper AppBar with back button — content naturally stays below ──
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
          tooltip: 'Back',
        ),
        title: Text(
          _appBarTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: _openSettings,
            tooltip: 'Player settings',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _reload,
            tooltip: 'Reload player',
          ),
        ],
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        children: [
          // ── WebView fills the body (below AppBar) ────────────────────────
          Positioned.fill(
            child: _hasError
                ? _ErrorView(onRetry: _reload)
                : WebViewWidget(controller: _controller),
          ),

          // ── Loading spinner ───────────────────────────────────────────────
          if (_isLoading && !_hasError)
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppTheme.primary),
                      SizedBox(height: 16),
                      Text(
                        'Loading player…',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Error view ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Could not load the player.',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 6),
            const Text(
              'Check your internet connection\nor try again later.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              icon: const Icon(Icons.refresh, color: Colors.black),
              label: const Text('Retry', style: TextStyle(color: Colors.black)),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Player Settings Sheet ────────────────────────────────────────────────────

class _PlayerSettingsSheet extends StatefulWidget {
  final VidsrcPlayerSettings current;
  final void Function(VidsrcPlayerSettings) onApply;

  const _PlayerSettingsSheet({required this.current, required this.onApply});

  @override
  State<_PlayerSettingsSheet> createState() => _PlayerSettingsSheetState();
}

class _PlayerSettingsSheetState extends State<_PlayerSettingsSheet> {
  late bool _autoplay;
  late bool _showControls;
  final _accentCtrl = TextEditingController();
  final _subCtrl = TextEditingController();
  final _startAtCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final s = widget.current;
    _autoplay = s.autoplay;
    _showControls = s.showControls;
    _accentCtrl.text = s.accentColor;
    _subCtrl.text = s.subtitleLang;
    _startAtCtrl.text = s.startAt > 0 ? '${s.startAt}' : '';
  }

  @override
  void dispose() {
    _accentCtrl.dispose();
    _subCtrl.dispose();
    _startAtCtrl.dispose();
    super.dispose();
  }

  void _apply() => widget.onApply(VidsrcPlayerSettings(
        autoplay: _autoplay,
        accentColor: _accentCtrl.text.trim().replaceAll('#', ''),
        subtitleLang: _subCtrl.text.trim().toLowerCase(),
        startAt: int.tryParse(_startAtCtrl.text.trim()) ?? 0,
        showControls: _showControls,
      ));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.tune, color: AppTheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Player Settings',
                  style: TextStyle(
                    color: AppTheme.onBackground,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _apply,
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                        color: AppTheme.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(color: AppTheme.background),

            _SwitchRow(
              icon: Icons.play_arrow,
              label: 'Autoplay',
              hint: '?autoplay=1',
              value: _autoplay,
              onChanged: (v) => setState(() => _autoplay = v),
            ),
            _SwitchRow(
              icon: Icons.videocam_outlined,
              label: 'Show controls',
              hint: '?controls=0 hides them',
              value: _showControls,
              onChanged: (v) => setState(() => _showControls = v),
            ),
            const SizedBox(height: 12),

            _FieldLabel(
              icon: Icons.color_lens_outlined,
              label: 'Accent colour (hex, no #)',
              hint: '?color=e50914',
            ),
            TextField(
              controller: _accentCtrl,
              style: const TextStyle(color: AppTheme.onBackground),
              decoration: _dec('e.g. e50914'),
              maxLength: 6,
            ),
            const SizedBox(height: 8),

            _FieldLabel(
              icon: Icons.subtitles_outlined,
              label: 'Subtitle language (ISO 639-1)',
              hint: '?sub=en',
            ),
            TextField(
              controller: _subCtrl,
              style: const TextStyle(color: AppTheme.onBackground),
              decoration: _dec('e.g. en, th, ja'),
              maxLength: 5,
            ),
            const SizedBox(height: 8),

            _FieldLabel(
              icon: Icons.access_time,
              label: 'Start at (seconds)',
              hint: '?t=120',
            ),
            TextField(
              controller: _startAtCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.onBackground),
              decoration: _dec('e.g. 120 — blank = from beginning'),
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'URL preview: ...${VidsrcPlayerSettings(
                  autoplay: _autoplay,
                  accentColor: _accentCtrl.text.trim().replaceAll('#', ''),
                  subtitleLang: _subCtrl.text.trim(),
                  startAt: int.tryParse(_startAtCtrl.text.trim()) ?? 0,
                  showControls: _showControls,
                ).toQueryString()}',
                style: const TextStyle(
                  color: AppTheme.onSurfaceVariant,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12),
        filled: true,
        fillColor: AppTheme.background,
        counterStyle: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      );
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: AppTheme.onBackground, fontSize: 14)),
                  Text(hint,
                      style: const TextStyle(
                          color: AppTheme.onSurfaceVariant, fontSize: 11)),
                ],
              ),
            ),
            Switch(
                value: value,
                activeColor: AppTheme.primary,
                onChanged: onChanged),
          ],
        ),
      );
}

class _FieldLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;

  const _FieldLabel({
    required this.icon,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: AppTheme.onBackground, fontSize: 13)),
                  Text(hint,
                      style: const TextStyle(
                          color: AppTheme.onSurfaceVariant, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      );
}
