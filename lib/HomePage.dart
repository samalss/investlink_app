import 'dart:io';

import 'package:flutter/material.dart';
import 'CryptoData.dart';
import 'CryptoDataRepository.dart';
import 'SearchPage.dart';
import 'TickerDetail.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  bool sortAscending = true;
  String sortBy = 'close';

  String error = "";

  //определяем высоту устройства для пагинации
  final double deviceHeight = WidgetsBinding.instance!.window.physicalSize
      .height / WidgetsBinding.instance!.window.devicePixelRatio;
  final CryptoDataRepository _cryptoDataRepository = CryptoDataRepository();

  List<CryptoData> cryptocurrencies = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCryptoData();
  }

  // отправляем запрос API
  Future<void> _fetchCryptoData() async {
    setState(() {
      _isLoading = true;
    });

    try {
     List<CryptoData> cryptoDataList = await _cryptoDataRepository.fetchCryptoData("home");
      setState(() {
        cryptocurrencies = cryptoDataList;
        _isLoading = false;
      });
    } on SocketException catch (e) {
      // Обработка ошибки сети (нет подключения)
      error='Ошибка сети: ${e.message}';
      setState(() {
        _isLoading = false;
      });
    } on HttpException catch (e) {
      // Обработка ошибки HTTP (например, неверный URL)
      error='Ошибка HTTP: ${e.message}';
      setState(() {
        _isLoading = false;
      });
    } on FormatException catch (e) {
      // Обработка ошибки формата данных
      error='Ошибка формата данных: ${e.message}';
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      error='Другая ошибка $e';
      setState(() {
        _isLoading = false;
      });
    }

  }

//сортировка при нажатии на название столбца
  void sortData(String field) {
    setState(() {
      if (sortBy == field) {
        sortAscending = !sortAscending;
      } else {
        sortAscending = true;
        sortBy = field;
      }

      if (field == "name") {
        cryptocurrencies!.sort((a, b) => a.name.compareTo(b.name));
      } else if (field == "close" && sortAscending) {
        cryptocurrencies!.sort((a, b) => a.close.compareTo(b.close));
      } else if (field == "change" && sortAscending) {
        cryptocurrencies!.sort((a, b) =>
            a.getChange().compareTo(b.getChange()));
      }
    });
  }
//Определение кол. строк в одной странице
  int calculateRowsPerPage(double height) {
    // Adjust the values as per your requirements
    if (height <= 600) {
      return 5;
    } else if (height <= 900) {
      return 13;
    } else {
      return 15;
    }
  }


  //обновление pull-to-refresh
  Future<void> _refreshData() async {
    // Здесь происходит обновление данных при выполнении Pull to Refresh
    _fetchCryptoData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 72,
          title: Text("Криптовалюта", style: TextStyle(
              decoration: TextDecoration.none,
              color: Colors.black,
              fontSize: 26,
              fontFamily: "Roboto",
              fontWeight: FontWeight.w400
          ),
          ),
          actions: [
            Container(
              padding: EdgeInsets.all(19),
              child: IconButton(
                icon: Image.asset('assets/Vector.png'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        SearchPage()),
                  );
                },
              ),
            )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: (cryptocurrencies == null)
                ? Center(child: Text(error),)
                : Center(
              child: PaginatedDataTable(
                columnSpacing: 24.0,
                showCheckboxColumn: false,
                columns: [
                  DataColumn(
                    label: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 13,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/EditSquare.png"),
                            ),
                          ),
                        ),
                        SizedBox(width: 2,),
                        Text('Тикер / Название', style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Colors.grey,
                            fontSize: 10,
                            fontFamily: "Roboto",
                            fontWeight: FontWeight.w400
                        ),
                        ),
                        SizedBox(width: 48,),
                      ],
                    ),
                    onSort: (columnIndex, ascending) {
                      sortData('name');
                    },
                  ),
                  DataColumn(
                    label: Row(
                      children: [
                        Text('Цена', style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Colors.grey,
                            fontSize: 10,
                            fontFamily: "Roboto",
                            fontWeight: FontWeight.w400
                        ),
                        ),
                        Icon(Icons.arrow_drop_down_outlined, size: 15,
                            color: Colors.grey),
                      ],
                    ),
                    numeric: true,
                    onSort: (columnIndex, ascending) {
                      sortData('close');
                    },
                  ),
                  DataColumn(
                    label: Row(
                      children: [
                        Text("Изм. % / \$", style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Colors.grey,
                            fontSize: 10,
                            fontFamily: "Roboto",
                            fontWeight: FontWeight.w400
                        ),
                        ),
                        Icon(Icons.arrow_drop_down_outlined, size: 15,
                            color: Colors.grey),
                      ],
                    ),
                    numeric: true,
                    onSort: (columnIndex, ascending) {
                      sortData('change');
                    },
                  ),
                ],
                source: CryptoDataDataSource(
                  cryptocurrencies!,
                  navigateToPage: (cryptoData) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          TickerDetails(ticker: cryptoData)),
                    );
                  },
                ),
                rowsPerPage: calculateRowsPerPage(
                    deviceHeight), // Number of rows per page

              ),
            ),
          ),
        )
    );
  }
}


class CryptoDataDataSource extends DataTableSource {
  final List<CryptoData> _cryptoDataList; // List of CryptoData objects

  final void Function(CryptoData) navigateToPage; //навигация в TickerDetail при нажатии на строку
  CryptoDataDataSource(this._cryptoDataList, {required this.navigateToPage});

  @override
  DataRow? getRow(int index) {
    if (index >= _cryptoDataList.length) {
      return null;
    }


    final cryptoData = _cryptoDataList[index];

    return DataRow(
      onSelectChanged: ((selected) {
        navigateToPage(cryptoData);
      }),
      cells: [
        DataCell(
          Text(cryptoData.convertName()),
        ),
        DataCell(
          Text(cryptoData.close.toString()),
        ),
        DataCell(
            Padding(
              padding: EdgeInsets.fromLTRB(0, 13, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(cryptoData.getChange()
                      .toStringAsFixed(
                      2) + "%",
                    style: TextStyle(
                      color: (cryptoData.getChange() < 0
                          ? Colors.red
                          : Colors.green
                      ),),
                  ),
                  Text((cryptoData.close -
                      cryptoData.open).toStringAsFixed(
                      2),
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10
                    ),)
                ],
              ),
            )
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _cryptoDataList.length;

  @override
  int get selectedRowCount => 0;
}

