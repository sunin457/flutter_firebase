import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  // อ่านข้อมูลจาก firestore
  final CollectionReference _products =
      FirebaseFirestore.instance.collection('products');

  // สร้างตัวแปรเก็บ text field
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // สร้างฟังก์ชังเพิ่มและแก้ไขสินค้า
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';

    // ถ้ามีการส่งข้อมูลเก่าเข้ามา
    if (documentSnapshot != null) {
      action = 'update';
      _nameController.text = documentSnapshot['name'];
      _priceController.text = documentSnapshot['price'].toString();
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Price'),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final String? name = _nameController.text;
                      final double? price =
                          double.tryParse(_priceController.text);
                      if (name != null && price != null) {
                        // กรณีต้องการเพิ่มข้อมูล
                        if (action == 'create') {
                          // บันทึกข้อมูลเข้า Firebase firestore
                          _products.add(
                            {
                              "name": name,
                              "price": price,
                              "create_at": Timestamp.now()
                            },
                          );
                        }
                        // กรณีต้อการแก้ไขข้อมูล
                        if (action == 'update') {
                          // บันทึกข้อมูลเข้า Firebase firestore
                          _products.doc(documentSnapshot!.id).update(
                            {
                              "name": name,
                              "price": price,
                            },
                          );
                        }
                        // เคลียร์ข้อมูลออกจาก text field
                        _nameController.text = '';
                        _priceController.text = '';

                        // สั่งปิดหน้า bottomsheet
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(action == 'create'
                        ? 'Create Product'
                        : 'Update Product'),
                  )
                ],
              ),
              SizedBox(height: 20)
            ],
          ),
        );
      },
    );
  }

  // สร้างฟังก์ชันลบข้อมูลจาก firebase firestore
  Future<void> _deleteProduct(String productId) async {
    await _products.doc(productId).delete();
    // แสดง popup แจ้งผลการลบ
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Delete Success')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: StreamBuilder(
        // stream: _products.snapshots(),
        stream: _products.orderBy('price', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      documentSnapshot['name'],
                    ),
                    subtitle: Text(
                      "${documentSnapshot['price']} THB",
                    ),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(children: [
                        IconButton(
                          onPressed: () {
                            _createOrUpdate(documentSnapshot);
                          },
                          icon: Icon(
                            Icons.edit,
                            color: Colors.orange,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _deleteProduct(documentSnapshot.id);
                          },
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ]),
                    ),
                  ),
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _createOrUpdate();
          },
          child: Icon(Icons.add)),
    );
  }
}
