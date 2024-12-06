import '../all_imports/imports.dart';

class HomeUsage extends StatelessWidget {
  final String kwh;

  const HomeUsage({super.key, required this.kwh});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 208,
      width: 202,
      decoration: greyBoxDecoration(),
      child: Column(
        children: [
          const Icon(
            Icons.house_siding_rounded,
            size: 150,
          ),
          Text(
            kwh,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            'Home Usage',
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
class ApplianceInfoCard extends StatelessWidget {
  final String imagePath;
  final String mainText;
  final String subText;

  const ApplianceInfoCard({
    super.key,
    required this.imagePath,
    required this.mainText,
    required this.subText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      width: 113,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: greyBoxDecoration(), // Assuming this is defined elsewhere
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                width: 150.0,
                height: 50.0,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10.0),
              Text(
                mainText,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  subText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
