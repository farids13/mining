# Setup Sekali dan Portability

Dokumen ini menjelaskan satu kali setup yang dibutuhkan agar repo mudah dipindah antar environment desktop.

## Fokus Dokumen Ini

Yang dimaksud `environment` di sini adalah environment desktop:

- Windows
- Linux
- macOS

Bukan sekadar file `.env`.

## Satu Titik Setup Device

Setup per desktop dipusatkan di file:

- [miner.env](../config.local/miner.env)

Template referensi:

- [miner.env.example](../config/miner.env.example)

## Tujuan Desain

Setup dipisah dari binary dan script agar:

- aman dipakai di banyak device
- tidak perlu edit script saat pindah desktop
- lebih mudah menentukan autostart per device
- perubahan antar environment tetap kecil

## One-Time Setup Per Desktop

Saat repo dipindah ke desktop baru, langkah setup yang ideal hanya ini:

1. Taruh repo di lokasi yang diinginkan
2. Update atau siapkan binary sesuai OS dari sumber resmi
3. Buka [miner.env](../config.local/miner.env)
4. Isi identitas device dan profile jalan
5. Coba jalankan manual
6. Jika sudah stabil, pilih manual terus atau aktifkan autostart

## One-Time Setup Tool

Untuk XMRig, sumber update yang dipakai harus dari upstream resmi:

- release terbaru: `https://github.com/xmrig/xmrig/releases/latest`
- dokumentasi resmi: `https://xmrig.com/docs/miner`

Contoh direct download yang bisa dipakai:

```text
https://github.com/xmrig/xmrig/releases/download/v6.25.0/xmrig-6.25.0-macos-arm64.tar.gz
```

Updater shell yang tersedia:

- macOS: [scripts/macos/update-xmrig.sh](../scripts/macos/update-xmrig.sh)
- Linux: [scripts/linux/update-xmrig.sh](../scripts/linux/update-xmrig.sh)

Prinsip update tool:

- Windows: update isi `tools/xmrig/windows/`
- Linux: update isi `tools/xmrig/linux/`
- macOS: update isi `tools/xmrig/macos/`

Jika ingin versi terbaru berikutnya, cukup ganti URL release dan isi folder tool yang sesuai OS.

## Fallback Jika Download Otomatis Gagal

Script updater akan mencoba:

1. membaca halaman resmi `https://xmrig.com/download`
2. mendeteksi versi terbaru
3. download archive yang sesuai OS dan arsitektur

Jika gagal, script akan meminta input:

- path file archive XMRig yang sudah Anda download manual
- atau URL direct download GitHub release

Sumber file manual yang harus dipakai:

- `https://xmrig.com/download`

Dengan alur ini, update tetap bisa dilakukan walaupun shell tidak bisa download langsung dari internet.

## Yang Biasanya Berubah Antar Desktop

Bagian yang paling umum berubah:

- `WORKER_NAME`
- `RIG_ID`
- `XMRIG_THREADS`
- `XMRIG_CPU_AFFINITY`
- `XMRIG_UNIX_BIN`
- `LOLMINER_UNIX_BIN`
- `AUTOSTART_PROFILE`

## Yang Tidak Perlu Sering Diubah

Biasanya bagian ini tetap:

- `COIN`
- `WALLET`
- pool utama
- algoritma utama

## Parameter Penting

### Identitas Wallet dan Worker

- `COIN`: jenis coin payout, misalnya `DOGE`
- `WALLET`: alamat wallet
- `PASSWORD`: password pool, default `x`
- `WORKER_NAME`: nama worker/device
- `RIG_ID`: id rig opsional

Contoh:

```env
COIN=DOGE
WALLET=DSycjXnngRekwJKRQKXJwY88GPw4w9FmQA
WORKER_NAME=OFFICE-LAPTOP
RIG_ID=rig-office-01
```

### Profile Jalan

- `AUTOSTART_PROFILE=cpu`
- `AUTOSTART_PROFILE=gpu`
- `AUTOSTART_PROFILE=both`

