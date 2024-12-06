import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import '../../all_imports/imports.dart';



class ThisMonthPage extends StatefulWidget {
  const ThisMonthPage({super.key});

  @override
  _ThisMonthPageState createState() => _ThisMonthPageState();
}

class _ThisMonthPageState extends State<ThisMonthPage> {
  DateTime selectedDate = DateTime.now();
  late String formattedDate;
  late int applianceCount = 0;
  late double co2Emission = 0.0;
  late double estimatedEnergy = 0.0;
  final List<dynamic> devices = [];
  Map<String, dynamic> monthlyData = {};
  List<Map<String, dynamic>> appliances = [];
  bool isLoading = false;
  Map<String, double> dataMap = {};
  final now = DateTime.now();
  final ScrollController _scrollController = ScrollController();
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    DateTime now = DateTime.now();
    selectedDate = DateTime(now.year, now.month - 1, now.day);
    if (now.month == 1) {
      selectedDate = DateTime(now.year - 1, 12, now.day);
    }
    super.initState();
    // fetchAppliances();
    fetchAppliancesData();
    // fetchAppliances1();
    totalMonthlyCostOfUserAppliances();
    getUsersApplianceCount();
  }

  Future<void> fetchAppliancesData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final appliancesData = await ApplianceService.fetchAppliance();

      setState(() {
        appliances = List<Map<String, dynamic>>.from(appliancesData);

        // Sort appliances by monthlyCost in descending order
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

        // Add top 8 appliances to the dataMaps
        for (int i = 0; i < 5 && i < appliances.length; i++) {
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
        if (appliances.length > 5) {
          for (int i = 5; i < appliances.length; i++) {
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

        isLoading = false;
      });
    } catch (e) {
      // Handle errors here
      print("Error fetching appliances: $e");
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> fetchAppliances() async {
    setState(() {
      isLoading = true;
    });

    try {
      final appliancesData = await ApplianceService.fetchAppliance();
      appliancesData.sort((a, b) {
        DateTime timestampA = DateTime.parse(a['createdAt']);
        DateTime timestampB = DateTime.parse(b['createdAt']);
        return timestampB.compareTo(timestampA); // Sort in descending order
      });

      setState(() {
        appliances = List<Map<String, dynamic>>.from(appliancesData);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getUsersApplianceCount() async {
    final box = Hive.box<User>('userBox');
    final currentUser = box.get('currentUser');

    final userId = currentUser!.userId;

    // Adjust the URL to match the new endpoint
    final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/getUsersCount/$userId/appliances'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        // Check if the appliances are included in the response
        if (data['appliances'] != null) {
          // Update the applianceCount variable based on the length of the appliances list
          applianceCount = data['appliances'].length;
        } else {
          applianceCount = 0; // Set to 0 if no appliances found
        }
      });
    } else {
      throw Exception('Failed to load appliances');
    }
  }

  Future<void> totalMonthlyCostOfUserAppliances() async {
    final box = Hive.box<User>('userBox');
    final currentUser = box.get('currentUser');

    final userId = currentUser!.userId;

    // Build the URL with the userId parameter
    final url = Uri.parse(
        "${ApiConfig.baseUrl}/totalMonthlyCostOfUserAppliances/$userId");

    // Make the HTTP request
    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        monthlyData['totalMonthlyCost'] = data['totalMonthlyCost'];
        monthlyData['totalMonthlyKwhConsumption'] =
            data['totalMonthlyKwhConsumption'];
        monthlyData['totalMonthlyCO2Emissions'] =
            data['totalMonthlyCO2Emissions'];
      });
      // Optional: You can log the fetched data if needed.
      print('Fetched total monthly cost: ${monthlyData['totalMonthlyCost']}');
    } else {
      throw Exception(
          'Failed to fetch total monthly cost: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Home Usage',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Center(child: content()),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 60.0,
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

  Widget content() {
    if (isLoading) {
      return const Center(
          child: LoadingWidget(
        message: 'Fetching my appliances',
        color: AppColors.primaryColor,
      ));
    } else if (appliances.isEmpty) {
      return const SizedBox(
        height: 450,
        width: 300,
        child:  Center(
          child: Text(
            'You haven\'t added any appliances yet. Start by adding appliances to track your energy usage and see estimated costs.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      return Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Container(
              margin: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  // Separate scrollable container for allAppliances
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: allAppliances(),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget allAppliances() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          headers(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: deviceUsageSummary(
                    applianceCount: applianceCount,
                    co2Emission: co2Emission,
                    estimatedEnergy: estimatedEnergy,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: appliancesContent(),
                ),
              ],
            ),
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
                          ringStrokeWidth: 1,
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

  Widget pieChartTitle() {
    String formattedDate = DateFormat('MMMM yyyy').format(now);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          formattedDate,
          style: const TextStyle(
              color: AppColors.secondaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ],
    );
  }

  Widget headers() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: AppColors.primaryColor,
      child: const Row(
        children: [
          SizedBox(
            width: 20,
          ),
          Text(
            'Device Usage Summary',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Spacer(),
          Text(
            'Devices',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  Widget appliancesContent() {
    if (isLoading) {
      return const Center(
          child: LoadingWidget(
        message: 'Fetching my appliances',
        color: AppColors.primaryColor,
      ));
    } else if (appliances.isEmpty) {
      return const Text(
        'You haven\'t added any appliances yet. Start by adding appliances to track your energy usage and see estimated costs.',
        textAlign: TextAlign.center,
      );
    } else {
      return SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFFADE7DB),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                offset: Offset(0, 4),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          height: 450, // Constrain height to enable scrolling within this box
          child: ScrollbarTheme(
            data: ScrollbarThemeData(
              thumbColor: MaterialStateProperty.all(AppColors.primaryColor),
              trackColor: MaterialStateProperty.all(Colors.grey[300]),
              trackBorderColor: MaterialStateProperty.all(Colors.transparent),
              thickness: MaterialStateProperty.all(5),
              radius: const Radius.circular(20),
              thumbVisibility: MaterialStateProperty.all(true),
            ),
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView(
                children: appliances.asMap().entries.map((entry) {
                  var appliance = entry.value;
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFADE7DB),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x40000000),
                          offset: Offset(0, 4),
                          blurRadius: 10,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${appliance['applianceName'] ?? 'Unknown'}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width *
                                0.04, // Responsive font size
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondaryColor,
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height *
                                0.01), // Responsive spacing
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'PHP ${appliance['monthlyCost'].toStringAsFixed(2) ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.03, // Responsive font size
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Monthly Cost",
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.02, // Responsive font size
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '${appliance['wattage'].toStringAsFixed(2) ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.03, // Responsive font size
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Wattage",
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.02, // Responsive font size
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget deviceUsageSummary({
    required int applianceCount,
    required double co2Emission,
    required double estimatedEnergy,
  }) {
    return Row(
      children: [
        Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                energyCard(
                  title: "Total Devices",
                  value: applianceCount.toString(),

                  // value: totalDevices.toString(),
                ),
                const SizedBox(height: 16),
                energyCard(
                  title: "CO2 Emission",
                  value: monthlyData['totalMonthlyCO2Emissions'] != null
                      ? double.parse(monthlyData['totalMonthlyCO2Emissions']
                              .toString())
                          .toStringAsFixed(2)
                      : 'N/A',
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    showApplianceInformationDialog( const Icon(
                      Icons.energy_savings_leaf_outlined,
                      color: AppColors.primaryColor,
                      size: 50,
                    ),
                        monthlyData['totalMonthlyKwhConsumption'] != null
                            ? '${double.parse(monthlyData['totalMonthlyKwhConsumption'].toString()).toStringAsFixed(2)} kWh'
                            : 'N/A',
                        'Estimated Energy Used');
                  },
                  child: energyCard(
                    title: "Estimated Energy Used",
                    value: monthlyData['totalMonthlyKwhConsumption'] != null
                        ? '${double.parse(monthlyData['totalMonthlyKwhConsumption'].toString()).toStringAsFixed(2)} kWh'
                        : 'N/A',
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    showApplianceInformationDialog(
                        const Icon(
                          Icons.monetization_on_outlined,
                          color: AppColors.primaryColor,
                          size: 50,
                        ),
                        monthlyData['totalMonthlyCost'] != null
                            ? 'PHP ${double.parse(monthlyData['totalMonthlyCost'].toString()).toStringAsFixed(2)}'
                            : 'N/A',
                        'Estimated Monthly Cost');
                  },
                  onPanDown: (details) {
                    // This is triggered when the user touches the screen and starts panning.
                    print(
                        'User touched the screen at: ${details.localPosition}');
                  },
                  child: energyCard(
                    title: "Estimated Monthly Cost",
                    value: monthlyData['totalMonthlyCost'] != null
                        ? 'PHP ${double.parse(monthlyData['totalMonthlyCost'].toString()).toStringAsFixed(2)}'
                        : 'N/A',
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void showApplianceInformationDialog(Icon icon,String data, String title) {
    showCustomGeneralDialog(
      context: context,
      barrierDismissible: true,
      pageBuilder: Center(
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
               icon,
                const SizedBox(height: 20),
                Text(
                  data,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Montserrat',
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[500],
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget applianceContentNew() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          'Devices',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor),
        ),
        const SizedBox(height: 20),
        appliancesContent(),
      ],
    );
  }

  Widget energyCard({required String title, required String value}) {
    return SizedBox(
      width: 117,
      height: 100,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFADE7DB),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              offset: Offset(0, 4),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1, // Limit to 1 line for value
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2, // Limit to 2 lines for title
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
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
          child: Padding(
            // padding: const EdgeInsets.only(top: 20.0,bottom: 10),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Adjust size based on content
              children: [
                pieChartTitle(),
                const SizedBox(height: 10),
                chart(),
              ],
            ),
          ),
        );
      },
    );
  }
}
