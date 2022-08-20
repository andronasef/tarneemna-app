import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tarneemna/screens/markdown/markdown_screen.dart';

import '../../core/values.dart';
import '../../utils/open_urls.dart';
import '../home/home_controller.dart';
import 'cwidgets/settings_tile.dart';
import 'cwidgets/settings_title.dart';

class SettingsScreen extends GetView<HomeController> {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("الاعدادات"),
          leading: const BackButton(),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            const SettingsTitle("الاعدادات (قيد الانشاء)"),
            const SettingsTitle("ساعدنا"),
            /*Rate 5 stars*/ SettingsListTile(
              title: "قيم التطبيق بخمس نجوم",
              icon: Icons.star,
              action: () => openUrl(AppUrls.rate),
            ),
            // /*More Apps*/ SettingsListTile(
            //   title: "More Apps",
            //   icon: Icons.apps_rounded,
            //   action: () => openUrl(AppUrls.moreapps),
            // ),
            /*Share the app*/ SettingsListTile(
              title: "شارك التطبيق لتعم الاستفادة",
              icon: Icons.share,
              action: () => Share.share(
                  "دلوقتي تقدر تحمل الترانيم بسهولة اكتر عن طريق تطبيق ترانيمنا: ${AppUrls.share}"),
            ),
            /*Become a supporter 
            SettingsListTile(
                title: "Become a supporter",
                icon: FontAwesome5.heart,
                action: () => openUrl(AppUrls.patreon)), */
            /*Request a feuture*/ SettingsListTile(
              title: "اطلب ميزة",
              icon: Icons.lightbulb,
              action: () => openUrl(AppUrls.support),
            ),
            /*Report  a bug*/ SettingsListTile(
              title: "بلغ عن مشكلة",
              icon: Icons.bug_report,
              action: () => openUrl(AppUrls.support),
            ),
            const SettingsTitle("المزيد"),
            // /*Changelog*/ SettingsListTile(
            //   title: "Changelog",
            //   icon: Icons.published_with_changes_rounded,
            //   action: () => Get.toNamed(Routes.changeLog),
            // ),
            /*Privacy Policy*/ SettingsListTile(
              title: "سياسة الخصوصية",
              icon: Icons.privacy_tip,
              action: () =>
                  Get.to(const MarkdownPage("assets/md/tarneemna.md")),
            ),
            // /*Contact us*/ SettingsListTile(
            //   title: "تواصل معنا",
            //   icon: Icons.whatsapp,
            //   action: () => openUrl(AppUrls.contact),
            // ),
            /*About us
            SettingsListTile(
              title: "About us",
              icon: Icons.info,
              action: () => openUrlWebView(AppUrls.about),
            ),*/
          ],
        ),
      ),
    );
  }
}
