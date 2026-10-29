# Soal 3 — HTTPS & Domain Configuration

## 1. Tujuan

Mengaktifkan HTTPS pada WordPress melalui Nginx reverse proxy menggunakan domain lokal `tnis.test`, dengan fitur:

- Redirect HTTP ke HTTPS.
- TLS 1.2 dan TLS 1.3.
- Reverse proxy ke WordPress.
- Endpoint health check.
- Deployment menggunakan Docker Compose dan Ansible.

## 2. Arsitektur

```text
Browser
   |
   | HTTPS :443 / HTTP :80
   v
Nginx Container
Host :443 -> Container :8443
Host :80  -> Container :8080
   |
   | HTTP internal
   v
WordPress :8080
   |
   v
PostgreSQL
```

## 3. Konfigurasi Domain

Tambahkan pada `/etc/hosts`:

```text
127.0.0.1 tnis.test
```

Verifikasi:

```bash
getent hosts tnis.test
```

## 4. Konfigurasi SSL dengan mkcert

Instal CA lokal dan buat sertifikat:

```bash
mkcert -install

mkcert \
  -cert-file nginx/certs/tnis.test.crt \
  -key-file nginx/certs/tnis.test.key \
  tnis.test

chmod 600 nginx/certs/tnis.test.key
```

Sertifikat dan private key digunakan oleh Nginx pada:

```text
/etc/nginx/certs/tnis.test.crt
/etc/nginx/certs/tnis.test.key
```

## 5. Konfigurasi Nginx

### HTTP Redirect

```nginx
server {
    listen 8080 default_server;
    server_name tnis.test _;

    location = /health {
        access_log off;
        default_type text/plain;
        return 200 "healthy\n";
    }

    location / {
        return 301 https://tnis.test$request_uri;
    }
}
```

Konfigurasi mengalihkan request HTTP ke HTTPS menggunakan status `301`. Endpoint `/health` dikecualikan dari redirect dan mengembalikan `200 OK`.

### HTTPS dan Reverse Proxy

```nginx
server {
    listen 8443 ssl;
    server_name tnis.test;

    ssl_certificate     /etc/nginx/certs/tnis.test.crt;
    ssl_certificate_key /etc/nginx/certs/tnis.test.key;

    ssl_protocols TLSv1.2 TLSv1.3;

    location = /health {
        access_log off;
        default_type text/plain;
        return 200 "healthy\n";
    }

    location / {
        set $wordpress_backend wordpress:8080;
        proxy_pass http://$wordpress_backend;

        proxy_http_version 1.1;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header Connection "";

        proxy_connect_timeout 5s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
```

Nginx menggunakan sertifikat `mkcert`, mengizinkan TLS 1.2 dan TLS 1.3, serta meneruskan request ke service `wordpress:8080`. Header `X-Forwarded-Proto` menginformasikan bahwa koneksi dari browser menggunakan HTTPS.

Konfigurasi global menggunakan `server_tokens off`, log ke stdout/stderr, dan resolver internal Docker `127.0.0.11` untuk resolusi service backend.

## 6. Deployment

Jalankan playbook Ansible:

```bash
cd Deployment-Otomatis-dengan-Ansible
sudo ansible-playbook deploy.yml
```

Periksa status container:

```bash
cd /opt/tnis-junior-se
sudo docker compose ps
```

Validasi konfigurasi Nginx:

```bash
sudo docker exec tnis-nginx nginx -t
```

## 7. Pengujian

### HTTP Redirect

```bash
curl -I http://tnis.test
```

Hasil yang diharapkan: status `301 Moved Permanently` dengan header `Location: https://tnis.test/...`.

### HTTPS

```bash
curl -I https://tnis.test
```

Request harus berhasil tanpa error validasi sertifikat.

### Health Check

```bash
curl -i https://tnis.test/health
```

Hasil yang diharapkan:

```text
HTTP/1.1 200 OK

healthy
```

### Validasi Sertifikat

```bash
openssl s_client \
  -connect tnis.test:443 \
  -servername tnis.test \
  -verify_return_error </dev/null
```

Pastikan output menunjukkan:

```text
Verify return code: 0 (ok)
```

## 8. Akses Browser

- Website: https://tnis.test
- Login: https://tnis.test/wp-login.php
- Dashboard: https://tnis.test/wp-admin

Pastikan browser tidak menampilkan peringatan sertifikat.



## 9. Dokumentasi Screenshot
### 9.1 Konfigurasi Domain Lokal

**Syntax pengujian:**
```bash
getent hosts tnis.test
```

**Bukti:** Domain `tnis.test` mengarah ke alamat `127.0.0.1`.

**Screenshot:**
 (../screenshots/screenshots/hosts.png)
 
---


### 9.2 Pengujian Redirect HTTP ke HTTPS

**Syntax pengujian:**
```bash
curl -I http://tnis.test
```
**Bukti:** Respons menunjukkan status `301 Moved Permanently` dan header `Location` menuju HTTPS.

**Screenshot:**
`screenshots/http-tnis.png`

---

### 9.3 Pengujian HTTPS

**Syntax pengujian:**
```bash
curl -I https://tnis.test
```

**Bukti:** Server memberikan respons HTTP tanpa error validasi sertifikat. Status yang diharapkan umumnya `200 OK` atau respons sukses lain sesuai halaman yang diakses.

**Screenshot:**
`screenshots/https-tnis.png`
---

### 9.4 Validasi Sertifikat SSL

**Syntax pengujian:**
```bash
openssl s_client \
  -connect tnis.test:443 \
  -servername tnis.test \
  -verify_return_error </dev/null
```

**Bukti:** Output menampilkan:
```text
Verify return code: 0 (ok)
```

**Screenshot:**
`screenshots/ssl-sert.png`

---

### 9.5 Akses Website melalui HTTPS

**Alamat pengujian:**
```text
https://tnis.test
```

**Bukti:** Website terbuka melalui HTTPS dan browser tidak menampilkan peringatan sertifikat.

**Screenshot:**

`screenshots/ssl-homepage.png`

---

### 9.6 Halaman Login WordPress

**Alamat pengujian:**
```text
https://tnis.test/wp-login.php
```

**Bukti:** Halaman login WordPress dapat diakses melalui HTTPS.

**Screenshot:**

`screenshots/wp-login.png`

---

### 9.7 Dashboard WordPress

**Alamat pengujian:**
```text
https://tnis.test/wp-admin
```

**Bukti:** Dashboard WordPress dapat diakses setelah login berhasil.

**Screenshot:**

`screenshots/dashboard-ssl.png`

---

### 9.8 Status Container Docker

**Syntax pengujian:**
```bash
cd /opt/tnis-junior-se
sudo docker compose ps
```

**Bukti:** Status container Nginx, WordPress, dan PostgreSQL ditampilkan sesuai kondisi deployment.

**Screenshot:**

`screenshots/docker-ps-ssl.png`

---

### 9.9 Validasi Konfigurasi Nginx

**Syntax pengujian:**
```bash
sudo docker exec tnis-nginx nginx -t
```

**Bukti:** Output menampilkan:
```text
syntax is ok
test is successful
```

**Screenshot:**
`screenshots/nginx-t.png`
---


## 10. Kesimpulan

Konfigurasi Nginx menerapkan redirect HTTP ke HTTPS, TLS 1.2/1.3, health check, dan reverse proxy ke WordPress. Domain lokal `tnis.test` dan sertifikat `mkcert` digunakan untuk menguji akses HTTPS di lingkungan development.

Sertifikat `mkcert` ditujukan untuk penggunaan lokal dan bukan sertifikat publik untuk lingkungan produksi.