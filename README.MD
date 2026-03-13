# Mining Portable

Repo ini dipakai untuk menjalankan miner secara portable di Windows, Linux, dan macOS dengan tujuan utama: sekali setup per desktop, lalu mudah dipindah dan bisa dipilih jalan manual atau autostart setelah restart.

## Ringkasan

- Semua binary miner sekarang dirapikan di folder `tools/`
- Setup per desktop dipusatkan di `config.local/miner.env`
- Launcher dipisah per OS
- Linux dan macOS memakai abstraksi Unix yang sama
- Autostart bersifat opsional
- Script lama `run.bat` tetap dipertahankan sebagai fallback

## Entry Point

- Windows: `run-portable.bat`
- Linux: `./run.sh cpu`
- macOS: `./run.sh cpu`

## Dokumentasi Lengkap

- [Index Docs](docs/README.md)
- [Quick Start](docs/quick-start.md)
- [Setup Sekali dan Portability](docs/configuration.md)
- [Arsitektur Folder](docs/folder-architecture.md)
- [Autostart](docs/autostart.md)
- [Operasional Harian](docs/operations.md)

## File Penting

- [miner.env.example](config/miner.env.example)
- [miner.env](config.local/miner.env)
- [tools](tools)
- [scripts/macos/update-xmrig.sh](scripts/macos/update-xmrig.sh)
- [scripts/linux/update-xmrig.sh](scripts/linux/update-xmrig.sh)
- [run.sh](run.sh)
- [run-portable.bat](run-portable.bat)
- [run.bat](run.bat)
