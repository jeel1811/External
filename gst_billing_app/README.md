# GST Billing App

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Version-1.0.0-blue?style=for-the-badge" alt="Version"/>
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License"/>
</div>

A comprehensive GST Billing App developed for TATA Retail Solutions to streamline billing processes, automate GST calculations, and maintain transaction records.

## 📋 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Tech Stack](#tech-stack)
- [Installation](#installation)
- [Usage](#usage)
- [App Architecture](#app-architecture)
- [Screenshots](#screenshots)
- [Contributors](#contributors)
- [License](#license)

## 🔍 Overview

At TATA Retail Solutions, cashiers previously relied on manual calculations for generating bills and computing GST, which led to frequent errors, delays, and compliance risks. This Flutter-based GST Billing App resolves these issues by automating tax calculations, simplifying invoice generation, and maintaining comprehensive sales records.

The app allows staff to quickly add products, apply the correct GST rates (5%, 12%, 18%, or 28%), and generate itemized bills with a clear breakdown of CGST, SGST, and the total amount. It also stores transaction history for future reference and business insights.

## ✨ Key Features

- **Automated GST Calculation**: Correctly calculates CGST and SGST (each at half the GST rate)
- **Dashboard & Analytics**: Provides sales insights with period filtering options
- **Product Management**: Add, edit, delete, and search products
- **Barcode Scanning**: Scan product barcodes for quick addition to bills
- **Invoice Generation**: Create, view, and print detailed GST-compliant invoices
- **Transaction History**: Store and search past invoices for reference
- **Customizable Settings**: Business details, display preferences, and app behavior
- **Print Support**: Generate and print PDF invoices

## 🛠️ Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Local Database**: Hive
- **Data Persistence**: SharedPreferences
- **PDF Generation**: pdf, printing packages
- **Barcode Scanning**: flutter_barcode_scanner

## 📥 Installation

1. **Prerequisites**:
   - Flutter SDK (version 3.0.0 or higher)
   - Dart SDK (version 3.0.0 or higher)
   - Android Studio / Xcode for device emulation

2. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/gst_billing_app.git
   cd gst_billing_app
   ```

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

## 📱 Usage

1. **Dashboard**: View sales analytics and recent invoices
2. **Products Management**: 
   - Add products with name, price, GST percentage, and optional barcode
   - Edit or delete existing products
   - Search products by name or barcode

3. **Creating Bills**:
   - Add products to cart by selecting from list or scanning barcode
   - Specify quantity for each product
   - View real-time subtotal, GST, and total calculations
   - Add optional customer details
   - Generate and print invoice

4. **Invoice History**:
   - View past invoices
   - Filter by date range or search by customer details
   - Print or share existing invoices

5. **Settings**:
   - Update business details
   - Toggle dark mode
   - Configure barcode scanning and printing preferences

## 🏗️ App Architecture

The app follows a clean architecture pattern with separation of concerns:

- **Models**: Data structures for Product, Invoice, InvoiceItem
- **Services**: Database operations and business logic
- **Providers**: State management using the Provider pattern
- **Screens**: UI components and user interaction
- **Utils**: Helper functions and formatters

## 📸 Screenshots

*[Include screenshots of key screens here]*

## 👥 Contributors

- TATA Retail Solutions Team

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

<div align="center">
  <p>© 2023 TATA Retail Solutions. All rights reserved.</p>
</div>
