# Dokumentasi Mining Portable

Dokumentasi ini menjelaskan tujuan utama repo ini: satu setup dasar, lalu mudah dipindah ke environment desktop mana pun, baik Windows, Linux, maupun macOS, dengan pilihan jalan manual atau autostart setelah desktop restart.

## Daftar Dokumen

- [Quick Start](quick-start.md)
- [Setup Sekali dan Portability](configuration.md)
- [Arsitektur Folder](folder-architecture.md)
- [Autostart](autostart.md)
- [Operasional Harian](operations.md)

## Prinsip Desain

Repo ini tidak didesain untuk bergantung pada satu desktop tertentu. Struktur yang dipakai sekarang memisahkan:

- binary per OS
- launcher per OS
- logika Unix bersama untuk Linux dan macOS
- satu basis config global untuk semua OS
- override lokal per desktop bila diperlukan
- mode jalan manual atau autostart

## Target Environment Desktop

### Windows

- entry point: [run-portable.bat](../run-portable.bat)
- autostart: Startup folder user
- binary default yang sudah ada: [xmrig.exe](../tools/xmrig/windows/xmrig.exe), [lolMiner.exe](../tools/lolminer/windows/lolMiner.exe)

### Linux

- entry point: [run.sh](../run.sh)
- autostart: `systemd --user`
- binary XMRig Linux tidak lagi dibundel sebagai default, jadi isi `XMRIG_UNIX_BIN` sesuai binary Linux yang Anda pakai

### macOS

- entry point: [run.sh](../run.sh)
- autostart: LaunchAgent user
- binary default macOS yang dipakai sekarang: [xmrig](../tools/xmrig/macos/xmrig)

## Hasil Yang Ingin Dicapai

Setelah setup awal selesai, target pemakaian repo ini adalah:

- copy repo ke desktop baru
- update binary yang sesuai OS dari rilis resmi
- sesuaikan identitas device
- pilih mode jalan: manual atau autostart
- desktop boleh restart kapan saja, miner tetap bisa hidup lagi jika autostart diaktifkan

## Sumber Resmi Tool

Untuk update XMRig, repo ini mengikuti sumber resmi:

- release terbaru: `https://github.com/xmrig/xmrig/releases/latest`
- dokumentasi resmi: `https://xmrig.com/docs/miner`

Contoh direct download macOS ARM64:

```text
https://github.com/xmrig/xmrig/releases/download/v6.25.0/xmrig-6.25.0-macos-arm64.tar.gz
```

## Entry Point Utama

- Windows: `run-portable.bat`
- Linux: `./run.sh cpu`
- macOS: `./run.sh cpu`

## File Penting

- [run-portable.bat](../run-portable.bat)
- [run.sh](../run.sh)
- [scripts/macos/update-xmrig.sh](../scripts/macos/update-xmrig.sh)
- [scripts/linux/update-xmrig.sh](../scripts/linux/update-xmrig.sh)
- [miner.env.example](../config/miner.env.example)
- [miner.env](../config/miner.env)
- [miner.env local](../config.local/miner.env)
- [README.MD](../README.MD)