Ini dipakai oleh:

- launcher manual
- script autostart

### CPU Miner

- `POOL_CPU`
- `ALGO_CPU`
- `XMRIG_UNIX_BIN`
- `XMRIG_THREADS`
- `XMRIG_CPU_PRIORITY`
- `XMRIG_CPU_AFFINITY`
- `XMRIG_PRINT_TIME`
- `XMRIG_HEALTH_PRINT_TIME`
- `XMRIG_DONATE_LEVEL`
- `XMRIG_HUGE_PAGES_JIT`
- `XMRIG_EXTRA_ARGS`

Contoh:

```env
POOL_CPU=rx.unmineable.com:3333
ALGO_CPU=rx
XMRIG_THREADS=2
XMRIG_CPU_PRIORITY=5
XMRIG_CPU_AFFINITY=0xC0
```

### GPU Miner

- `POOL_GPU`
- `ALGO_GPU`
- `LOLMINER_UNIX_BIN`
- `LOL_WORKER_NAME`
- `LOL_API_PORT`
- `LOL_EXTRA_ARGS`

Contoh:

```env
POOL_GPU=etchash.unmineable.com:3333
ALGO_GPU=ETCHASH
LOL_WORKER_NAME=GPU-RIG-01
LOL_API_PORT=8020
LOL_EXTRA_ARGS=--ethstratum ETHPROXY
```

## Default Yang Dipakai Script

Jika tidak diisi, script akan memakai default berikut:

- `POOL_CPU=rx.unmineable.com:3333`
- `ALGO_CPU=rx`
- `POOL_GPU=etchash.unmineable.com:3333`
- `ALGO_GPU=ETCHASH`
- `PASSWORD=x`
- `AUTOSTART_PROFILE=cpu`
- `XMRIG_THREADS=2`
- `XMRIG_CPU_PRIORITY=5`
- `XMRIG_PRINT_TIME=60`
- `XMRIG_HEALTH_PRINT_TIME=60`
- `XMRIG_DONATE_LEVEL=1`
- `XMRIG_HUGE_PAGES_JIT=false`
- `LOL_API_PORT=8020`

## Portability Antar Desktop

Untuk banyak desktop, pola yang disarankan:

- satu repo per device
- satu `config.local/miner.env` per device
- `WORKER_NAME` harus unik
- jika perlu, `RIG_ID` juga unik

Contoh:

- Laptop A: `WORKER_NAME=LAPTOP-A`
- Laptop B: `WORKER_NAME=LAPTOP-B`
- Mac Mini: `WORKER_NAME=MAC-MINI-01`

## Pemetaan Binary Per Environment Desktop

Linux dan macOS memakai launcher Unix bersama. Karena itu path binary Unix bisa diset manual.

### Windows

Default binary yang sudah dibundel:

- [xmrig.exe](../tools/xmrig/windows/xmrig.exe)
- [lolMiner.exe](../tools/lolminer/windows/lolMiner.exe)

### Linux

Repo ini tidak lagi memakai binary Linux default bawaan.

Isi manual:

```env
XMRIG_UNIX_BIN=/path/ke/tools/xmrig/linux/xmrig
```

Jika binary GPU Linux tidak ada di default path, isi:

```env
LOLMINER_UNIX_BIN=/path/ke/tools/lolminer/linux/lolMiner
```

### macOS

Default macOS yang ada di repo:

- [xmrig](../tools/xmrig/macos/xmrig)

Isi manual:

```env
XMRIG_UNIX_BIN=/path/ke/tools/xmrig/macos/xmrig
LOLMINER_UNIX_BIN=/path/ke/tools/lolminer/macos/lolMiner
```

## Hasil Akhir Yang Diharapkan

Jika setup sudah benar, maka di desktop mana pun alurnya menjadi sederhana:

- jalankan manual jika ingin kontrol penuh
- atau aktifkan autostart jika ingin miner hidup lagi setelah restart desktop
