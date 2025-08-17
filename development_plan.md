# Kara Defter - Geliştirme Planı

## 🎯 Proje Özeti

Babanızın dükkanda kullandığı kara defteri dijital ortama taşıyan Flutter mobil uygulaması. Geleneksel kara defter kullanımını modern teknoloji ile birleştirerek, alacak-borç takibini kolaylaştırmak.

## 📋 Mevcut Durum

### ✅ Tamamlanan Kısımlar
- [x] Proje yapısı oluşturuldu
- [x] Tema dosyaları hazırlandı (koyu tema)
- [x] Ana navigasyon yapısı
- [x] Dashboard sayfası (ana sayfa)
- [x] Müşteri listesi sayfası
- [x] İşlem listesi sayfası
- [x] Ayarlar sayfası
- [x] Hızlı işlem ekleme dialog'u
- [x] README ve dokümantasyon

### 🔄 Devam Eden Kısımlar
- [ ] Veritabanı implementasyonu
- [ ] BLoC state management
- [ ] Gerçek veri entegrasyonu

## 🚀 Sonraki Adımlar

### 1. Veritabanı Katmanı (Öncelik: Yüksek)
```dart
// Oluşturulacak dosyalar:
lib/data/database/app_database.dart
lib/data/database/tables/customer_table.dart
lib/data/database/tables/transaction_table.dart
lib/data/database/dao/customer_dao.dart
lib/data/database/dao/transaction_dao.dart
```

**Görevler:**
- SQLite veritabanı kurulumu
- Tablo şemalarının oluşturulması
- DAO (Data Access Object) sınıfları
- Migration stratejisi

### 2. Model Sınıfları (Öncelik: Yüksek)
```dart
// Oluşturulacak dosyalar:
lib/features/customer/data/models/customer_model.dart
lib/features/transaction/data/models/transaction_model.dart
lib/features/customer/domain/entities/customer_entity.dart
lib/features/transaction/domain/entities/transaction_entity.dart
```

**Görevler:**
- Entity sınıfları
- Model sınıfları
- JSON serialization
- Validation logic

### 3. Repository Katmanı (Öncelik: Yüksek)
```dart
// Oluşturulacak dosyalar:
lib/features/customer/data/repositories/customer_repository.dart
lib/features/transaction/data/repositories/transaction_repository.dart
lib/features/dashboard/data/repositories/dashboard_repository.dart
```

**Görevler:**
- Repository interface'leri
- Repository implementasyonları
- Error handling
- Data caching

### 4. BLoC State Management (Öncelik: Orta)
```dart
// Oluşturulacak dosyalar:
lib/features/customer/presentation/bloc/customer_bloc.dart
lib/features/transaction/presentation/bloc/transaction_bloc.dart
lib/features/dashboard/presentation/bloc/dashboard_bloc.dart
```

**Görevler:**
- Event sınıfları
- State sınıfları
- BLoC implementasyonları
- Event handling

### 5. UI Geliştirmeleri (Öncelik: Orta)
```dart
// Oluşturulacak dosyalar:
lib/features/customer/presentation/pages/add_customer_page.dart
lib/features/customer/presentation/pages/customer_detail_page.dart
lib/features/transaction/presentation/pages/add_transaction_page.dart
lib/features/transaction/presentation/pages/transaction_detail_page.dart
```

**Görevler:**
- Form sayfaları
- Detay sayfaları
- Validation UI
- Loading states

### 6. Utility Sınıfları (Öncelik: Düşük)
```dart
// Oluşturulacak dosyalar:
lib/core/utils/date_utils.dart
lib/core/utils/currency_utils.dart
lib/core/utils/validation_utils.dart
lib/core/constants/app_colors.dart
lib/core/constants/app_strings.dart
```

**Görevler:**
- Tarih formatlama
- Para birimi formatlama
- Form validation
- Sabitler

### 7. Test Yazımı (Öncelik: Düşük)
```dart
// Oluşturulacak dosyalar:
test/unit/customer_repository_test.dart
test/unit/transaction_repository_test.dart
test/widget/customer_list_page_test.dart
test/widget/dashboard_page_test.dart
```

**Görevler:**
- Unit testler
- Widget testler
- Integration testler
- Test coverage

## 🛠️ Teknik Detaylar

### Veritabanı Şeması
```sql
-- Customers tablosu
CREATE TABLE customers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  phone TEXT,
  address TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Transactions tablosu
CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  customer_id INTEGER,
  type TEXT NOT NULL CHECK (type IN ('credit', 'debit')),
  amount REAL NOT NULL CHECK (amount > 0),
  description TEXT,
  date DATETIME DEFAULT CURRENT_TIMESTAMP,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX idx_transactions_customer_id ON transactions(customer_id);
CREATE INDEX idx_transactions_date ON transactions(date);
CREATE INDEX idx_customers_name ON customers(name);
```

