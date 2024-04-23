import 'dart:math';
import 'package:flutter/material.dart';

class SampleItem {
  String id;
  ValueNotifier<String> name;
  ValueNotifier<String> description;

  SampleItem({String? id, required String name, String? description})
      : id = id ?? generateUuid(),
        name = ValueNotifier(name),
        description = ValueNotifier(description ?? '');

  static String generateUuid() {
    return int.parse(
            '${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(100000)}')
        .toRadixString(35)
        .substring(0, 9);
  }
}

class SampleItemViewModel extends ChangeNotifier {
  static final _instance = SampleItemViewModel._();
  factory SampleItemViewModel() => _instance;
  SampleItemViewModel._();
  final List<SampleItem> items = [];

  void addItem(String name, String description) {
    items.add(SampleItem(name: name, description: description));
    notifyListeners();
  }

  void removeItem(String id, BuildContext context) {
    items.removeWhere((item) => item.id == id);
    notifyListeners();
    showSnackbar(context, "Đã xóa mục thành công");
  }

  void updateItem(String id, String newName, String newDescription) {
    try {
      final item = items.firstWhere((item) => item.id == id);
      item.name.value = newName;
      item.description.value = newDescription;
      notifyListeners();
    } catch (e) {
      debugPrint("Không tìm thấy mục với ID $id");
    }
  }

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class SampleItemUpdate extends StatefulWidget {
  final String? initialName;
  final String? initialDescription;

  const SampleItemUpdate({Key? key, this.initialName, this.initialDescription})
      : super(key: key);

  @override
  State<SampleItemUpdate> createState() => _SampleItemUpdateState();
}

class _SampleItemUpdateState extends State<SampleItemUpdate> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController =
        TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialName != null ? 'Chỉnh sửa' : 'Thêm mới'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop({
                'name': _nameController.text,
                'description': _descriptionController.text
              });
            },
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên'),
              ),
              const SizedBox(
                  height: 20), // Thêm một khoảng cách giữa các TextFormField
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
              ),
              const SizedBox(
                  height: 20), // Thêm một khoảng cách giữa các TextFormField
              // Add more text fields or other widgets here if needed
            ],
          ),
        ),
      ),
    );
  }
}

class SampleItemWidget extends StatelessWidget {
  final SampleItem item;
  final VoidCallback? onTap;

  const SampleItemWidget({Key? key, required this.item, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: item.name,
      builder: (context, name, child) {
        return ListTile(
          title: Text(item.id),
          subtitle: Text(name!),
          leading: const CircleAvatar(
            foregroundImage: AssetImage('assets/images/flutter_logo.png'),
          ),
          onTap: onTap,
          trailing: const Icon(Icons.keyboard_arrow_right),
        );
      },
    );
  }
}

class SampleItemDetailsView extends StatefulWidget {
  final SampleItem item;

  const SampleItemDetailsView({Key? key, required this.item});

  @override
  State<SampleItemDetailsView> createState() => _SampleItemDetailsViewState();
}

class _SampleItemDetailsViewState extends State<SampleItemDetailsView> {
  final viewModel = SampleItemViewModel();

  void _deleteItem(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Xác nhận xóa"),
          content: const Text("Bạn có chắc muốn xóa mục này?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Bỏ qua"),
            ),
            TextButton(
              onPressed: () {
                viewModel.removeItem(widget.item.id, context);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("Xóa"),
            ),
          ],
        );
      },
    );
  }

  void _editItem(BuildContext context) {
    showModalBottomSheet<Map<String, String>?>(
      context: context,
      builder: (context) => SampleItemUpdate(
        initialName: widget.item.name.value,
        initialDescription: widget.item.description.value,
      ),
    ).then((value) {
      if (value != null) {
        viewModel.updateItem(
          widget.item.id,
          value['name'] ?? '',
          value['description'] ?? '',
        );
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết mục'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editItem(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteItem(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                widget.item.name.value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.item.description.value,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16.0), // Add some spacing at the bottom
          ],
        ),
      ),
    );
  }
}

class SampleItemListView extends StatefulWidget {
  const SampleItemListView({Key? key}) : super(key: key);

  @override
  State<SampleItemListView> createState() => _SampleItemListViewState();
}

class _SampleItemListViewState extends State<SampleItemListView> {
  final viewModel = SampleItemViewModel();
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Các mục mẫu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet<Map<String, String>?>(
                context: context,
                builder: (context) => const SampleItemUpdate(),
              ).then((value) {
                if (value != null) {
                  viewModel.addItem(
                    value['name'] ?? '',
                    value['description'] ?? '',
                  );
                }
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(
                    () {}); // Khi có sự thay đổi trong ô tìm kiếm, cập nhật giao diện
              },
              decoration: InputDecoration(
                labelText: 'Tìm kiếm',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: viewModel,
              builder: (context, _) {
                // Lọc danh sách mục dựa trên từ khóa tìm kiếm
                final filteredItems = viewModel.items.where((item) {
                  final searchTerm = _searchController.text.toLowerCase();
                  final itemName = item.name.value.toLowerCase();
                  return itemName.contains(searchTerm);
                }).toList();
                return ListView.builder(
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return SampleItemWidget(
                      key: ValueKey(item.id),
                      item: item,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SampleItemDetailsView(
                              item: item,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
