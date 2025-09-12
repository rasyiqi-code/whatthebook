import 'package:flutter/material.dart';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  bool _privateProfile = false;
  bool _showEmail = false;
  bool _allowMessages = true;
  bool _twoFactorAuth = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privasi & Keamanan')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Privasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Profil Privat'),
            subtitle: const Text(
              'Hanya pengikut yang dapat melihat buku dan aktivitas Anda',
            ),
            value: _privateProfile,
            onChanged: (bool value) {
              setState(() {
                _privateProfile = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Tampilkan Email'),
            subtitle: const Text('Email Anda akan terlihat di profil publik'),
            value: _showEmail,
            onChanged: (bool value) {
              setState(() {
                _showEmail = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Izinkan Pesan'),
            subtitle: const Text(
              'Pengguna lain dapat mengirim pesan kepada Anda',
            ),
            value: _allowMessages,
            onChanged: (bool value) {
              setState(() {
                _allowMessages = value;
              });
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Keamanan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Autentikasi Dua Faktor'),
            subtitle: const Text(
              'Tambahkan lapisan keamanan ekstra untuk akun Anda',
            ),
            value: _twoFactorAuth,
            onChanged: (bool value) {
              setState(() {
                _twoFactorAuth = value;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Ubah Password'),
            subtitle: const Text('Perbarui password akun Anda'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showChangePasswordDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Sesi Aktif'),
            subtitle: const Text(
              'Kelola perangkat yang terhubung ke akun Anda',
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showActiveSessionsDialog();
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Data & Akun',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Unduh Data Saya'),
            subtitle: const Text('Dapatkan salinan data akun Anda'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showDownloadDataDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Hapus Akun',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text(
              'Hapus akun dan semua data Anda secara permanen',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red),
            onTap: () {
              _showDeleteAccountDialog();
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Kebijakan & Hukum',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Kebijakan Privasi'),
            subtitle: const Text('Baca kebijakan privasi aplikasi kami'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, '/privacy');
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Syarat & Ketentuan'),
            subtitle: const Text('Baca syarat dan ketentuan penggunaan'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, '/terms');
            },
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Password'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password Lama',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password Baru',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Konfirmasi Password Baru',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password berhasil diubah')),
              );
            },
            child: const Text('Ubah'),
          ),
        ],
      ),
    );
  }

  void _showActiveSessionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sesi Aktif'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.phone_android),
              title: Text('Android - Samsung Galaxy'),
              subtitle: Text('Aktif sekarang'),
              trailing: Text('Saat ini'),
            ),
            ListTile(
              leading: Icon(Icons.computer),
              title: Text('Windows - Chrome'),
              subtitle: Text('Jakarta, Indonesia'),
              trailing: Text('2 jam lalu'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Semua sesi lain telah diakhiri')),
              );
            },
            child: const Text('Akhiri Sesi Lain'),
          ),
        ],
      ),
    );
  }

  void _showDownloadDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unduh Data'),
        content: const Text(
          'Kami akan mengirimkan file berisi semua data akun Anda ke email yang terdaftar. Proses ini mungkin membutuhkan waktu hingga 24 jam.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Permintaan unduh data telah dikirim'),
                ),
              );
            },
            child: const Text('Kirim Permintaan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Akun'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus akun? Tindakan ini tidak dapat dibatalkan dan semua data Anda akan hilang permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showFinalDeleteConfirmation();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Hapus Akun',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Terakhir'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ketik "HAPUS AKUN" untuk mengkonfirmasi:'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'HAPUS AKUN',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Akun akan dihapus dalam 30 hari'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Hapus Permanen',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
