import 'package:flutter/material.dart';
import 'package:navixplore/features/widgets/webview_screen.dart';
import 'package:url_launcher/url_launcher.dart';

enum IconType { icon, asset }

class ExpressTab extends StatefulWidget {
  const ExpressTab({Key? key}) : super(key: key);

  @override
  State<ExpressTab> createState() => _ExpressTabState();
}

class _ExpressTabState extends State<ExpressTab> {
  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.05),
            Colors.white,
          ],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // Main IRCTC Booking Card
          GestureDetector(
            onTap: () async {
              const String irctcAppUrl = 'irctc://';
              const String playStoreUrl =
                  'https://play.google.com/store/apps/details?id=cris.org.in.prs.ima';

              try {
                await _launchUrl(irctcAppUrl);
              } catch (e) {
                await _launchUrl(playStoreUrl);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset(
                          "assets/images/IRCTC.png",
                          width: 32,
                          height: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Book Train Tickets",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Reserve seats through official IRCTC app",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "OPEN IRCTC APP",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Section title
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 30, 0, 16),
            child: Text(
              "Quick Services",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),

          // Service Cards Grid
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              // PNR Status Card
              _buildServiceCard(
                context: context,
                title: "PNR Status",
                icon: "assets/images/pnr_status.png",
                iconType: IconType.asset,
                color: Colors.blue.shade700,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WebView_Screen(
                        url: "https://www.indianrail.gov.in/enquiry/PNR/PnrEnquiry.html?locale=en",
                        title: "PNR Status",
                      ),
                    ),
                  );
                },
              ),

              // Fare Enquiry Card
              _buildServiceCard(
                context: context,
                title: "Fare Enquiry",
                icon: Icons.currency_rupee_rounded,
                iconType: IconType.icon,
                color: Colors.green.shade700,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WebView_Screen(
                        url: "https://www.indianrail.gov.in/enquiry/FARE/FareEnquiry.html?locale=en",
                        title: "Fare Enquiry",
                      ),
                    ),
                  );
                },
              ),

              // Train Schedule Card
              _buildServiceCard(
                context: context,
                title: "Train Schedule",
                icon: "assets/images/schedule.png",
                iconType: IconType.asset,
                color: Colors.orange.shade700,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WebView_Screen(
                        url: "https://www.indianrail.gov.in/enquiry/SCHEDULE/TrainSchedule.html",
                        title: "Train Schedule",
                      ),
                    ),
                  );
                },
              ),

              // Seat Availability Card
              _buildServiceCard(
                context: context,
                title: "Seat Availability",
                icon: Icons.airline_seat_recline_normal_rounded,
                iconType: IconType.icon,
                color: Colors.purple.shade700,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WebView_Screen(
                        url: "https://www.indianrail.gov.in/enquiry/SEAT/SeatAvailability.html?locale=en",
                        title: "Seat Availability",
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          // More Services Section
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 30, 0, 16),
            child: Text(
              "More Services",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildMoreServiceItem(
                  context: context,
                  title: "Train Route Information",
                  icon: Icons.route_rounded,
                  onTap: () {
                    // Implement navigation for Train Route page
                  },
                ),
                const Divider(height: 20),
                _buildMoreServiceItem(
                  context: context,
                  title: "Station Information",
                  icon: Icons.train_rounded,
                  onTap: () {
                    // Implement navigation for Station Information page
                  },
                ),
                const Divider(height: 20),
                _buildMoreServiceItem(
                  context: context,
                  title: "Travel Planner",
                  icon: Icons.map_rounded,
                  onTap: () {
                    // Implement navigation for Travel Planner page
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
  required BuildContext context,
  required String title,
  required dynamic icon,
  required IconType iconType,
  required Color color,
  required VoidCallback onTap,
  }) {
  return GestureDetector(
  onTap: onTap,
  child: Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(20),
  boxShadow: [
  BoxShadow(
  color: Colors.black.withOpacity(0.05),
  spreadRadius: 0,
  blurRadius: 10,
  offset: const Offset(0, 2),
  ),
  ],
  ),
  child: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
  Container(
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
  color: color.withOpacity(0.1),
  borderRadius: BorderRadius.circular(16),
  ),
  child: iconType == IconType.icon
  ? Icon(icon, size: 32, color: color)
      : Image.asset(icon, height: 32, width: 32),
  ),
  const SizedBox(height: 16),
  Text(
  title,
  textAlign: TextAlign.center,
  style: TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: Colors.grey.shade800,
  ),
  ),
  ],
  ),
  ),
  );
  }

  // Helper method for more service items
  Widget _buildMoreServiceItem({
  required BuildContext context,
  required String title,
  required IconData icon,
  required VoidCallback onTap,
  }) {
  return InkWell(
  onTap: onTap,
  borderRadius: BorderRadius.circular(12),
  child: Padding(
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: Row(
  children: [
  Container(
  padding: const EdgeInsets.all(10),
  decoration: BoxDecoration(
  color: Theme.of(context).primaryColor.withOpacity(0.1),
  borderRadius: BorderRadius.circular(12),
  ),
  child: Icon(
  icon,
  size: 24,
  color: Theme.of(context).primaryColor,
  ),
  ),
  const SizedBox(width: 16),
  Expanded(
  child: Text(
  title,
  style: TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: Colors.grey.shade800,
  ),
  ),
  ),
  Icon(
  Icons.arrow_forward_ios_rounded,
  size: 16,
  color: Colors.grey.shade400,
  ),
  ],
  ),
  ),
  );
  }
}