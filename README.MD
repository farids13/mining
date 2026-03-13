# Mining Portable

Repo ini dipakai untuk menjalankan miner secara portable di Windows, Linux, dan macOS dengan tujuan utama: sekali setup per desktop, lalu mudah dipindah dan bisa dipilih jalan manual atau autostart setelah restart.

README ini tetap mempertahankan cara jalan sederhana berbasis CLI agar user yang ingin langsung run tanpa dashboard tetap bisa memakai pola lama.

## Ringkasan

- Semua binary miner sekarang dirapikan di folder `tools/`
- Basis config bersama semua OS dipusatkan di `config/miner.env`
- `config.local/miner.env` hanya untuk override lokal per desktop bila diperlukan
- Launcher dipisah per OS
- Linux dan macOS memakai abstraksi Unix yang sama
- Autostart bersifat opsional
- Script lama `run.bat` tetap dipertahankan sebagai fallback

## Entry Point

- Windows: `run-portable.bat`
- Linux: `./run.sh cpu`
- macOS: `./run.sh cpu`

## Simple CLI / Legacy Run

README lama tidak saya buang. Cara jalan cepat tetap seperti ini.

### Windows

Masuk ke folder `xmrig` Windows lalu jalankan:

```bat
start.bat
```

### Windows atau Linux

Masuk ke folder XMRig yang sesuai OS, lalu jalankan command CLI berikut:

```sh
xmrig.exe -o rx.unmineable.com:3333 -a rx -k -u DOGE:DSycjXnngRekwJKRQKXJwY88GPw4w9FmQA.DELL -p x --threads=2 --cpu-priority=5 --huge-pages-jit --print-time=1 --health-print-time=10 --donate-level=0 --threads=2 --cpu-priority=5 --cpu-affinity=0xC0
```

Untuk Linux, ganti `xmrig.exe` menjadi `./xmrig`.

Referensi resmi opsi CLI XMRig:

- `https://xmrig.com/docs/miner/command-line-options`

## CPU Affinity Settings

Berikut adalah nilai hexadecimal untuk setting CPU affinity berdasarkan core dan logical CPU.

| Core | Logical CPUs | Hex Value | Command Parameter |
| --- | --- | --- | --- |
| Core 1 | CPU 0, CPU 1 | `0x3` | `--cpu-affinity=0x3` |
| Core 2 | CPU 2, CPU 3 | `0xC` | `--cpu-affinity=0xC` |
| Core 3 | CPU 4, CPU 5 | `0x30` | `--cpu-affinity=0x30` |
| Core 4 | CPU 6, CPU 7 | `0xC0` | `--cpu-affinity=0xC0` |
| Core 5 | CPU 8, CPU 9 | `0x300` | `--cpu-affinity=0x300` |
| Core 6 | CPU 10, CPU 11 | `0xC00` | `--cpu-affinity=0xC00` |
| Core 7 | CPU 12, CPU 13 | `0x3000` | `--cpu-affinity=0x3000` |
| Core 8 | CPU 14, CPU 15 | `0xC000` | `--cpu-affinity=0xC000` |
| Core 9 | CPU 16, CPU 17 | `0x30000` | `--cpu-affinity=0x30000` |
| Core 10 | CPU 18, CPU 19 | `0xC0000` | `--cpu-affinity=0xC0000` |
| Core 11 | CPU 20, CPU 21 | `0x300000` | `--cpu-affinity=0x300000` |
| Core 12 | CPU 22, CPU 23 | `0xC00000` | `--cpu-affinity=0xC00000` |
| Core 13 | CPU 24, CPU 25 | `0x3000000` | `--cpu-affinity=0x3000000` |
| Core 14 | CPU 26, CPU 27 | `0xC000000` | `--cpu-affinity=0xC000000` |
| Core 15 | CPU 28, CPU 29 | `0x30000000` | `--cpu-affinity=0x30000000` |
| Core 16 | CPU 30, CPU 31 | `0xC0000000` | `--cpu-affinity=0xC0000000` |

Contoh penggunaan:

- Untuk menggunakan Core 2: `--cpu-affinity=0xC`
- Untuk menggunakan Core 4: `--cpu-affinity=0xC0`
- Untuk menggunakan Core 1 dan 2: `--cpu-affinity=0xF`

## Dokumentasi Lengkap

- [Index Docs](docs/README.md)
- [Quick Start](docs/quick-start.md)
- [Setup Sekali dan Portability](docs/configuration.md)
- [Arsitektur Folder](docs/folder-architecture.md)
- [Autostart](docs/autostart.md)
- [Operasional Harian](docs/operations.md)

## File Penting

- [miner.env.example](config/miner.env.example)
- [miner.env](config/miner.env)
- [miner.env local](config.local/miner.env)
- [tools](tools)
- [scripts/macos/update-xmrig.sh](scripts/macos/update-xmrig.sh)
- [scripts/linux/update-xmrig.sh](scripts/linux/update-xmrig.sh)
- [run.sh](run.sh)
- [run-portable.bat](run-portable.bat)
- [run.bat](run.bat)
