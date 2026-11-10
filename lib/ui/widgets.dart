// lib/ui/widgets.dart
//
// Bausteine des Designsystems. Bewusst wenige, dafür überall dieselben.
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import 'tokens.dart';

/// Seitengerüst für alle neuen Screens.
///
/// - [title] gesetzt: klassische Navigationsleiste (für geschobene Seiten).
/// - [title] leer: Tab-Wurzelseite; die große Überschrift kommt aus dem Inhalt.
class LPage extends StatelessWidget {
  const LPage({
    super.key,
    this.title,
    this.trailing,
    this.leading,
    this.background = LC.night,
    required this.child,
  });

  final String? title;
  final Widget? trailing;
  final Widget? leading;
  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: background,
      navigationBar: title == null
          ? null
          : CupertinoNavigationBar(
              backgroundColor: background,
              automaticBackgroundVisibility: false,
              border: null,
              leading: leading,
              middle: Text(title!, style: LT.heading),
              trailing: trailing,
            ),
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: LS.maxWidth),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Scrollbarer Seiteninhalt mit einheitlichen Rändern.
class LScroll extends StatelessWidget {
  const LScroll({super.key, required this.children, this.controller, this.top = LS.lg});

  final List<Widget> children;
  final ScrollController? controller;
  final double top;

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.of(context).padding.bottom + 96;
    return ListView(
      controller: controller,
      padding: EdgeInsets.fromLTRB(LS.page, top, LS.page, bottom),
      children: children,
    );
  }
}

/// Große Überschrift einer Tab-Wurzelseite.
class LHeader extends StatelessWidget {
  const LHeader({super.key, required this.title, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: LS.sm, bottom: LS.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: LT.display),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: LS.xs),
                  Text(subtitle!, style: LT.bodyMuted),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Abschnittsüberschrift mit optionaler Aktion rechts.
class LSection extends StatelessWidget {
  const LSection(this.title, {super.key, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: LS.xl, bottom: LS.md),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(title, style: LT.title.copyWith(fontSize: 19))),
          if (actionLabel != null)
            LTap(
              onTap: onAction,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(actionLabel!, style: LT.label.copyWith(color: LC.iris)),
              ),
            ),
        ],
      ),
    );
  }
}

/// Tippfläche mit dezentem Druck-Feedback.
class LTap extends StatefulWidget {
  const LTap({super.key, required this.child, this.onTap, this.semanticLabel});

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  State<LTap> createState() => _LTapState();
}

class _LTapState extends State<LTap> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap == null) return;
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: widget.onTap != null,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 90),
          opacity: _down ? 0.6 : 1,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Fläche für zusammengehörige Inhalte.
class LCard extends StatelessWidget {
  const LCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(LS.lg),
    this.color = LC.surface,
    this.borderColor,
    this.radius = LRad.md,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color? borderColor;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    final Widget box = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: radius,
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: child,
    );
    if (onTap == null) return box;
    return LTap(onTap: onTap, child: box);
  }
}

enum LButtonKind { primary, secondary, quiet, moon }

/// Schaltfläche. Beschriftung sagt, was passiert.
class LButton extends StatelessWidget {
  const LButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = LButtonKind.primary,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final LButtonKind kind;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    Color bg;
    Color fg;
    Color? border;
    switch (kind) {
      case LButtonKind.primary:
        bg = LC.iris;
        fg = LC.night;
        break;
      case LButtonKind.moon:
        bg = LC.moon;
        fg = LC.night;
        break;
      case LButtonKind.secondary:
        bg = LC.surfaceHi;
        fg = LC.text;
        break;
      case LButtonKind.quiet:
        bg = LC.transparent;
        fg = LC.iris;
        border = LC.line;
        break;
    }
    final Widget content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: LS.sm),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: LT.heading.copyWith(color: fg, fontSize: 16),
          ),
        ),
      ],
    );
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: LTap(
        onTap: onPressed,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: LS.xl, vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: LRad.md,
            border: border == null ? null : Border.all(color: border),
          ),
          child: content,
        ),
      ),
    );
  }
}

