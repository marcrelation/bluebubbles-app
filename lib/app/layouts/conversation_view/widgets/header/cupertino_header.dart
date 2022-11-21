import 'dart:async';
import 'dart:ui';

import 'package:bluebubbles/app/layouts/conversation_details/conversation_details.dart';
import 'package:bluebubbles/app/layouts/conversation_view/widgets/header/header_widgets.dart';
import 'package:bluebubbles/app/components/avatars/contact_avatar_group_widget.dart';
import 'package:bluebubbles/app/wrappers/theme_switcher.dart';
import 'package:bluebubbles/app/wrappers/stateful_boilerplate.dart';
import 'package:bluebubbles/helpers/helpers.dart';
import 'package:bluebubbles/main.dart';
import 'package:bluebubbles/models/models.dart';
import 'package:bluebubbles/services/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide BackButton;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:universal_io/io.dart';

class CupertinoHeader extends StatelessWidget implements PreferredSizeWidget {
  const CupertinoHeader({Key? key, required this.controller});

  final ConversationViewController controller;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: context.theme.colorScheme.properSurface.withOpacity(0.3),
            border: Border(
              bottom: BorderSide(color: context.theme.colorScheme.properSurface, width: 1),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                if (ss.settings.showConnectionIndicator.value)
                  const ConnectionIndicator(),
                Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 20, top: MediaQuery.of(context).viewPadding.top - 2),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            if (controller.inSelectMode.value) {
                              controller.inSelectMode.value = false;
                              controller.selected.clear();
                              return;
                            }
                            if (ls.isBubble) {
                              SystemNavigator.pop();
                              return;
                            }
                            eventDispatcher.emit("update-highlight", null);
                            while (Get.isOverlaysOpen) {
                              Get.back();
                            }
                            Navigator.of(context).pop();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: _UnreadIcon(controller: controller),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              ThemeSwitcher.buildPageRoute(
                                builder: (context) => ConversationDetails(
                                  chat: controller.chat,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: _ChatIconAndTitle(parentController: controller),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ManualMark(controller: controller)
                      ),
                    ]
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(Get.context!.orientation == Orientation.landscape && Platform.isAndroid ? 55 : 75);
}

class _UnreadIcon extends StatefulWidget {
  const _UnreadIcon({required this.controller});

  final ConversationViewController controller;

  @override
  State<StatefulWidget> createState() => _UnreadIconState();
}

class _UnreadIconState extends OptimizedState<_UnreadIcon> {
  int count = 0;
  late final StreamSubscription<Query<Chat>> sub;

  @override
  void initState() {
    super.initState();
    updateObx(() {
      final unreadQuery = chatBox.query(Chat_.hasUnreadMessage.equals(true)).watch(triggerImmediately: true);
      sub = unreadQuery.listen((Query<Chat> query) {
        final c = query.count();
        if (count != c) {
          setState(() {
            count = c;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3.0, right: 3),
          child: Obx(() {
            final icon = widget.controller.inSelectMode.value ? CupertinoIcons.xmark : CupertinoIcons.back;
            return Text(
              String.fromCharCode(icon.codePoint),
              style: TextStyle(
                fontFamily: icon.fontFamily,
                package: icon.fontPackage,
                fontSize: 35,
                color: context.theme.colorScheme.primary,
              ),
            );
          }),
        ),
        Obx(() {
          final _count = widget.controller.inSelectMode.value ? widget.controller.selected.length : count;
          if (_count == 0) return const SizedBox.shrink();
          return Container(
            width: _count > 9 ? 25.0 : 20,
            height: 20.0,
            decoration: BoxDecoration(
              color: context.theme.colorScheme.primary,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(25)
            ),
            alignment: Alignment.center,
            child: Center(
              child: Text(
                _count.toString(),
                textAlign: TextAlign.center,
                style: context.textTheme.bodyLarge!.copyWith(color: context.theme.colorScheme.onPrimary),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ChatIconAndTitle extends CustomStateful<ConversationViewController> {
  const _ChatIconAndTitle({required super.parentController});

  @override
  State<StatefulWidget> createState() => _ChatIconAndTitleState();
}

class _ChatIconAndTitleState extends CustomState<_ChatIconAndTitle, void, ConversationViewController> {
  String title = "Unknown";
  late final StreamSubscription<Query<Chat>> sub;
  String? cachedDisplayName = "";
  List<Handle> cachedParticipants = [];

  @override
  void initState() {
    super.initState();
    tag = controller.chat.guid;
    // keep controller in memory since the widget is part of a list
    // (it will be disposed when scrolled out of view)
    forceDelete = false;
    cachedDisplayName = controller.chat.displayName;
    cachedParticipants = controller.chat.handles;
    title = controller.chat.getTitle();
    // run query after render has completed
    updateObx(() {
      final titleQuery = chatBox.query(Chat_.guid.equals(controller.chat.guid))
          .watch();
      sub = titleQuery.listen((Query<Chat> query) {
        final chat = query.findFirst()!;
        // check if we really need to update this widget
        if (chat.displayName != cachedDisplayName
            || chat.handles.length != cachedParticipants.length) {
          final newTitle = chat.getTitle();
          if (newTitle != title) {
            setState(() {
              title = newTitle;
            });
          }
        }
        cachedDisplayName = chat.displayName;
        cachedParticipants = chat.handles;
      });
    });
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final children = [
      IgnorePointer(
        ignoring: true,
        child: ContactAvatarGroupWidget(
          chat: controller.chat,
          size: !controller.chat.isGroup ? 40 : 45,
        ),
      ),
      const SizedBox(height: 5, width: 5),
      Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ns.width(context) / 2.5,
            ),
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              text: TextSpan(
                style: context.theme.textTheme.bodyMedium,
                children: MessageHelper.buildEmojiText(
                  title,
                  context.theme.textTheme.bodyMedium!,
                ),
              ),
            ),
          ),
          Icon(
            CupertinoIcons.chevron_right,
            size: context.theme.textTheme.bodyMedium!.fontSize!,
            color: context.theme.colorScheme.outline,
          ),
        ]
      ),
    ];

    if (context.orientation == Orientation.landscape && Platform.isAndroid) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    }
  }
}