# 📱 Wellsloan Customer Mobile App (Flutter)

> **Next-Gen Micro-Lending & Instant Credit Platform**  
> Engineered with Clean Architecture, Reactive State Management (Provider), and Multimodal Gemini AI.

---

## 🌟 Overview

The **Wellsloan App** replaces the customer-facing web portal with a high-performance, native mobile banking experience for Android and iOS. Built with modern fintech design principles, the app allows users to get pre-approved micro-loans, perform paperless AI-powered KYC verification, track EMI schedules, make 1-click repayments, and consult an AI Financial Copilot.

---

## 🏛️ System Architecture

The Wellsloan ecosystem is cleanly separated into two distinct components:

```
Wellsloan Ecosystem
├── 🌐 wellsloan-backend (Laravel 11)
│   ├── 🖥️ Admin Web Portal (/admin) — Loan approvals, KYC reviews, audit logs
│   ├── 📡 REST API (/api) — Endpoints for Auth, Loans, KYC, Payments, Eligibility
│   └── 🤖 AI Gateway (/api/ai) — Gemini 3.8 Flash Advisor & Vision OCR Scan
│
└── 📱 wellsloan-app (Flutter Mobile)
    ├── 🎨 Core & Theme — Fintech color tokens, Plus Jakarta Sans typography
    ├── 🔒 Storage & Network — Encrypted secure token storage & Dio client
    ├── 📦 Data Layer — Models & Repositories
    ├── ⚡ Providers — Reactive State Management
    └── 📱 Screens — Auth, Dashboard, Apply Wizard, KYC Hub, Payments, AI Copilot
```

---

## 🎨 UI/UX Design System

Designed by an **App Design Specialist** following global fintech design benchmarks (Apple Card, Revolut, CRED):

| Token | Light Mode | Dark Mode | Usage |
| :--- | :--- | :--- | :--- |
| **Brand Primary** | `#6366F1` | `#4F46E5` | Primary buttons, active tabs, brand accents |
| **Luxury Midnight** | `[#0F172A, #1E1B4B, #31104B]` | Gradients for Pre-Approved Credit Card & Hero banners |
| **Emerald Growth** | `#10B981` | `#059669` | Disbursals, approved states, paid EMIs, growth metrics |
| **Amber Caution** | `#F59E0B` | `#D97706` | In review, upcoming due dates, KYC pending |
| **Rose Alert** | `#EF4444` | `#DC2626` | Overdue EMIs, rejected states, sign-out actions |
| **Background** | `#F8FAFC` | `#0B0F19` | Modern contrast, frictionless reading |

---

## 🚀 Key Feature Modules

### 1. ⚡ Dynamic Dashboard & Credit Limit
- **Pre-Approved Sanction Card**: Real-time credit limit gauge with interest rates from 11.99% p.a.
- **Active Loans Carousel**: Visual loan progress bars, outstanding balances, and next EMI reminders.
- **Upcoming Due Banner**: Proactive countdowns with 1-click pay action.

### 2. 📝 4-Step Loan Application Wizard
- **Dual Interactive Sliders**: Live amount & tenure selector (₹10,000 to ₹5,00,000; 3 to 36 months).
- **Real-Time Amortization**: Instant EMI formula calculation ($EMI = P \times r \times (1+r)^n / ((1+r)^n - 1)$).
- **Automated Underwriting**: Backend validation against monthly income and FOIR benchmark.

### 3. 🛡️ Multimodal AI KYC Verification Hub
- **Government ID Support**: Aadhaar Card, PAN Card, Passport, Driving License, Voter ID.
- **Gemini Vision OCR**: Live document scanner that extracts cardholder name, ID number, and verifies security patterns.
- **Real-time Status Tracking**: Instant visual badges (Verified, In Review, Action Required).

### 4. 💳 1-Click EMI Repayment & History
- **Multi-Method Checkout**: UPI (Google Pay, PhonePe, Paytm), Debit Card, and NetBanking.
- **Instant Digital Receipts**: Confirmation animations and transaction reference tracking.
- **Amortization Schedule**: Full breakdown of principal vs interest paid to date.

### 5. 🤖 Gemini 3.8 Flash AI Financial Advisor
- **Conversational Copilot**: Context-aware chat with borrower name, income, and debt context injected.
- **Smart Financial Queries**: Affordability assessments, tenure comparisons, and interest reduction tips.
- **Quick Action Pills**: One-tap suggested prompts for instant financial advice.

### 6. 🔐 Security & Preferences
- **Biometric App Lock**: Integrated Face ID and Fingerprint hardware authentication.
- **Secure Encrypted Storage**: Zero plain-text token exposure on device.
- **API Environment Switcher**: Toggle seamlessly between Production (Hostinger) and Local Development.

---

## 🛠️ How to Run the Flutter App

### Prerequisites
- Flutter SDK (v3.10.0 or higher)
- Android Studio / Xcode

### Setup & Launch
```bash
# 1. Navigate to app directory
cd wellsloan-app

# 2. Get dependencies
flutter pub get

# 3. Run on connected device or emulator
flutter run
```

### Backend Connection
The app connects by default to the production Wellsloan cloud backend:
- API Base URL: `https://wellsloan.wellsee.co.in/api`