/// Auswahl-Chip (Filter, Tags, Optionen).
class LChip extends StatelessWidget {
  const LChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
    this.tone = LC.iris,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final Color fg = selected ? LC.night : LC.text;
    return LTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? tone : LC.surface,
          borderRadius: LRad.pill,
          border: Border.all(color: selected ? tone : LC.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: 15, color: fg),
              const SizedBox(width: 6),
            ],
            Text(label, style: LT.label.copyWith(color: fg)),
          ],
        ),
      ),
    );
  }
}

/// Kleine Kennzeichnung ohne Interaktion (z. B. Evidenzgrad).
class LBadge extends StatelessWidget {
  const LBadge(this.label, {super.key, this.color = LC.iris, this.background = LC.irisSoft});

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: LRad.pill),
      child: Text(label, style: LT.caption.copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }
}

/// Symbol in getönter Rundfläche.
class LIconDot extends StatelessWidget {
  const LIconDot(this.icon, {super.key, this.color = LC.iris, this.size = 40});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.5, color: color),
    );
  }
}

/// Listenzeile: Symbol, Titel, Unterzeile, optionaler Abschluss.
class LRow extends StatelessWidget {
  const LRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor = LC.iris,
    this.trailing,
    this.onTap,
    this.chevron = true,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    return LTap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: LS.md),
        child: Row(
          children: <Widget>[
            if (icon != null) ...<Widget>[
              LIconDot(icon!, color: iconColor),
              const SizedBox(width: LS.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: LT.heading.copyWith(fontSize: 16)),
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: LT.labelMuted),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...<Widget>[const SizedBox(width: LS.sm), trailing!],
            if (trailing == null && chevron && onTap != null)
              const Icon(CupertinoIcons.chevron_right, size: 16, color: LC.faint),
          ],
        ),
      ),
    );
  }
}

/// Gruppe von Zeilen in einer Karte, getrennt durch Haarlinien.
class LGroup extends StatelessWidget {
  const LGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final List<Widget> out = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      out.add(children[i]);
      if (i < children.length - 1) {
        out.add(Container(height: 1, color: LC.line));
      }
    }
    return LCard(
      padding: const EdgeInsets.symmetric(horizontal: LS.lg, vertical: LS.xs),
      child: Column(children: out),
    );
  }
}

/// Ein-/Ausschalter (eigene Umsetzung, unabhängig von Framework-Versionen).
class LSwitch extends StatelessWidget {
  const LSwitch({super.key, required this.value, required this.onChanged, this.tone = LC.iris});

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 50,
          height: 30,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: value ? tone : LC.line,
            borderRadius: LRad.pill,
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(color: LC.text, shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fortschrittsring.
class LRing extends StatelessWidget {
  const LRing({
    super.key,
    required this.value,
    this.size = 56,
    this.stroke = 6,
    this.color = LC.iris,
    this.track = LC.line,
    this.child,
  });

  final double value; // 0..1
  final double size;
  final double stroke;
  final Color color;
  final Color track;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(value.clamp(0.0, 1.0).toDouble(), stroke, color, track),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.stroke, this.color, this.track);

  final double value;
  final double stroke;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final double r = (math.min(size.width, size.height) - stroke) / 2;
    final Paint base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    canvas.drawCircle(c, r, base);
    if (value <= 0) return;
    final Paint arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      2 * math.pi * value,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.track != track || old.stroke != stroke;
}

/// Balkenreihe für kleine Verläufe (z. B. 7 Tage).
class LBars extends StatelessWidget {
  const LBars({
    super.key,
    required this.values,
    required this.labels,
    this.highlights = const <bool>[],
    this.height = 72,
    this.color = LC.iris,
    this.highlightColor = LC.moon,
  });

