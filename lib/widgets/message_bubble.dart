import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/message.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

const _quickEmojis = ['👍', '❤️', '😂', '😮', '😢', '👏'];
const _skipExternalLinkWarningKey = 'skip_external_link_warning';

Future<void> _openLinkWithWarning(BuildContext context, String rawUrl) async {
  final uri = Uri.tryParse(rawUrl);
  if (uri == null) return;

  final prefs = await SharedPreferences.getInstance();
  final skipWarning = prefs.getBool(_skipExternalLinkWarningKey) ?? false;

  if (skipWarning) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    return;
  }

  if (!context.mounted) return;

  bool dontShowAgain = false;
  final openConfirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text('Open external link?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This link will open outside CampusCollab. Make sure you trust the sender before continuing.',
                ),
                const SizedBox(height: 10),
                Text(
                  rawUrl,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: dontShowAgain,
                  title: const Text("Don't show this warning again"),
                  onChanged: (value) {
                    setDialogState(() {
                      dontShowAgain = value ?? false;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Open'),
              ),
            ],
          );
        },
      );
    },
  );

  if (openConfirmed != true) return;

  if (dontShowAgain) {
    await prefs.setBool(_skipExternalLinkWarningKey, true);
  }
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final String groupId;
  /// 'owner' | 'admin' | 'member' | 'mentor' | ''
  final String myRole;
  /// Called when the user requests to edit this message.
  /// The parent (ChatDetailScreen) shows the dialog from its stable context.
  final void Function(Message)? onEditRequest;

  const MessageBubble({
    super.key,
    required this.message,
    required this.groupId,
    required this.myRole,
    this.onEditRequest,
  });

  bool get _canEdit =>
      message.isMe && message.type == MessageType.text;

  bool get _canDelete =>
      message.isMe ||
      (!message.isMe && (myRole == 'owner' || myRole == 'admin'));

  void _showOptions(BuildContext context) {
    showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _MessageOptionsSheet(
        message: message,
        groupId: groupId,
        canEdit: _canEdit,
        canDelete: _canDelete,
      ),
    ).then((editRequested) {
      if (editRequested == true) {
        onEditRequest?.call(message);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasReactions = message.reactions.isNotEmpty;
    return Column(
      crossAxisAlignment:
          message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onLongPress: () => _showOptions(context),
          child: message.isMe
              ? _SentBubble(message: message)
              : _ReceivedBubble(message: message),
        ),
        if (hasReactions)
          Padding(
            padding: EdgeInsets.only(
              left: message.isMe ? 60 : 44,
              right: message.isMe ? 44 : 60,
              bottom: 2,
            ),
            child: _ReactionsRow(
              reactions: message.reactions,
              myUid: FirebaseAuth.instance.currentUser?.uid ?? '',
              onToggle: (emoji) =>
                  FirestoreService().toggleReaction(groupId, message.id, emoji),
            ),
          ),
      ],
    );
  }
}

// ── Reaction row ─────────────────────────────────────────────────────────────

class _ReactionsRow extends StatelessWidget {
  final Map<String, List<String>> reactions;
  final String myUid;
  final void Function(String emoji) onToggle;

  const _ReactionsRow({
    required this.reactions,
    required this.myUid,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: reactions.entries.map((e) {
        final emoji = e.key;
        final count = e.value.length;
        final iMine = e.value.contains(myUid);
        return GestureDetector(
          onTap: () => onToggle(emoji),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: iMine
                  ? AppTheme.primary.withValues(alpha: 0.15)
                  : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: iMine
                    ? AppTheme.primary.withValues(alpha: 0.5)
                    : cs.outlineVariant,
                width: 1,
              ),
            ),
            child: Text(
              '$emoji $count',
              style: TextStyle(fontSize: 12, color: cs.onSurface),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Sent (right-aligned) ─────────────────────────────────────────────────────

class _SentBubble extends StatelessWidget {
  final Message message;
  const _SentBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 60, right: 12, top: 4, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(child: _buildContent(context)),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.blue[300],
            child: const Icon(Icons.person, size: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (message.type) {
      case MessageType.image:
        return _ImageCard(imageUrl: message.imageUrl, isMe: true);
      case MessageType.file:
        return _FileCard(message: message, isMe: true);
      case MessageType.text:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFF1D4ED8),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              _TextWithEmbeds(
                text: message.text ?? '',
                textColor: Colors.white,
                secondaryTextColor: Colors.white70,
              ),
              if (message.isEdited)
                const Text(
                  'edited',
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontStyle: FontStyle.italic),
                ),
            ],
          ),
        );
    }
  }
}

