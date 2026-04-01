import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

const double kAeroPageBottomSpacing = 16.0;

class AeroPageScaffold extends HookWidget {
  const AeroPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.showBackButton = false,
    this.onBack,
    this.largeTitle = true,
    this.bodyTopPadding = 16,
    this.bodyBottomPadding,
    this.contentMaxWidth,
    this.scrollViewKey,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBack;
  final bool largeTitle;
  final double bodyTopPadding;
  final double? bodyBottomPadding;
  final double? contentMaxWidth;
  final Key? scrollViewKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scrollController = useScrollController();
    final isScrolled = useState(false);

    useEffect(() {
      void handleScroll() {
        if (!scrollController.hasClients) {
          return;
        }

        final shouldBeScrolled = scrollController.offset > 12;
        if (shouldBeScrolled != isScrolled.value) {
          isScrolled.value = shouldBeScrolled;
        }
      }

      scrollController.addListener(handleScroll);
      return () => scrollController.removeListener(handleScroll);
    }, [scrollController]);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 64,
        backgroundColor: Colors.transparent,
        flexibleSpace: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          color: isScrolled.value
              ? theme.colorScheme.surfaceContainer
              : theme.colorScheme.surface,
        ),
        leading: showBackButton
            ? IconButton(
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : null,
        titleSpacing: showBackButton ? 4 : null,
        title: Text(
          title,
          style:
              (largeTitle
                      ? theme.textTheme.headlineSmall
                      : theme.textTheme.titleLarge)
                  ?.copyWith(color: theme.colorScheme.onSurface),
        ),
        actions: actions,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final horizontalPadding = width >= 840 ? 32.0 : 16.0;
          final resolvedBodyBottomPadding =
              bodyBottomPadding ?? kAeroPageBottomSpacing;
          final resolvedContentMaxWidth =
              contentMaxWidth ??
              (width >= 1200
                  ? 960.0
                  : width >= 840
                  ? 840.0
                  : double.infinity);

          return SingleChildScrollView(
            key: scrollViewKey,
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              bodyTopPadding,
              horizontalPadding,
              resolvedBodyBottomPadding,
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: resolvedContentMaxWidth),
                child: body,
              ),
            ),
          );
        },
      ),
    );
  }
}
