# Changelog - KasirKu

All notable changes to this project will be documented in this file.

## [1.0.0] - 2024-XX-XX

### Added
- Initial release of KasirKu
- Complete point-of-sale system for small businesses

### Features

#### Products Module
- Add/edit/delete products
- Barcode support with manual entry
- Category management
- Stock tracking
- Low stock alerts
- Product search and filtering

#### Kasir (Point of Sale)
- Quick product selection
- Shopping cart functionality
- Quantity adjustment
- Per-item discount
- Multiple payment methods:
  - Cash (Tunai)
  - QRIS (Static QR)
  - Bank Transfer
- Automatic change calculation
- Transaction history

#### Suppliers Module
- Supplier database
- Contact information
- Debt tracking
- Supplier notes

#### Reports Module
- Sales reports (daily/weekly/monthly)
- Top selling products
- Low stock inventory
- Financial analysis
- Payment method breakdown
- Date range filtering

#### Settings
- Store information management
- Tax (PPN) configuration
- Database backup & restore
- Excel export/import
- Category management

### Technical
- Flutter 3.x framework
- Riverpod for state management
- SQLite local database
- Clean Architecture
- Mobile-first design
- Offline-first functionality

## [Planned for v1.1.0]
- [ ] Dynamic QRIS integration
- [ ] Bluetooth printer support
- [ ] Cloud sync
- [ ] Multi-user support
- [ ] Customer database

## [Planned for v1.2.0]
- [ ] Purchase order system
- [ ] Expense tracking
- [ ] Profit/loss reports
- [ ] Advanced analytics

---

## Installation Notes

### Development Environment
- Flutter SDK: 3.x
- Dart SDK: 3.x
- Android SDK: 34+
- iOS: 12.0+

### Database
- Local SQLite database
- Automatic schema migration
- JSON backup/restore capability

---

For support and questions:
- Email: support@kasirku.app
- Website: www.kasirku.app
