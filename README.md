# 📱 WorkMate – Worker Task Management System (Phase 3)

### STIWK2114 Mobile Programming Final Project – By Nur Anis Athirah

WorkMate is a Flutter-based mobile app designed to help workers manage daily tasks, track their submission history, and update their personal profile efficiently. This project completes **Phase 3** of the course by adding profile viewing, updating, and improved navigation.

---

## 🔧 Setup Instructions

 Clone the Project

git clone https://github.com/Anisfazed/workmate.git

cd workmate

Open lib/myconfig.dart and replace the URL with your actual PHP backend server:
class MyConfig {
  static const String myurl = "https://yourserver.com"; // <-- change this!
}

Install Dependencies
flutter pub get
---

Dummy Data for Testing

INSERT INTO `tbl_users` (`user_id`, `name`, `email`, `password`, `phone`, `address`, `image`) VALUES
(1, 'Chaerin Lee', 'chaechae@gmail.com', '7c4a8d09ca3762af61e59520943dc26494f8941b', '0114045510', 'Cyberjaya', '1_profile.png'),
(2, 'Anas Huffaz', 'anas@gmail.com', '7c4a8d09ca3762af61e59520943dc26494f8941b', '01140752066', 'Klang', '2_profile.png'),
(3, 'Nur Anis Athirah', 'anis@gmail.com', '7c4a8d09ca3762af61e59520943dc26494f8941b', '01140752066', 'Kepala Batas,Penang', 'anis@gmail.com.png');

---
Images are uploaded as Base64 and saved to assets/images/.
----

📝 Notes
Profile image updates use timestamped URLs to prevent browser cache.

App works across Android, iOS, and Flutter Web.

Requires internet access for image upload and profile changes.


