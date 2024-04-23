import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Định nghĩa lớp Phone để lưu trữ thông tin điện thoại
class Phone {
  String id;
  ValueNotifier<String> brand;
  ValueNotifier<String> model;
  ValueNotifier<int> price;
  ValueNotifier<String> specifications;
  String? image;

  Phone({
    String? id,
    required String brand,
    required String model,
    required int price,
    required String? image,
    String? specifications,
  })  : id = id ?? generateUuid(),
        brand = ValueNotifier(brand),
        model = ValueNotifier(model),
        price = ValueNotifier(price),
        specifications = ValueNotifier(specifications ?? ''),
        image = image;

  static String generateUuid() {
    return int.parse(
            '${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(100000)}')
        .toRadixString(35)
        .substring(0, 9);
  }
}

// Lớp ViewModel cho danh sách điện thoại
class PhoneViewModel extends ChangeNotifier {
  static final _instance = PhoneViewModel._();
  factory PhoneViewModel() => _instance;
  PhoneViewModel._();
  final List<Phone> phones = [];

  // Thêm điện thoại mới vào danh sách
  void addPhone(String brand, String model, int price, String? image,
      String specifications) {
    phones.add(Phone(
        brand: brand,
        model: model,
        price: price,
        image: image,
        specifications: specifications));
    notifyListeners();
  }

  // Xóa điện thoại từ danh sách
  void removePhone(String id, BuildContext context) {
    phones.removeWhere((phone) => phone.id == id);
    notifyListeners();
    showSnackbar(context, "Điện thoại đã được xóa thành công");
  }

  // Cập nhật thông tin điện thoại trong danh sách
  void updatePhone(String id, String newBrand, String newModel, int newPrice,
      String newSpecifications) {
    try {
      final phone = phones.firstWhere((phone) => phone.id == id);
      phone.brand.value = newBrand;
      phone.model.value = newModel;
      phone.price.value = newPrice;
      phone.specifications.value = newSpecifications;
      notifyListeners();
    } catch (e) {
      debugPrint("Không tìm thấy điện thoại với ID $id");
    }
  }

  // Hiển thị thông báo
  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// Widget cho màn hình cập nhật điện thoại
class PhoneUpdate extends StatefulWidget {
  final String? initialBrand;
  final String? initialModel;
  final int? initialPrice;
  final String? initialSpecifications;

  const PhoneUpdate(
      {Key? key,
      this.initialBrand,
      this.initialModel,
      this.initialPrice,
      this.initialSpecifications})
      : super(key: key);

  @override
  State<PhoneUpdate> createState() => _PhoneUpdateState();
}

class _PhoneUpdateState extends State<PhoneUpdate> {
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _priceController;
  late TextEditingController _specificationsController;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController(text: widget.initialBrand);
    _modelController = TextEditingController(text: widget.initialModel);
    _priceController =
        TextEditingController(text: widget.initialPrice?.toString() ?? '');
    _specificationsController =
        TextEditingController(text: widget.initialSpecifications);
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _priceController.dispose();
    _specificationsController.dispose();
    super.dispose();
  }

