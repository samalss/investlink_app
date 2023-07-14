class CryptoData {
  final String name;
  final double close;
  final double open;
  final double high;
  final double low;
  final int time;

  CryptoData({
    required this.name,
    required this.close,
    required this.open,
    required this.high,
    required this.low,
    required this.time,
  });

  String convertName() {
    // для конвертации cryptocurrency pair X:BTCUSD в формат  BTC/USD
    String baseCurrency = name.substring(2, name.length - 3);
    String quoteCurrency = name.substring(name.length - 3);
    return '$baseCurrency / $quoteCurrency';
  }

  double getChange() {
    //Изменение в процентах
    return (close - open) / open * 100;
  }

  factory CryptoData.fromJson(Map<String, dynamic> json) {
    return CryptoData(
      name: json['T'].toString(),
      close: double.parse(json['c'].toString()),
      open: double.parse(json['o'].toString()),
      high: double.parse(json['h'].toString()),
      low: double.parse(json['l'].toString()),
      time: int.parse(json['t'].toString()),
    );
  }
}
