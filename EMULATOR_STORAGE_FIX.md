# Emülatör Depolama Sorunu Çözümü

## Hata: INSTALL_FAILED_INSUFFICIENT_STORAGE

Bu hata, Android emülatöründe yetersiz depolama alanı olduğunu gösterir.

### Çözüm Yöntemleri:

#### 1. Emülatörü Yeniden Başlatın
- Android Studio'da emülatörü kapatın
- Emülatörü tekrar başlatın
- Uygulamayı tekrar çalıştırmayı deneyin

#### 2. Emülatör Depolama Alanını Artırın
1. Android Studio'da **Tools** > **Device Manager** açın
2. Emülatörünüzün yanındaki **▼** (dropdown) butonuna tıklayın
3. **Show on Disk** seçeneğini seçin
4. Emülatör klasöründe `config.ini` dosyasını açın
5. `disk.dataPartition.size` değerini artırın (örn: `4096M` veya `8192M`)
6. Emülatörü yeniden başlatın

#### 3. Emülatörde Uygulamaları Temizleyin
1. Emülatörü açın
2. **Settings** > **Apps** gidin
3. Kullanılmayan uygulamaları kaldırın

#### 4. Cold Boot Yapın
1. Android Studio'da emülatörü kapatın
2. **Device Manager**'da emülatörün yanındaki **▼** butonuna tıklayın
3. **Cold Boot Now** seçeneğini seçin

#### 5. Yeni Emülatör Oluşturun
Eğer yukarıdaki yöntemler işe yaramazsa:
1. **Device Manager**'da yeni bir emülatör oluşturun
2. Daha fazla depolama alanı ile (en az 4GB) oluşturun
3. Yeni emülatörü kullanın

### Hızlı Çözüm (Terminal):
```bash
# Emülatörü temizle ve yeniden başlat
adb shell pm clear com.example.recipes
flutter clean
flutter pub get
flutter run
```