// ── Received (left-aligned) ──────────────────────────────────────────────────

class _ReceivedBubble extends StatelessWidget {
  final Message message;
  const _ReceivedBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 60, top: 4, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.grey[400],
            child: Text(
              message.senderName.isNotEmpty ? message.senderName[0] : '?',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.senderName,
                  style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 3),
                _buildContent(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (message.type) {
      case MessageType.image:
        return _ImageCard(imageUrl: message.imageUrl, isMe: false);
      case MessageType.file:
        return _FileCard(message: message, isMe: false);
      case MessageType.text:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _TextWithEmbeds(
                text: message.text ?? '',
                textColor: cs.onSurface,
                secondaryTextColor: cs.onSurfaceVariant,
              ),
              if (message.isEdited)
                Text(
                  'edited',
                  style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 10,
                      fontStyle: FontStyle.italic),
                ),
            ],
          ),
        );
    }
  }
}

// ── File card ────────────────────────────────────────────────────────────────

class _FileCard extends StatelessWidget {
  final Message message;
  final bool isMe;
  const _FileCard({required this.message, required this.isMe});

  Future<void> _openFile() async {
    final raw = message.fileUrl;
    if (raw == null || raw.isEmpty) return;
    final uri = Uri.tryParse(raw);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: _openFile,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[600] : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: isMe ? null : Border.all(color: Colors.grey[200]!),
          boxShadow: isMe
              ? null
              : [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1))
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue[800] : Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.description,
                  color: isMe ? Colors.white : Colors.blue[700], size: 24),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.fileName ?? 'File',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: isMe ? Colors.white : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message.fileSubtitle ?? 'Tap to open',
                    style: TextStyle(
                        fontSize: 11,
                        color: isMe ? Colors.blue[100] : Colors.grey[500]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.open_in_new,
                size: 16, color: isMe ? Colors.white70 : Colors.grey[500]),
          ],
        ),
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String? imageUrl;
  final bool isMe;

  const _ImageCard({required this.imageUrl, required this.isMe});

  Future<void> _openImage() async {
    final raw = imageUrl;
    if (raw == null || raw.isEmpty) return;
    final uri = Uri.tryParse(raw);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final raw = imageUrl;
    if (raw == null || raw.isEmpty) {
      return Container(
        width: 220,
        height: 160,
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.broken_image_outlined,
            size: 40, color: Colors.blueGrey),
      );
    }

    return InkWell(
      onTap: _openImage,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 220,
          height: 160,
          child: Image.network(
            raw,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                color: isMe ? Colors.blue[100] : Colors.grey[300],
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: isMe ? Colors.blue[100] : Colors.grey[300],
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image_outlined,
                  size: 40, color: Colors.blueGrey),
            ),
          ),
        ),
      ),
    );
  }
}

