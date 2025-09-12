> **Note:** This source code is intended for developers with experience in Flutter and mobile/web app deployment. Basic Flutter/Dart knowledge is required.

# Alhuda Library

A comprehensive Flutter-based digital book platform that enables users to read, write, and share books. Built with modern Clean Architecture and featuring a robust role-based system, this application provides a complete solution for digital publishing and reading.

## 🚀 Features

### 📚 **Advanced Book Management**
- **Rich Text Editor**: Create and edit books with Flutter Quill WYSIWYG editor
- **Chapter Management**: Organize content with unlimited chapters and auto-save
- **PDF Support**: Upload and read PDF books with Syncfusion PDF viewer
- **Book Status System**: Draft → Completed → Published workflow
- **Cover Image Upload**: Custom book covers with image optimization
- **Genre & Tags**: Organize books with categories and tags

### 👥 **Multi-Role System**
- **Reader Role**: Browse, read, bookmark, comment, follow authors
- **Author Role**: Create books, edit chapters, manage content, track productivity
- **Publisher Role**: Review books, publish content, manage PDF books
- **Admin Role**: Full system access, user management, content moderation

### 📖 **Enhanced Reading Experience**
- **Responsive Online Reader**: Rich text reading with proper formatting
- **Professional PDF Viewer**: Syncfusion PDF viewer with bookmark system
- **Reading Progress**: Cloud and local storage for progress tracking
- **Bookmark System**: Add bookmarks to books and PDF pages
- **Search Functionality**: Text search within PDF documents
- **Dark/Light Theme**: Toggle between reading themes

### 🏆 **Gamification & Analytics**
- **Achievements System**: Track productivity with 5 key metrics
- **Author Leaderboard**: Weekly, monthly, and all-time rankings
- **Productivity Charts**: Time series data with community comparison
- **Reading Lists**: Create public and private reading lists
- **Social Features**: Comments, likes, follows, book views tracking

