# Translation Guide

## Python Script Kullanımı

1. Gerekli paketi yükleyin:
```bash
pip install -r requirements.txt
```

2. Çeviri scriptini çalıştırın:
```bash
python translate_recipes.py
```

Script, `assets/hazir_tarifler.json` dosyasını okuyup Türkçe'ye çevirerek `assets/hazir_tarifler_tr.json` olarak kaydedecektir.

**Not:** Çeviri işlemi zaman alabilir (her tarif için API çağrısı yapılır). Rate limiting için gecikmeler eklenmiştir.

## Flutter Uygulaması

Uygulama artık İngilizce ve Türkçe dil desteğine sahiptir:

- **Dil Değiştirme:** AppBar'daki 🌐 (Globe) ikonuna tıklayarak dil değiştirebilirsiniz
- **Otomatik Yükleme:** Dil değiştirildiğinde tarifler otomatik olarak ilgili dildeki JSON dosyasından yüklenir
- **UI Çevirileri:** Tüm butonlar, başlıklar ve mesajlar seçilen dile göre gösterilir

## Yeni Çeviri Ekleme

`lib/services/language_service.dart` dosyasındaki `Translations` sınıfına yeni çeviriler ekleyebilirsiniz:

```dart
'en': {
  'newKey': 'English Text',
  ...
},
'tr': {
  'newKey': 'Türkçe Metin',
  ...
},
```

Sonra kodda kullanın:
```dart
Text(Translations.get('newKey'))
```

