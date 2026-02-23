import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../providers/auth_provider.dart';
import '../../data/models/shared_task_model.dart';
import '../../data/services/task_service.dart';
import '../widgets/task_item.dart';
import 'add_task_page.dart';

class SharedTasksPage extends StatefulWidget {
  final VoidCallback onBack;
  const SharedTasksPage({super.key, required this.onBack});

  @override
  State<SharedTasksPage> createState() => _SharedTasksPageState();
}

class _SharedTasksPageState extends State<SharedTasksPage>
    with SingleTickerProviderStateMixin {
  final TaskService _taskService = TaskService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final coupleId = authProvider.coupleId;
    final myUid = authProvider.user?.uid;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF161B22)
        : const Color(0xFFF3F5FA);
    final primaryTextColor = isDark ? Colors.white : Colors.black87;

    if (coupleId == null || myUid == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: primaryTextColor),
            onPressed: widget.onBack,
          ),
        ),
        body: Center(
          child: Text(
            "Bạn chưa kết nối với ai!",
            style: GoogleFonts.inter(color: primaryTextColor),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Công việc chung",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 24, // Larger title
            color: primaryTextColor,
          ),
        ),
        centerTitle: false, // Left align
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryTextColor),
          onPressed: widget.onBack,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_rounded, color: primaryTextColor),
            onPressed: () {
              // Filter action
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF2C3545)
                  : const Color(0xFFE3E8EF), // Light grey background
              borderRadius: BorderRadius.circular(30), // More rounded
            ),
            padding: const EdgeInsets.all(4), // Padding for pill look
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white, // White indicator
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: const Color(0xFF4B89EA), // Blue text when selected
              unselectedLabelColor: Colors.grey, // Grey text when unselected
              labelStyle: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(child: Text("Chưa làm")),
                Tab(child: Text("Đã xong")),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<SharedTask>>(
              stream: _taskService.getTasksStream(coupleId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Lỗi tải dữ liệu: ${snapshot.error}",
                      style: GoogleFonts.inter(color: Colors.red),
                    ),
                  );
                }

                final allTasks = snapshot.data ?? [];
                final pendingTasks = allTasks
                    .where((t) => !t.isCompleted)
                    .toList();
                final completedTasks = allTasks
                    .where((t) => t.isCompleted)
                    .toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTaskList(
                      context,
                      pendingTasks,
                      coupleId,
                      myUid,
                      isDark,
                    ),
                    _buildTaskList(
                      context,
                      completedTasks,
                      coupleId,
                      myUid,
                      isDark,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80), // Move up above BottomNav
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    AddTaskPage(coupleId: coupleId, userId: myUid),
              ),
            );
          },
          backgroundColor: const Color(0xFF4B89EA),
          elevation: 4,
          shape: const CircleBorder(), // Circular shape
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTaskList(
    BuildContext context,
    List<SharedTask> tasks,
    String coupleId,
    String myUid,
    bool isDark,
  ) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.clipboardList,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              "Trống trơn!",
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Calculate Today's tasks count for header
    final todayCount = tasks.length;

    return ListView.builder(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 100,
      ), // Bottom padding for FAB/Nav
      itemCount: tasks.length + 2, // Header + Tasks + Footer
      itemBuilder: (context, index) {
        if (index == 0) {
          // HEADER
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "HÔM NAY",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  "$todayCount CÔNG VIỆC",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        } else if (index == tasks.length + 1) {
          // FOOTER (Banner)
          return _buildMotivationalBanner(isDark);
        }

        // TASK ITEM
        final taskIndex = index - 1;
        final task = tasks[taskIndex];
        final isMe = task.assigneeId == myUid;

        // Simple mapping for demo purposes - enhance with real User data if available
        String assigneeName = "Cả hai";
        String assigneeAvatar =
            "https://i.pravatar.cc/150?u=both"; // Placeholder

        if (task.assigneeId == myUid) {
          assigneeName = "Tôi";
          assigneeAvatar =
              "https://i.pravatar.cc/150?u=$myUid"; // Use authProvider user photoURL if available
        } else if (task.assigneeId == 'partner_id_placeholder' ||
            (task.assigneeId != null && task.assigneeId != 'both')) {
          assigneeName = "Người ấy";
          assigneeAvatar = "https://i.pravatar.cc/150?u=partner";
        }

        final dueDateStr = task.dueDate != null
            ? "${task.dueDate!.day}/${task.dueDate!.month}"
            : "";
        final isOverdue =
            task.dueDate != null &&
            task.dueDate!.isBefore(DateTime.now()) &&
            !task.isCompleted;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TaskItem(
            title: task.title,
            dueDate: dueDateStr,
            assigneeName: assigneeName,
            assigneeAvatar: assigneeAvatar,
            isOverdue: isOverdue,
            isMe: isMe,
            isDark: isDark,
            isCompleted: task.isCompleted,
            onToggle: () async {
              try {
                await _taskService.updateTask(
                  coupleId,
                  task.copyWith(isCompleted: !task.isCompleted),
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
                }
              }
            },
            onMenuSelected: (value) async {
              if (value == 'delete') {
                try {
                  await _taskService.deleteTask(coupleId, task.id);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Lỗi xóa: $e")));
                  }
                }
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildMotivationalBanner(bool isDark) {
    return Container(
      // margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2C3545)
            : const Color(0xFFE3F2FD), // Light blue like image
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              FontAwesomeIcons.solidHeart,
              color: Color(0xFF4B89EA), // Blue heart
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Cố lên nhé hai bạn!",
                  style: GoogleFonts.inter(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Hoàn thành xong mình đi ăn kem nha 🍦",
                  style: GoogleFonts.inter(
                    color: isDark ? Colors.white70 : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