  final List<double> values; // 0..1
  final List<String> labels;
  final List<bool> highlights;
  final double height;
  final Color color;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        for (int i = 0; i < values.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: height,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: math.max(4.0, height * values[i].clamp(0.0, 1.0).toDouble()),
                        decoration: BoxDecoration(
                          color: (i < highlights.length && highlights[i])
                              ? highlightColor
                              : (values[i] > 0 ? color : LC.line),
                          borderRadius: const BorderRadius.all(Radius.circular(6)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(i < labels.length ? labels[i] : '', style: LT.caption),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Leerer Zustand: sagt, was hier entsteht und wie man anfängt.
class LEmpty extends StatelessWidget {
  const LEmpty({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LS.xxl),
      child: Column(
        children: <Widget>[
          LIconDot(icon, size: 64, color: LC.iris),
          const SizedBox(height: LS.lg),
          Text(title, style: LT.title, textAlign: TextAlign.center),
          const SizedBox(height: LS.sm),
          Text(text, style: LT.bodyMuted, textAlign: TextAlign.center),
          if (actionLabel != null) ...<Widget>[
            const SizedBox(height: LS.xl),
            LButton(label: actionLabel!, onPressed: onAction, expand: false),
          ],
        ],
      ),
    );
  }
}

/// Hinweisfläche (Sicherheit, Einordnung).
class LNote extends StatelessWidget {
  const LNote({super.key, required this.text, this.icon = CupertinoIcons.info_circle, this.tone = LC.iris});

  final String text;
  final IconData icon;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LS.lg),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.10),
        borderRadius: LRad.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: tone),
          const SizedBox(width: LS.md),
          Expanded(child: Text(text, style: LT.label.copyWith(color: LC.text, height: 1.45))),
        ],
      ),
    );
  }
}

/// Einzeiliges oder mehrzeiliges Eingabefeld im App-Stil.
class LField extends StatelessWidget {
  const LField({
    super.key,
    required this.controller,
    this.placeholder,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.prefix,
    this.style,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String? placeholder;
  final int? maxLines;
  final int? minLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final Widget? prefix;
  final TextStyle? style;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      maxLines: maxLines,
      minLines: minLines,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      autofocus: autofocus,
      prefix: prefix == null
          ? null
          : Padding(padding: const EdgeInsets.only(left: LS.md), child: prefix),
      textInputAction: textInputAction,
      textCapitalization: TextCapitalization.sentences,
      cursorColor: LC.iris,
      style: style ?? LT.body,
      placeholderStyle: (style ?? LT.body).copyWith(color: LC.faint),
      padding: const EdgeInsets.symmetric(horizontal: LS.lg, vertical: 14),
      decoration: const BoxDecoration(
        color: LC.surface,
        borderRadius: LRad.md,
      ),
    );
  }
}

/// Bodenblatt für kurze Auswahl- und Bestätigungsdialoge.
Future<T?> showLSheet<T>(BuildContext context, {required WidgetBuilder builder}) {
  return showCupertinoModalPopup<T>(
    context: context,
    builder: (BuildContext ctx) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: LS.maxWidth),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: LC.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.fromLTRB(
              LS.page,
              LS.md,
              LS.page,
              LS.xl + MediaQuery.of(ctx).padding.bottom + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: DefaultTextStyle(
              style: LT.body,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: LS.lg),
                      decoration: const BoxDecoration(color: LC.line, borderRadius: LRad.pill),
                    ),
                  ),
                  builder(ctx),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// Kurze Rückfrage vor nicht umkehrbaren Aktionen.
Future<bool> confirmL(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final bool? ok = await showCupertinoDialog<bool>(
    context: context,
    builder: (BuildContext ctx) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        CupertinoDialogAction(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Abbrechen'),
        ),
        CupertinoDialogAction(
          isDestructiveAction: destructive,
          isDefaultAction: !destructive,
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Uhrzeit als "07:30".
String hhmm(int hour, int minute) =>
    '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
