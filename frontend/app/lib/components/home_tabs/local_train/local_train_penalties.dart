import 'package:flutter/material.dart';

class LocalTrainPenalties extends StatefulWidget {
  const LocalTrainPenalties({super.key});

  @override
  State<LocalTrainPenalties> createState() => _LocalTrainPenaltiesState();
}

class _LocalTrainPenaltiesState extends State<LocalTrainPenalties> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(
          color: Colors.black,
        ),
        title:const Text("Local Penalties",
          style: TextStyle(color: Colors.orange),
        )
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black, // Border color
                width: 1.0, // Border width
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Travelling Fraudulently",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text("Sec. 137 Railway Act"),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text("Penalty")
                        ),
                        Expanded(child: Text("6 month jail, fine Rs 1,000/- or both.", maxLines: 10)),
                      ]
                  ),
                ),
                ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black, // Border color
                width: 1.0, // Border width
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Tavelling without proper pass/ticket",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text("Sec. 138 Railway Act"),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:[
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          margin: EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text("Penalty")
                      ),
                      Expanded(child: Text("Ticket fare + excess charge i.e 250/- or equivalent to fare whichever is more", maxLines: 10)),
                    ]
                  ),
                ),
                Text("Ordinary single fare for the distance which he has travelled or from the station from which the train started and excess charge i.e 250/- or equivalent to the fare whichever is more."),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black, // Border color
                width: 1.0, // Border width
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Alarm Chain Pulling",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text("Sec. 141 Railway Act"),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text("Penalty")
                        ),
                        Expanded(child: Text("12 months jail, fine Rs 1,000 or both.", maxLines: 10)),
                      ]
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black, // Border color
                width: 1.0, // Border width
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Touting",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text("Sec. 143 Railway Act"),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text("Penalty")
                        ),
                        Expanded(child: Text("3 years jail, fine Rs 10,000 or both.", maxLines: 10)),
                      ]
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black, // Border color
                width: 1.0, // Border width
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Unauthorised Hawking",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text("Sec. 144 Railway Act"),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text("Penalty")
                        ),
                        Expanded(child: Text("1 year jail, fine min. Rs 1,000/- to max. Rs 2,000/- or both.", maxLines: 10)),
                      ]
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black, // Border color
                width: 1.0, // Border width
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Nuisance and Littering",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text("Sec. 145 (b) Railway Act"),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text("Penalty")
                        ),
                        Expanded(child: Text("6 months jail, fine Rs 1,000/- or both.", maxLines: 10)),
                      ]
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black, // Border color
                width: 1.0, // Border width
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Trespassing",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text("Sec. 147 Railway Act"),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text("Penalty")
                        ),
                        Expanded(child: Text("6 months jail, fine Rs 1,000 or both.", maxLines: 10)),
                      ]
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black, // Border color
                width: 1.0, // Border width
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Travelling in Coach Reserved for Handicapped Passengers",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text("Sec. 155 (a) Railway Act"),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text("Penalty")
                        ),
                        Expanded(child: Text("3 months jail, fine Rs 500 or both.", maxLines: 10)),
                      ]
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black, // Border color
                width: 1.0, // Border width
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Travelling on Roof Top",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text("Sec. 156 Railway Act"),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text("Penalty")
                        ),
                        Expanded(child: Text("3 months jail, fine Rs 500 or both.", maxLines: 10)),
                      ]
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black, // Border color
                width: 1.0, // Border width
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Travelling in Coach Reserved for Ladies Passengers",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text("Sec. 162 "),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text("Penalty")
                        ),
                        Expanded(child: Text("Fine upto Rs. 500, ticket will be forfeited and passenger be removed from the compartment.", maxLines: 10)),
                      ]
                  ),
                ),
                Text("If any  male passenger is detected travelling in coaches reserved exclusively for Ladies")
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black, // Border color
                width: 1.0, // Border width
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Dangerous Explosive Goods",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text("Sec. 164"),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text("Penalty")
                        ),
                        Expanded(child: Text("Imprisonment upto 3 years or fine upto Rs. 1000/- or both.", maxLines: 10)),
                      ]
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black, // Border color
                width: 1.0, // Border width
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Bill Pasting",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text("Sec. 166 (b) Railway Act"),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text("Penalty")
                        ),
                        Expanded(child: Text("6 months jail, fine Rs 500 or both.", maxLines: 10)),
                      ]
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

    );
  }
}
