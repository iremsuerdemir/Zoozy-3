import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:zoozy/models/favori_item.dart';
import 'package:zoozy/models/comment.dart';
import 'package:zoozy/services/comment_service_http.dart';
import 'package:zoozy/services/favorite_service.dart';
import 'package:zoozy/components/comment_card.dart';
import 'package:zoozy/components/comment_dialog.dart';

class MomentsPostCard extends StatefulWidget {
  final String userName;
  final String displayName;
  final String userPhoto;
  final String postImage;
  final String description;
  final int likes;
  final int comments;
  final DateTime timePosted;
  final currentUserName;
  // 👇 YENİ: Profil fotoğrafına tıklama olayını yakalamak için geri çağırım
  final VoidCallback? onProfileTap;

  const MomentsPostCard({
    Key? key,
    required this.userName,
    required this.displayName,
    required this.userPhoto,
    required this.postImage,
    required this.description,
    required this.likes,
    required this.comments,
    required this.timePosted,
    required this.currentUserName,
    this.onProfileTap, // Parametreyi ekledik
  }) : super(key: key);

  @override
  State<MomentsPostCard> createState() => _MomentsPostCardState();
}

class _MomentsPostCardState extends State<MomentsPostCard> {
  bool isFavorite = false;
  late int likeCount;
  final CommentServiceHttp _commentService = CommentServiceHttp();
  final FavoriteService _favoriteService = FavoriteService();
  List<Comment> _comments = [];
  bool _showComments = false;
  bool _isLoadingComments = false;

  @override
  void initState() {
    super.initState();
    likeCount = widget.likes;
    _checkIfFavorite();
    _loadComments();
  }

  Future<void> _loadComments() async {
    // Moment kartı için unique cardId kullanıyoruz
    final cardId =
        "moment_${widget.userName}_${widget.timePosted.millisecondsSinceEpoch}";
    setState(() {
      _isLoadingComments = true;
    });

    try {
      final comments = await _commentService.getCommentsForCard(cardId);
      setState(() {
        _comments = comments;
        _isLoadingComments = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingComments = false;
      });
      print('Yorum yükleme hatası: $e');
    }
  }

  Future<void> _onCommentAdded(Comment comment) async {
    final cardId =
        "moment_${widget.userName}_${widget.timePosted.millisecondsSinceEpoch}";
    final success = await _commentService.addComment(cardId, comment);
    if (success) {
      await _loadComments();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yorum eklenirken bir hata oluştu.')),
        );
      }
    }
  }

  void _toggleComments() {
    setState(() {
      _showComments = !_showComments;
    });
  }

  Future<void> _checkIfFavorite() async {
    final exists = await _favoriteService.isFavorite(
      title: widget.displayName,
      tip: "moments",
      imageUrl: widget.postImage,
    );

    setState(() {
      isFavorite = exists;
    });
  }

  void toggleFavorite() async {
    setState(() {
      isFavorite = !isFavorite;
      likeCount += isFavorite ? 1 : -1;
    });

    if (isFavorite) {
      await _favoriyeEkle();
    } else {
      await _favoridenSil();
    }
  }

  Future<void> _favoriyeEkle() async {
    final favItem = FavoriteItem(
      title: widget.displayName,
      subtitle: widget.description,
      imageUrl: widget.postImage,
      profileImageUrl: widget.userPhoto,
      tip: "moments",
    );

    final success = await _favoriteService.addFavorite(favItem);
    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Favorilere eklendi!")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Favori eklenirken bir hata oluştu.")));
    }
  }

  Future<void> _favoridenSil() async {
    final success = await _favoriteService.removeFavorite(
      title: widget.displayName,
      tip: "moments",
      imageUrl: widget.postImage,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Favorilerden kaldırıldı!")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Favoriden kaldırılırken bir hata oluştu.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            // 👇 Profil resmine tıklama ekleme
            leading: GestureDetector(
              onTap: widget.onProfileTap,
              child: CircleAvatar(
                backgroundImage: AssetImage(widget.userPhoto),
                radius: 24,
              ),
            ),
            // 👇 DisplayName'e tıklama ekleme (isteğe bağlı, ListTile'ın onTap'i yerine)
            title: GestureDetector(
              onTap: widget.onProfileTap,
              child: Text(widget.displayName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            subtitle: Text('@${widget.userName}',
                style: const TextStyle(color: Colors.blueAccent)),
            trailing: Text(
              timeAgo(widget.timePosted),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              widget.postImage,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  iconSize: 28,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey[600],
                  ),
                  onPressed: toggleFavorite,
                ),
                Text('$likeCount',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(width: 20),
                IconButton(
                  iconSize: 26,
                  icon: const Icon(Icons.mode_comment_outlined,
                      color: Colors.grey),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => CommentDialog(
                        currentUserName: widget.currentUserName,
                        cardId:
                            "moment_${widget.userName}_${widget.timePosted.millisecondsSinceEpoch}",
                        onCommentAdded: _onCommentAdded,
                      ),
                    );
                  },
                ),
                Text('${_comments.length}',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          if (_showComments)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: _comments
                    .map((comment) => CommentCard(comment: comment))
                    .toList(),
              ),
            ),
          TextButton(
            onPressed: _toggleComments,
            child: Text(_showComments ? 'Yorumları Gizle' : 'Yorumları Göster'),
          ),
        ],
      ),
    );
  }

  String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays >= 1) return '${difference.inDays} gün önce';
    if (difference.inHours >= 1) return '${difference.inHours} saat önce';
    if (difference.inMinutes >= 1) return '${difference.inMinutes} dakika önce';
    return 'Az önce';
  }
}
