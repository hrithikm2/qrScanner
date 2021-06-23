import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qrscanner/Contact.dart';
import 'package:qrscanner/Network/ContactData.dart';
import 'package:velocity_x/velocity_x.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(primaryColor: Colors.deepPurple),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<Contacts> future;
  CameraController? controller;

  @override
  void initState() {
    super.initState();
    future = fetchImageData();
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
    });
    getPermissions();
  }

  getPermissions() async {
    if (await Permission.contacts.request().isGranted) {
      getAllContacts();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceRatio =
        MediaQuery.of(context).size.width / MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.arrow_left,
            color: Colors.black,
          ),
          onPressed: () {
            SystemNavigator.pop();
          },
        ),
        centerTitle: true,
        title: Text('Savings',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      ),
      body: Stack(
        children: <Widget>[
          Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: (!controller!.value.isInitialized)
                  ? Container(color: Colors.grey)
                  : Stack(children: [
                      AspectRatio(
                        aspectRatio: deviceRatio + 0.07,
                        child: CameraPreview(controller!),
                      ),
                      Center(
                          child: Container(
                        height: MediaQuery.of(context).size.height * 0.2,
                        width: MediaQuery.of(context).size.height * 0.2,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 4)),
                      ))
                    ])),
          Container(
            height: MediaQuery.of(context).size.height * 0.16,
            color: Colors.white,
            child: Column(
              children: [
                HeightBox(MediaQuery.of(context).size.height * 0.025),
                Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.025),
                    child: Text("Pay through UPI",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 22))),
                HeightBox(MediaQuery.of(context).size.height * 0.025),
                Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.05,
                      right: MediaQuery.of(context).size.width * 0.05),
                  child: TextField(
                    onTap: () {
                      setState(() {
                        enableBottomSheet();
                      });
                    },
                    readOnly: true,
                    showCursor: true,
                    decoration: InputDecoration(
                      hintText: 'Enter UPI Number',
                      hintStyle: TextStyle(color: Colors.black26),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepPurple),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepPurple),
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepPurple),
                      ),
                    ),
                  ),
                ),
                HeightBox(MediaQuery.of(context).size.height * 0.025),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void enableBottomSheet() {
    showModalBottomSheet(
      enableDrag: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            HeightBox(MediaQuery.of(context).size.height * 0.0125),
            Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.025),
                child: Text("Search Contact",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 22))),
            HeightBox(MediaQuery.of(context).size.height * 0.0125),
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                ),
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(Icons.assignment_outlined,
                          color: Colors.deepPurple),
                      onPressed: () {
                        // setState(() {
                        //   Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //           builder: (context) =>
                        //               //ContactList()
                        //       ));
                        // });
                      },
                    ),
                    hintText: 'Select Number',
                    hintStyle: TextStyle(color: Colors.black26),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepPurple),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepPurple),
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepPurple),
                    ),
                  ),
                ),
              ),
            ),
            HeightBox(MediaQuery.of(context).size.height * 0.0125),
            FutureBuilder<Contacts>(
              future: fetchImageData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: ListTile(
                          title: Text('John Doe'),
                          subtitle: Text('lorem ipsum'),
                          leading: ClipOval(
                              child: (snapshot.data!.imageUrl != null)
                                  ? Image.network(snapshot.data!.imageUrl!)
                                  : Flexible(
                                      child: Center(
                                          child: CircularProgressIndicator(
                                        color: Colors.deepPurple,
                                        strokeWidth: 0.5,
                                      )),
                                    ))));
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                // By default, show a loading spinner.
                return CircularProgressIndicator();
              },
            ),
            HeightBox(MediaQuery.of(context).size.height * 0.0125),
          ],
        );
      },
    );
  }
}

// class ContactList extends StatefulWidget {
//   const ContactList({Key? key}) : super(key: key);
//
//   @override
//   _ContactListState createState() => _ContactListState();
// }

// class _ContactListState extends State<ContactList> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: ListView.builder(
//           itemCount: contacts.length,
//           itemBuilder: (context, index) {
//         return (contacts.length >0)
//             ? ListTile(
//                 title: (contacts[index].phones!.elementAt(0).value != null)
//                     ? Text(contacts[index].displayName!)
//                     : Text('Empty Contact'),
//                 subtitle: (contacts[index].phones!.elementAt(0).value != null)
//                     ? Text(contacts[index].phones!.elementAt(0).value!)
//                     : Text('Empty Contact'),
//               )
//             : Center(child: CircularProgressIndicator());
//       }),
//     );
//   }
// }
