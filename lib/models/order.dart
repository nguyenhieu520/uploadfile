class Order {
  final String id;
  final String orderCode;
  final String orderType; // Ngồi lại / Mang đi / Giao hàng
  final String? tableNumber;
  final String staffId;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.orderCode,
    required this.orderType,
    this.tableNumber,
    required this.staffId,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'order_code': orderCode,
    'order_type': orderType,
    'table_number': tableNumber,
    'staff_id': staffId,
    'total_amount': totalAmount,
    'payment_method': paymentMethod,
    'payment_status': paymentStatus,
    'created_at': createdAt.toIso8601String(),
  };

  static Order fromMap(Map<String, dynamic> map) => Order(
    id: map['id'],
    orderCode: map['order_code'],
    orderType: map['order_type'],
    tableNumber: map['table_number'],
    staffId: map['staff_id'],
    totalAmount: map['total_amount'],
    paymentMethod: map['payment_method'],
    paymentStatus: map['payment_status'],
    createdAt: DateTime.parse(map['created_at']),
  );
}

class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? note;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.note,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'order_id': orderId,
    'product_id': productId,
    'quantity': quantity,
    'unit_price': unitPrice,
    'total_price': totalPrice,
    'note': note,
  };

  static OrderItem fromMap(Map<String, dynamic> map) => OrderItem(
    id: map['id'],
    orderId: map['order_id'],
    productId: map['product_id'],
    quantity: map['quantity'],
    unitPrice: map['unit_price'],
    totalPrice: map['total_price'],
    note: map['note'],
  );
}