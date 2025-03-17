# Ringkasan README.md

README.md ini berisi informasi tentang proyek ini, termasuk deskripsi, fitur, dan cara penggunaan.


For windows you can run to folder xmrig and run 

start.bat


oke you run this commant in foldet xmrig windows or linux 


```
xmrig.exe -o rx.unmineable.com:3333 -a rx -k -u DOGE:DSycjXnngRekwJKRQKXJwY88GPw4w9FmQA.DELL -p x --threads=2  --cpu-priority=5 --huge-pages-jit --print-time=1 --health-print-time=10 --donate-level=0 --threads=2  --cpu-priority=5 --cpu-affinity=0xC0
```



## CPU Affinity Settings

Berikut adalah daftar nilai hexadecimal untuk setting CPU affinity berdasarkan core dan logical CPU:

| Core | Logical CPUs | Hex Value | Command Parameter |
|------|--------------|-----------|-------------------|
| Core 1 | CPU 0, CPU 1 | 0x3 | --cpu-affinity=0x3 |
| Core 2 | CPU 2, CPU 3 | 0xC | --cpu-affinity=0xC |
| Core 3 | CPU 4, CPU 5 | 0x30 | --cpu-affinity=0x30 |
| Core 4 | CPU 6, CPU 7 | 0xC0 | --cpu-affinity=0xC0 |
| Core 5 | CPU 8, CPU 9 | 0x300 | --cpu-affinity=0x300 |
| Core 6 | CPU 10, CPU 11 | 0xC00 | --cpu-affinity=0xC00 |
| Core 7 | CPU 12, CPU 13 | 0x3000 | --cpu-affinity=0x3000 |
| Core 8 | CPU 14, CPU 15 | 0xC000 | --cpu-affinity=0xC000 |
| Core 9 | CPU 16, CPU 17 | 0x30000 | --cpu-affinity=0x30000 |
| Core 10 | CPU 18, CPU 19 | 0xC0000 | --cpu-affinity=0xC0000 |
| Core 11 | CPU 20, CPU 21 | 0x300000 | --cpu-affinity=0x300000 |
| Core 12 | CPU 22, CPU 23 | 0xC00000 | --cpu-affinity=0xC00000 |
| Core 13 | CPU 24, CPU 25 | 0x3000000 | --cpu-affinity=0x3000000 |
| Core 14 | CPU 26, CPU 27 | 0xC000000 | --cpu-affinity=0xC000000 |
| Core 15 | CPU 28, CPU 29 | 0x30000000 | --cpu-affinity=0x30000000 |
| Core 16 | CPU 30, CPU 31 | 0xC0000000 | --cpu-affinity=0xC0000000 |

Contoh penggunaan:
- Untuk menggunakan Core 2 (CPU 2 & 3): `--cpu-affinity=0xC`
- Untuk menggunakan Core 4 (CPU 6 & 7): `--cpu-affinity=0xC0`
- Untuk menggunakan Core 1 & 2 (CPU 0-3): `--cpu-affinity=0xF`

