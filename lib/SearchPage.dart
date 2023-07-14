import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  String error = "";

  void _performSearch(String query) async {
    try {
      // Отправка запроса API и обработка ответа
      final response = await http.get(Uri.parse(
          'https://api.polygon.io/v3/reference/tickers?search=$query&active=true&apiKey=R_jgOGq3tzE6br7ZfRPNxx7we9jHT5GJ'));
      if (response.statusCode == 200) {
        // Если запрос успешен, извлекаем результаты из ответа
        final jsonData = json.decode(response.body);
        final results = jsonData['results'];

        setState(() {
          _searchResults = List<Map<String, dynamic>>.from(results);
        });
      } else {
        error = 'Request failed with status: ${response.statusCode}';
      }
    } on SocketException catch (e) {
      // Обработка ошибки сети (нет подключения)
      error='Ошибка сети: ${e.message}';
    } on HttpException catch (e) {
      // Обработка ошибки HTTP (например, неверный URL)
      error='Ошибка HTTP: ${e.message}';
    } on FormatException catch (e) {
      // Обработка ошибки формата данных
      error='Ошибка формата данных: ${e.message}';
    } catch (e) {
      error='Другая ошибка $e';
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              children: [
                Container(
                  width: 275,
                  height: 40,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      _performSearch(value);
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                          Icons.search_rounded, color: Colors.grey),
                      hintText: 'Тикер / Название',
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      // Цвет подсказки
                      fillColor: Colors.white,
                      // Цвет фона
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.grey.shade300, width: 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.grey.shade300, width: 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),

                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 16, 16, 16),
                        child: TextButton(
                          onPressed: _clearSearch,
                          child: Text('Отмена', style: TextStyle(color: Colors
                              .black,
                              fontSize: 15,
                              fontFamily: 'Roboto'),),
                        ),
                      )
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final result = _searchResults[index];
                final primaryExchange = result['primary_exchange'];
                final name = result['name'];
                final ticker = result['ticker'];

                return ListTile(
                  title: Text(ticker ?? ''),
                  subtitle: Text(name ?? ''),
                  trailing: Text(primaryExchange ?? ''),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
