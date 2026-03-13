# Operasional Harian

Dokumen ini menjelaskan cara kerja harian, troubleshooting dasar, dan aturan operasional repo.

## Flow Kerja Harian

### Menjalankan Manual

Windows:

```bat
run-portable.bat
```

Linux/macOS:

```sh
./run.sh cpu
```

### Mengganti Device Name

Edit:

- [miner.env](../config.local/miner.env)

Ubah:

- `WORKER_NAME`
- `RIG_ID`

### Mengubah Mode CPU ke GPU

Edit:

- `AUTOSTART_PROFILE`

Atau jalankan langsung:

```sh
./run.sh gpu
```

## Troubleshooting

### Config Tidak Terbaca

Gejala:

- script bilang `config.local/miner.env` tidak ada

Solusi:

- pastikan file [miner.env](../config.local/miner.env) ada
- jika hilang, copy dari [miner.env.example](../config/miner.env.example)

### Binary Tidak Ditemukan

Gejala:

- script error `Binary XMRig tidak ditemukan`
- script error `Binary lolMiner tidak ditemukan`

Solusi:

- pastikan binary ada di path default
- atau isi `XMRIG_UNIX_BIN`
- atau isi `LOLMINER_UNIX_BIN`

### macOS Tidak Jalan

Penyebab paling umum:

- binary macOS belum ada
- file belum executable
- path binary belum diisi

Solusi:

```sh
chmod +x /path/ke/tools/xmrig/macos/xmrig
chmod +x /path/ke/tools/lolminer/macos/lolMiner
```

Lalu isi path di:

- [miner.env](../config.local/miner.env)

### Linux GPU Tidak Jalan

Penyebab paling umum:

- repo belum punya binary lolMiner Linux default

Solusi:

- sediakan binary Linux
- isi `LOLMINER_UNIX_BIN=/path/ke/tools/lolminer/linux/lolMiner`

## Aturan Operasional

- Jangan simpan config sensitif di script launcher.
- Simpan perbedaan device hanya di `config.local/miner.env`.
- Jangan ubah `run.bat` lama jika masih dipakai untuk flow lama.
- Gunakan `run-portable.bat` atau `run.sh` untuk flow portable baru.

## Rekomendasi Penggunaan

- Gunakan `WORKER_NAME` unik per device.
- Simpan binary sesuai OS.
- Aktifkan autostart hanya untuk device yang memang stabil.
- Jika pindah laptop, cukup copy repo lalu sesuaikan `config.local/miner.env`.
