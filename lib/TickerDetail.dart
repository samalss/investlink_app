import 'dart:io';

import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:investlink_app/CryptoData.dart';

class TickerDetails extends StatefulWidget {
  final CryptoData ticker;

  TickerDetails({required this.ticker});

  @override
  _TickerDetailsState createState() => _TickerDetailsState();
}

class _TickerDetailsState extends State<TickerDetails> {
  //Даты для запроса API
  late String startDate;
  late String endDate;

  List<DataPoint>? chartData;
  int selectedButtonIndex = 0; //для выбора периода
  String error = "";
  bool isLoading = false; // Флаг для отслеживания состояния загрузки
  void onButtonPressed(int index) {
    setState(() {
      selectedButtonIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // Инициализация значений startDate и endDate на предыдущий день
    DateTime currentDate = DateTime.now().subtract(Duration(days: 1));
    startDate = formatDate(currentDate);
    endDate = formatDate(currentDate);
    fetchData();
  }

  //API
  void fetchData() async {
    List<DataPoint> chartDataTemp = [];
    String url =
        'https://api.polygon.io/v2/aggs/ticker/${widget.ticker
        .name}/range/1/day/$startDate/$endDate?adjusted=true&sort=asc&limit=120&apiKey=R_jgOGq3tzE6br7ZfRPNxx7we9jHT5GJ'; // Замените на свой URL API
    try{
      var response = await http.get(Uri.parse(url));
      setState(() {
        isLoading = true; // Устанавливаем флаг загрузки в true
      });
      if (response.statusCode == 200) {
        String jsonResponse = response.body;
        var results = jsonDecode(jsonResponse)['results'];

        for (var result in results) {
          double close = double.parse(result['c'].toString());
          int time = int.parse(result['t'].toString());
          DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time);

          DataPoint dataPoint = DataPoint(close, dateTime);
          chartDataTemp.add(dataPoint);
        }

        setState(() {
          chartData = chartDataTemp;
          isLoading = false;
        });
      } else {
        setState(() {
          chartData = null;
          error = response.statusCode.toString();
        });
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

  //Приводим в формат yyyy-MM-dd
  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day
        .toString().padLeft(2, '0')}';
  }

  //при выборе периода запрашиваем новые данные
  void requestData(int days, int index) {
    DateTime startDateValue = DateTime.now().subtract(Duration(days: 1));
    DateTime endDateValue = startDateValue.subtract(Duration(days: days));
    String newStartDate = formatDate(startDateValue);
    String newEndDate = formatDate(endDateValue);
    setState(() {
      selectedButtonIndex = index;
      startDate = newEndDate;
      endDate = newStartDate;
    });
    fetchData();
  }

//pull-to-referesh
  Future<void> refresh() async {
    fetchData(); // Call the fetchData method
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 55,
        elevation: 0,
        title: Container(
            padding: EdgeInsets.fromLTRB(0, 6, 0, 0),
            child: Text(widget.ticker.convertName(), style: TextStyle(
                decoration: TextDecoration.none,
                color: Colors.black,
                fontSize: 26,
                fontFamily: "Roboto",
                fontWeight: FontWeight.w400
            ),
            )
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black,),

          onPressed: () {
            Navigator.pop(context);
          },
          // Настройте стиль иконки стрелки здесь
          iconSize: 30,
          color: Colors.white,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: (isLoading && error == "") ?
          CircularProgressIndicator() : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  height: 41,
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Row(
                      children: [
                        Text(
                          "ЦЕНА:",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(widget.ticker.close.toString(),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                          ),)
                      ],
                    ),
                  )
              ),
              SizedBox(height: 8),
              Container(
                height: 41,
                color: Colors.white,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 60, // Set the width of the button
                            height: 17, // Set the height of the button
                            child: buildButton(0, '1Д', 1),
                          ),
                          Container(
                            width: 60, // Set the width of the button
                            height: 17, // Set the height of the button
                            child: buildButton(1, '5Д', 5),
                          ),
                          Container(
                            width: 60, // Set the width of the button
                            height: 17, // Set the height of the button
                            child: buildButton(2, '1Н', 7),
                          ),
                          Container(
                            width: 60, // Set the width of the button
                            height: 17, // Set the height of the button
                            child: buildButton(3, '1МЕС', 30),
                          ),
                          Container(
                            width: 60, // Set the width of the button
                            height: 17, // Set the height of the button
                            child: buildButton(4, '3МЕС', 90),
                          ),
                        ],
                      ),
                    )
                ),
              ),
              SizedBox(height: 8),
              (chartData == null)
                  ? Center(child: Text(error))
                  : Container(
                  height: 184,
                  color: Colors.white,
                  child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: SfCartesianChart(
                          primaryXAxis: CategoryAxis(isVisible: false),

                          series: <ChartSeries>[
                            LineSeries<DataPoint, DateTime>(
                              dataSource: chartData!,
                              xValueMapper: (DataPoint data, _) => data.time,
                              yValueMapper: (DataPoint data, _) => data.close,
                              color: Color.fromRGBO(119, 200, 80, 1),
                            ),
                          ],
                        ),
                      )
                  )
              ),
              SizedBox(height: 8),
              Container(
                  height: 80,
                  color: Colors.white,
                  child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: 170,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      buildText("HIGH: ",
                                          widget.ticker.high.toString()),
                                      SizedBox(height: 10),
                                      buildText("OPEN: ",
                                          widget.ticker.open.toString()),
                                    ],
                                  ),
                                ),

                                Container(
                                    width: 170,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        buildText("LOW: ",
                                            widget.ticker.low.toString()),
                                        SizedBox(height: 10),
                                        buildText("CLOSE: ",
                                            widget.ticker.close.toString()),
                                      ],
                                    )
                                )
                              ]
                          )
                      )
                  )
              )

            ],
          ),
        ),
      ),
    );
  }

  //Text для HIGH LOW OPEN CLOSE
  Widget buildText(String param, String value) {
    return Row(
      children: [
        Text(
          param,
          style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w400
          ),
        ),
        SizedBox(width: 10,),
        Text(
          value + " USDT",
          style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600
          ),
        )
      ],
    );
  }

  //периоды 1д 5д и тд
  Widget buildButton(int index, String label, int days) {
    final isSelected = selectedButtonIndex == index;
    final buttonColor = isSelected ? Color.fromRGBO(119, 200, 80, 1) : Colors
        .white;
    final textColor = isSelected ? Colors.white : Colors.black;

    return ElevatedButton(
      onPressed: () => requestData(days, index),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(buttonColor),
        elevation: MaterialStateProperty.all<double>(0),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontFamily: "Roboto",
            fontSize: 10,
            color: textColor
        ),
      ),
    );
  }
}


class DataPoint {
  final double close;
  final DateTime time;

  DataPoint(this.close, this.time);
}
