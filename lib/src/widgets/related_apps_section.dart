import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/related_apps.dart';
import '../selekt_sdk.dart';

typedef RelatedAppTap = Future<void> Function(RelatedApp app);

class RelatedAppsSection extends StatefulWidget {
  const RelatedAppsSection({
    this.sdk,
    this.future,
    this.feed,
    this.onAppTap,
    this.margin = EdgeInsets.zero,
    this.spacing = 12,
    this.empty = const SizedBox.shrink(),
    this.loading,
    super.key,
  }) : assert(
         sdk != null || future != null || feed != null,
         'Provide sdk, future, or feed',
       );

  final SelektSdk? sdk;
  final Future<RelatedAppsFeed>? future;
  final RelatedAppsFeed? feed;
  final RelatedAppTap? onAppTap;
  final EdgeInsetsGeometry margin;
  final double spacing;
  final Widget empty;
  final Widget? loading;

  @override
  State<RelatedAppsSection> createState() => _RelatedAppsSectionState();
}

class _RelatedAppsSectionState extends State<RelatedAppsSection> {
  Future<RelatedAppsFeed>? _feedFuture;

  @override
  void initState() {
    super.initState();
    _feedFuture = widget.feed == null
        ? widget.future ?? widget.sdk?.getRelatedApps()
        : null;
  }

  @override
  void didUpdateWidget(covariant RelatedAppsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.feed == null &&
        (oldWidget.sdk != widget.sdk || oldWidget.future != widget.future)) {
      _feedFuture = widget.future ?? widget.sdk?.getRelatedApps();
    }
    if (widget.feed != null && oldWidget.feed != widget.feed) {
      _feedFuture = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final feed = widget.feed;
    if (feed != null) {
      return _RelatedAppsBlocks(
        feed: feed,
        margin: widget.margin,
        spacing: widget.spacing,
        empty: widget.empty,
        onAppTap: widget.onAppTap,
      );
    }

    return FutureBuilder<RelatedAppsFeed>(
      future: _feedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loading ?? _RelatedAppsLoading(margin: widget.margin);
        }
        final data = snapshot.data;
        if (snapshot.hasError || data == null) {
          return widget.empty;
        }
        return _RelatedAppsBlocks(
          feed: data,
          margin: widget.margin,
          spacing: widget.spacing,
          empty: widget.empty,
          onAppTap: widget.onAppTap,
        );
      },
    );
  }
}

class _RelatedAppsBlocks extends StatelessWidget {
  const _RelatedAppsBlocks({
    required this.feed,
    required this.margin,
    required this.spacing,
    required this.empty,
    required this.onAppTap,
  });

  final RelatedAppsFeed feed;
  final EdgeInsetsGeometry margin;
  final double spacing;
  final Widget empty;
  final RelatedAppTap? onAppTap;

  @override
  Widget build(BuildContext context) {
    final blocks = feed.blocks
        .where((block) => block.apps.isNotEmpty)
        .toList(growable: false);
    if (blocks.isEmpty) {
      return empty;
    }

    return Padding(
      padding: margin,
      child: Column(
        children: [
          for (var index = 0; index < blocks.length; index++) ...[
            if (blocks[index].isBanner)
              _RelatedAppsBanner(block: blocks[index], onAppTap: onAppTap)
            else
              _RelatedAppsGrid(block: blocks[index], onAppTap: onAppTap),
            if (index != blocks.length - 1) SizedBox(height: spacing),
          ],
        ],
      ),
    );
  }
}

class _RelatedAppsBanner extends StatelessWidget {
  const _RelatedAppsBanner({required this.block, required this.onAppTap});

  final RelatedAppsBlock block;
  final RelatedAppTap? onAppTap;

  @override
  Widget build(BuildContext context) {
    final app = block.apps.first;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return _PressableSurface(
      onTap: () => _openApp(app, onAppTap),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          children: [
            _RelatedAppIcon(app: app, size: 56),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    block.title ?? 'Другие приложения',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _appTitle(app),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  if ((app.shortDescription ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      app.shortDescription!.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _RelatedAppsGrid extends StatelessWidget {
  const _RelatedAppsGrid({required this.block, required this.onAppTap});

  final RelatedAppsBlock block;
  final RelatedAppTap? onAppTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final apps = block.apps.toList(growable: false);
    final columns = block.columns.clamp(1, 4);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            block.title ?? 'Другие приложения',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: apps.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              final app = apps[index];
              return _PressableSurface(
                onTap: () => _openApp(app, onAppTap),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _RelatedAppIcon(app: app, size: 44),
                      const SizedBox(height: 8),
                      Text(
                        _appTitle(app),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                          height: 1.12,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RelatedAppIcon extends StatelessWidget {
  const _RelatedAppIcon({required this.app, required this.size});

  final RelatedApp app;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final imageUrl = app.imageUrl?.trim() ?? '';
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: Container(
        width: size,
        height: size,
        color: colors.primaryContainer,
        child: imageUrl.isEmpty
            ? Icon(Icons.apps_rounded, color: colors.onPrimaryContainer)
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.apps_rounded, color: colors.onPrimaryContainer),
              ),
      ),
    );
  }
}

class _RelatedAppsLoading extends StatelessWidget {
  const _RelatedAppsLoading({required this.margin});

  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: margin,
      child: Container(
        height: 92,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.outlineVariant),
        ),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _PressableSurface extends StatelessWidget {
  const _PressableSurface({
    required this.child,
    required this.borderRadius,
    this.onTap,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: borderRadius, child: child),
    );
  }
}

String _appTitle(RelatedApp app) {
  final displayName = app.displayName?.trim() ?? '';
  if (displayName.isNotEmpty) {
    return displayName;
  }
  final title = app.title.trim();
  return title.isEmpty ? app.name : title;
}

Future<void> _openApp(RelatedApp app, RelatedAppTap? onAppTap) async {
  if (onAppTap != null) {
    await onAppTap(app);
    return;
  }
  final url = app.ruStoreUrl?.trim() ?? '';
  if (url.isEmpty) {
    return;
  }
  final uri = Uri.tryParse(url);
  if (uri == null) {
    return;
  }
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
