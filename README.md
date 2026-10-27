# 32-Bit Timer ve GPIO Kontrolcüsü – ASIC Tasarımı

## 1. Projenin Amacı

Bu projenin amacı, Verilog donanım tanımlama dili kullanılarak 32-bit programlanabilir bir zamanlayıcı (Timer) ve GPIO kontrolcüsü tasarlamak ve OpenLane 2 aracılığıyla ASIC fiziksel tasarım sürecini gerçekleştirmektir.

Tasarım, Wishbone veri yolu üzerinden kontrol edilmektedir. Fiziksel tasarımda SkyWater SKY130 üretim teknolojisi kullanılmıştır.

## 2. Sistem Mimarisi

Tasarım üç temel bileşenden oluşmaktadır:

- **32-bit Timer:** Programlanabilir zamanlayıcı ve kesme sinyali üretimi.
- **GPIO Kontrolcüsü:** Dijital giriş/çıkış pinlerinin kontrolü.
- **Wishbone Arayüzü:** İşlemci ile çevre birimleri arasında register tabanlı haberleşme.

Sistem içinde 32-bit GPIO veri yolu kullanılmış, üst modülde 16 fiziksel GPIO pini dışarıya açılmıştır.

### Kullanılan Verilog Modülleri

| Modül | Görevi |
|---|---|
| `timer32.v` | 32-bit zamanlayıcı |
| `timer_gpio_controller.v` | Wishbone ve GPIO kontrolü |
| `user_proj_example.v` | Caravel uyumlu üst modül |

## 3. Register Haritası

| Adres | Register | Açıklama |
|---|---|---|
| `0x00` | CTRL | Timer etkinleştirme |
| `0x04` | RELOAD | Timer yenileme değeri |
| `0x08` | COUNT | Güncel sayaç değeri |
| `0x0C` | STATUS | Timer tamamlanma durumu |
| `0x10` | GPIO_OUT | GPIO çıkış verileri |
| `0x14` | GPIO_IN | GPIO giriş verileri |
| `0x18` | GPIO_DIR | GPIO yön kontrolü |

GPIO yön register'ında `1` çıkışı, `0` girişi ifade eder.

## 4. Kullanılan Araçlar

- Verilog HDL
- OpenLane 2
- OpenROAD
- Yosys
- Magic
- KLayout
- Netgen
- SkyWater SKY130 PDK

Tasarımın hedef saat periyodu **25 ns (40 MHz)** olarak belirlenmiştir.

## 5. OpenLane Fiziksel Tasarım Akışı

Proje aşağıdaki aşamalardan geçirilmiştir:

1. RTL kodlarının hazırlanması
2. Fonksiyonel simülasyon
3. Mantık sentezi (Synthesis)
4. Floorplanning
5. Placement
6. Clock Tree Synthesis (CTS)
7. Global ve Detailed Routing
8. Anten kontrolü ve onarımı
9. Statik zamanlama analizi (STA)
10. DRC ve LVS doğrulaması
11. GDSII oluşturulması

### OpenLane Çalıştırma

OpenLane 2 ortamı etkinleştirildikten sonra:

```bash
cd ~/timer32-caravel
openlane --flow Classic openlane/user_proj_example/config.json
```

## 6. Fiziksel Tasarım Sonuçları

Son başarılı çalışma:

`RUN_2026-10-27_10-25-22`

| Kontrol | Sonuç |
|---|---|
| OpenLane akışı | 78/78 tamamlandı |
| Antenna | Başarılı |
| DRC | Başarılı |
| LVS | Başarılı |
| Setup ihlali | 0 |
| Hold ihlali | 0 |
| En kötü Setup Slack | +7.868 ns |
| En kötü Hold Slack | +0.465 ns |
| Max Slew ihlali | 98 |
| Max Fanout ihlali | 32 |

Anten, DRC, LVS ve raporlanan setup/hold kontrolleri başarıyla tamamlanmıştır.

Max Slew ve Max Fanout ihlalleri devam etmektedir. Ayrıca varsayılan Caravel SDC dosyasında bazı GPIO giriş/çıkış zamanlama yolları kısıtlanmamıştır. Bu nedenle tasarım tamamen ihlalsiz olarak değerlendirilmemelidir.

## 7. Karşılaşılan Problemler ve Çözümler

### Anten İhlalleri

İlk fiziksel tasarım çalışmalarında anten kuralı ihlalleri tespit edilmiştir.

Anten onarım ayarları aşağıdaki şekilde güncellenmiştir:

- `GRT_ANTENNA_MARGIN = 50`
- `GRT_ANTENNA_ITERS = 10`

Bu değişikliklerle son tasarımda anten kontrolü başarıyla tamamlanmıştır.

### Uzun Bağlantı Hatları

Uzun bağlantı hatlarının elektriksel performansını değerlendirmek amacıyla:

`DESIGN_REPAIR_MAX_WIRE_LENGTH = 500`

ayarı kullanılmıştır.

Bu değişiklik sonrasında Max Slew ihlali 100'den 98'e, Max Fanout ihlali ise 34'ten 32'ye düşmüştür. Ancak kalan ihlaller tamamen giderilememiştir.

## 8. Doğrulama

Timer ve Wishbone/GPIO kontrolcüsü için fonksiyonel simülasyonlar gerçekleştirilmiştir.

Fiziksel doğrulama aşamasında DRC ve LVS kontrolleri başarıyla tamamlanmıştır. Statik zamanlama analizinde tanımlı kısıtlar altında setup ve hold ihlali tespit edilmemiştir.

## 9. Proje Dosyaları

- `verilog/rtl/` – Verilog kaynak kodları
- `tb/` – Testbench dosyaları
- `openlane/user_proj_example/config.json` – OpenLane yapılandırması
- `openlane/user_proj_example/base_user_proj_example.sdc` – Zamanlama kısıtları
- `README.md` – Proje dokümantasyonu

Büyük boyutlu ara tasarım dosyaları GitHub deposundan hariç tutulmuştur.

## 10. Sonuç ve Gelecek Çalışmalar

Bu proje kapsamında 32-bit Timer ve GPIO kontrolcüsü tasarlanmış ve OpenLane kullanılarak RTL seviyesinden GDSII üretimine kadar ASIC tasarım süreci gerçekleştirilmiştir.

Gelecekte Max Slew ve Max Fanout ihlallerinin azaltılması, GPIO girişlerinin asenkron kullanımına yönelik senkronizasyon eklenmesi ve zamanlama kısıtlarının geliştirilmesi hedeflenmektedir.

## 11. Kaynaklar

- [OpenLane](https://openlane2.readthedocs.io/)
- [OpenROAD](https://openroad.readthedocs.io/)
- [SkyWater SKY130 PDK](https://github.com/google/skywater-pdk)
- [Efabless Caravel](https://github.com/efabless/caravel_user_project)
