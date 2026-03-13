# Quick Start

Panduan ini fokus ke alur yang Anda inginkan: repo bisa dipindah ke desktop Windows, Linux, atau macOS, lalu cukup setup sekali dan pilih apakah miner akan jalan manual atau otomatis saat login kembali setelah restart.

## Alur Besar

1. Copy repo ke desktop target
2. Pastikan binary untuk OS itu tersedia
3. Lakukan setup awal satu kali
4. Jalankan manual atau aktifkan autostart

## 1. Siapkan Desktop Target

### Windows

Yang sudah ada di repo:

- [xmrig.exe](../tools/xmrig/windows/xmrig.exe)
- [lolMiner.exe](../tools/lolminer/windows/lolMiner.exe)

### Linux

Yang perlu Anda siapkan:

- binary XMRig Linux
- jika pakai GPU, binary lolMiner Linux

Lalu arahkan path binary Linux itu saat setup.

### macOS

Repo ini sudah membawa binary XMRig macOS:

- [xmrig](../tools/xmrig/macos/xmrig)

Jadi saat setup di Mac:

- jika pakai GPU, sediakan juga lolMiner macOS
- arahkan path binary itu ke launcher yang dipakai repo

## 2. Setup Awal Sekali

Saat `./run.sh` dijalankan pertama kali, repo akan otomatis membuat:

- [miner.env](../config.local/miner.env)

dari template:

- [miner.env.example](../config/miner.env.example)

Yang perlu Anda sesuaikan per desktop:

- identitas worker
- jumlah thread CPU
- binary path jika OS tidak memakai binary default repo
- profile jalan default

Minimal setup yang disarankan:

```env
COIN=DOGE
WALLET=DSycjXnngRekwJKRQKXJwY88GPw4w9FmQA
WORKER_NAME=DESKTOP-01
AUTOSTART_PROFILE=cpu
```

## 2A. Update Tool Dari Rilis Resmi

Untuk XMRig, gunakan rilis resmi dari repo asli XMRig, bukan file acak dari sumber lain.

Pola update yang dipakai repo ini:

1. buka halaman rilis resmi XMRig
2. ambil binary yang sesuai dengan desktop target
3. ganti isi folder tool yang sesuai
4. jalankan ulang test manual

Sumber resmi:

- halaman release terbaru: `https://github.com/xmrig/xmrig/releases/latest`
- dokumentasi resmi: `https://xmrig.com/docs/miner`

Contoh direct download macOS ARM64:

```text
https://github.com/xmrig/xmrig/releases/download/v6.25.0/xmrig-6.25.0-macos-arm64.tar.gz
```

Contoh alur update macOS:

1. download archive resmi
2. extract isinya
3. ganti file binary di `tools/xmrig/macos/`
4. cek permission executable
5. jalankan `./run.sh cpu`

Contoh command macOS:

```sh
./scripts/macos/update-xmrig.sh
```

Contoh alur update Linux:

1. download binary Linux resmi dari halaman release yang sama
2. taruh binary hasil extract ke `tools/xmrig/linux/`
3. jika path berbeda, isi `XMRIG_UNIX_BIN`
4. jalankan `./run.sh cpu`

Contoh alur update Windows:

1. download zip Windows resmi dari halaman release yang sama
2. extract
3. ganti isi `tools/xmrig/windows/`
4. jalankan `run-portable.bat`

Jika script `.sh` gagal download otomatis:

1. script akan meminta input path file atau URL
2. download manual dari `https://xmrig.com/download`
3. Anda bisa masukkan:
   - path file `.tar.gz` yang sudah Anda download
   - atau URL direct download GitHub release
4. script akan extract dan mengganti binary aktif di folder `tools/xmrig/...`

## 3. Jalankan Manual

### Windows

Paling mudah:

```bat
run-portable.bat
```

Atau langsung:

```bat
scripts\windows\start-profile.cmd cpu
scripts\windows\start-profile.cmd gpu
scripts\windows\start-profile.cmd both
```

### Linux

```sh
./run.sh cpu
./run.sh gpu
./run.sh both
```

### macOS

```sh
./run.sh cpu
./run.sh gpu
./run.sh both
```

## 4. Pilih Profile Jalan

Nilai `AUTOSTART_PROFILE` dan parameter launcher mendukung:

- `cpu`
- `gpu`
- `both`

## 5. Jika Ingin Tetap Jalan Setelah Restart Desktop

Jika desktop sering restart dan Anda ingin miner hidup lagi otomatis setelah login user:

- Windows: aktifkan autostart Windows
- Linux: aktifkan autostart `systemd --user`
- macOS: aktifkan autostart LaunchAgent

Panduan detailnya ada di:

- [Autostart](autostart.md)

## 6. Jika Pindah ke Desktop Lain

Target repo ini adalah mempermudah pindah environment desktop. Saat repo dipindah, yang umumnya perlu dicek hanya:

- [miner.env](../config.local/miner.env)

Yang biasanya berubah antar desktop:

- `WORKER_NAME`
- `RIG_ID`
- `XMRIG_THREADS`
- `XMRIG_CPU_AFFINITY`
- `XMRIG_UNIX_BIN`
- `LOLMINER_UNIX_BIN`

Intinya:

- Windows ke Windows: biasanya paling mudah karena binary default sudah ada
- Linux ke Linux: CPU langsung bisa, GPU tergantung binary
- macOS: perlu binary macOS lebih dulu
