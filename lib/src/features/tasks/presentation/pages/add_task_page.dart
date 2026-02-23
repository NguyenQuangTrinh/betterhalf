import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../data/models/shared_task_model.dart';
import '../../data/services/task_service.dart';

class AddTaskPage extends StatefulWidget {
  final String coupleId;
  final String userId;

  const AddTaskPage({super.key, required this.coupleId, required this.userId});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _taskService = TaskService();

  String _selectedAssignee = 'me'; // 'me', 'partner', 'both'
  DateTime? _selectedDate;
  String _selectedPriority = 'Trung bình';
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tiêu đề công việc')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final task = SharedTask(
        id: '', // Firestore generated
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        assigneeId: _selectedAssignee == 'me'
            ? widget.userId
            : (_selectedAssignee == 'partner'
                  ? 'partner_id_placeholder'
                  : 'both'), // Placeholder for partner ID
        createdAt: DateTime.now(),
        dueDate: _selectedDate,
        isCompleted: false,
        priority: _selectedPriority,
      );

      await _taskService.addTask(widget.coupleId, task);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF121418)
        : const Color(0xFFF3F5FA);
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final labelColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Thêm công việc',
          style: GoogleFonts.inter(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Title Input ---
            _buildLabel('Tiêu đề công việc', labelColor),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _titleController,
              hint: 'Ví dụ: Đi siêu thị, Trả tiền điện...',
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // --- Description Input ---
            _buildLabel('Mô tả chi tiết', labelColor),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _descriptionController,
              hint: 'Nhập ghi chú, danh sách đồ cần mua...',
              isDark: isDark,
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            // --- Assignee Selector ---
            _buildLabel('Gán cho ai', labelColor),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2C3545)
                    : const Color(0xFFE3E8EF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildAssigneeOption(
                      'Tôi',
                      FontAwesomeIcons.user,
                      'me',
                      isDark,
                    ),
                  ),
                  Expanded(
                    child: _buildAssigneeOption(
                      'Cả hai',
                      FontAwesomeIcons.heart,
                      'both',
                      isDark,
                    ),
                  ),
                  Expanded(
                    child: _buildAssigneeOption(
                      'Người ấy',
                      FontAwesomeIcons.user,
                      'partner',
                      isDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Due Date Picker ---
            _buildLabel('Ngày hạn chót', labelColor),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2329) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.transparent : Colors.grey[200]!,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1D2836)
                            : const Color(0xFF4B89EA).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF4B89EA), // Or adjust for dark mode
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _selectedDate != null
                          ? "${_selectedDate!.day} tháng ${_selectedDate!.month}, ${_selectedDate!.year}"
                          : 'Chọn ngày',
                      style: GoogleFonts.inter(
                        color: primaryTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Priority Selector ---
            _buildLabel('Độ ưu tiên', labelColor),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildPriorityOption(
                    'Thấp',
                    FontAwesomeIcons.leaf,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPriorityOption(
                    'Trung bình',
                    FontAwesomeIcons.flag,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPriorityOption(
                    'Cao',
                    FontAwesomeIcons.exclamation,
                    isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: isDark
                        ? const Color(0xFF1E2329)
                        : const Color(0xFFF3F5FA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Hủy',
                    style: GoogleFonts.inter(
                      color: primaryTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF67B0F0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Lưu công việc',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2329) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.transparent : Colors.grey[200]!,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.inter(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.grey[500], fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildAssigneeOption(
    String label,
    IconData icon,
    String value,
    bool isDark,
  ) {
    final isSelected = _selectedAssignee == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedAssignee = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF28384E) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? const Color(0xFF4B89EA) : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected ? const Color(0xFF4B89EA) : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityOption(String label, IconData icon, bool isDark) {
    final isSelected = _selectedPriority == label;
    Color color;
    if (label == 'Thấp') {
      color = Colors.green;
    } else if (label == 'Trung bình') {
      color = const Color(0xFF4B89EA);
    } else {
      color = Colors.red;
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedPriority = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : (isDark ? const Color(0xFF1E2329) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? Colors.transparent : Colors.grey[200]!),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            // Dot for selected
            if (isSelected)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 8,
                    top: 0,
                  ), // manual adjustment
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            Icon(
              icon,
              color: isSelected
                  ? color
                  : (isDark ? Colors.white54 : Colors.grey),
              size: 20,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected
                    ? color
                    : (isDark ? Colors.white54 : Colors.grey),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
