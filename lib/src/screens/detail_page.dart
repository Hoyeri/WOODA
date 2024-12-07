import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:wooda_client/src/models/detail_page_model.dart';
import 'package:wooda_client/src/models/items_model.dart';
import 'package:wooda_client/src/screens/edit_schedule_page.dart';
import 'package:wooda_client/src/screens/comment_page.dart';
import 'package:wooda_client/src/services/items_service.dart';

class DetailPage extends StatefulWidget {
  final DetailPageModel model;
  final Item item;
  final void Function(Item) onUpdate;
  final void Function() onDelete;
  final ItemsService itemsService; // ItemsService 추가

  const DetailPage({
    super.key,
    required this.model,
    required this.onDelete,
    required this.onUpdate,
    required this.item,
    required this.itemsService,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late bool isLiked;
  int commentCount = 0;

  @override
  void initState() {
    super.initState();
    const currentUserId = "user123";

    // 좋아요 여부 초기화
    isLiked = widget.item.likes_users.contains(currentUserId);

    // 초기 댓글 수 로드
    _loadCommentCount();
  }

  Future<void> _loadCommentCount() async {
      final comments = await widget.itemsService.getComments(widget.item.id);
      setState(() {
        commentCount = comments.length;
      });
  }

  void toggleLike() async {
    try {
      await widget.itemsService.toggleLike(widget.item);
      setState(() {
        isLiked = !isLiked;
        widget.item.likes += isLiked ? 1 : -1;
      });
      widget.onUpdate(widget.item); // 변경 사항 부모 위젯에 전달
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("좋아요 실패: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
    DateFormat('yyyy년 MM월 dd일 EEEE, HH:mm', 'ko_KR').format(widget.model.date);

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (String value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditSchedulePage(
                      schedule: widget.item,
                      onUpdate: (updatedSchedule) {
                        widget.onUpdate(updatedSchedule);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              } else if (value == 'delete') {
                widget.onDelete();
                Navigator.pop(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'edit', child: Text('수정')),
              const PopupMenuItem(value: 'delete', child: Text('삭제')),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_01.png',
              fit: BoxFit.cover,
            ),
          ),
          // 내용
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: Colors.white.withOpacity(0.8),
                child: Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.all(35),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.model.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.model.description,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (widget.model.image != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              widget.model.image!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 400,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: Colors.pinkAccent,
                          ),
                          onPressed: toggleLike,
                        ),
                        Text('${widget.item.likes}',
                            style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.comment_outlined, color: Colors.grey),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (BuildContext context) {
                                return CommentPage(
                                  itemId: widget.item.id, // 댓글과 연결된 Item ID
                                  itemsService: widget.itemsService, // 댓글 관리 서비스
                                );
                              },
                            ).then((updatedCommentsCount) {
                              if (updatedCommentsCount != null) {
                                setState(() {
                                  widget.item.commentsCount = updatedCommentsCount; // 댓글 수 갱신
                                });
                              }
                            });
                          },
                        ),
                        Text('$commentCount', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