### 🎨 **Modern UI/UX**
- **Material Design 3**: Modern UI with green theme (#7AC142)
- **Responsive Design**: Works on web, mobile, and desktop
- **Multi-language Support**: English and Indonesian
- **Dynamic Layouts**: Adaptive card layouts based on screen size
- **Smooth Animations**: Professional transitions and interactions

## 🛠️ Technical Stack

### **Framework & Architecture**
- **Flutter 3.8.1** with Dart 3.0+
- **Clean Architecture** with BLoC pattern
- **Supabase Backend** (PostgreSQL + Auth + Storage)
- **Dependency Injection** with GetIt

### **Key Dependencies**
- **State Management**: flutter_bloc, equatable
- **Rich Text**: flutter_quill with extensions
- **PDF Handling**: syncfusion_flutter_pdfviewer, flutter_pdfview
- **Charts**: fl_chart for analytics
- **Storage**: hive for local storage, shared_preferences
- **UI Components**: image_picker, share_plus, timeago

### **Platform Support**
- ✅ **Web** (Primary platform)
- ✅ **Android** (Full support)
- ✅ **iOS** (Full support)

## 🎯 Use Cases

### **For Authors**
- Create and manage books with rich text editor
- Track writing productivity and achievements
- Build author profile and following
- Publish books through workflow system

### **For Publishers**
- Review and approve author submissions
- Manage PDF book library
- Track publishing metrics
- Curate content for readers

### **For Readers**
- Discover books by category and recommendations
- Read books online or download PDFs
- Track reading progress across devices
- Engage with authors through comments and likes

### **For Administrators**
- Manage user roles and permissions
- Monitor system analytics
- Moderate content and comments
- Configure platform settings

## 💡 Value Proposition

### **Complete Digital Publishing Solution**
- End-to-end book creation and publishing workflow
- Professional reading experience with advanced features
- Social engagement and community building
- Analytics and productivity tracking

### **Scalable Architecture**
- Clean, maintainable codebase
- Role-based access control
- Multi-platform support
- Cloud-based backend with local fallbacks

### **Modern User Experience**
- Intuitive interface design
- Responsive across all devices
- Fast performance with caching
- Accessibility features

## 📊 Features Breakdown

### **Book Creation (Author)**
- Rich text editor with formatting tools
- Chapter management with auto-save
- Book cover upload and optimization
- Status management (Draft → Completed → Published)
- Word count and progress tracking

### **Book Reading (Reader)**
- Responsive online reader
- Professional PDF viewer with bookmarks
- Reading progress synchronization
- Search functionality within PDFs
- Dark/light theme toggle

### **Social Features**
- Comment system for books and chapters
- Like/unlike books
- Follow authors
- Public/private reading lists
- Book view tracking

### **Analytics & Gamification**
- 5 productivity metrics tracking
- Time series charts
- Author leaderboards
- Achievement system
- Community comparison

### **Admin Features**
- User role management
- Content moderation
- System analytics
- Platform configuration

## 🔧 Installation & Setup

### **Prerequisites**
- Flutter SDK 3.8.1 or higher
- Dart 3.0+
- Supabase account (free tier available)
- Firebase account (for hosting)
- Git
- IDE (VS Code recommended, or Android Studio/IntelliJ IDEA)

### **Quick Setup**
1. Clone the repository
2. Run `flutter pub get`
3. Configure Supabase credentials
4. Run database migrations
5. Start development server

### **IDE Setup (Recommended)**
**VS Code (Recommended)**:
1. Install VS Code and Flutter/Dart extensions
2. Configure Flutter SDK path in settings
3. Install recommended extensions for Flutter development
4. Open project and run `flutter pub get`

**Android Studio**:
1. Install Android Studio and Flutter plugin
2. Configure Flutter SDK path
3. Open project and verify setup with `flutter doctor`

### **Firebase Deployment**
1. Install Firebase CLI: `npm install -g firebase-tools`
2. Install FlutterFire CLI: `dart pub global activate flutterfire_cli`
3. Login to Firebase: `firebase login`
4. Configure Firebase: `flutterfire configure`
5. Build the app: `flutter build web`
6. Deploy: `firebase deploy --only hosting`

### **Android Build & Signing**
1. Generate keystore: `keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
2. Configure `android/key.properties` with keystore details
3. Update `android/app/build.gradle` with signing config
4. Get SHA fingerprints: `keytool -list -v -keystore ~/upload-keystore.jks -alias upload`
5. **⚠️ CRITICAL**: Add SHA fingerprints to Firebase Console (Project Settings → General → Your apps → Android app → Add fingerprint)
6. Build app bundle: `flutter build appbundle --release`

### **iOS Build & Signing**
1. Configure Apple Developer account and certificates
2. Update bundle identifier in Xcode
3. Configure signing in "Signing & Capabilities"
4. Build for iOS: `flutter build ios --release`
5. Archive in Xcode: Product → Archive
6. Upload to App Store Connect

### **Package Name Customization**
**Android**:
1. Update `android/app/build.gradle` (applicationId)
2. Update all `AndroidManifest.xml` files
3. Rename directory structure in `android/app/src/main/kotlin/`
4. Update package declaration in `MainActivity.kt`

**iOS**:
1. Update bundle identifier in Xcode project settings
2. Update `ios/Runner/Info.plist`

**Web**:
1. Update `web/index.html` title and description
2. Update `web/manifest.json` app name

For detailed installation and deployment instructions, see [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md)

## 📱 Demo Information

### **Live Demo**
- **URL**: [https://alhuda-library-demo.web.app](https://alhuda-library-demo.web.app)
- **Test Accounts**: Available in [DEMO_CREDENTIALS.md](DEMO_CREDENTIALS.md)

### **Demo Features**
- All roles and permissions
- Sample books and PDFs
- Social features demonstration
- Analytics and leaderboards

## 🎨 Customization

### **Branding**
- Easy color scheme customization
- Logo and app name changes
- Theme modifications
- Custom styling options

### **Features**
- Enable/disable features by role
- Custom permission system
- Additional social features
- Extended analytics

### **Integration**
- Third-party authentication
- Payment gateway integration
- Email service integration
- Custom API endpoints

## 📞 Support

### **Documentation**
- Complete installation guide
- API documentation
- Customization guide
- Troubleshooting guide

### **Support Policy**
- 6 months included support
- Bug fixes and updates
- Installation assistance
- Basic customization help

## 🚀 Ready for Production

This application is production-ready with:
- ✅ Clean, well-documented code
- ✅ Comprehensive error handling
- ✅ Security best practices
- ✅ Performance optimization
- ✅ Cross-platform compatibility
- ✅ Scalable architecture

Perfect for digital publishing platforms, educational institutions, or any organization looking to create a comprehensive book reading and writing platform.

## 📋 Documentation

- [Installation Guide](INSTALLATION_GUIDE.md) - Complete setup instructions
- [Demo Credentials](DEMO_CREDENTIALS.md) - Demo account information
- [Changelog](CHANGELOG.md) - Version history and updates
- [License](LICENSE.md) - Commercial license terms
- [Support Policy](SUPPORT_POLICY.md) - Support terms and conditions

## 🔄 Development

### **Architecture**
- **Clean Architecture**: Separation of concerns
- **BLoC Pattern**: State management
- **Dependency Injection**: GetIt for service management
- **Error Handling**: Comprehensive error management

### **Database Schema**
- **Users**: User profiles with role management (reader, author, publisher, admin)
- **Books**: Book metadata with genre, tags, and status management
- **Chapters**: Chapter content with word count and status tracking
- **PDF Books**: PDF book management with metadata (author, ISBN, pages, file size)
- **Reading Progress**: User reading tracking for both books and PDFs with progress percentage
- **Bookmarks**: User bookmarks for books and PDFs with page tracking and notes
- **PDF Bookmarks**: Dedicated bookmark system for PDF files with page indexing
- **Comments**: Social interaction system with nested comments and threading
- **Book Likes**: Like system for books with unique constraints
- **Book Views**: View tracking and analytics with timestamp
- **Follows**: Author following system with self-follow prevention
- **Reading Lists**: Public and private reading collections
- **Reading List Books**: Junction table for reading lists with unique constraints
- **Reviews**: Book rating and review system (1-5 stars) with unique user-book constraint
- **Banners**: Promotional content management with active status
- **Views**: Advanced analytics views for user stats, productivity, leaderboards, and book metadata

### **Security Features**
- **Row Level Security (RLS)**: Database-level permissions
- **Role-Based Access Control**: Granular feature permissions
- **Authentication**: Secure user authentication via Supabase
- **Authorization**: Role-based feature access
- **Data Protection**: User privacy and data security

## 📈 Performance & Analytics

### **Productivity Tracking**
- **Total Words Written**: Track author productivity with word count
- **Books Published**: Count of published books by status
- **Chapters Published**: Chapter completion tracking with status
- **Reviews Written**: Comment and review activity tracking
- **Likes Received**: Social engagement metrics from book likes
- **Books Read**: Reading progress tracking for completed books
- **Reading Streak**: Continuous reading activity tracking
- **Writing Streak**: Continuous writing activity tracking

### **Reading Analytics**
- **Progress Tracking**: Cloud and local storage with percentage tracking
- **Reading Statistics**: Time spent, pages read, last read timestamp
- **Bookmark Analytics**: Popular bookmark locations with notes and names
- **Engagement Metrics**: Comments, likes, shares, and view tracking
- **PDF Analytics**: Page-level tracking for PDF documents
- **Chapter Progress**: Individual chapter completion tracking

### **Community Analytics**
- **Popular Books**: Most viewed and liked books with recent views tracking
- **Top Authors**: Most productive authors with leaderboards (weekly, monthly, all-time)
- **Trending Content**: What's popular this week with view analytics
- **User Growth**: Platform adoption metrics with productivity tracking
- **Community Productivity**: Monthly productivity comparisons across users
- **Author Rankings**: Rating-based leaderboards with review counts

## 🎯 Target Market

### **Primary Users**
- **Publishing Companies**: Digital book platforms
- **Educational Institutions**: Digital libraries
- **Content Creators**: Personal publishing
- **Startups**: MVP for book platforms

### **Use Cases**
- **Digital Publishing**: Complete publishing workflow
- **Educational Platforms**: Student reading tracking
- **Community Building**: Social reading platform
- **Monetization**: Subscription and payment ready

## 💰 Monetization Ready

### **Built-in Features**
- User subscription system
- Premium content access
- Author revenue sharing
- Advertisement integration

### **Payment Integration**
- Stripe integration ready
- PayPal integration ready
- In-app purchases
- Subscription management

## 🔄 Regular Updates

### **Version 1.0.0**
- ✅ Complete role-based system
- ✅ Book management features
- ✅ Reading experience
- ✅ Social features
- ✅ Gamification system

### **Future Updates**
- 🔄 AI-powered recommendations
- 🔄 Advanced analytics
- 🔄 Multi-language support
- 🔄 Advanced search filters

## 📋 Requirements

### **Development**
- Flutter SDK 3.8.1+
- Dart 3.0+
- Supabase account (free tier available)
- Git

### **Deployment**
- Web hosting (Vercel, Netlify, Firebase)
- Mobile app stores (Google Play, App Store)
- Supabase project (production plan recommended)

## 🎉 Why Choose Alhuda Library?

### **Complete Solution**
- Ready-to-deploy application
- Comprehensive documentation
- Professional code quality
- Scalable architecture

### **Modern Technology**
- Latest Flutter framework
- Supabase backend
- Clean architecture
- Best practices

### **Business Ready**
- Monetization features
- Multi-platform support
- Customization options
- Professional support

---

**Alhuda Library v1.0.0** - Your Complete Digital Book Platform Solution

*Built with ❤️ using Flutter & Supabase*
