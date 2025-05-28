# Student Budget AI

An AI-powered budget tracking app designed specifically for students, featuring intelligent expense categorization, receipt scanning, and personalized financial insights.

## Features

- 🤖 **AI-Powered Expense Tracking**: Natural language transaction entry with smart categorization
- 📸 **Receipt Scanning**: OCR-powered receipt processing and data extraction
- 🎤 **Voice Commands**: Add expenses and query data using voice input
- 📊 **Smart Analytics**: Personalized insights and spending pattern analysis
- 💰 **Budget Management**: Set and track budgets with intelligent recommendations
- 🔮 **Predictive Insights**: Cash flow forecasting and spending alerts

## Tech Stack

- **Frontend**: Flutter (Dart)
- **State Management**: Provider
- **Local Database**: Hive (NoSQL)
- **AI Processing**: OpenAI API
- **OCR**: Google ML Kit
- **Charts**: FL Chart

## Quick Start

### Prerequisites

- Flutter SDK 3.16+
- Dart 3.2+
- Android Studio / VS Code
- OpenAI API key (for AI features)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/student_budget_ai.git
   cd student_budget_ai
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Generate code (for Hive adapters)**

   ```bash
   flutter packages pub run build_runner build
   ```

4. **Set up environment variables**
   Create a `.env` file in the root directory:

   ```
   OPENAI_API_KEY=your_openai_api_key_here
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app/                      # App configuration
│   ├── app.dart             # Main app widget
│   ├── theme.dart           # App theme
│   └── routes.dart          # Navigation setup
├── core/                     # Core utilities
│   ├── constants/           # App constants
│   ├── services/            # Core services
│   └── utils/               # Utility functions
├── features/                 # Feature modules
│   ├── dashboard/           # Dashboard feature
│   ├── transactions/        # Transaction management
│
```
