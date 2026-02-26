# Keystore Configuration

## Info Keystore
- **Nama File**: `android/app/cari_kata.jks`
- **Alias**: `cari_kata`
- **Algoritma**: RSA 2048-bit
- **Validitas**: 10,000 hari (~27 tahun)

## Informasi Penting
Keystore ini digunakan untuk menandatangani release build APK. Dengan keystore yang sama, user dapat melakukan update aplikasi di perangkat tanpa perlu uninstall versi sebelumnya.

## Perhatian
⚠️ **JANGAN BAGIKAN KEYSTORE INI KE ORANG LAIN**. Simpan file `android/app/cari_kata.jks` dengan aman. Password keystore tersimpan di `android/app/build.gradle.kts`.

## Build Release
Untuk membuat APK terundatangi dengan keystore ini:
```bash
flutter build apk --release
```

Atau untuk split APK per ABI:
```bash
flutter build apk --release --split-per-abi
```

## Untuk Play Store
Jika ingin mendistribusikan di Google Play Store, gunakan App Bundle:
```bash
flutter build appbundle --release
```
