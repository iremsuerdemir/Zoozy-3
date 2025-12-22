import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoozy/components/bottom_navigation_bar.dart';
import 'package:zoozy/screens/help_center_page.dart';
import 'package:zoozy/screens/indexbox_message.dart';
import 'package:zoozy/screens/pet_profile_page.dart';
import 'package:zoozy/screens/pet_walk_page.dart';
import 'package:zoozy/screens/profile_screen.dart';
import 'package:zoozy/services/guest_access_service.dart';
import 'package:zoozy/services/request_service.dart';
import 'package:zoozy/services/notification_service.dart';

import '../models/request_item.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  int selectedIndex = 0;

  static const Color primaryPurple = Color.fromARGB(255, 111, 79, 172);
  static const Color softPink = Color(0xFFF48FB1);
  static const Color cardIconBgColor = Color(0xFFF3E5F5);

  List<RequestItem> requestList = [];
  final RequestService _requestService = RequestService();
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = true;
  bool _hasUnreadNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadRequests();
    _checkNotifications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Build tamamlandıktan sonra yükle (setState during build hatasını önlemek için)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRequests();
      _checkNotifications();
    });
  }

  /// Bildirimleri kontrol et
  Future<void> _checkNotifications() async {
    try {
      final isGuest = await GuestAccessService.isGuest();
      if (isGuest) {
        if (mounted) {
          setState(() {
            _hasUnreadNotifications = false;
          });
        }
        return;
      }

      final notifications = await _notificationService.getNotifications();
      final hasUnread = notifications.any((n) => !n.isRead);
      if (mounted) {
        setState(() {
          _hasUnreadNotifications = hasUnread;
        });
      }
    } catch (e) {
      print('Bildirim kontrol hatası: $e');
    }
  }

  /// Tüm bildirimleri okundu yap
  Future<void> _markAllNotificationsAsRead() async {
    try {
      final notifications = await _notificationService.getNotifications();
      final unreadNotifications =
          notifications.where((n) => !n.isRead).toList();

      for (var notification in unreadNotifications) {
        await _notificationService.markAsRead(notification.id);
      }

      // Bildirimleri tekrar kontrol et
      await _checkNotifications();
    } catch (e) {
      print('Bildirim okundu işaretleme hatası: $e');
    }
  }

  IconData _getServiceIcon(String serviceName) {
    switch (serviceName) {
      case "Pansiyon":
        return Icons.house_outlined;
      case "Gündüz Bakımı":
        return Icons.sunny_snowing;
      case "Evde Bakım":
        return Icons.chair_outlined;
      case "Gezdirme":
        return Icons.directions_walk;
      case "Taksi":
        return Icons.local_taxi_outlined;
      case "Bakım":
        return Icons.cut_outlined;
      case "Eğitim":
        return Icons.school_outlined;
      default:
        return Icons.pets;
    }
  }

  Future<void> _deleteRequest(int index) async {
    final request = requestList[index];
    
    // Delete from backend if it has an ID
    if (request.id != null) {
      final success = await _requestService.deleteRequest(request.id!);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Talep silinirken bir hata oluştu.')),
        );
        return;
      }
    }

    setState(() {
      requestList.removeAt(index);
    });
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final requests = await _requestService.getUserRequests();
      setState(() {
        requestList = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Request yükleme hatası: $e');
    }
  }

  Future<ImageProvider?> _loadProfileImageProvider(String userPhoto) async {
    try {
      if (userPhoto.startsWith('data:image') ||
          userPhoto.length > 100 &&
              RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(userPhoto)) {
        final bytes = base64Decode(userPhoto);
        return MemoryImage(bytes);
      }
      if (userPhoto.isNotEmpty &&
          (userPhoto.startsWith('http://') ||
              userPhoto.startsWith('https://'))) {
        return NetworkImage(userPhoto);
      }
      final prefs = await SharedPreferences.getInstance();
      final profileImagePath = prefs.getString('profileImagePath');
      if (profileImagePath != null && profileImagePath.isNotEmpty) {
        try {
          final bytes = base64Decode(profileImagePath);
          return MemoryImage(bytes);
        } catch (e) {
          print('Profil resmi decode edilemedi: $e');
          return null;
        }
      }
      return null;
    } catch (e) {
      print('Profil resmi yüklenirken hata: $e');
      return null;
    }
  }

  Widget _buildIconTextCard(
    IconData icon,
    String text, {
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: () async {
        if (text == "Köpek Gezdir" || text == "Yardım") {
          final allowed = await GuestAccessService.ensureLoggedIn(context);
          if (allowed) {
            if (text == "Köpek Gezdir") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PetWalkPage()),
              );
            } else if (text == "Yardım") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpCenterPage()),
              );
            }
          }
        }

        // ⭐⭐⭐ HİZMET AL BURADA YAKALANIYOR ⭐⭐⭐
        else if (text == "Hizmet Al") {
          final allowed = await GuestAccessService.ensureLoggedIn(context);
          if (!allowed) return;
          _showBroadcastRequestModal(context);
        } else {
          setState(() {
            selectedIndex = _getIndexFromText(text);
          });
        }
      },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isSelected ? primaryPurple : cardIconBgColor,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : primaryPurple,
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.black87 : Colors.black54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  int _getIndexFromText(String text) {
    switch (text) {
      case "İstekler":
        return 0;
      case "Hizmet Al":
        return 1;
      case "Köpek Gezdir":
        return 2;
      case "Yardım":
        return 3;
      default:
        return 0;
    }
  }

  Widget _buildServiceSelectionCard(
    BuildContext context,
    IconData icon,
    String text,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context); // Modalı kapat
          switch (text) {
            case "Pansiyon":
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PetProfilePage(
                    fromRequestPage: true,
                    serviceName: "Pansiyon",
                  ),
                ),
              );
              break;
            case "Gündüz Bakımı":
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PetProfilePage(
                    fromRequestPage: true,
                    serviceName: "Gündüz Bakımı",
                  ),
                ),
              );
              break;
            case "Evde Bakım":
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PetProfilePage(
                    fromRequestPage: true,
                    serviceName: "Evde Bakım",
                  ),
                ),
              );
              break;
            case "Gezdirme":
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PetProfilePage(
                    fromRequestPage: true,
                    serviceName: "Gezdirme",
                  ),
                ),
              );
              break;

            case "Taksi":
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PetProfilePage(
                    fromRequestPage: true,
                    serviceName: "Taksi",
                  ),
                ),
              );
              break;
            case "Bakım":
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PetProfilePage(
                    fromRequestPage: true,
                    serviceName: "Bakım",
                  ),
                ),
              );
              break;

            case "Eğitim":
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PetProfilePage(
                    fromRequestPage: true,
                    serviceName: "Eğitim",
                  ),
                ),
              );
              break;
          }
        },
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Icon(icon, color: primaryPurple, size: 32),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  void _showBroadcastRequestModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "İlan Yayını",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Yakınınızdaki destekçilere evcil hayvanlarınızla ilgili yardıma ihtiyacınız olduğunu bildirmek için ilan yayınlayın.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _buildServiceSelectionCard(
                    context,
                    Icons.house_outlined,
                    "Pansiyon",
                  ),
                  _buildServiceSelectionCard(
                    context,
                    Icons.sunny_snowing,
                    "Gündüz Bakımı",
                  ),
                  _buildServiceSelectionCard(
                    context,
                    Icons.chair_outlined,
                    "Evde Bakım",
                  ),
                  _buildServiceSelectionCard(
                    context,
                    Icons.directions_walk,
                    "Gezdirme",
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _buildServiceSelectionCard(
                    context,
                    Icons.local_taxi_outlined,
                    "Taksi",
                  ),
                  _buildServiceSelectionCard(
                    context,
                    Icons.cut_outlined,
                    "Bakım",
                  ),
                  _buildServiceSelectionCard(
                    context,
                    Icons.school_outlined,
                    "Eğitim",
                  ),
                  const Expanded(child: SizedBox.shrink()),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 50,
        title: const Row(
          children: [
            Icon(Icons.pets, color: primaryPurple, size: 28),
            SizedBox(width: 8),
            Text(
              "Zoozy",
              style: TextStyle(
                color: primaryPurple,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.chat_bubble_outline,
                  color: primaryPurple,
                  size: 24,
                ),
                onPressed: () async {
                  final allowed =
                      await GuestAccessService.ensureLoggedIn(context);
                  if (!allowed) return;
                  // Bildirimleri okundu yap (kırmızı nokta gitsin)
                  await _markAllNotificationsAsRead();
                  // State'i hemen güncelle (kırmızı nokta anında kaybolsun)
                  if (mounted) {
                    setState(() {
                      _hasUnreadNotifications = false;
                    });
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IndexboxMessageScreen(),
                    ),
                  ).then((notificationsRead) {
                    // Eğer tike basıldıysa (notificationsRead == true), kırmızı noktayı hemen kaldır
                    if (notificationsRead == true) {
                      if (mounted) {
                        setState(() {
                          _hasUnreadNotifications = false;
                        });
                      }
                    } else {
                      // Normal şekilde sayfadan dönüldüyse, bildirimleri tekrar kontrol et
                      _checkNotifications();
                    }
                  });
                },
              ),
              if (_hasUnreadNotifications)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  height: screenHeight * 0.35,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryPurple, softPink],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: screenWidth / 2 - 80,
                  top: 20,
                  child: Center(
                    child: Transform.scale(
                      scale: 1.3,
                      child: Image.asset(
                        'assets/images/jobs.png',
                        height: 160,
                        width: 160,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.25,
                  left: screenWidth * 0.06,
                  right: screenWidth * 0.06,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildIconTextCard(
                          Icons.list_alt,
                          "İstekler",
                          isSelected: selectedIndex == 0,
                        ),
                        _buildIconTextCard(
                          Icons.touch_app_outlined,
                          "Hizmet Al",
                          isSelected: selectedIndex == 1,
                        ),
                        _buildIconTextCard(
                          Icons.pets,
                          "Köpek Gezdir",
                          isSelected: selectedIndex == 2,
                        ),
                        _buildIconTextCard(
                          Icons.help_outline,
                          "Yardım",
                          isSelected: selectedIndex == 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 100),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: primaryPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.pets, size: 60, color: primaryPurple),
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Yakınınızdaki hayvan bakıcılarından teklif almak için talepte bulunun.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primaryPurple,
                side: const BorderSide(color: primaryPurple, width: 1.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                if (!await GuestAccessService.ensureLoggedIn(context)) {
                  return;
                }
                _showBroadcastRequestModal(context);
              },
              child: Text(
                "TALEP OLUŞTURUN",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              )
            else if (requestList.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 30),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: requestList.length,
                itemBuilder: (context, i) {
                  final x = requestList[i];
                  return FutureBuilder<ImageProvider?>(
                    future: _loadProfileImageProvider(x.userPhoto),
                    builder: (context, snapshot) {
                      return Card(
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 35),
                              child: ListTile(
                                // burası sende zaten var
                                leading: CircleAvatar(
                                  backgroundColor: Colors.grey[200],
                                  child: Icon(_getServiceIcon(x.serviceName),
                                      color: Colors.deepPurple, size: 28),
                                ),
                                title: Text("${x.petName} - ${x.serviceName}"),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Tarih: " +
                                          DateFormat('d MMMM yyyy', 'tr_TR')
                                              .format(x.startDate) +
                                          " - " +
                                          DateFormat('d MMMM yyyy', 'tr_TR')
                                              .format(x.endDate),
                                      style: const TextStyle(
                                          fontSize: 15, color: Colors.black87),
                                    ),
                                    Text(
                                      "Süre: ${x.dayDiff - 1} gün",
                                      style: const TextStyle(
                                          fontSize: 15, color: Colors.black87),
                                    ),
                                    if (x.note.isNotEmpty)
                                      Text(
                                        "Not: ${x.note}",
                                        style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black87),
                                      ),
                                  ],
                                ),
                              ),
                            ),

                            // ⭐ Sağ alt silme butonu ⭐
                            Positioned(
                              right: 8,
                              bottom: 8,
                              child: InkWell(
                                onTap: () => _deleteRequest(i),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.delete,
                                      color: Colors.red, size: 22),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              )
            else ...[
              const SizedBox(height: 30),
              const Text(
                'Henüz kayıtlı talep yok.',
                style: TextStyle(fontSize: 17, color: Colors.black),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        selectedColor: primaryPurple,
        unselectedColor: Colors.grey[700]!,
        onTap: (index) {
          if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const RequestsScreen()),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
      ),
    );
  }
}
