# Kara Defter Mobil Uygulaması - Proje Yapısı

## Uygulama Özellikleri

### Ana Özellikler
- **Müşteri Yönetimi**: Müşteri/kişi ekleme, düzenleme, silme
- **İşlem Kayıtları**: Alacak/borç işlemlerini kaydetme
- **Özet Görünümü**: Toplam alacak/borç durumu
- **Geçmiş Takibi**: Tarih bazlı işlem geçmişi
- **Arama/Filtreleme**: Müşteri ve işlem arama
- **Veri Yedekleme**: Yerel depolama ve yedekleme

### Teknik Özellikler
- **Offline Çalışma**: İnternet bağlantısı olmadan kullanım
- **Yerel Veritabanı**: SQLite ile veri saklama
- **Basit Arayüz**: Kolay kullanım için minimal tasarım
- **Hızlı Erişim**: Sık kullanılan işlemler için kısayollar

## Proje Yapısı

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── app_constants.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── utils/
│   │   ├── date_utils.dart
│   │   ├── currency_utils.dart
│   │   └── validation_utils.dart
│   └── widgets/
│       ├── custom_app_bar.dart
│       ├── custom_button.dart
│       └── custom_text_field.dart
├── features/
│   ├── customer/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── customer_model.dart
│   │   │   └── repositories/
│   │   │       └── customer_repository.dart
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── customer_entity.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── customer_list_page.dart
│   │       │   ├── customer_detail_page.dart
│   │       │   └── add_customer_page.dart
│   │       └── widgets/
│   │           └── customer_card.dart
│   ├── transaction/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── transaction_model.dart
│   │   │   └── repositories/
│   │   │       └── transaction_repository.dart
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── transaction_entity.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── transaction_list_page.dart
│   │       │   ├── add_transaction_page.dart
│   │       │   └── transaction_detail_page.dart
│   │       └── widgets/
│   │           └── transaction_card.dart
│   └── dashboard/
│       ├── data/
│       │   └── repositories/
│       │       └── dashboard_repository.dart
│       └── presentation/
│           ├── pages/
│           │   └── dashboard_page.dart
│           └── widgets/
│               ├── summary_card.dart
│               └── recent_transactions.dart
├── data/
│   ├── database/
│   │   ├── app_database.dart
│   │   ├── tables/
│   │   │   ├── customer_table.dart
│   │   │   └── transaction_table.dart
│   │   └── dao/
│   │       ├── customer_dao.dart
│   │       └── transaction_dao.dart
│   └── services/
│       └── backup_service.dart
├── l10n/
│   ├── app_tr.arb
│   └── app_en.arb
└── main.dart
```

## Veritabanı Yapısı

### Customer Tablosu
- id (PRIMARY KEY)
- name (TEXT)
- phone (TEXT)
- address (TEXT)
- created_at (DATETIME)
- updated_at (DATETIME)

### Transaction Tablosu
- id (PRIMARY KEY)
- customer_id (FOREIGN KEY)
- type (TEXT) - 'credit' veya 'debit'
- amount (REAL)
- description (TEXT)
- date (DATETIME)
- created_at (DATETIME)

## UI/UX Tasarım Prensipleri

### Renk Paleti
- Ana Renk: Koyu tema (kara defter hissi)
- Vurgu Renkleri: Yeşil (alacak), Kırmızı (borç)
- Arka Plan: Koyu gri tonları

### Navigasyon
- Alt navigasyon çubuğu
- Ana sayfa: Özet ve son işlemler
- Müşteriler: Müşteri listesi
- İşlemler: Tüm işlemler
- Ayarlar: Uygulama ayarları

### Kullanıcı Deneyimi
- Tek elle kullanım
- Büyük dokunma alanları
- Hızlı işlem ekleme
- Kolay arama ve filtreleme
