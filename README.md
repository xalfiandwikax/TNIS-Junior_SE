# Soal 1 — Docker & Docker Compose

**Nama Kandidat:** Alfian Dwika  
**Posisi:** Junior System Engineer  
**Topik:** Containerization menggunakan Docker dan Docker Compose

---

## 1. Deskripsi

Pada soal ini, saya membangun lingkungan aplikasi menggunakan Docker dan Docker Compose yang terdiri dari tiga layanan utama:

- **Nginx:** Reverse proxy untuk menerima request HTTP dan meneruskannya ke WordPress.
- **WordPress:** Aplikasi web yang berjalan di dalam container.
- **PostgreSQL:** Database server untuk menyimpan data aplikasi.

Setiap layanan menggunakan Dockerfile masing-masing dan dikonfigurasi melalui Docker Compose.

## 2. Arsitektur

Arsitektur aplikasi yang dirancang:

```text
                  Client / Browser
                         |
                         | HTTP :8080
                         v
                  +-------------+
                  |    Nginx    |
                  | Reverse Proxy|
                  +-------------+
                         |
                  Frontend Network
                         |
                         v
                  +-------------+
                  |  WordPress  |
                  |  Web App    |
                  +-------------+
                         |
                   Backend Network
                         |
                         v
                  +-------------+
                  | PostgreSQL  |
                  |  Database   |
                  +-------------+
```

### Penjelasan jaringan

- Nginx terhubung ke jaringan `frontend`.
- WordPress terhubung ke jaringan `frontend` dan `backend`.
- PostgreSQL hanya terhubung ke jaringan `backend`.
- Port aplikasi yang dipublikasikan ke host adalah `8080`.
- Port PostgreSQL `5432` tidak dipublikasikan langsung ke host.

## 3. Struktur Direktori

```text
TNIS-Junior_SE/
├── docker-compose.yml
├── .env
├── README.md
├── nginx/
│   ├── Dockerfile
│   └── nginx.conf
├── wordpress/
│   └── Dockerfile
└── postgres/
    └── Dockerfile
```

## 4. Teknologi yang Digunakan

| Komponen | Teknologi |
|---|---|
| Reverse Proxy | Nginx |
| Web Application | WordPress |
| Database | PostgreSQL |
| Containerization | Docker |
| Container Orchestration | Docker Compose |
| Operating System | openSUSE Linux |

## 5. Konfigurasi dan Menjalankan Aplikasi

### 5.1 Memeriksa konfigurasi Docker Compose

```bash
sudo docker compose config
```

Perintah ini digunakan untuk memeriksa konfigurasi Docker Compose sebelum menjalankan layanan.

### 5.2 Build dan menjalankan container

```bash
sudo docker compose up -d --build
```

Perintah tersebut membangun image dan menjalankan layanan di background.

### 5.3 Memeriksa status container

```bash
sudo docker compose ps
```

**Screenshot:**  
![Status container Docker](screenshots/01-container-status.png)

> Simpan screenshot status container dengan nama `01-container-status.png` di dalam folder `screenshots`.

### 5.4 Memeriksa log aplikasi

```bash
sudo docker compose logs --tail=100
```

Untuk melihat log layanan tertentu:

```bash
sudo docker compose logs nginx
sudo docker compose logs wordpress
sudo docker compose logs postgres
```

## 6. Pengujian Aplikasi

### 6.1 Mengakses WordPress

Buka alamat berikut melalui browser:

```text
http://localhost:8080/wp-admin/install.php
```

Halaman instalasi WordPress dapat diakses melalui Nginx pada port `8080`.

**Screenshot:**

![Halaman instalasi WordPress](screenshots/05-wordpress-install-page.png)

### 6.2 Memeriksa port yang dipublikasikan

```bash
sudo docker ps --format 'table {{.Names}}\t{{.Ports}}'
```

Pemeriksaan ini digunakan untuk memastikan port yang dipublikasikan oleh masing-masing container sesuai dengan konfigurasi.

**Screenshot:**

![Published ports](screenshots/03-published-ports.png)

### 6.3 Memeriksa jaringan Docker

```bash
sudo docker network ls
sudo docker compose config
```

Untuk memeriksa detail jaringan, sesuaikan nama jaringan dengan hasil `docker network ls`:

```bash
sudo docker network inspect NAMA_NETWORK
```

**Screenshot:**

![Konfigurasi jaringan Docker](screenshots/02-docker-network.png)

### 6.4 Memeriksa user dalam container

Jalankan perintah berikut:

```bash
sudo docker exec tnis-nginx id
sudo docker exec tnis-wordpress id
sudo docker exec tnis-postgres id
```

