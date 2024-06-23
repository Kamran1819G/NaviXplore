import 'package:flutter/material.dart';
import 'package:navixplore/widgets/penalties_card.dart';

class NM_MetroPenalties extends StatefulWidget {
  const NM_MetroPenalties({super.key});

  @override
  State<NM_MetroPenalties> createState() => _NM_MetroPenaltiesState();
}

class _NM_MetroPenaltiesState extends State<NM_MetroPenalties> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: const BackButton(
            color: Colors.black,
          ),
          title: const Text(
            "Metro Offences & Penalties",
            style: TextStyle(color: Colors.orange),
          )),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "As per the Metro Railway (Operation and Maintenance) Act, 2002, the following acts are punishable offences and attract penalties as mentioned below.",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                PenaltieCard(
                    title: "Drunkenness or Nuisance on the Metro railway",
                    section: "59",
                    penalty: "Rs. 500 fine and Forfeiture of fare paid / removal from carriage"),
                PenaltieCard(
                  title: "Spitting",
                  section: "59",
                  penalty: "Rs. 500 fine and Forfeiture of fare paid / removal from carriage",
                ),
                PenaltieCard(
                  title: "Taking or causing to take offensive material on the Metro railway",
                  section: "60",
                  penalty: "Rs. 500 fine in addition to damages",
                ),
                PenaltieCard(
                  title: "Taking or causing to take dangerous material on the Metro railway",
                  section: "61",
                  penalty: "Rs. 5000 fine and imprisonment up to 4 years",
                ),
                PenaltieCard(
                  title: "Prohibition of demonstrations upon metro railway",
                  section: "62",
                  penalty: "Exclusion from the Metro premises and Rs. 1000 fine or imprisonment up to 6 months or both",
                ),
                PenaltieCard(
                  title: "Travelling on the roof of the Metro, etc.",
                  section: "63",
                  penalty: "Rs. 50 fine or imprisonment up to 1 month or both",
                ),
                PenaltieCard(
                  title: "Unlawfully entering or remaining upon metro railway",
                  section: "64",
                  penalty: "Imprisonment up to 3 months or Fine up to Rs.250 or with both",
                ),
                PenaltieCard(
                  title: "Walking on metro track without lawful authority",
                  section: "64",
                  penalty: "Imprisonment up to 6 months or Fine up to Rs.500 or with both",
                ),
                PenaltieCard(
                  title: "Obstructing running of train, etc.",
                  section: "67",
                  penalty: "Rs. 5000 fine or imprisonment up to 4 years or both",
                ),
                PenaltieCard(
                  title: "Obstructing Metro railway official in discharging his/her duties",
                  section: "68",
                  penalty: "Rs. 1000 fine or imprisonment up to 1 year or both",
                ),
                PenaltieCard(
                  title: "Travelling without a proper pass or ticket or beyond authorized distance",
                  section: "69",
                  penalty: "Rs. 50 fine and amount of fare",
                ),
                PenaltieCard(
                  title: "Needlessly interfering with means of communication in a train.",
                  section: "70",
                  penalty: "Rs. 1000 fine or imprisonment up to 1 year or both",
                ),
                PenaltieCard(
                  title: "Altering or defacing or counterfeiting pass or ticket",
                  section: "71",
                  penalty: "Imprisonment up to 6 months",
                ),
                PenaltieCard(
                  title: "Defacing public notices",
                  section: "72",
                  penalty: "Rs. 250 fine and imprisonment up to 2 months",
                ),
                PenaltieCard(
                  title: "Unauthorized sale of articles on the Metro railway",
                  section: "73",
                  penalty: "Rs. 500 fine and in default of payment of fine, imprisonment up to 6 months",
                ),
                PenaltieCard(
                  title: "Maliciously wrecking a train or causing sabotage",
                  section: "74",
                  penalty: "Imprisonment for life or rigorous imprisonment up to 10 years or punishable with death, as the case may be",
                ),
                PenaltieCard(
                  title: "Unauthorized sale of tickets",
                  section: "75",
                  penalty: "Rs. 500 fine or imprisonment up to 3 months or both and forfeiture of such tickets",
                ),
                PenaltieCard(
                  title: "Maliciously hurting or attempting to hurt other persons traveling by Metro railway",
                  section: "76",
                  penalty: "Imprisonment for life or imprisonment up to 10 years, as the case may be",
                ),
                PenaltieCard(
                  title: "Endangering safety of persons traveling by Metro railway by rash or negligent act or omission",
                  section: "77",
                  penalty: "Imprisonment up to 1 year or fine or both",
                ),
                PenaltieCard(
                  title: "Damage to or destruction of certain Metro railway properties",
                  section: "78",
                  penalty: "Imprisonment up to 10 years",
                ),
                PenaltieCard(
                  title: "Endangering safety of persons traveling by Metro railway by willful act or omission",
                  section: "79",
                  penalty: "Imprisonment up to 7 years",
                ),
                PenaltieCard(
                  title: "Making false claim for compensation",
                  section: "80",
                  penalty: "Imprisonment up to 3 years or fine or both",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
