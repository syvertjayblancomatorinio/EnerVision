import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';

import '../../all_imports/imports.dart';

class LastMonthPage extends StatefulWidget {
  const LastMonthPage({super.key});

  @override
  State<LastMonthPage> createState() => _LastMonthPageState();
}

class _LastMonthPageState extends State<LastMonthPage> {
  Map<String, dynamic> monthlyData = {};
  int applianceCount = 0;
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> appliances = [];
  final AppControllers controllers = AppControllers();
  Map<String, double> dataMap = {};
  bool isLoading = false;
  bool _showPieChart = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    selectedDate = DateTime(now.year, now.month - 1, now.day);
    if (now.month == 1) {
      selectedDate = DateTime(now.year - 1, 12, now.day);
    }
    getLastMonth(selectedDate);
  }

  Future<void> getLastMonth(DateTime date) async {
    final box = Hive.box<User>('userBox');
    final currentUser = box.get('currentUser');

    final userId = currentUser!.userId;
    if (userId == null) {
      print("User ID is null. Cannot fetch monthly consumption.");
      return;
    }

    final formattedMonth = DateFormat('MM').format(date);
    final formattedYear = DateFormat('yyyy').format(date);

    final url = Uri.parse(
        "${ApiConfig.baseUrl}/monthlyDataNew/$userId?month=$formattedMonth&year=$formattedYear");

    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 404) {
        setState(() {
          monthlyData = {
            'totalMonthlyConsumption': null,
            'totalMonthlyKwhConsumption': null,
          };
          applianceCount = 0; // Reset applianceCount to 0 for 404 response.
          appliances = []; // Clear appliances list for consistency.
        });
        await _showApplianceErrorDialog(context);
        return;
      } else if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final double totalMonthlyConsumption =
            data['data']['totalMonthlyConsumption']?.toDouble() ?? 0.0;

        // Fetch user's kwhRate from a reliable source
        final double kwhRate = await getUserKwhRate(userId);

        // Calculate totalKwhConsumption
        double totalKwhConsumption =
            (kwhRate > 0) ? totalMonthlyConsumption / kwhRate : 0.0;
        double totalCO2Emission = totalKwhConsumption * 0.7;
        await getUsersApplianceCount(); // Fetch appliances count here.

        setState(() {
          monthlyData = {
            'totalMonthlyConsumption': totalMonthlyConsumption,
            'totalMonthlyKwhConsumption': totalKwhConsumption,
            'totalMonthlyCO2Emission': totalCO2Emission,
          };
        });
        print("Monthly Data: $monthlyData");
      } else {
        setState(() {
          applianceCount = 0; // Reset applianceCount for other error responses.
        });
        print(
            "Failed to load monthly data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching monthly data: $e");
      setState(() {
        applianceCount = 0; // Reset applianceCount in case of exceptions.
      });
    }
  }

  Future<void> getUsersApplianceCount() async {
    final box = Hive.box<User>('userBox');
    final currentUser = box.get('currentUser');

    final userId = currentUser!.userId;
    if (userId == null) {
      print("User ID is null. Cannot fetch appliance count.");
      return;
    }

    final formattedMonth = DateFormat('MM').format(selectedDate);
    final formattedYear = DateFormat('yyyy').format(selectedDate);

    final response = await http.get(Uri.parse(
        '${ApiConfig.baseUrl}/getNewUsersCount/$userId/appliances?month=$formattedMonth&year=$formattedYear'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        applianceCount = data['count'] ?? 0;
        appliances = List<Map<String, dynamic>>.from(data['appliances'] ?? []);
        appliances.sort((a, b) {
          double costA = (a["monthlyCost"] is int)
              ? (a["monthlyCost"] as int).toDouble()
              : a["monthlyCost"];
          double costB = (b["monthlyCost"] is int)
              ? (b["monthlyCost"] as int).toDouble()
              : b["monthlyCost"];
          return costB.compareTo(costA); // Descending order
        });

        // Prepare the dataMap for the pie chart
        dataMap = {};
        double othersCost = 0.0;

        // Add top 4 appliances to the dataMaps
        for (int i = 0; i < 3 && i < appliances.length; i++) {
          var appliance = appliances[i];
          if (appliance["monthlyCost"] != null &&
              appliance["applianceName"] != null) {
            dataMap[appliance["applianceName"]] =
                (appliance["monthlyCost"] is int
                    ? (appliance["monthlyCost"] as int).toDouble()
                    : appliance["monthlyCost"]) as double;
          }
        }

        // Sum the monthly costs of the remaining appliances and assign to "Others"
        if (appliances.length > 3) {
          for (int i = 3; i < appliances.length; i++) {
            var appliance = appliances[i];
            if (appliance["monthlyCost"] != null) {
              othersCost += (appliance["monthlyCost"] is int
                  ? (appliance["monthlyCost"] as int).toDouble()
                  : appliance["monthlyCost"]) as double;
            }
          }
          // Add "Others" category
          dataMap["Others"] = othersCost;
        }
      });
    } else if (response.statusCode == 404) {
      setState(() {
        applianceCount = 0;
        appliances = [];
      });
      print("No monthly consumption data found for the specified period.");
    } else {
      throw Exception('Failed to load appliances');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          child: Container(
            margin: const EdgeInsets.only(bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                DatePickerWidget(
                  initialDate: selectedDate,
                  onDateSelected: onDateSelected,
                  getApplianceCount: () {},
                ),
                const SizedBox(height: 20),
                HomeUsage(
                  kwh: monthlyData['totalMonthlyKwhConsumption'] != null
                      ? '${double.parse(monthlyData['totalMonthlyKwhConsumption'].toString()).toStringAsFixed(2)} kwh'
                      : 'N/A',
                ),
                const SizedBox(height: 40),
                bottomPart(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 20.0,
          right: 20.0,
          child: ElevatedButton(
            onPressed: () {
              showPieChartDialog(context);
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
            ),
            child: const Icon(
              Icons.pie_chart,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget pieChartTitle() {
    String formattedDate = DateFormat('MMMM yyyy').format(selectedDate);
    return Container(
      padding: const EdgeInsets.all(10),
      color: AppColors.primaryColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // const Text(
          //   'Summary |',
          //   style: TextStyle(
          //       color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          // ),
          const SizedBox(width: 10),
          Text(
            formattedDate,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget chart() {
    return SafeArea(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : appliances.isEmpty
              ? const Center(child: Text(""))
              : Center(
                  child: dataMap.isNotEmpty
                      ? PieChart(
                          dataMap: dataMap,
                          animationDuration: const Duration(milliseconds: 500),
                          chartLegendSpacing: 10,
                          chartRadius: MediaQuery.of(context).size.width / 1.5,
                          colorList: colorList,
                          initialAngleInDegree: 0,
                          chartType: ChartType.disc,
                          ringStrokeWidth: 32,
                          centerWidget: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          legendOptions: const LegendOptions(
                            showLegendsInRow: false,
                            legendPosition: LegendPosition.right,
                            showLegends: true,
                            legendShape: BoxShape.circle,
                            legendTextStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          chartValuesOptions: const ChartValuesOptions(
                            showChartValueBackground: false,
                            chartValueStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                            showChartValues: true,
                            showChartValuesInPercentage: true,
                            showChartValuesOutside: false,
                            decimalPlaces: 1,
                          ),
                        )
                      : const Center(child: Text("No data to display")),
                ),
    );
  }

  Widget bottomPart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () {
            print('Appliances tapped');
            showApplianceInformationDialog(context);
          },
          child: ApplianceInfoCard(
            imagePath: 'assets/image (7).png',
            mainText: applianceCount.toString(),
            subText: 'No. of Appliances Added',
          ),
        ),
        ApplianceInfoCard(
          imagePath: 'assets/image (9).png',
          mainText: monthlyData['totalMonthlyConsumption'] != null
              ? double.parse(monthlyData['totalMonthlyConsumption'].toString())
                  .toStringAsFixed(2)
              : 'N/A',
          subText: 'Estimated Total Cost for the Month',
        ),
        ApplianceInfoCard(
          imagePath: 'assets/image (8).png',
          mainText: monthlyData['totalMonthlyCO2Emission'] != null
              ? double.parse(monthlyData['totalMonthlyCO2Emission'].toString())
                  .toStringAsFixed(2)
              : 'N/A',
          subText: 'CO2 Emission',
        ),
      ],
    );
  }

  Future<void> _showApplianceErrorDialog(BuildContext context) async {
    await showCustomDialog(
      context: context,
      title: 'No data available',
      message:
          'No data available for this month or year. \nPlease use a different date.',
      buttonText: 'OK',
    );
  }

  Future<double> getUserKwhRate(String userId) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/user/$userId/kwhRate");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['kwhRate']?.toDouble() ?? 0.0;
      } else {
        print("Failed to fetch kwhRate. Status code: ${response.statusCode}");
        return 0.0;
      }
    } catch (e) {
      print("Error fetching kwhRate: $e");
      return 0.0;
    }
  }

  void onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
    getLastMonth(date);
  }

  void showApplianceInformationDialog(BuildContext context) {
    if (appliances.isEmpty) {
      print('No appliances to show.');
    }

    showDialog(
      context: context,
      builder: (context) {
        return ApplianceListDialog(appliances: appliances);
      },
    );
  }

  void showPieChartDialog(BuildContext context) {
    if (appliances.isEmpty) {
      print('No appliances to show.');
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Adjust size based on content
            children: [
              pieChartTitle(),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: chart(), // Replace with your chart widget
              ),
            ],
          ),
        );
      },
    );
  }
}