### State Management Yapısı
```dart
// Event sınıfları
abstract class CustomerEvent {}

class LoadCustomers extends CustomerEvent {}
class AddCustomer extends CustomerEvent {
  final Customer customer;
  AddCustomer(this.customer);
}
class UpdateCustomer extends CustomerEvent {
  final Customer customer;
  UpdateCustomer(this.customer);
}
class DeleteCustomer extends CustomerEvent {
  final int customerId;
  DeleteCustomer(this.customerId);
}

// State sınıfları
abstract class CustomerState {}

class CustomerInitial extends CustomerState {}
class CustomerLoading extends CustomerState {}
class CustomerLoaded extends CustomerState {
  final List<Customer> customers;
  CustomerLoaded(this.customers);
}
class CustomerError extends CustomerState {
  final String message;
  CustomerError(this.message);
}
```

## 📱 Kullanıcı Senaryoları

### Senaryo 1: Yeni Müşteri Ekleme
1. Kullanıcı "Müşteriler" sekmesine gider
2. "+" butonuna tıklar
3. Müşteri bilgilerini girer (ad, telefon, adres)
4. "Kaydet" butonuna tıklar
5. Müşteri listesinde yeni müşteri görünür

### Senaryo 2: Alacak İşlemi Ekleme
1. Kullanıcı ana sayfada "Alacak Ekle" butonuna tıklar
2. Müşteri seçer veya yeni müşteri ekler
3. Tutarı girer
4. Açıklama ekler
5. "Kaydet" butonuna tıklar
6. Ana sayfada toplam alacak güncellenir

### Senaryo 3: Borç İşlemi Ekleme
1. Kullanıcı ana sayfada "Borç Ekle" butonuna tıklar
2. Müşteri seçer
3. Tutarı girer
4. Açıklama ekler
5. "Kaydet" butonuna tıklar
6. Ana sayfada toplam borç güncellenir

### Senaryo 4: Müşteri Detayı Görüntüleme
1. Kullanıcı müşteri listesinde bir müşteriye tıklar
2. Müşteri detay sayfası açılır
3. Müşterinin tüm işlemleri görünür
4. Toplam bakiye gösterilir

## 🎨 UI/UX Geliştirmeleri

### Tema Geliştirmeleri
- [ ] Animasyonlar ekleme
- [ ] Loading skeleton'ları
- [ ] Error state'leri
- [ ] Empty state'leri

### Kullanıcı Deneyimi
- [ ] Swipe to delete
- [ ] Pull to refresh
- [ ] Search functionality
- [ ] Filter options
- [ ] Sort options

## 🔒 Güvenlik ve Performans

### Veri Güvenliği
- [ ] SQL injection koruması
- [ ] Input validation
- [ ] Data encryption (opsiyonel)
- [ ] Backup encryption

### Performans Optimizasyonu
- [ ] Lazy loading
- [ ] Pagination
- [ ] Image caching
- [ ] Database indexing

## 📊 Test Stratejisi

### Unit Tests
- Repository sınıfları
- BLoC sınıfları
- Utility fonksiyonları
- Model sınıfları

### Widget Tests
- Sayfa widget'ları
- Form validation
- Navigation
- User interactions

### Integration Tests
- End-to-end senaryolar
- Veritabanı işlemleri
- State management

## 🚀 Deployment Planı

### Android
1. Keystore oluşturma
2. Release build
3. APK imzalama
4. Google Play Store'a yükleme

### iOS
1. Apple Developer hesabı
2. App Store Connect setup
3. Release build
4. App Store'a yükleme

## 📈 Gelecek Özellikler

### v1.1
- [ ] PDF rapor oluşturma
- [ ] Excel export
- [ ] Cloud backup (Google Drive/Dropbox)
- [ ] Multi-language support

### v1.2
- [ ] Barcode/QR kod desteği
- [ ] Fotoğraf ekleme
- [ ] Ses notu ekleme
- [ ] Offline sync

### v2.0
- [ ] Web dashboard
- [ ] Multi-user support
- [ ] Real-time sync
- [ ] Advanced analytics

## 📞 İletişim ve Destek

- **Geliştirici**: Kara Defter Team
- **E-posta**: [email@example.com]
- **GitHub**: [https://github.com/username/kara-defter]

---

**Not**: Bu plan sürekli güncellenmektedir. Yeni gereksinimler ve geri bildirimler doğrultusunda değişiklikler yapılabilir.
