import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfnd_app/screens/adminSide/userinfo.dart'; // Import the Userprofile screen
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';

class aUsers extends StatefulWidget {
  const aUsers({Key? key}) : super(key: key);

  @override
  State<aUsers> createState() => _aUsersState();
}

class _aUsersState extends State<aUsers> {
  late DateTime _selectedDate;
  bool _showAllUsers = true;
 
  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.bgColor,
        iconTheme: const IconThemeData(
          color: AppColor.hintColor,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const ReusableText(
          title: "Registered Users",
          color: AppColor.blackColor,
          size: 20,
          weight: FontWeight.w500,
        ),
        actions: const [
          SizedBox(width: 20),
        ],
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('RegisterUsers')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var documents = snapshot.data!.docs;

                if (_showAllUsers) {
                  return _buildUserList(documents);
                } else {
                  // Filter documents based on the selected date
                  var filteredDocuments = documents.where((document) {
                    return document['date'].toString().substring(0, 10) ==
                        _selectedDate.toIso8601String().substring(0, 10);
                  }).toList();
                  return _buildUserList(filteredDocuments);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(List<QueryDocumentSnapshot> documents) {
    return ListView.builder(
      itemCount: documents.length,
      itemBuilder: (context, index) {
        var document = documents[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Userprofile(
                  
                  email: document['email'].toString(),
                  image: document['image'].toString(),
                  username: document['name'].toString(),
                  phone: document['completenumber'].toString(), state: document['State'].toString(), location: document['Location'].toString(), Nationality: document['Nationality'].toString(),

                  industeries: document['Countryyy'], countrrr: document['industeries'],
                ),
              ),
            );
          },
          child: Column(
            children: [
              SizedBox(height: 20,),
            ListTile(
  leading: CircleAvatar(
    backgroundImage: (document['image'] != null && document['image']!.isNotEmpty)
        ? NetworkImage(document['image'] as String) as ImageProvider<Object>?
        : const AssetImage("assets/images/tfndlog.jpg"),
    radius: 25,
  ),
  title: Text(
    document['name'],
    style: const TextStyle(
      color: AppColor.blackColor,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
  ),
  subtitle: Padding(
    padding: const EdgeInsets.only(top: 5),
    child: Row(
      children: [
        Expanded(
          child: Text(
            document['email'],
            style: const TextStyle(
              color: AppColor.darkTextColor,
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8), // Adjust the width as needed for the space
        Text(
          '${document['time']} || ${document['date']}',
          style: const TextStyle(
            color: AppColor.blackColor,
            fontSize: 8,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  ),
),


              const Divider(
                color: AppColor.hintColor,
                thickness: 0.5,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
       
        SizedBox(
          width: 300,
          child: ElevatedButton(
          
            style: ButtonStyle(
              shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      20), // Adjust the radius as needed
                  side: const BorderSide(
                      color: AppColor
                          .btnColor), // Adjust the color as needed
                ),
              ),
            ),
            onPressed: () {
              _selectDate(context);
            },
            child: const  Text('Search By Date',style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        
        initialDate: _selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime.now());
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
        _showAllUsers = false;
      });
  }

  String _getMonthName(int month) {
    return DateTime(0, month).toString().split(' ')[0];
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
}