Pemeriksaan ini digunakan untuk memverifikasi user yang menjalankan proses di dalam setiap container. Catat hasil aktual dari masing-masing container.

**Screenshot:**

![User dalam container](screenshots/04-container-users.png)

## 7. Integrasi WordPress dan PostgreSQL

WordPress secara default mendukung MySQL/MariaDB. Untuk menggunakan PostgreSQL, proyek ini menggunakan adapter pihak ketiga PG4WP.

Konfigurasi tersebut memerlukan validasi kompatibilitas antara versi WordPress, adapter PG4WP, dan PostgreSQL.

### Hasil pengujian

- Halaman instalasi WordPress dapat diakses melalui Nginx.
- Container telah dijalankan menggunakan Docker Compose.
- Pengujian awal menemukan error adapter terkait `information_schema`.
- Pemeriksaan database belum menemukan tabel WordPress.

Dengan demikian, **integrasi WordPress dan PostgreSQL belum dinyatakan berhasil sepenuhnya**. Pengujian perlu dilanjutkan sampai instalasi WordPress selesai dan tabel aplikasi berhasil dibuat di PostgreSQL.

Untuk memeriksa tabel database:

```bash
sudo docker exec tnis-postgres \
  psql -U appuser -d wordpress -c '\dt'
```

**Screenshot setelah integrasi berhasil:**

![Tabel WordPress di PostgreSQL](screenshots/06-wordpress-database-tables.png)

> Tambahkan screenshot ini setelah tabel WordPress benar-benar berhasil dibuat. Jangan gunakan gambar contoh sebagai bukti hasil pengujian.

## 8. Keamanan dan Isolasi

Konfigurasi yang diterapkan atau diperiksa dalam proyek ini meliputi:

- PostgreSQL tidak dipublikasikan langsung ke host.
- Akses ke aplikasi melalui Nginx sebagai reverse proxy.
- Pemisahan jaringan frontend dan backend.
- Penggunaan file `.env` untuk menyimpan konfigurasi lingkungan.
- Pemeriksaan user yang menjalankan proses di dalam container.

Status penerapan setiap poin perlu disesuaikan dengan konfigurasi aktual dan hasil pengujian.

**Catatan:** Jangan memasukkan password, token, atau nilai rahasia dari file `.env` ke dalam screenshot atau repository publik.

## 9. Bukti Screenshot

Simpan screenshot di dalam folder `screenshots/` dengan struktur berikut:

```text
TNIS-Junior_SE/
├── README.md
└── screenshots/
    ├── 01-container-status.png
    ├── 02-docker-network.png
    ├── 03-published-ports.png
    ├── 04-container-users.png
    ├── 05-wordpress-install-page.png
    └── 06-wordpress-database-tables.png
```

Daftar bukti yang disiapkan:

| No. | Screenshot | Tujuan |
|---|---|---|
| 1 | `01-container-status.png` | Menunjukkan status container |
| 2 | `02-docker-network.png` | Menunjukkan konfigurasi jaringan |
| 3 | `03-published-ports.png` | Menunjukkan port yang dipublikasikan |
| 4 | `04-container-users.png` | Menunjukkan user dalam container |
| 5 | `05-wordpress-install-page.png` | Menunjukkan halaman instalasi WordPress |
| 6 | `06-wordpress-database-tables.png` | Membuktikan tabel WordPress di PostgreSQL |

## 10. Status Pengerjaan

- [x] Membuat konfigurasi Docker Compose untuk tiga layanan.
- [x] Membuat Dockerfile untuk layanan yang digunakan.
- [x] Menjalankan container dan memeriksa status layanan.
- [x] Mengakses halaman instalasi WordPress melalui Nginx.
- [ ] Memverifikasi seluruh persyaratan user non-root.
- [ ] Melengkapi bukti konfigurasi jaringan dan published ports.
- [ ] Menyelesaikan integrasi WordPress dengan PostgreSQL.
- [ ] Memastikan tabel WordPress berhasil dibuat dan aplikasi berfungsi.

Status di atas harus diperbarui sesuai hasil pengujian terakhir.

---

## 11. Kesimpulan

Proyek ini membangun lingkungan container yang terdiri dari Nginx, WordPress, dan PostgreSQL menggunakan Docker Compose. Aplikasi WordPress dapat diakses melalui reverse proxy Nginx pada port `8080`.

Namun, keberhasilan akses halaman instalasi belum membuktikan bahwa WordPress telah terhubung dan berfungsi sepenuhnya dengan PostgreSQL. Integrasi database masih perlu diselesaikan dan diverifikasi sebelum seluruh Soal 1 dinyatakan selesai.
