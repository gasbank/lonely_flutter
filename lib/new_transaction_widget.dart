import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum TransactionType {
  buy,
  sell,
}

class Transaction {
  Transaction(
      {required this.stockId,
      required this.price,
      required this.count,
      required this.transactionType,
      required this.dateTime});

  Transaction.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    stockId = map['stockId'];
    price = map['price'];
    count = map['count'];
    transactionType = map['transactionType'] == 0
        ? TransactionType.buy
        : TransactionType.sell;
    dateTime = DateTime.parse(map['dateTime']);
    earn = map['earn'];
  }

  int? id;
  late final String stockId;
  late final int price;
  late final int count;
  late final TransactionType transactionType;
  late final DateTime dateTime;
  int? earn;

  Map<String, dynamic> toMap() {
    return {
      'stockId': stockId,
      'price': price,
      'count': count,
      'transactionType': transactionType == TransactionType.buy
          ? 0
          : transactionType == TransactionType.sell
              ? 1
              : -1,
      'dateTime': dateTime.toIso8601String(),
      'earn': earn,
    };
  }
}

class NewTransactionWidget extends StatefulWidget {
  const NewTransactionWidget({super.key, required this.onNewTransaction});

  final Future<bool> Function(Transaction transaction) onNewTransaction;

  @override
  State<StatefulWidget> createState() => _NewTransactionWidgetState();
}

class _NewTransactionWidgetState extends State<NewTransactionWidget> {
  final TextEditingController _stockIdController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _countController = TextEditingController();

  void onPress(TransactionType transactionType) async {
    if (_stockIdController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _countController.text.isEmpty) {
      showSimpleError('칸을 모두 채우세요.');
      return;
    }

    final price = int.tryParse(_priceController.text) ?? 0;
    final count = int.tryParse(_countController.text) ?? 0;

    if (price <= 0) {
      showSimpleError('단가가 이상하네요...');
      return;
    }

    if (count <= 0) {
      showSimpleError('수량이 이상하네요...');
      return;
    }

    if (await widget.onNewTransaction(Transaction(
        transactionType: transactionType,
        count: count,
        price: price,
        stockId: _stockIdController.text,
        dateTime: DateTime.now()))) {
      clearTextFields();
    }
  }

  void showSimpleError(String msg) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar(reason: SnackBarClosedReason.action);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
    ));
  }

  void clearTextFields() {
    _stockIdController.text = '';
    _priceController.text = '';
    _countController.text = '';
  }

  @override
  void dispose() {
    _stockIdController.dispose();
    _priceController.dispose();
    _countController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (kDebugMode) {
      //print('initState(): NewTransactionWidget');
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: TextField(
                controller: _stockIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '종목코드',
                    contentPadding: EdgeInsets.all(10.0)),
                autocorrect: false,
                textInputAction: TextInputAction.next,
              ),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '단가',
                    contentPadding: EdgeInsets.all(10.0)),
                textInputAction: TextInputAction.next,
              ),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: TextField(
                controller: _countController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '수량',
                    contentPadding: EdgeInsets.all(10.0)),
                textInputAction: TextInputAction.done,
              ),
            ),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: ButtonStyle(
                foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.redAccent),
              ),
              onPressed: () {
                onPress(TransactionType.buy);
              },
              child: const Text('매수'),
            ),
          ),
          Expanded(
            child: OutlinedButton(
              style: ButtonStyle(
                foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.blueAccent),
              ),
              onPressed: () {
                onPress(TransactionType.sell);
              },
              child: const Text('매도'),
            ),
          ),
        ],
      ),
    ]);
  }
}
