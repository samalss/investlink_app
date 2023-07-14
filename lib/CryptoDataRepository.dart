import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'CryptoData.dart';

class CryptoDataRepository {
  static const String apiUrl = 'https://api.polygon.io';
  static const String apiKey = "apiKey=R_jgOGq3tzE6br7ZfRPNxx7we9jHT5GJ";

  Future<List<CryptoData>> fetchCryptoData(String endpoint) async {
    try {
      endpoint = getEndpointUrl(
          "home"); //Для запроса списка криптовалют с текущими ценами за предыдущий  closed день
      final response = await http.get(Uri.parse(apiUrl + endpoint + apiKey));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<CryptoData> cryptoDataList = [];

        for (var item in jsonData['results']) {
          CryptoData cryptoData = CryptoData(
            name: item['T'].toString(),
            close: double.parse(item['c'].toString()),
            open: double.parse(item['o'].toString()),
            high: double.parse(item['h'].toString()),
            low: double.parse(item['l'].toString()),
            time: int.parse(item['t'].toString()),
          );
          cryptoDataList.add(cryptoData);
        }

        return cryptoDataList;
      } else {
        throw Exception('Failed to fetch crypto data');
      }
    } catch (e) {
      throw Exception('Failed to fetch crypto data');
    }
  }

  String getEndpointUrl(String page) {
    //
    switch (page) {
      case 'home':
        var now = DateTime.now();
        var previousDay = now.subtract(Duration(days: 1));
        var formatter = DateFormat('yyyy-MM-dd');
        String formattedDate = formatter.format(previousDay);
        return "/v2/aggs/grouped/locale/global/market/crypto/" + formattedDate +
            "?adjusted=true&";

      case 'search':
        return 'https://api.polygon.io/v3/reference/tickers?search=$page&active=true&apiKey=R_jgOGq3tzE6br7ZfRPNxx7we9jHT5GJ';
      default:
        throw Exception('Invalid page');
    }
  }
}
