# Kara Defter - Alacak Borç Takip Uygulaması

Babanızın dükkanda kullandığı kara defteri dijital ortama taşıyan mobil uygulama.

## 🎯 Proje Amacı

Geleneksel kara defter kullanımını modern mobil teknoloji ile birleştirerek, alacak-borç takibini kolaylaştırmak ve veri güvenliğini sağlamak.

## ✨ Özellikler

### Ana Özellikler
- **Müşteri Yönetimi**: Müşteri ekleme, düzenleme, silme
- **İşlem Kayıtları**: Alacak/borç işlemlerini kaydetme
- **Özet Görünümü**: Toplam alacak/borç durumu
- **Geçmiş Takibi**: Tarih bazlı işlem geçmişi
- **Arama/Filtreleme**: Müşteri ve işlem arama
- **Veri Yedekleme**: Yerel depolama ve yedekleme

### Teknik Özellikler
- **Offline Çalışma**: İnternet bağlantısı olmadan kullanım
- **Yerel Veritabanı**: SQLite ile veri saklama
- **Koyu Tema**: Kara defter hissi veren tasarım
- **Hızlı Erişim**: Sık kullanılan işlemler için kısayollar

## 🛠️ Teknoloji Stack

- **Framework**: Flutter 3.x
- **State Management**: BLoC Pattern
- **Veritabanı**: SQLite
- **UI**: Material Design 3
- **Dil**: Dart

## 📱 Ekran Görüntüleri

### Ana Sayfa
- Toplam alacak/borç özeti
- Son işlemler listesi
- Hızlı işlem kısayolları

### Müşteriler
- Müşteri listesi
- Müşteri bazlı bakiye görünümü
- Müşteri detay sayfası

### İşlemler
- Tüm işlemlerin listesi
- Filtreleme ve arama
- İşlem detayları

### Ayarlar
- Tema ayarları
- Veri yedekleme
- Uygulama ayarları

## 🚀 Kurulum

### Gereksinimler
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / VS Code

### Adımlar

1. **Projeyi klonlayın**
```bash
git clone [repository-url]
cd alacak-borc
```

2. **Bağımlılıkları yükleyin**
```bash
flutter pub get
```

3. **Uygulamayı çalıştırın**
```bash
flutter run
```

## 📁 Proje Yapısı

```
lib/
├── core/
│   ├── constants/          # Sabitler
│   ├── theme/             # Tema dosyaları
│   ├── utils/             # Yardımcı fonksiyonlar
│   └── widgets/           # Ortak widget'lar
├── features/
│   ├── customer/          # Müşteri özellikleri
│   ├── transaction/       # İşlem özellikleri
│   └── dashboard/         # Ana sayfa özellikleri
├── data/
│   ├── database/          # Veritabanı dosyaları
│   └── services/          # Servis dosyaları
└── main.dart              # Ana uygulama dosyası
```

## 🎨 Tasarım Prensipleri

### Renk Paleti
- **Ana Renk**: Koyu gri (#1A1A1A)
- **İkincil Renk**: Orta gri (#2D2D2D)
- **Vurgu Renk**: Yeşil (#4CAF50) - Alacak
- **Hata Renk**: Kırmızı (#E57373) - Borç

### Kullanıcı Deneyimi
- Tek elle kullanım
- Büyük dokunma alanları
- Hızlı işlem ekleme
- Kolay arama ve filtreleme

## 📊 Veritabanı Şeması

### Customer Tablosu
```sql
CREATE TABLE customers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  phone TEXT,
  address TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### Transaction Tablosu
```sql
CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  customer_id INTEGER,
  type TEXT NOT NULL, -- 'credit' veya 'debit'
  amount REAL NOT NULL,
  description TEXT,
  date DATETIME DEFAULT CURRENT_TIMESTAMP,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers (id)
);
```

## 🔧 Geliştirme

### Kod Standartları
- Clean Architecture prensipleri
- BLoC pattern kullanımı
- Null safety
- Proper error handling
- Unit test coverage

### Test Etme
```bash
# Unit testleri çalıştır
flutter test

# Widget testleri çalıştır
flutter test test/widget_test.dart
```

## 📦 Dağıtım

### Android APK Oluşturma
```bash
flutter build apk --release
```

### iOS IPA Oluşturma
```bash
flutter build ios --release
```

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit yapın (`git commit -m 'Add amazing feature'`)
4. Push yapın (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## 📞 İletişim

- **Geliştirici**: Kara Defter Team
- **E-posta**: [email@example.com]
- **Proje Linki**: [https://github.com/username/kara-defter]

## 🙏 Teşekkürler

- Flutter ekibine
- Material Design ekibine
- Açık kaynak topluluğuna

---

**Not**: Bu uygulama geleneksel kara defter kullanımını modernize etmek amacıyla geliştirilmiştir. Verilerinizin güvenliği için düzenli yedekleme yapmanız önerilir.