class _TextWithEmbeds extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color secondaryTextColor;

  const _TextWithEmbeds({
    required this.text,
    required this.textColor,
    required this.secondaryTextColor,
  });

  static final RegExp _urlRegex =
      RegExp(r'https?:\/\/[^\s]+', caseSensitive: false);

  List<String> _extractUrls() {
    final matches = _urlRegex.allMatches(text);
    return matches.map((m) => m.group(0)!).toList();
  }

  @override
  Widget build(BuildContext context) {
    final urls = _extractUrls();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ClickableMessageText(
          text: text,
          textColor: textColor,
        ),
        if (urls.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...urls.map(
            (url) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _EmbeddedLinkCard(
                url: url,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _EmbeddedLinkCard extends StatelessWidget {
  final String url;
  final Color textColor;
  final Color secondaryTextColor;

  const _EmbeddedLinkCard({
    required this.url,
    required this.textColor,
    required this.secondaryTextColor,
  });

  Future<void> _openLink(BuildContext context) async {
    await _openLinkWithWarning(context, url);
  }

  String? _extractYoutubeId() {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    final host = uri.host.toLowerCase();
    if (host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    if (host.contains('youtube.com')) {
      if (uri.path == '/watch') return uri.queryParameters['v'];
      if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'shorts') {
        return uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
      }
      if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'embed') {
        return uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ytId = _extractYoutubeId();
    final isYoutube = ytId != null && ytId.isNotEmpty;
    final cs = Theme.of(context).colorScheme;

    if (isYoutube) {
      final thumb = 'https://img.youtube.com/vi/$ytId/hqdefault.jpg';
      return InkWell(
        onTap: () => _openLink(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 220,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 124,
                      child: Image.network(
                        thumb,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: cs.surfaceContainerHighest,
                          alignment: Alignment.center,
                          child: Icon(Icons.play_circle_fill,
                              size: 36, color: cs.onSurfaceVariant),
                        ),
                      ),
                    ),
                    const Icon(Icons.play_circle_fill,
                        size: 40, color: Colors.white),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'YouTube link',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => _openLink(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.link, size: 14, color: secondaryTextColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                url,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                  decorationColor: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClickableMessageText extends StatelessWidget {
  final String text;
  final Color textColor;

  const _ClickableMessageText({required this.text, required this.textColor});

  static final RegExp _urlRegex =
      RegExp(r'https?:\/\/[^\s]+', caseSensitive: false);

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    int cursor = 0;
    for (final match in _urlRegex.allMatches(text)) {
      final start = match.start;
      final end = match.end;
      if (start > cursor) {
        spans.add(
          TextSpan(
            text: text.substring(cursor, start),
            style: TextStyle(color: textColor, fontSize: 14.5),
          ),
        );
      }
      final link = text.substring(start, end);
      spans.add(
        TextSpan(
          text: link,
          style: TextStyle(
            color: textColor,
            fontSize: 14.5,
            decoration: TextDecoration.underline,
            decorationColor: textColor,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              _openLinkWithWarning(context, link);
            },
        ),
      );
      cursor = end;
    }

    if (cursor < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(cursor),
          style: TextStyle(color: textColor, fontSize: 14.5),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}

// ── Options bottom sheet ─────────────────────────────────────────────────────

class _MessageOptionsSheet extends StatefulWidget {
  final Message message;
  final String groupId;
  final bool canEdit;
  final bool canDelete;

  const _MessageOptionsSheet({
    required this.message,
    required this.groupId,
    required this.canEdit,
    required this.canDelete,
  });

  @override
  State<_MessageOptionsSheet> createState() => _MessageOptionsSheetState();
}

class _MessageOptionsSheetState extends State<_MessageOptionsSheet> {
  bool _loading = false;

  Future<void> _toggleReaction(String emoji) async {
    setState(() => _loading = true);
    await FirestoreService()
        .toggleReaction(widget.groupId, widget.message.id, emoji);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _deleteMessage() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete message'),
        content:
            const Text('This message will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (mounted) Navigator.pop(context);
    await FirestoreService()
        .deleteMessage(widget.groupId, widget.message.id);
  }

  void _editMessage() {
    // Pop sheet with true — the bubble's _showEditDialog handles the dialog
    // after the sheet is fully gone (avoids duplicate GlobalKey conflicts).
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final myReactions = widget.message.reactions.entries
        .where((e) => e.value.contains(myUid))
        .map((e) => e.key)
        .toSet();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Quick emoji row
            Text('React',
                style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _quickEmojis.map((emoji) {
                final selected = myReactions.contains(emoji);
                return GestureDetector(
                  onTap: _loading ? null : () => _toggleReaction(emoji),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primary.withValues(alpha: 0.15)
                          : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? AppTheme.primary.withValues(alpha: 0.6)
                            : Colors.transparent,
                      ),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                  ),
                );
              }).toList(),
            ),

            if (widget.canEdit || widget.canDelete) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 4),
            ],

            if (widget.canEdit)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.edit_outlined, color: cs.onSurface),
                title: Text('Edit message',
                    style: TextStyle(color: cs.onSurface)),
                onTap: _loading ? null : _editMessage,
                dense: true,
              ),

            if (widget.canDelete)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading:
                    const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete message',
                    style: TextStyle(color: Colors.red)),
                onTap: _loading ? null : _deleteMessage,
                dense: true,
              ),

            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
