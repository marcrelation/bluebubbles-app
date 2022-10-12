import 'dart:math';

import 'package:bluebubbles/helpers/constants.dart';
import 'package:bluebubbles/helpers/ui/theme_helpers.dart';
import 'package:bluebubbles/helpers/utils.dart';
import 'package:bluebubbles/layouts/settings/pages/conversation_list/pinned_order_panel.dart';
import 'package:bluebubbles/layouts/settings/widgets/settings_widgets.dart';
import 'package:bluebubbles/layouts/stateful_boilerplate.dart';
import 'package:bluebubbles/services/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatListPanel extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _ChatListPanelState();
}

class _ChatListPanelState extends OptimizedState<ChatListPanel> with ThemeHelpers {
  
  @override
  Widget build(BuildContext context) {
    final inactiveCheckColor = context.theme.colorScheme.properSurface.computeDifference(tileColor) < 15
        ? context.theme.colorScheme.properOnSurface.withOpacity(0.6) : context.theme.colorScheme.properSurface;

    return SettingsScaffold(
        title: "Chat List",
        initialHeader: "Indicators",
        iosSubtitle: iosSubtitle,
        materialSubtitle: materialSubtitle,
        tileColor: tileColor,
        headerColor: headerColor,
        bodySlivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[
                SettingsSection(
                  backgroundColor: tileColor,
                  children: [
                    Obx(() => SettingsSwitch(
                          onChanged: (bool val) {
                            settings.settings.showConnectionIndicator.value = val;
                            saveSettings();
                          },
                          initialVal: settings.settings.showConnectionIndicator.value,
                          title: "Show Connection Indicator",
                          subtitle: "Enables a connection status indicator at the top left",
                          backgroundColor: tileColor,
                        )),
                    Container(
                      color: tileColor,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: SettingsDivider(color: context.theme.colorScheme.surfaceVariant),
                      ),
                    ),
                    Obx(() => SettingsSwitch(
                          onChanged: (bool val) {
                            settings.settings.showSyncIndicator.value = val;
                            saveSettings();
                          },
                          initialVal: settings.settings.showSyncIndicator.value,
                          title: "Show Sync Indicator in Chat List",
                          subtitle:
                              "Enables a small indicator at the top left to show when the app is syncing messages",
                          backgroundColor: tileColor,
                          isThreeLine: true,
                        )),
                    Container(
                      color: tileColor,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: SettingsDivider(color: context.theme.colorScheme.surfaceVariant),
                      ),
                    ),
                    Obx(() => SettingsSwitch(
                          onChanged: (bool val) {
                            settings.settings.colorblindMode.value = val;
                            saveSettings();
                          },
                          initialVal: settings.settings.colorblindMode.value,
                          title: "Colorblind Mode",
                          subtitle: "Replaces the colored connection indicator with icons to aid accessibility",
                          backgroundColor: tileColor,
                          isThreeLine: true,
                        )),
                    Container(
                      color: tileColor,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: SettingsDivider(color: context.theme.colorScheme.surfaceVariant),
                      ),
                    ),
                    Obx(() => SettingsSwitch(
                      onChanged: (bool val) {
                        settings.settings.statusIndicatorsOnChats.value = val;
                        saveSettings();
                      },
                      initialVal: settings.settings.statusIndicatorsOnChats.value,
                      title: "Message Status Indicators",
                      subtitle: "Adds status indicators to the chat list for the sent / delivered / read status of your most recent message",
                      backgroundColor: tileColor,
                      isThreeLine: true,
                    )),
                  ],
                ),
                SettingsHeader(
                    headerColor: headerColor,
                    tileColor: tileColor,
                    iosSubtitle: iosSubtitle,
                    materialSubtitle: materialSubtitle,
                    text: "Filtering"),
                SettingsSection(
                  backgroundColor: tileColor,
                  children: [
                    Obx(() => SettingsSwitch(
                          onChanged: (bool val) {
                            settings.settings.filteredChatList.value = val;
                            saveSettings();
                          },
                          initialVal: settings.settings.filteredChatList.value,
                          title: "Filtered Chat List",
                          subtitle:
                              "Filters the chat list based on parameters set in iMessage (usually this removes old, inactive chats)",
                          backgroundColor: tileColor,
                          isThreeLine: true,
                        )),
                    Container(
                      color: tileColor,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: SettingsDivider(color: context.theme.colorScheme.surfaceVariant),
                      ),
                    ),
                    Obx(() => SettingsSwitch(
                          onChanged: (bool val) {
                            settings.settings.filterUnknownSenders.value = val;
                            saveSettings();
                          },
                          initialVal: settings.settings.filterUnknownSenders.value,
                          title: "Filter Unknown Senders",
                          subtitle:
                              "Turn off notifications for senders who aren't in your contacts and sort them into a separate chat list",
                          backgroundColor: tileColor,
                          isThreeLine: true,
                        )),
                  ],
                ),
                SettingsHeader(
                    headerColor: headerColor,
                    tileColor: tileColor,
                    iosSubtitle: iosSubtitle,
                    materialSubtitle: materialSubtitle,
                    text: "Appearance"),
                SettingsSection(
                  backgroundColor: tileColor,
                  children: [
                    Obx(() => SettingsSwitch(
                      onChanged: (bool val) {
                        settings.settings.hideDividers.value = val;
                        saveSettings();
                      },
                      initialVal: settings.settings.hideDividers.value,
                      title: "Hide Dividers",
                      backgroundColor: tileColor,
                      subtitle: "Hides dividers between tiles",
                    )),
                    Container(
                      color: tileColor,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: SettingsDivider(color: context.theme.colorScheme.surfaceVariant),
                      ),
                    ),
                    Obx(() => SettingsSwitch(
                          onChanged: (bool val) {
                            settings.settings.denseChatTiles.value = val;
                            saveSettings();
                          },
                          initialVal: settings.settings.denseChatTiles.value,
                          title: "Dense Conversation Tiles",
                          backgroundColor: tileColor,
                          subtitle: "Compresses chat tile size on the conversation list page",
                          isThreeLine: true,
                        )),
                    Obx(() {
                      if (iOS) {
                        return Container(
                          color: tileColor,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: SettingsDivider(color: context.theme.colorScheme.surfaceVariant),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
                    Obx(() {
                      if (iOS) {
                        return SettingsSwitch(
                          onChanged: (bool val) {
                            settings.settings.reducedForehead.value = val;
                            saveSettings();
                          },
                          initialVal: settings.settings.reducedForehead.value,
                          title: "Reduced Forehead",
                          backgroundColor: tileColor,
                          subtitle: "Reduces the appbar size on conversation pages",
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
                    Container(
                      color: tileColor,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: SettingsDivider(color: context.theme.colorScheme.surfaceVariant),
                      ),
                    ),
                    if (!kIsDesktop && !kIsWeb)
                      Obx(() {
                        if (iOS) {
                          return SettingsTile(
                            title: "Max Pin Rows",
                            subtitle:
                                "The maximum row count of pins displayed${kIsDesktop ? "" : " when using the app in the portrait orientation"}",
                            isThreeLine: true,
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                    if (!kIsDesktop && !kIsWeb)
                      Obx(() {
                        if (iOS) {
                          return Row(
                            children: <Widget>[
                              Flexible(
                                child: SettingsSlider(
                                  min: 1,
                                  max: 4,
                                  divisions: 3,
                                  update: (double val) {
                                    settings.settings.pinRowsPortrait.value = val.toInt();
                                  },
                                  onChangeEnd: (double val) {
                                    saveSettings();
                                  },
                                  startingVal: settings.settings.pinRowsPortrait.value.toDouble(),
                                  backgroundColor: tileColor,
                                  formatValue: (val) =>
                                      "${settings.settings.pinRowsPortrait.value} row${settings.settings.pinRowsPortrait.value > 1 ? "s" : ""} of ${kIsDesktop
                                          ? settings.settings.pinColumnsLandscape.value.toString()
                                          : settings.settings.pinColumnsPortrait.value.toString()}",
                                ),
                              ),
                              const SizedBox(width: 20),
                            ],
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                    if (kIsDesktop)
                      Obx(() {
                        if (iOS) {
                          return SettingsTile(
                            title:
                                "Pinned Chat Configuration (${settings.settings.pinRowsPortrait.value} row${settings.settings.pinRowsPortrait.value > 1 ? "s" : ""} of ${settings.settings.pinColumnsLandscape})",
                            subtitle:
                                "Pinned chats will overflow onto multiple pages if they do not fit in this configuration. Keep in mind that you cannot access different pages of the pinned chats without a touchscreen or horizontal scrolling capability.",
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                    if (kIsDesktop)
                      Obx(() {
                        if (iOS) {
                          return Row(
                            children: <Widget>[
                              Flexible(
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        const Padding(
                                          padding: EdgeInsets.only(left: 48),
                                          child: SizedBox(
                                            width: 100,
                                            child: Text("Row Count"),
                                          ),
                                        ),
                                        Flexible(
                                          child: SettingsOptions<int>(
                                            initial: settings.settings.pinRowsPortrait.value,
                                            options: List.generate(4, (index) => index + 1),
                                            onChanged: (int? val) {
                                              if (val == null) return;
                                              settings.settings.pinRowsPortrait.value = val;
                                              saveSettings();
                                            },
                                            title: "Pin Rows",
                                            backgroundColor: tileColor,
                                            secondaryColor: context.theme.colorScheme.secondary,
                                            textProcessing: (val) => val.toString(),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        const Padding(
                                          padding: EdgeInsets.only(left: 48),
                                          child: SizedBox(
                                            width: 100,
                                            child: Text("Column Count"),
                                          ),
                                        ),
                                        Flexible(
                                          child: SettingsOptions<int>(
                                            initial: settings.settings.pinColumnsLandscape.value,
                                            options: List.generate(5, (index) => index + 2),
                                            onChanged: (int? val) {
                                              if (val == null) return;
                                              settings.settings.pinColumnsLandscape.value = val;
                                              saveSettings();
                                            },
                                            title: "Pins Per Row",
                                            backgroundColor: tileColor,
                                            secondaryColor: context.theme.colorScheme.secondary,
                                            textProcessing: (val) => val.toString(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Obx(() {
                                navigatorService.listener.value;
                                double width = 108 * context.width / context.height;
                                if (navigatorService.width(context) != context.width) {
                                  return Container(
                                    width: width,
                                    height: 108,
                                    margin: const EdgeInsets.only(left: 24, right: 48),
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Flexible(
                                          child: Container(
                                            color: context.theme.colorScheme.secondary,
                                            padding: const EdgeInsets.symmetric(horizontal: 2),
                                            child: AbsorbPointer(
                                              child: Obx(
                                                () => Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Container(
                                                        height: 12,
                                                        padding: const EdgeInsets.only(left: 2, top: 3),
                                                        child: Text(
                                                          "Messages",
                                                          style: context.textTheme.labelLarge!.copyWith(fontSize: 4),
                                                          textAlign: TextAlign.left,
                                                        )),
                                                    Obx(
                                                      () => Expanded(
                                                        flex: settings.settings.pinRowsPortrait.value *
                                                            (width -
                                                                navigatorService.width(context) /
                                                                    context.width *
                                                                    width) ~/
                                                            settings.settings.pinColumnsLandscape.value,
                                                        child: GridView.custom(
                                                          shrinkWrap: true,
                                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount:
                                                                settings.settings.pinColumnsLandscape.value,
                                                          ),
                                                          physics: NeverScrollableScrollPhysics(),
                                                          childrenDelegate: SliverChildBuilderDelegate(
                                                            (context, index) => Container(
                                                              margin: EdgeInsets.all(2 /
                                                                  max(
                                                                      settings.settings.pinRowsPortrait.value,
                                                                      settings
                                                                          .settings
                                                                          .pinColumnsLandscape
                                                                          .value)),
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(50 /
                                                                      max(
                                                                          settings
                                                                              .settings
                                                                              .pinRowsPortrait
                                                                              .value,
                                                                          settings
                                                                              .settings
                                                                              .pinColumnsLandscape
                                                                              .value)),
                                                                  color: context.theme.colorScheme.secondary
                                                                      .lightenOrDarken(10)),
                                                            ),
                                                            childCount:
                                                                settings.settings.pinColumnsLandscape.value *
                                                                    settings.settings.pinRowsPortrait.value,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    if (settings.settings.pinRowsPortrait.value *
                                                            (width -
                                                                navigatorService.width(context) /
                                                                    context.width *
                                                                    width) /
                                                            settings.settings.pinColumnsLandscape.value <
                                                        96)
                                                      Expanded(
                                                        flex: 96 -
                                                            settings.settings.pinRowsPortrait.value *
                                                                (width -
                                                                    navigatorService.width(context) /
                                                                        context.width *
                                                                        width) ~/
                                                                settings.settings.pinColumnsLandscape.value,
                                                        child: ListView.builder(
                                                            padding: EdgeInsets.only(top: 2),
                                                            physics: NeverScrollableScrollPhysics(),
                                                            shrinkWrap: true,
                                                            itemBuilder: (context, index) => Container(
                                                                height: 12,
                                                                margin: const EdgeInsets.symmetric(vertical: 1),
                                                                decoration: BoxDecoration(
                                                                    color: context.theme.colorScheme.secondary
                                                                        .lightenOrDarken(10),
                                                                    borderRadius: BorderRadius.circular(3))),
                                                            itemCount: 8),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                            width: 1,
                                            height: 108,
                                            color: context.theme.colorScheme.secondary.oppositeLightenOrDarken(40)),
                                        Container(
                                            width: navigatorService.width(context) / context.width * width - 1,
                                            height: 108,
                                            color: context.theme.colorScheme.secondary),
                                      ],
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }),
                            ],
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                    if (!kIsWeb)
                      Container(
                        color: tileColor,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: SettingsDivider(color: context.theme.colorScheme.surfaceVariant),
                        ),
                      ),
                    if (!kIsWeb)
                      SettingsTile(
                        title: "Pinned Order",
                        subtitle: "Set the order for your pinned chats",
                        onTap: () {
                          navigatorService.pushSettings(
                            context,
                            PinnedOrderPanel(),
                          );
                        },
                        trailing: Icon(
                          iOS ? CupertinoIcons.chevron_right : Icons.arrow_forward,
                          color: context.theme.colorScheme.outline,
                        ),
                      ),
                  ],
                ),
                if (!kIsWeb && !kIsDesktop)
                  SettingsHeader(
                      headerColor: headerColor,
                      tileColor: tileColor,
                      iosSubtitle: iosSubtitle,
                      materialSubtitle: materialSubtitle,
                      text: "Swipe Actions"),
                if (!kIsWeb && !kIsDesktop)
                  SettingsSection(
                    backgroundColor: tileColor,
                    children: [
                      Obx(() {
                        if (samsung ||
                            material) {
                          return SettingsSwitch(
                            onChanged: (bool val) {
                              settings.settings.swipableConversationTiles.value = val;
                              saveSettings();
                            },
                            initialVal: settings.settings.swipableConversationTiles.value,
                            title: "Swipe Actions for Conversation Tiles",
                            subtitle: "Enables swipe actions for conversation tiles when using Material theme",
                            backgroundColor: tileColor,
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                      if (iOS)
                        SettingsTile(
                          title: "Customize Swipe Actions",
                          subtitle: "Enable or disable specific swipe actions",
                        ),
                      Obx(() {
                        if (iOS) {
                          return Container(
                            color: tileColor,
                            constraints: BoxConstraints(maxWidth: navigatorService.width(context) - 20),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Row(
                                children: [
                                  Column(children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text("Right", style: context.theme.textTheme.bodyLarge),
                                    ),
                                    Opacity(
                                      opacity: settings.settings.iosShowPin.value ? 1 : 0.7,
                                      child: Container(
                                        height: 60,
                                        width: navigatorService.width(context) / 5 - 12,
                                        color: Colors.yellow[800],
                                        child: IconButton(
                                          icon: const Icon(CupertinoIcons.pin, color: Colors.white),
                                          onPressed: () async {
                                            settings.settings.iosShowPin.value =
                                                !settings.settings.iosShowPin.value;
                                            saveSettings();
                                          },
                                        ),
                                      ),
                                    ),
                                    CupertinoButton(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: settings.settings.iosShowPin.value
                                                  ? context.theme.colorScheme.primary
                                                  : tileColor,
                                              border: Border.all(
                                                  color: settings.settings.iosShowPin.value
                                                      ? context.theme.colorScheme.primary
                                                      : inactiveCheckColor,
                                                  style: BorderStyle.solid,
                                                  width: 1),
                                              borderRadius: BorderRadius.all(Radius.circular(25))),
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Icon(CupertinoIcons.check_mark,
                                                size: 18,
                                                color: settings.settings.iosShowPin.value
                                                    ? context.theme.colorScheme.onPrimary
                                                    : inactiveCheckColor),
                                          ),
                                        ),
                                        onPressed: () {
                                          settings.settings.iosShowPin.value =
                                              !settings.settings.iosShowPin.value;
                                          saveSettings();
                                        }),
                                  ]),
                                  Spacer(),
                                  Column(children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text("Left", style: context.theme.textTheme.bodyLarge),
                                    ),
                                    Row(children: [
                                      Column(
                                        children: [
                                          Opacity(
                                            opacity: settings.settings.iosShowAlert.value ? 1 : 0.7,
                                            child: Container(
                                              height: 60,
                                              color: Colors.purple[700],
                                              width: navigatorService.width(context) / 5 - 12,
                                              child: IconButton(
                                                icon: const Icon(CupertinoIcons.bell_slash, color: Colors.white),
                                                onPressed: () async {
                                                  settings.settings.iosShowAlert.value =
                                                      !settings.settings.iosShowAlert.value;
                                                  saveSettings();
                                                },
                                              ),
                                            ),
                                          ),
                                          CupertinoButton(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: settings.settings.iosShowAlert.value
                                                        ? context.theme.colorScheme.primary
                                                        : tileColor,
                                                    border: Border.all(
                                                        color: settings.settings.iosShowAlert.value
                                                            ? context.theme.colorScheme.primary
                                                            : inactiveCheckColor,
                                                        style: BorderStyle.solid,
                                                        width: 1),
                                                    borderRadius: BorderRadius.all(Radius.circular(25))),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(3.0),
                                                  child: Icon(CupertinoIcons.check_mark,
                                                      size: 18,
                                                      color: settings.settings.iosShowAlert.value
                                                          ? context.theme.colorScheme.onPrimary
                                                          : inactiveCheckColor),
                                                ),
                                              ),
                                              onPressed: () {
                                                settings.settings.iosShowAlert.value =
                                                    !settings.settings.iosShowAlert.value;
                                                saveSettings();
                                              }),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Opacity(
                                            opacity: settings.settings.iosShowDelete.value ? 1 : 0.7,
                                            child: Container(
                                              height: 60,
                                              color: Colors.red,
                                              width: navigatorService.width(context) / 5 - 12,
                                              child: IconButton(
                                                icon: const Icon(CupertinoIcons.trash, color: Colors.white),
                                                onPressed: () async {
                                                  settings.settings.iosShowDelete.value =
                                                      !settings.settings.iosShowDelete.value;
                                                  saveSettings();
                                                },
                                              ),
                                            ),
                                          ),
                                          CupertinoButton(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: settings.settings.iosShowDelete.value
                                                        ? context.theme.colorScheme.primary
                                                        : tileColor,
                                                    border: Border.all(
                                                        color: settings.settings.iosShowDelete.value
                                                            ? context.theme.colorScheme.primary
                                                            : inactiveCheckColor,
                                                        style: BorderStyle.solid,
                                                        width: 1),
                                                    borderRadius: BorderRadius.all(Radius.circular(25))),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(3.0),
                                                  child: Icon(CupertinoIcons.check_mark,
                                                      size: 18,
                                                      color: settings.settings.iosShowDelete.value
                                                          ? context.theme.colorScheme.onPrimary
                                                          : inactiveCheckColor),
                                                ),
                                              ),
                                              onPressed: () {
                                                settings.settings.iosShowDelete.value =
                                                    !settings.settings.iosShowDelete.value;
                                                saveSettings();
                                              }),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Opacity(
                                            opacity: settings.settings.iosShowMarkRead.value ? 1 : 0.7,
                                            child: Container(
                                              height: 60,
                                              color: Colors.blue,
                                              width: navigatorService.width(context) / 5 - 12,
                                              child: IconButton(
                                                icon: const Icon(CupertinoIcons.person_crop_circle_badge_exclam,
                                                    color: Colors.white),
                                                onPressed: () {
                                                  settings.settings.iosShowMarkRead.value =
                                                      !settings.settings.iosShowMarkRead.value;
                                                  saveSettings();
                                                  saveSettings();
                                                },
                                              ),
                                            ),
                                          ),
                                          CupertinoButton(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: settings.settings.iosShowMarkRead.value
                                                        ? context.theme.colorScheme.primary
                                                        : tileColor,
                                                    border: Border.all(
                                                        color: settings.settings.iosShowMarkRead.value
                                                            ? context.theme.colorScheme.primary
                                                            : inactiveCheckColor,
                                                        style: BorderStyle.solid,
                                                        width: 1),
                                                    borderRadius: BorderRadius.all(Radius.circular(25))),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(3.0),
                                                  child: Icon(CupertinoIcons.check_mark,
                                                      size: 18,
                                                      color: settings.settings.iosShowMarkRead.value
                                                          ? context.theme.colorScheme.onPrimary
                                                          : inactiveCheckColor),
                                                ),
                                              ),
                                              onPressed: () {
                                                settings.settings.iosShowMarkRead.value =
                                                    !settings.settings.iosShowMarkRead.value;
                                                saveSettings();
                                              }),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Opacity(
                                            opacity: settings.settings.iosShowArchive.value ? 1 : 0.7,
                                            child: Container(
                                              height: 60,
                                              color: Colors.red,
                                              width: navigatorService.width(context) / 5 - 12,
                                              child: IconButton(
                                                icon: const Icon(CupertinoIcons.tray_arrow_down, color: Colors.white),
                                                onPressed: () {
                                                  settings.settings.iosShowArchive.value =
                                                      !settings.settings.iosShowArchive.value;
                                                  saveSettings();
                                                },
                                              ),
                                            ),
                                          ),
                                          CupertinoButton(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: settings.settings.iosShowArchive.value
                                                        ? context.theme.colorScheme.primary
                                                        : tileColor,
                                                    border: Border.all(
                                                        color: settings.settings.iosShowArchive.value
                                                            ? context.theme.colorScheme.primary
                                                            : inactiveCheckColor,
                                                        style: BorderStyle.solid,
                                                        width: 1),
                                                    borderRadius: BorderRadius.all(Radius.circular(25))),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(3.0),
                                                  child: Icon(CupertinoIcons.check_mark,
                                                      size: 18,
                                                      color: settings.settings.iosShowArchive.value
                                                          ? context.theme.colorScheme.onPrimary
                                                          : inactiveCheckColor),
                                                ),
                                              ),
                                              onPressed: () {
                                                settings.settings.iosShowArchive.value =
                                                    !settings.settings.iosShowArchive.value;
                                                saveSettings();
                                              }),
                                        ],
                                      ),
                                    ]),
                                  ]),
                                ],
                              ),
                            ),
                          );
                        } else if (settings.settings.swipableConversationTiles.value) {
                          return Container(
                            color: tileColor,
                            child: Column(
                              children: [
                                SettingsOptions<MaterialSwipeAction>(
                                  initial: settings.settings.materialRightAction.value,
                                  onChanged: (val) {
                                    if (val != null) {
                                      settings.settings.materialRightAction.value = val;
                                      saveSettings();
                                    }
                                  },
                                  options: MaterialSwipeAction.values,
                                  textProcessing: (val) =>
                                      val.toString().split(".")[1].replaceAll("_", " ").capitalizeFirst!,
                                  title: "Swipe Right Action",
                                  backgroundColor: tileColor,
                                  secondaryColor: headerColor,
                                ),
                                SettingsOptions<MaterialSwipeAction>(
                                  initial: settings.settings.materialLeftAction.value,
                                  onChanged: (val) {
                                    if (val != null) {
                                      settings.settings.materialLeftAction.value = val;
                                      saveSettings();
                                    }
                                  },
                                  options: MaterialSwipeAction.values,
                                  textProcessing: (val) =>
                                      val.toString().split(".")[1].replaceAll("_", " ").capitalizeFirst!,
                                  title: "Swipe Left Action",
                                  backgroundColor: tileColor,
                                  secondaryColor: headerColor,
                                ),
                              ],
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                    ],
                  ),
                SettingsHeader(
                    headerColor: headerColor,
                    tileColor: tileColor,
                    iosSubtitle: iosSubtitle,
                    materialSubtitle: materialSubtitle,
                    text: "Misc"),
                SettingsSection(
                  backgroundColor: tileColor,
                  children: [
                    Obx(() => SettingsSwitch(
                          onChanged: (bool val) {
                            settings.settings.moveChatCreatorToHeader.value = val;
                            saveSettings();
                          },
                          initialVal: settings.settings.moveChatCreatorToHeader.value,
                          title: "Move Chat Creator Button to Header",
                          subtitle: "Replaces the floating button at the bottom to a fixed button at the top",
                          backgroundColor: tileColor,
                          isThreeLine: true,
                        )),
                    if (!kIsWeb && !kIsDesktop)
                      Container(
                        color: tileColor,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: SettingsDivider(color: context.theme.colorScheme.surfaceVariant),
                        ),
                      ),
                    if (!kIsWeb && !kIsDesktop)
                      Obx(() => SettingsSwitch(
                            onChanged: (bool val) {
                              settings.settings.cameraFAB.value = val;
                              saveSettings();
                            },
                            initialVal: settings.settings.cameraFAB.value,
                            title: settings.settings.skin.value != Skins.iOS
                                ? "Long Press for Camera"
                                : "Add Camera Button",
                            subtitle: settings.settings.skin.value != Skins.iOS
                                ? "Long press the start chat button to easily send a picture to a chat"
                                : "Adds a dedicated camera button near the new chat creator button to easily send pictures",
                            backgroundColor: tileColor,
                            isThreeLine: true,
                          )),
                  ],
                ),
              ],
            ),
          ),
        ]);
  }

  void saveSettings() {
    settings.saveSettings(settings.settings);
  }
}
