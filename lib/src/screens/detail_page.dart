/// detail_page.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:wooda_client/src/models/detail_page_model.dart';
import 'package:wooda_client/src/models/items_model.dart';
import 'package:wooda_client/src/screens/edit_schedule_page.dart';
import 'package:wooda_client/src/screens/comment_page.dart';

// 전역 상태: 스케줄 ID별 좋아요 누른 사용자 관리
Map<int, Set<String>> userLikes = {};
Map<int, List<Map<String, dynamic>>> itemComments = {};

class DetailPage extends StatefulWidget {
  final DetailPageModel model;
  final Item item;
  final void Function(Item) onUpdate;
  final void Function() onDelete;

  const DetailPage({
    super.key,
    required this.model,
    required this.onDelete,
    required this.onUpdate,
    required this.item,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late bool isLiked;

  @override
  void initState() {
    super.initState();
    const currentUserId = "user123";

    // 좋아요 여부 확인 및 초기화
    isLiked = userLikes[widget.item.id]?.contains(currentUserId) ?? false;
    itemComments.putIfAbsent(widget.item.id, () => []);
  }

  void toggleLike() {
    setState(() {
      const currentUserId = "user123";

      if (isLiked) {
        userLikes[widget.item.id]?.remove(currentUserId);
        widget.item.likes--;
      } else {
        userLikes.putIfAbsent(widget.item.id, () => {});
        userLikes[widget.item.id]!.add(currentUserId);
        widget.item.likes++;
      }

      isLiked = !isLiked;
      widget.onUpdate(widget.item); // 변경 사항 전달
    });
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
                        // 기존 likes 값을 수정된 스케줄에 반영
                        updatedSchedule.likes = widget.item.likes;

                        // 기존 userLikes 상태 유지
                        userLikes[updatedSchedule.id] = userLikes[widget.item.id] ?? {};

                        widget.onUpdate(updatedSchedule);
                        Navigator.pop(context); // 수정 후 복귀
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
                color: Colors.white.withOpacity(0.8), // 배경 투명도 설정
                child: Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container( // 텍스트가 왼쪽에 정렬되도록 컨테이너 사용
                    alignment: Alignment.topLeft, // 컨테이너 내에서 왼쪽 정렬
                    padding: const EdgeInsets.all(35),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Column의 하위 위젯을 왼쪽 정렬
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
                            height: 1.5, // 줄 간격 설정
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
                              builder: (context) {
                                return CommentPage(
                                  initialComments: itemComments[widget.item.id]!,
                                  onCommentsUpdated: (updatedComments) {
                                    // 댓글 리스트를 업데이트하여 전역 상태에 반영
                                    setState(() {
                                      itemComments[widget.item.id] = updatedComments;
                                    });
                                  },
                                );
                              },
                            );
                          },
                        ),
                        Text(
                            '${itemComments[widget.item.id]?.length ?? 0}',
                            style: const TextStyle(fontSize: 16)
                        )
                      ],
                    )

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
