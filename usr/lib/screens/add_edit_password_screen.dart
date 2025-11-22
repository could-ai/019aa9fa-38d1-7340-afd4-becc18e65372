import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/password_entry.dart';
import '../services/mock_data_service.dart';
import '../utils/password_generator.dart';

class AddEditPasswordScreen extends StatefulWidget {
  final PasswordEntry? entry;

  const AddEditPasswordScreen({super.key, this.entry});

  @override
  State<AddEditPasswordScreen> createState() => _AddEditPasswordScreenState();
}

class _AddEditPasswordScreenState extends State<AddEditPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isPasswordVisible = false;
  final MockDataService _dataService = MockDataService();
  Color _selectedColor = Colors.blue;

  // Predefined color palette
  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title;
      _usernameController.text = widget.entry!.username;
      _passwordController.text = widget.entry!.password;
      _urlController.text = widget.entry!.url ?? '';
      _notesController.text = widget.entry!.notes ?? '';
      _selectedColor = widget.entry!.categoryColor;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      final entry = PasswordEntry(
        id: widget.entry?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        username: _usernameController.text,
        password: _passwordController.text,
        url: _urlController.text.isEmpty ? null : _urlController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        createdAt: widget.entry?.createdAt ?? DateTime.now(),
        categoryColor: _selectedColor,
      );

      if (widget.entry != null) {
        _dataService.updateEntry(entry);
      } else {
        _dataService.addEntry(entry);
      }

      Navigator.pop(context);
    }
  }

  void _deleteEntry() {
    if (widget.entry != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('删除密码？'),
          content: const Text('确定要删除这个密码吗？此操作无法撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                _dataService.deleteEntry(widget.entry!.id);
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close screen
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('删除'),
            ),
          ],
        ),
      );
    }
  }

  void _generatePassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PasswordGeneratorSheet(
        onPasswordGenerated: (password) {
          setState(() {
            _passwordController.text = password;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.entry != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '编辑账号' : '新增账号'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteEntry,
              tooltip: '删除',
            ),
          TextButton(
            onPressed: _saveEntry,
            child: const Text(
              '保存',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Color Selection Section
              Text(
                '选择分类颜色',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colorOptions.length,
                  itemBuilder: (context, index) {
                    final color = _colorOptions[index];
                    final isSelected = color == _selectedColor;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          border: Border.all(
                            color: isSelected
                                ? (isDark ? Colors.white : Colors.black87)
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 32,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),
              
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: '名称 (如 Google, GitHub)',
                  hintText: '输入账号名称',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.apps_rounded),
                  filled: true,
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Username Field
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: '用户名 / 邮箱',
                  hintText: '输入用户名或邮箱',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  filled: true,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: '密码',
                  hintText: '输入密码',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  filled: true,
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded),
                        onPressed: _generatePassword,
                        tooltip: '生成密码',
                      ),
                    ],
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入密码';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // URL Field
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: '网站 (网址)',
                  hintText: 'https://example.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.language_rounded),
                  filled: true,
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              
              // Notes Field
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: '备注 (可选)',
                  hintText: '添加备注信息',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.note_outlined),
                  alignLabelWithHint: true,
                  filled: true,
                ),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PasswordGeneratorSheet extends StatefulWidget {
  final Function(String) onPasswordGenerated;

  const PasswordGeneratorSheet({super.key, required this.onPasswordGenerated});

  @override
  State<PasswordGeneratorSheet> createState() => _PasswordGeneratorSheetState();
}

class _PasswordGeneratorSheetState extends State<PasswordGeneratorSheet> {
  double _length = 16;
  bool _useLetters = true;
  bool _useNumbers = true;
  bool _useSpecial = true;
  String _generatedPassword = '';

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    setState(() {
      _generatedPassword = PasswordGenerator.generate(
        length: _length.round(),
        useLetters: _useLetters,
        useNumbers: _useNumbers,
        useSpecial: _useSpecial,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '生成密码',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.transparent : Colors.black.withOpacity(0.06),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _generatedPassword,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: _generate,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                '长度: ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Expanded(
                child: Slider(
                  value: _length,
                  min: 6,
                  max: 32,
                  divisions: 26,
                  label: _length.round().toString(),
                  onChanged: (value) {
                    setState(() {
                      _length = value;
                    });
                    _generate();
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _length.round().toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('字母 (A-Z, a-z)'),
            value: _useLetters,
            onChanged: (value) {
              setState(() => _useLetters = value);
              _generate();
            },
            dense: true,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          SwitchListTile(
            title: const Text('数字 (0-9)'),
            value: _useNumbers,
            onChanged: (value) {
              setState(() => _useNumbers = value);
              _generate();
            },
            dense: true,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          SwitchListTile(
            title: const Text('特殊字符 (!@#...)'),
            value: _useSpecial,
            onChanged: (value) {
              setState(() => _useSpecial = value);
              _generate();
            },
            dense: true,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              widget.onPasswordGenerated(_generatedPassword);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '使用此密码',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
