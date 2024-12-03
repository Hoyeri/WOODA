import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:wooda_client/src/models/detail_page_model.dart';
import 'package:wooda_client/src/models/schedule_model.dart';
import 'package:wooda_client/src/screens/edit_schedule_page.dart';

// 전역 상태: 스케줄 ID별 좋아요 누른 사용자 관리
Map<int, Set<String>> userLikes = {};

class DetailPage extends StatefulWidget {
  final DetailPageModel model;
  final Schedule schedule;
  final void Function(Schedule) onUpdate;
  final void Function() onDelete;

  const DetailPage({
    Key? key,
    required this.model,
    required this.onDelete,
    required this.onUpdate,
    required this.schedule,
  }) : super(key: key);

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
    isLiked = userLikes[widget.schedule.id]?.contains(currentUserId) ?? false;
  }

  void toggleLike() {
    setState(() {
      const currentUserId = "user123";

      if (isLiked) {
        userLikes[widget.schedule.id]?.remove(currentUserId);
        widget.schedule.likes--;
      } else {
        userLikes.putIfAbsent(widget.schedule.id, () => {});
        userLikes[widget.schedule.id]!.add(currentUserId);
        widget.schedule.likes++;
      }

      isLiked = !isLiked;
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
                      schedule: widget.schedule,
                      onUpdate: (updatedSchedule) {
                        // 기존 likes 값을 수정된 스케줄에 반영
                        updatedSchedule.likes = widget.schedule.likes;

                        // 기존 userLikes 상태 유지
                        userLikes[updatedSchedule.id] = userLikes[widget.schedule.id] ?? {};

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
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.white,
            child: Text(
              formattedDate,
              style: const TextStyle(fontSize: 15, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.model.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(widget.model.description, style: const TextStyle(fontSize: 15)),
                    const SizedBox(height: 24),
                    if (widget.model.image != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          widget.model.image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
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
                    Text('${widget.schedule.likes}', style: const TextStyle(fontSize: 16)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.comment_outlined, color: Colors.grey),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("댓글 버튼 클릭됨")),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
