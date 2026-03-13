# Arsitektur Folder

Dokumen ini menjelaskan bagaimana folder repo disusun agar mendukung perpindahan antar environment desktop.

## Struktur Inti

```text
mining/
├── config/
├── config.local/
├── docs/
├── scripts/
│   ├── windows/
│   ├── unix/
│   ├── linux/
│   └── macos/
├── tools/
│   ├── xmrig/
│   │   ├── windows/
│   │   ├── linux/
│   │   └── macos/
│   └── lolminer/
│       ├── windows/
│       ├── linux/
│       └── macos/
├── run-portable.bat
├── run.sh
└── run.bat
```

## Prinsip Arsitektur

Arsitektur folder ini dibuat untuk memecah tanggung jawab:

- binary OS disimpan terpisah
- launcher OS disimpan terpisah
- logic bersama Unix tidak diduplikasi
- state per desktop tidak dicampur ke repo umum

## Penjelasan Folder

### `tools/`

Isi:

- semua binary dan bundle tool mining dikumpulkan dalam satu tempat

Tujuan:

- repo lebih rapi
- semua tool mudah dicari
- perpindahan antar desktop lebih mudah dipahami

Subfolder utama:

- `tools/xmrig/windows`
- `tools/xmrig/linux`
- `tools/xmrig/macos`
- `tools/lolminer/windows`
- `tools/lolminer/linux`
- `tools/lolminer/macos`

### `config/`

Isi:

- template setup yang aman dibagikan

File utama:

- [miner.env.example](../config/miner.env.example)

### `config.local/`

Isi:

- state setup lokal aktif per desktop
- tidak ikut git

File utama:

- [miner.env](../config.local/miner.env)

Tujuan:

- menyimpan perbedaan antar environment desktop
- menghindari hardcode wallet dan worker di script

### `docs/`

Isi:

- dokumentasi penggunaan
- dokumentasi arsitektur
- dokumentasi operasional

### `scripts/windows/`

Isi:

- launcher khusus environment Windows
- menu interaktif
- helper autostart Startup folder

File utama:

- [menu.cmd](../scripts/windows/menu.cmd)
- [start-profile.cmd](../scripts/windows/start-profile.cmd)
- [enable-autostart.ps1](../scripts/windows/enable-autostart.ps1)

### `scripts/unix/`

Isi:

- logika inti bersama untuk environment Linux dan macOS

File utama:

- [common.sh](../scripts/unix/common.sh)
- [start-xmrig.sh](../scripts/unix/start-xmrig.sh)
- [start-lolminer.sh](../scripts/unix/start-lolminer.sh)
- [start-profile.sh](../scripts/unix/start-profile.sh)

Tujuan:

- mengurangi duplikasi script Linux dan macOS
- menjaga perilaku antar Unix tetap konsisten

### `scripts/linux/`

Isi:

- wrapper khusus environment Linux
- autostart Linux berbasis `systemd --user`

File utama:

- [start-profile.sh](../scripts/linux/start-profile.sh)
- [enable-autostart.sh](../scripts/linux/enable-autostart.sh)

### `scripts/macos/`

Isi:

- wrapper khusus environment macOS
- autostart macOS berbasis LaunchAgent

File utama:

- [start-profile.sh](../scripts/macos/start-profile.sh)
- [enable-autostart.sh](../scripts/macos/enable-autostart.sh)

### `tools/xmrig/windows/`

Isi:

- binary XMRig Windows
- file config vendor Windows

### `tools/xmrig/linux/`

Isi:

- binary XMRig Linux
- file config vendor Linux

### `tools/xmrig/macos/`

Isi:

- binary XMRig macOS arm64 versi 6.25.0
- file config vendor macOS

### `tools/lolminer/windows/`

Isi:

- binary lolMiner Windows
- script vendor bawaan Windows

### `tools/lolminer/linux/`

Isi:

- tempat untuk binary lolMiner Linux jika digunakan

### `tools/lolminer/macos/`

Isi:

- tempat untuk binary lolMiner macOS jika digunakan

## Alur Arsitektur

Secara sederhana, alurnya seperti ini:

```text
Desktop Windows  -> scripts/windows -> miner binary Windows
Desktop Linux    -> run.sh -> scripts/linux -> scripts/unix -> miner binary Linux
Desktop macOS    -> run.sh -> scripts/macos -> scripts/unix -> miner binary macOS
```

## Entry Point Repo

### Jalur baru

- [run-portable.bat](../run-portable.bat)
- [run.sh](../run.sh)

### Jalur lama

- [run.bat](../run.bat)

Status `run.bat`:

- tidak diubah
- tetap disimpan sebagai fallback lama
- tidak direkomendasikan untuk flow portable baru
