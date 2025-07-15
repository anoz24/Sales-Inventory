import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String barcode;
  
  @HiveField(3)
  final double price;
  
  @HiveField(4)
  final int stockQuantity;
  
  @HiveField(5)
  final String? imageUrl; // Optional image
  
  const Product({
    required this.id,
    required this.name,
    required this.barcode,
    required this.price,
    required this.stockQuantity,
    this.imageUrl,
  });
  
  @override
  List<Object?> get props => [
        id,
        name,
        barcode,
        price,
        stockQuantity,
        imageUrl,
      ];
} 