import 'package:flutter/material.dart';

class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() =>
      _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _newFollowerNotif = true;
  bool _newCommentNotif = true;
  bool _newLikeNotif = true;
  bool _newBookNotif = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Notifikasi Push'),
            subtitle: const Text(
              'Terima notifikasi langsung di perangkat Anda',
            ),
            value: _pushNotifications,
            onChanged: (bool value) {
              setState(() {
                _pushNotifications = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Notifikasi Email'),
            subtitle: const Text('Terima notifikasi melalui email'),
            value: _emailNotifications,
            onChanged: (bool value) {
              setState(() {
                _emailNotifications = value;
              });
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Jenis Notifikasi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Pengikut Baru'),
            subtitle: const Text('Ketika seseorang mengikuti Anda'),
            value: _newFollowerNotif,
            onChanged: (bool value) {
              setState(() {
                _newFollowerNotif = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Komentar Baru'),
            subtitle: const Text('Ketika seseorang mengomentari buku Anda'),
            value: _newCommentNotif,
            onChanged: (bool value) {
              setState(() {
                _newCommentNotif = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Suka Baru'),
            subtitle: const Text('Ketika seseorang menyukai buku Anda'),
            value: _newLikeNotif,
            onChanged: (bool value) {
              setState(() {
                _newLikeNotif = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Buku Baru'),
            subtitle: const Text(
              'Ketika penulis yang Anda ikuti menerbitkan buku baru',
            ),
            value: _newBookNotif,
            onChanged: (bool value) {
              setState(() {
                _newBookNotif = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
