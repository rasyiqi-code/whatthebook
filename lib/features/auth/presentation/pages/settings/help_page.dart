import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bantuan')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Pusat Bantuan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('FAQ (Pertanyaan Umum)'),
            subtitle: const Text(
              'Temukan jawaban untuk pertanyaan yang sering diajukan',
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showFAQDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Panduan Pengguna'),
            subtitle: const Text('Pelajari cara menggunakan aplikasi'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showUserGuideDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.video_library),
            title: const Text('Tutorial Video'),
            subtitle: const Text('Tonton video tutorial langkah demi langkah'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showTutorialDialog(context);
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Hubungi Kami',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email Support'),
            subtitle: const Text('support@alhudalibrary.com'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _launchEmail();
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Live Chat'),
            subtitle: const Text('Chat langsung dengan tim support'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showLiveChatDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Telepon'),
            subtitle: const Text('+62 21 1234 5678'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _launchPhone();
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Laporkan Masalah',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Laporkan Bug'),
            subtitle: const Text('Laporkan masalah teknis yang Anda temukan'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showBugReportDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Kirim Feedback'),
            subtitle: const Text('Berikan saran untuk perbaikan aplikasi'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showFeedbackDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('Laporkan Konten'),
            subtitle: const Text('Laporkan konten yang tidak pantas'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showContentReportDialog(context);
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Informasi Aplikasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Tentang Aplikasi'),
            subtitle: const Text('Versi 1.0.0'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Syarat & Ketentuan'),
            subtitle: const Text('Baca syarat penggunaan aplikasi'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, '/terms');
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Kebijakan Privasi'),
            subtitle: const Text(
              'Pelajari bagaimana kami melindungi data Anda',
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, '/privacy');
            },
          ),
        ],
      ),
    );
  }

  void _showFAQDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('FAQ'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Q: Bagaimana cara membuat buku baru?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('A: Buka tab "Buku Saya" dan tap tombol "Buat Buku Baru".'),
              SizedBox(height: 16),
              Text(
                'Q: Bagaimana cara mengikuti penulis lain?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('A: Kunjungi profil penulis dan tap tombol "Follow".'),
              SizedBox(height: 16),
              Text(
                'Q: Bagaimana cara menyimpan buku favorit?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('A: Tap ikon bookmark pada halaman detail buku.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showUserGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Panduan Pengguna'),
        content: const Text(
          'Panduan lengkap akan segera tersedia. Sementara itu, Anda dapat menggunakan fitur FAQ atau menghubungi support untuk bantuan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showTutorialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tutorial Video'),
        content: const Text(
          'Video tutorial sedang dalam proses pembuatan. Akan segera tersedia di channel YouTube kami.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showLiveChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Live Chat'),
        content: const Text(
          'Fitur live chat akan segera tersedia. Sementara itu, silakan hubungi kami melalui email atau telepon.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showBugReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Laporkan Bug'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Judul Bug',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Deskripsi Bug',
                border: OutlineInputBorder(),
                hintText: 'Jelaskan masalah yang Anda alami...',
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
                const SnackBar(content: Text('Laporan bug telah dikirim')),
              );
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kirim Feedback'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Subjek',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Feedback Anda',
                border: OutlineInputBorder(),
                hintText: 'Berikan saran atau masukan...',
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
                const SnackBar(content: Text('Feedback telah dikirim')),
              );
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  void _showContentReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Laporkan Konten'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'URL atau ID Konten',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Alasan Pelaporan',
                border: OutlineInputBorder(),
                hintText: 'Jelaskan mengapa konten ini tidak pantas...',
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
                const SnackBar(content: Text('Laporan konten telah dikirim')),
              );
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tentang Alhuda Library'),
        content: const Text(
          'Alhuda Library App adalah platform untuk membaca dan menulis buku secara digital. '
          'Bergabunglah dengan komunitas penulis dan pembaca dari seluruh Indonesia.\n\n'
          'Versi: 1.0.0\n'
          'Build: 100\n'
          'Dikembangkan dengan ❤️ Oleh Rasyiqi - PT. Retas Lintas Batas di Indonesia',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@alhudalibrary.com',
      query: 'subject=Bantuan Alhuda Library',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+6221123456789');

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}
