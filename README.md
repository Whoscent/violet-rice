<div align="center">

# 🌸 violet-rice

> *A seamless blend of scenic nature and a clean, violet-pastel terminal setup.*

![Desktop Overview](https://z-cdn-media.chatglm.cn/files/90aecf11-28ce-4e9e-a3d7-1eaa96ca2c79.png)

**Artix Linux** • **MangoWM** • **Foot** • **Starship**

</div>

---

## ✨ Tentang Repo Ini
**violet-rice** adalah kumpulan *dotfiles* personal milik **Senarch**. Tema ini berfokus pada gradien warna *violet-to-pink pastel* yang mulus, dikombinasikan dengan pemandangan alam yang *muted* dan *aesthetic*. Didesain agar nyaman dilihat berjam-jam di depan layar tanpa membuat mata silau.

## 🧩 Komponen Utama
Berikut adalah aplikasi dan *tools* yang saya gunakan untuk membangun *rice* ini:

| Kategori | Aplikasi |
| :--- | :--- |
| **OS** | Artix Linux |
| **Window Manager** | MangoWM |
| **Bar** | Waybar |
| **Terminal** | Foot |
| **Shell Prompt** | Starship |
| **App Launcher** | Rofi |
| **Notification Daemon** | Mako |
| **Display Manager** | SDDM |
| **Music Visualizer** | Cava |
| **File Manager** | Thunar |
| **Text Editor** | Neovim |

## 🔤 Fonts
Pastikan font berikut terinstall di sistemmu agar simbol dan tampilan teks terlihat sempurna:
- `JetBrainsMono Nerd Font`
- `Cormorant Garamond`
- `EB Garamond`

---

<details>
<summary>🖼️ <b>Gallery (Klik untuk melihat)</b></summary>

<br>

| <img src="https://z-cdn-media.chatglm.cn/files/90aecf11-28ce-4e9e-a3d7-1eaa96ca2c79.png" width="400"/> | <img src="https://z-cdn-media.chatglm.cn/files/196323af-75b9-440c-a548-9fe540a4d5a9.png" width="400"/> |
|:---:|:---:|
| **Desktop Overview (Waybar & Wallpaper)** | **Terminal & Starship Prompt** |

| <img src="https://z-cdn-media.chatglm.cn/files/59fbd113-fc17-4300-96c2-85c176058462.png" width="400"/> | <img src="https://z-cdn-media.chatglm.cn/files/663595c1-808f-4e47-9477-73012b3b0d89.png" width="400"/> |
|:---:|:---:|
| **Media & Cava Visualizer** | **Rofi App Launcher** |

| <img src="https://z-cdn-media.chatglm.cn/files/cd89b3be-f5c9-457b-a051-5edae3cd1589.png" width="400"/> | <img src="https://z-cdn-media.chatglm.cn/files/337f914f-12cd-45cd-a613-5c16c8b096d0.png" width="400"/> |
|:---:|:---:|
| **NetworkManager** | **SDDM Login Screen** |

| <img src="https://z-cdn-media.chatglm.cn/files/2a4a1426-6d69-4967-8614-149d8364d56f.png" width="400"/> | <img src="https://z-cdn-media.chatglm.cn/files/c0b0cf0b-2f43-4b40-b472-571ae5b5afa6.png" width="400"/> |
|:---:|:---:|
| **Swaylock Screen** | **Wlogout Menu** |

| <img src="https://z-cdn-media.chatglm.cn/files/711e6c8a-f870-402f-8111-6fef44736986.png" width="400"/> | <img src="https://z-cdn-media.chatglm.cn/files/d03b9a1d-51c9-446b-b9fd-67b26bca4cf3.png" width="400"/> |
|:---:|:---:|
| **GRUB Theme** | **Mako Notifications** |

</details>

---

<details>
<summary>🚀 <b>Instalasi (Klik untuk melihat)</b></summary>

<br>

> ⚠️ **Peringatan:** Repo ini adalah konfigurasi personal. Pastikan kamu sudah membackup config lama kamu sebelum mengoverwrite. Tidak ada `install.sh` otomatis, jadi kita akan melakukannya manual.

### 1. Install Dependencies
Install semua aplikasi yang dibutuhkan. Jika kamu menggunakan Artix Linux (pacman), jalankan:
```bash
sudo pacman -S mangowm foot starship waybar rofi mako sddm cava thunar neovim
```
*Catatan: Untuk MangoWM, pastikan kamu install dari AUR atau compile dari source sesuai panduan resminya.*

### 2. Install Fonts
Jangan lupa install font yang dibutuhkan:
```bash
sudo pacman -S ttf-jetbrains-mono-nerd
# Untuk EB Garamond dan Cormorant Garamond, cari di AUR atau unduh manual
```

### 3. Clone Repository
```bash
git clone https://github.com/Senarch/violet-rice.git
cd violet-rice
```

### 4. Copy Konfigurasi
Pindahkan folder konfigurasi ke direktori `~/.config/` di sistemmu. Contoh untuk beberapa aplikasi utama:
```bash
# Contoh copy MangoWM, Waybar, Foot, Starship, dll
cp -r mangowm ~/.config/
cp -r waybar ~/.config/
cp -r foot ~/.config/
cp -r starship ~/.config/
cp -r rofi ~/.config/
cp -r mako ~/.config/
cp -r cava ~/.config/
```

### 5. Setup GRUB Theme
- Copy folder theme ke `/boot/grub/themes/`
- Edit file `/etc/default/grub` dan tambahkan: `GRUB_THEME="/boot/grub/themes/violet-rice/theme.txt"`
- Update GRUB:
```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### 6. Restart Service
Restart service yang berjalan di background agar config baru terbaca, atau bisa juga langsung *reboot* PC kamu:
```bash
systemctl --user restart waybar mako
```

</details>

---

<div align="center">

## 💜 Credits & Thanks

Dibuat dengan ❤️ oleh **[Senarch](https://github.com/Senarch)**.
Terima kasih kepada komunitas r/unixporn dan pembuat aplikasi *open-source* yang luar biasa!

Jika kamu suka dengan *rice* ini, jangan lupa kasih ⭐ di repository ini!

</div>
```

***
