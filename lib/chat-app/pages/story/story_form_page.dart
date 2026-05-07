import 'package:flutter/material.dart';
import 'package:flutter_example/chat-app/models/story_model.dart';
import 'package:flutter_example/chat-app/providers/story_controller.dart';
import 'package:get/get.dart';

import 'package:uuid/uuid.dart'; // 需要添加到 pubspec.yaml

class StoryFormPage extends GetView<StoryController> {
  StoryFormPage({super.key,this.initialStory});

  // 从路由参数中获取传入的故事对象，null 表示添加模式
  StoryModel? initialStory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isEditing = initialStory != null;
    final story = initialStory;

    // 控制器初始化
    final nameController = TextEditingController(text: story?.name ?? '');
    final remarkController = TextEditingController(text: story?.remark ?? '');
    final promptController = TextEditingController(text: story?.story_prompt ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '编辑故事' : '添加故事'),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: '名称',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入故事名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: remarkController,
                decoration: InputDecoration(
                  labelText: '备注',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: promptController,
                decoration: InputDecoration(
                  labelText: '提示词',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
                minLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入故事提示词';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _onSave(
                  isEditing,
                  story,
                  nameController.text.trim(),
                  remarkController.text.trim(),
                  promptController.text.trim(),
                  context,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _onSave(
    bool isEditing,
    StoryModel? originalStory,
    String name,
    String remark,
    String prompt,
    BuildContext context,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    if (isEditing && originalStory != null) {
      // 编辑模式：保留其他字段不变
      final updated = originalStory.copyWith(
        name: name,
        remark: remark,
        story_prompt: prompt,
      );
      await controller.updateStory(updated, null);
    } else {
      // 添加模式：生成新 ID，仅设置编辑的字段，其余使用默认值
      final newStory = StoryModel(
        id: const Uuid().v4(),
        name: name,
        remark: remark,
        story_prompt: prompt,
      );
      await controller.addStory(newStory);
    }

    if (context.mounted) {
      Get.back(); // 返回上一页（自动刷新列表因为 StoryManagementPage 使用了响应式 stories）
    }
  }
}