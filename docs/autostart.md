# Autostart

Autostart di repo ini bersifat opsional. Tujuannya adalah memberi pilihan:

- jalan manual jika Anda ingin kontrol penuh
- jalan otomatis jika Anda ingin miner hidup lagi setelah desktop restart dan user login kembali

Profile yang dijalankan saat autostart diambil dari:

- `AUTOSTART_PROFILE` di [miner.env](../config.local/miner.env)

Nilai yang didukung:

- `cpu`
- `gpu`
- `both`

## Prinsip Umum

Mode yang dianjurkan:

1. setup desktop sekali
2. coba jalankan manual dulu
3. jika sudah stabil, baru aktifkan autostart

Dengan alur ini, repo tetap aman dipindah ke desktop lain tanpa perlu ubah struktur.

## Windows

Windows memakai folder Startup user.

Script:

- Aktifkan: [enable-autostart.ps1](../scripts/windows/enable-autostart.ps1)
- Matikan: [disable-autostart.ps1](../scripts/windows/disable-autostart.ps1)

Cara pakai:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\windows\enable-autostart.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\windows\disable-autostart.ps1
```

Target shortcut:

- [run-autostart.cmd](../scripts/windows/run-autostart.cmd)

## Linux

Linux memakai `systemd --user`.

Script:

- Aktifkan: [enable-autostart.sh](../scripts/linux/enable-autostart.sh)
- Matikan: [disable-autostart.sh](../scripts/linux/disable-autostart.sh)

Cara pakai:

```sh
./scripts/linux/enable-autostart.sh
./scripts/linux/disable-autostart.sh
```

Service yang dibuat:

- `mining-portable.service`

Lokasi:

- `~/.config/systemd/user/mining-portable.service`

## macOS

macOS memakai LaunchAgent user.

Script:

- Aktifkan: [enable-autostart.sh](../scripts/macos/enable-autostart.sh)
- Matikan: [disable-autostart.sh](../scripts/macos/disable-autostart.sh)

Cara pakai:

```sh
./scripts/macos/enable-autostart.sh
./scripts/macos/disable-autostart.sh
```

File yang dibuat:

- `~/Library/LaunchAgents/com.fast.mining-portable.plist`

## Kapan Sebaiknya Tidak Mengaktifkan Autostart

Sebaiknya tetap manual jika:

- device sering dipakai kerja normal
- Anda ingin mengontrol waktu mining
- device sering berpindah jaringan atau mode baterai
- Anda masih sering ubah config

## Kapan Cocok Mengaktifkan Autostart

Cocok jika:

- device memang dikhususkan untuk mining
- konfigurasi device sudah stabil
- Anda ingin miner hidup otomatis setelah login user
- Anda ingin desktop kembali mining walaupun sebelumnya sempat restart
