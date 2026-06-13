-- ============================================================
--  Challenge Tracker – Demo Veritabanı
--  Oluşturulma: 2026-06-13
--  Kullanım: MySQL 5.7+ / MariaDB 10.3+
--  Import: mysql -u root -p challenge_tracker < challenge_tracker_demo.sql
-- ============================================================

DROP DATABASE IF EXISTS challenge_tracker;
CREATE DATABASE challenge_tracker
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE challenge_tracker;

-- ============================================================
-- TABLO 1: users
-- ============================================================
CREATE TABLE users (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  username      VARCHAR(80)  NOT NULL UNIQUE,
  email         VARCHAR(120) NOT NULL UNIQUE,
  password_hash VARCHAR(256) NOT NULL,
  created_at    DATETIME     DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLO 2: challenges
-- ============================================================
CREATE TABLE challenges (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  user_id     INT          NOT NULL,
  title       VARCHAR(200) NOT NULL,
  description TEXT,
  start_date  DATE         NOT NULL,
  end_date    DATE         NOT NULL,
  category    VARCHAR(50)  DEFAULT 'Diğer',
  status      VARCHAR(20)  DEFAULT 'active'
                           CHECK (status IN ('active','completed','failed')),
  created_at  DATETIME     DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLO 3: daily_logs
-- ============================================================
CREATE TABLE daily_logs (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  challenge_id INT         NOT NULL,
  log_date     DATE        NOT NULL,
  status       VARCHAR(20) NOT NULL
                           CHECK (status IN ('completed','missed','pending')),
  notes        TEXT,
  created_at   DATETIME    DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (challenge_id) REFERENCES challenges(id) ON DELETE CASCADE,
  UNIQUE KEY uq_challenge_date (challenge_id, log_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLO 4: badges
-- ============================================================
CREATE TABLE badges (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  icon_url    VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLO 5: user_badges
-- ============================================================
CREATE TABLE user_badges (
  id        INT AUTO_INCREMENT PRIMARY KEY,
  user_id   INT      NOT NULL,
  badge_id  INT      NOT NULL,
  earned_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id)  REFERENCES users(id)  ON DELETE CASCADE,
  FOREIGN KEY (badge_id) REFERENCES badges(id) ON DELETE CASCADE,
  UNIQUE KEY uq_user_badge (user_id, badge_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- DEMO VERİLERİ
-- ============================================================

-- KULLANICILAR (şifreler: "demo1234" Werkzeug hash ile)
INSERT INTO users (username, email, password_hash) VALUES
('ali_dev',   'ali@example.com',    'pbkdf2:sha256:260000$demo$ali_dev_hash_placeholder'),
('zeynep_t',  'zeynep@example.com', 'pbkdf2:sha256:260000$demo$zeynep_hash_placeholder'),
('mehmet_y',  'mehmet@example.com', 'pbkdf2:sha256:260000$demo$mehmet_hash_placeholder');

-- ROZETLER
INSERT INTO badges (name, description, icon_url) VALUES
('İlk Adım',           'İlk meydan okumayı oluştur.',                   '/icons/badge_first.png'),
('İstikrar Başlangıcı','Herhangi bir challenge''da 3 günlük seri yap.', '/icons/badge_3streak.png'),
('Haftalık Savaşçı',   '7 günlük kesintisiz seri tamamla.',              '/icons/badge_7streak.png'),
('Fatih',              'En az 1 challenge''ı başarıyla bitir.',           '/icons/badge_conqueror.png');

-- CHALLENGE'LAR
INSERT INTO challenges (user_id, title, description, start_date, end_date, category, status) VALUES
(1, '30 Gün Kod',        'Her gün en az 1 saat kod yazılacak.',              '2026-05-01', '2026-05-30', 'Yazılım',       'completed'),
(1, '100 Gün Flutter',   'Flutter öğrenmek için 100 günlük plan.',           '2026-06-01', '2026-09-08', 'Yazılım',       'active'),
(2, 'Sabah Koşusu',      'Her sabah en az 3 km koş.',                        '2026-05-15', '2026-06-14', 'Spor & Sağlık', 'active'),
(2, 'Almanca B1',        'Duolingo + Anki ile her gün 30 dk Almanca.',       '2026-04-01', '2026-06-30', 'Yabancı Dil',   'active'),
(3, 'Kitap Okuma',       'Ayda 1 kitap, her gün en az 20 sayfa.',            '2026-03-01', '2026-03-31', 'Kitap Okuma',   'completed'),
(3, 'Diyet Takibi',      'Kalori takibi ve öğün planlaması.',                '2026-06-01', '2026-06-30', 'Spor & Sağlık', 'failed');

-- GÜNLÜK LOGLAR (challenge 1 – 30 Gün Kod, seçili günler)
INSERT INTO daily_logs (challenge_id, log_date, status, notes) VALUES
(1,'2026-05-01','completed','İlk gün! Python egzersizleri yapıldı.'),
(1,'2026-05-02','completed','Algoritma soruları çözüldü.'),
(1,'2026-05-03','completed','Flask routing öğrenildi.'),
(1,'2026-05-04','completed','Veritabanı bağlantısı kuruldu.'),
(1,'2026-05-05','completed','API endpoint yazıldı.'),
(1,'2026-05-06','completed','Frontend ile entegrasyon.'),
(1,'2026-05-07','completed','7 günlük seri tamamlandı!'),
(1,'2026-05-08','missed',   NULL),
(1,'2026-05-09','completed','Geri döndüm, eksik günü telafi ettim.'),
(1,'2026-05-10','completed','CSS çalışması.'),
(1,'2026-05-30','completed','Challenge bitiş günü, proje deploy edildi!');

-- GÜNLÜK LOGLAR (challenge 2 – 100 Gün Flutter)
INSERT INTO daily_logs (challenge_id, log_date, status, notes) VALUES
(2,'2026-06-01','completed','Dart temelleri gözden geçirildi.'),
(2,'2026-06-02','completed','Flutter kurulumu ve ilk widget.'),
(2,'2026-06-03','completed','StatefulWidget vs StatelessWidget.'),
(2,'2026-06-04','completed','Navigator ile sayfa geçişleri.'),
(2,'2026-06-05','completed','Provider state yönetimi.'),
(2,'2026-06-06','completed','HTTP paketi ile API çağrısı.'),
(2,'2026-06-07','completed','ListView ve GridView kullanımı.'),
(2,'2026-06-08','completed','8. gün, animasyon temelleri.'),
(2,'2026-06-09','completed','CustomPainter denemeleri.'),
(2,'2026-06-10','completed','Uygulama: küçük hava durumu uygulaması.'),
(2,'2026-06-11','completed','Navigator 2.0 çalışıldı.'),
(2,'2026-06-12','completed','Provider ile state yönetimi bitti.'),
(2,'2026-06-13','completed','Bugün de tamamlandı!');

-- GÜNLÜK LOGLAR (challenge 3 – Sabah Koşusu)
INSERT INTO daily_logs (challenge_id, log_date, status, notes) VALUES
(3,'2026-05-15','completed','İlk koşu: 3.2 km, 22 dk.'),
(3,'2026-05-16','completed','3.5 km.'),
(3,'2026-05-17','completed','3 km, bacaklar ağrıdı.'),
(3,'2026-05-18','missed',   NULL),
(3,'2026-05-19','completed','Geri döndüm: 4 km.'),
(3,'2026-06-12','completed','Yağmura rağmen koştum: 5 km, 28 dk.'),
(3,'2026-06-13','completed','Sabah erken kalktım: 5.5 km.');

-- GÜNLÜK LOGLAR (challenge 4 – Almanca B1)
INSERT INTO daily_logs (challenge_id, log_date, status, notes) VALUES
(4,'2026-04-01','completed','Duolingo: 30 dk.'),
(4,'2026-04-02','completed','Anki tekrar + 10 yeni kelime.'),
(4,'2026-04-03','completed','Duolingo: 30 dk.'),
(4,'2026-06-13','missed',   NULL);

-- GÜNLÜK LOGLAR (challenge 5 – Kitap Okuma)
INSERT INTO daily_logs (challenge_id, log_date, status, notes) VALUES
(5,'2026-03-01','completed','Sapiens: 1. bölüm okundu.'),
(5,'2026-03-02','completed','Sapiens: 2. bölüm.'),
(5,'2026-03-28','completed','Kitap bitmek üzere.'),
(5,'2026-03-31','completed','Kitap bitti! Harika bir okuma deneyimiydi.');

-- GÜNLÜK LOGLAR (challenge 6 – Diyet Takibi)
INSERT INTO daily_logs (challenge_id, log_date, status, notes) VALUES
(6,'2026-06-01','completed','Kalori hedefi tutturuldu.'),
(6,'2026-06-02','completed','Sağlıklı öğünler.'),
(6,'2026-06-03','completed','İyi gidiyor.'),
(6,'2026-06-12','missed',   NULL),
(6,'2026-06-13','missed',   NULL);

-- ROZET KAZANIMLARI
INSERT INTO user_badges (user_id, badge_id, earned_at) VALUES
(1, 1, '2026-05-01 10:00:00'),  -- ali: İlk Adım
(1, 2, '2026-05-04 18:00:00'),  -- ali: İstikrar Başlangıcı
(1, 3, '2026-05-08 18:00:00'),  -- ali: Haftalık Savaşçı
(1, 4, '2026-05-30 23:59:00'),  -- ali: Fatih
(2, 1, '2026-05-15 09:00:00'),  -- zeynep: İlk Adım
(2, 2, '2026-05-18 09:00:00'),  -- zeynep: İstikrar Başlangıcı
(3, 1, '2026-03-01 08:00:00'),  -- mehmet: İlk Adım
(3, 4, '2026-03-31 23:59:00');  -- mehmet: Fatih

-- ============================================================
-- ÖRNEK KONTROL SORGULARI
-- ============================================================

-- Tüm tabloları listele:
-- SHOW TABLES;

-- Kullanıcı istatistikleri:
-- SELECT u.username, COUNT(c.id) as challenge_sayisi,
--        SUM(CASE WHEN c.status='completed' THEN 1 ELSE 0 END) as tamamlanan
-- FROM users u LEFT JOIN challenges c ON u.id = c.user_id
-- GROUP BY u.id;

-- En uzun seri (streak) hesabı:
-- SELECT c.title, COUNT(d.id) as toplam_tamamlanan
-- FROM challenges c JOIN daily_logs d ON c.id = d.challenge_id
-- WHERE d.status = 'completed'
-- GROUP BY c.id ORDER BY toplam_tamamlanan DESC;