  // Chọn và thiết lập hình ảnh cho điện thoại
  Future<String?> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return pickedFile.path;
    } else {
      return null;
    }
  }

  // Chọn và thiết lập hình ảnh cho điện thoại
  void _pickAndSetImage() async {
    final imagePath = await _pickImage();
    if (imagePath != null) {
      setState(() {
        _imagePath = imagePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialBrand != null
            ? 'Chỉnh sửa điện thoại'
            : 'Thêm điện thoại'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop({
                'brand': _brandController.text,
                'model': _modelController.text,
                'price': int.tryParse(_priceController.text) ?? 0,
                'image': _imagePath, // Chuyển đường dẫn hình ảnh cho người gọi
                'specifications': _specificationsController.text
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
              GestureDetector(
                onTap: _pickAndSetImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _imagePath != null
                      ? Image.file(
                          File(_imagePath!),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : const Icon(
                          Icons.add_photo_alternate,
                          size: 60,
                          color: Colors.grey,
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Thương hiệu'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Mẫu'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Giá (VND)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _specificationsController,
                decoration:
                    const InputDecoration(labelText: 'Thông số kỹ thuật'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget cho danh sách điện thoại
class PhoneWidget extends StatelessWidget {
  final Phone phone;
  final VoidCallback? onTap;

  const PhoneWidget({Key? key, required this.phone, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 60,
          height: 60,
          child: phone.image != null
              ? Image.file(
                  File(phone.image!),
                  fit: BoxFit.scaleDown,
                )
              : const Icon(
                  Icons.phone,
                  size: 40,
                  color: Colors.grey,
                ),
        ),
      ),
      title: Text('${phone.brand.value} ${phone.model.value}'),
      subtitle: Text('${phone.price.value} VND'),
      onTap: onTap,
    );
  }
}

// Widget cho màn hình chi tiết điện thoại
class PhoneDetailsView extends StatefulWidget {
  final Phone phone;

  const PhoneDetailsView({Key? key, required this.phone}) : super(key: key);

  @override
  State<PhoneDetailsView> createState() => _PhoneDetailsViewState();
}

class _PhoneDetailsViewState extends State<PhoneDetailsView> {
  final viewModel = PhoneViewModel();

  // Xác nhận xóa điện thoại
  void _deletePhone(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Xác nhận Xóa"),
          content:
              const Text("Bạn có chắc chắn muốn xóa điện thoại này không?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                viewModel.removePhone(widget.phone.id, context);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("Xóa"),
            ),
          ],
        );
      },
    );
  }

  // Chỉnh sửa thông tin điện thoại
  void _editPhone(BuildContext context) {
    showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      builder: (context) => PhoneUpdate(
        initialBrand: widget.phone.brand.value,
        initialModel: widget.phone.model.value,
        initialPrice: widget.phone.price.value,
        initialSpecifications: widget.phone.specifications.value,
      ),
    ).then((value) {
      if (value != null) {
        viewModel.updatePhone(
          widget.phone.id,
          value['brand'] ?? '',
          value['model'] ?? '',
          value['price'] ?? 0,
          value['specifications'] ?? '',
        );
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Điện Thoại'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editPhone(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deletePhone(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.phone.image != null &&
                      File(widget.phone.image!)
                          .existsSync()) // Kiểm tra nếu đường dẫn hình ảnh không rỗng và tệp tồn tại
                    Image.file(
                      File(widget.phone.image!),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.contain,
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[200],
                      child: Center(
                        child: Text(
                          'Không có Hình ảnh',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    'Thương hiệu: ${widget.phone.brand.value}',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Mẫu: ${widget.phone.model.value}',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Giá: ${widget.phone.price.value} VND',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Thông số kỹ thuật: ${widget.phone.specifications.value}',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget cho danh sách điện thoại
class PhoneListView extends StatefulWidget {
  const PhoneListView({Key? key}) : super(key: key);

  @override
  State<PhoneListView> createState() => _PhoneListViewState();
}

class _PhoneListViewState extends State<PhoneListView> {
  final viewModel = PhoneViewModel();
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
        title: const Text('Cửa hàng Điện thoại'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet<Map<String, dynamic>>(
                context: context,
                builder: (context) => const PhoneUpdate(),
              ).then((value) {
                if (value != null) {
                  viewModel.addPhone(
                    value['brand'] ?? '',
                    value['model'] ?? '',
                    value['price'] ?? 0,
                    value['image'], // Chuyển đường dẫn hình ảnh
                    value['specifications'] ?? '',
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
                setState(() {}); // Cập nhật UI khi truy vấn tìm kiếm thay đổi
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
                // Lọc danh sách điện thoại dựa trên truy vấn tìm kiếm
                final filteredPhones = viewModel.phones.where((phone) {
                  final searchTerm = _searchController.text.toLowerCase();
                  final phoneBrand = phone.brand.value.toLowerCase();
                  final phoneModel = phone.model.value.toLowerCase();
                  return phoneBrand.contains(searchTerm) ||
                      phoneModel.contains(searchTerm);
                }).toList();
                return ListView.builder(
                  itemCount: filteredPhones.length,
                  itemBuilder: (context, index) {
                    final phone = filteredPhones[index];
                    return PhoneWidget(
                      key: ValueKey(phone.id),
                      phone: phone,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PhoneDetailsView(
                              phone: phone,
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
