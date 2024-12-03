import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:wooda_client/src/models/detail_page_model.dart';
import 'package:wooda_client/src/models/schedule_model.dart';
import 'package:wooda_client/src/screens/edit_schedule_page.dart';

class DetailPage extends StatefulWidget {
  final DetailPageModel model; // 모델로 받기
  final Schedule schedule;
  final void Function(Schedule) onUpdate; // 수정 시 호출
  final void Function() onDelete; // 삭제 시 호출

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
  bool isLiked = false; // 좋아요 상태

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
    DateFormat('yyyy년 MM월 dd일 EEEE, HH:mm', 'ko_KR').format(widget.model.date);

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
          iconSize: 23,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
            iconSize: 25,
            onSelected: (String value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditSchedulePage(
                      schedule: widget.schedule,
                      onUpdate: (updatedSchedule) {
                        widget.onUpdate(updatedSchedule); // 업데이트된 스케줄 전달
                        Navigator.pop(context); // 수정 후 DetailPage로 복귀
                      },
                    ),
                  ),
                );
              } else if (value == 'delete') {
                widget.onDelete(); // 삭제 기능 호출
                Navigator.pop(context); // 삭제 후 이전 화면으로 이동
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('수정'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('삭제'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 날짜 영역
          Container(
            width: double.infinity,
            color: Colors.white, // 날짜 배경 흰색 고정
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                // 배경 이미지
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/background_01.png', // 배경 이미지 경로
                    fit: BoxFit.fill, // 화면 크기에 맞춤
                  ),
                ),
                // 내용
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                      children: [
                        // 제목
                        Text(
                          widget.model.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // 제목 검은색
                          ),
                        ),
                        const SizedBox(height: 12),
                        // 내용
                        Text(
                          widget.model.description,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey, // 내용 회색
                            height: 1.5, // 줄 간격
                          ),
                        ),
                        const SizedBox(height: 24),
                        // 사진 표시
                        if (widget.model.image != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              widget.model.image!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 400,
                            ),
                          )
                        else
                          Container(
                            height: 400, // 사진 높이와 동일
                            width: double.infinity,
                            color: Colors.transparent, // 투명 배경
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 좋아요 및 댓글 버튼
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 좋아요 버튼
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: Colors.pinkAccent,
                        size: 28,
                      ),
                      onPressed: () {
                        setState(() {
                          isLiked = !isLiked;
                          if (isLiked) {
                            widget.schedule.likes++;
                          } else {
                            widget.schedule.likes--;
                          }
                        });
                      },
                    ),
                    Text(
                      '${widget.schedule.likes}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                // 댓글 버튼
                IconButton(
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.grey,
                    size: 28,
                  ),
                  onPressed: () {
                    // 댓글 버튼 클릭 시 실행될 기능 추가
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("댓글 버튼이 눌렸습니다."),
                      ),
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
