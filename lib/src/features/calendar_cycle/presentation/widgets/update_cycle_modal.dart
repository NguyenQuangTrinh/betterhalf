import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../data/services/cycle_service.dart';

class UpdateCycleModal extends StatefulWidget {
  final String? userId; // Target user ID to update logs for
  final Map<String, dynamic>? initialLog;

  const UpdateCycleModal({super.key, this.userId, this.initialLog});

  @override
  State<UpdateCycleModal> createState() => _UpdateCycleModalState();
}

class _UpdateCycleModalState extends State<UpdateCycleModal> {
  DateTime _selectedDate = DateTime.now();
  DateTime? _endDate;
  final TextEditingController _noteController = TextEditingController();
  final List<String> _selectedMoods = [];
  final List<String> _selectedSymptoms = [];
  bool _isLoading = false;

  final CycleService _cycleService = CycleService();

  @override
  void initState() {
    super.initState();
    if (widget.initialLog != null) {
      final log = widget.initialLog!;
      if (log['startDate'] != null) {
        _selectedDate = (log['startDate'] as dynamic).toDate();
      }
      if (log['endDate'] != null) {
        _endDate = (log['endDate'] as dynamic).toDate();
      }
      if (log['moods'] != null) {
        _selectedMoods.addAll(List<String>.from(log['moods']));
      }
      if (log['symptoms'] != null) {
        _selectedSymptoms.addAll(List<String>.from(log['symptoms']));
      }
      if (log['note'] != null) {
        _noteController.text = log['note'];
      }
    }
  }

  void _toggleMood(String mood) {
    setState(() {
      if (_selectedMoods.contains(mood)) {
        _selectedMoods.remove(mood);
      } else {
        _selectedMoods.add(mood);
      }
    });
  }

  void _toggleSymptom(String symptom) {
    setState(() {
      if (_selectedSymptoms.contains(symptom)) {
        _selectedSymptoms.remove(symptom);
      } else {
        _selectedSymptoms.add(symptom);
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _selectedDate,
      firstDate: _selectedDate,
      lastDate: DateTime.now().add(
        const Duration(days: 90),
      ), // Allow future dates for prediction/planning if needed, or stick to now
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _handleSave() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _cycleService.saveCycleLog(
        userId: widget.userId,
        startDate: _selectedDate,
        endDate: _endDate,
        moods: _selectedMoods,
        symptoms: _selectedSymptoms,
        note: _noteController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật chu kỳ thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1E2432) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white54 : Colors.black54;
    final primaryBlue = const Color(0xFF4B89EA);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        32 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cập nhật chu kỳ',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: subTextColor),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Time Section ---
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Color(0xFF4B89EA),
                ),
                const SizedBox(width: 8),
                Text(
                  'Thời gian',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BẮT ĐẦU',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: subTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2C3545)
                                : const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: primaryBlue.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _selectedDate.day.toString(),
                                style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat(
                                      'MMMM',
                                      'vi_VN',
                                    ).format(_selectedDate),
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  Text(
                                    DateFormat(
                                      'EEEE',
                                      'vi_VN',
                                    ).format(_selectedDate),
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: subTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // End Date Selection
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectEndDate(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KẾT THÚC',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: subTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2C3545)
                                  : const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _endDate != null
                                    ? primaryBlue.withOpacity(0.3)
                                    : Colors.grey.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _endDate != null
                                      ? _endDate!.day.toString()
                                      : '--',
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: _endDate != null
                                        ? textColor
                                        : subTextColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _endDate != null
                                          ? DateFormat(
                                              'MMMM',
                                              'vi_VN',
                                            ).format(_endDate!)
                                          : 'Tháng --',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _endDate != null
                                            ? textColor
                                            : subTextColor,
                                      ),
                                    ),
                                    Text(
                                      _endDate != null
                                          ? DateFormat(
                                              'EEEE',
                                              'vi_VN',
                                            ).format(_endDate!)
                                          : 'Dự kiến',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: subTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- Mood Section ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.sentiment_satisfied,
                      size: 16,
                      color: Color(0xFF4B89EA),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tâm trạng',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildMoodItem('Vui vẻ', '😊', isDark),
                  _buildMoodItem('Đau bụng', '😣', isDark),
                  _buildMoodItem('Mệt mỏi', '😪', isDark),
                  _buildMoodItem('Cáu kỉnh', '😡', isDark),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- Symptoms Section ---
            Row(
              children: [
                const Icon(
                  FontAwesomeIcons.notesMedical,
                  size: 16,
                  color: Color(0xFF4B89EA),
                ),
                const SizedBox(width: 8),
                Text(
                  'Triệu chứng',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildSymptomChip('Đau lưng', isDark),
                _buildSymptomChip('Mụn trứng cá', isDark),
                _buildSymptomChip('Đau đầu', isDark),
                _buildSymptomChip('Thèm ăn', isDark),
                _buildSymptomChip('Khó ngủ', isDark),
                // _buildSymptomChip('+ Thêm', isDark, isAdd: true), // Feature for later
              ],
            ),
            const SizedBox(height: 32),

            // --- Note Section ---
            Row(
              children: [
                const Icon(Icons.edit_note, size: 16, color: Color(0xFF4B89EA)),
                const SizedBox(width: 8),
                Text(
                  'Ghi chú',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 100,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2C3545)
                    : const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _noteController,
                style: GoogleFonts.inter(color: textColor),
                maxLines: 5,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Hôm nay em cảm thấy thế nào? Ghi lại nhé...',
                  hintStyle: GoogleFonts.inter(color: subTextColor),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // --- Actions ---
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: subTextColor.withOpacity(0.2)),
                      ),
                    ),
                    child: Text(
                      'Hủy',
                      style: GoogleFonts.inter(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Lưu thông tin',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodItem(String label, String emoji, bool isDark) {
    final isSelected = _selectedMoods.contains(label);
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: GestureDetector(
        onTap: () => _toggleMood(label),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF4B89EA).withOpacity(0.1)
                    : (isDark
                          ? const Color(0xFF2C3545)
                          : const Color(0xFFF5F7FA)),
                border: isSelected
                    ? Border.all(color: const Color(0xFF4B89EA), width: 2)
                    : null,
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected
                    ? const Color(0xFF4B89EA)
                    : (isDark ? Colors.white54 : Colors.black54),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomChip(String label, bool isDark, {bool isAdd = false}) {
    if (isAdd) return const SizedBox.shrink(); // Hide add button for now

    final isSelected = _selectedSymptoms.contains(label);
    return GestureDetector(
      onTap: () => _toggleSymptom(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4B89EA)
              : (isDark ? const Color(0xFF2C3545) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white : Colors.black87),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
