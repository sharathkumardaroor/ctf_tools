# CTF Analyzer Dashboard

A comprehensive Flutter-based dashboard application designed for cybersecurity professionals and CTF (Capture The Flag) enthusiasts to analyze files, manage challenges, and perform forensic analysis.

## 🚀 Features

### File Analysis
- **Multi-format File Support**: Analyze various file types including executables, archives, images, and text files
- **Hash Generation**: Generate MD5, SHA1, SHA256, and other cryptographic hashes
- **Metadata Extraction**: Extract EXIF data, file properties, and embedded information
- **String Extraction**: Find readable strings within binary files
- **Security Scanning**: Identify potential security flags and vulnerabilities
- **Hex Viewer**: Built-in hexadecimal viewer for low-level file inspection

### CTF Challenge Management
- **Challenge Tracking**: Organize challenges by category (Web, Crypto, Forensics, Reversing, PWN, MISC, OSINT, Steganography)
- **Difficulty Levels**: Categorize challenges from Easy to Insane
- **Progress Tracking**: Monitor solved/unsolved challenges with timestamps
- **Note Taking**: Add notes and observations for each challenge
- **File Association**: Link challenge files for easy access

### Forensics Tools
- **Network Analysis**: Analyze network traffic and protocols
- **Timeline Analysis**: Create and visualize event timelines
- **Statistics Dashboard**: View analysis statistics and metrics
- **Tools Panel**: Quick access to common forensic tools

### User Interface
- **Dark Theme**: Cybersecurity-focused dark theme with neon accents
- **Responsive Design**: Works across desktop, web, and mobile platforms
- **Tabbed Interface**: Organized workspace with multiple analysis views
- **Real-time Updates**: Live updates using Provider state management

## 🛠️ Technology Stack

- **Framework**: Flutter 3.8.1+
- **Language**: Dart
- **State Management**: Provider
- **UI Components**: Material Design 3
- **File Handling**: file_picker, crypto, convert
- **Data Visualization**: fl_chart
- **Binary Analysis**: hex, image
- **Network**: http

## 📋 Prerequisites

- Flutter SDK 3.8.1 or higher
- Dart SDK
- Android Studio / VS Code (recommended)
- Git

## 🚀 Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd dashboard_gui
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

## 🖥️ Platform Support

- ✅ **Linux** (Primary development platform)
- ✅ **Windows** 
- ✅ **macOS**
- ✅ **Web**
- ✅ **Android**
- ✅ **iOS**

## 📱 Usage

### File Analysis
1. Click on the "Upload File" button or drag and drop files
2. Select the file you want to analyze
3. View comprehensive analysis results including:
   - File metadata and properties
   - Cryptographic hashes
   - Extracted strings
   - Security flags and recommendations
   - Hex dump view

### Challenge Management
1. Navigate to the "Challenges" tab
2. Add new CTF challenges with details:
   - Name and description
   - Category and difficulty
   - Points and tags
   - Associated files
3. Track progress and add notes
4. Mark challenges as solved with flags

### Forensics Analysis
1. Use the "Forensics" tab for advanced analysis
2. Analyze network traffic patterns
3. Create timeline visualizations
4. Access specialized forensic tools

## 🏗️ Project Structure

```
lib/
├── main.dart                 # Application entry point
├── models/                   # Data models
│   ├── file_analysis_result.dart
│   └── ctf_challenge.dart
├── providers/                # State management
│   ├── file_analysis_provider.dart
│   └── ctf_challenge_provider.dart
├── screens/                  # UI screens
│   └── dashboard_screen.dart
├── services/                 # Business logic
│   └── file_analyzer_service.dart
└── widgets/                  # Reusable UI components
    ├── analysis_results_widget.dart
    ├── challenge_list_widget.dart
    ├── file_upload_widget.dart
    ├── forensics_widget.dart
    ├── hex_viewer_widget.dart
    ├── network_analysis_widget.dart
    ├── statistics_widget.dart
    ├── timeline_widget.dart
    └── tools_panel_widget.dart
```

## 🔧 Configuration

The application uses a dark cybersecurity theme with the following color scheme:
- Primary: `#00D4FF` (Cyan)
- Secondary: `#7C3AED` (Purple)
- Background: `#0D1117` (Dark)
- Surface: `#161B22` (Dark Gray)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🐛 Known Issues

- Large file analysis may take time depending on system resources
- Some advanced forensic features are still in development

## 🔮 Roadmap

- [ ] Plugin system for custom analyzers
- [ ] Cloud storage integration
- [ ] Team collaboration features
- [ ] Advanced malware analysis
- [ ] Machine learning-based file classification
- [ ] Export analysis reports

## 📞 Support

For support, questions, or feature requests, please open an issue on the GitHub repository.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Cybersecurity community for inspiration and feedback
- CTF community for use cases and requirements

---

**Built with ❤️ for the cybersecurity community**
