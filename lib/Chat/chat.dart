import 'package:chatdb/Chat/message_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Database/databasehelper.dart';
import '../Elements/checkinternet.dart';
// import 'chat_api.dart';
import 'controller.dart';

class ChatFragment extends StatefulWidget {
  const ChatFragment({super.key});

  @override
  ChatFragmentState createState() => ChatFragmentState();
}

class ChatFragmentState extends State<ChatFragment> {
  final Controller c = Get.put(Controller());
  final CheckInternet p = Get.put(CheckInternet());
  final TextEditingController textEditingController = TextEditingController();
  final dbHelper = DatabaseHelper();

  final ScrollController _scrollController = ScrollController();

  // ChatAPI api = ChatAPI();

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    // ignore: unused_local_variable
    double availableWidth = mediaQueryData.size.width;
    // ignore: unused_local_variable
    double availableHeight = mediaQueryData.size.height;

    p.checkUserConnection();

    return Container(
      margin: const EdgeInsets.only(right: 16.0, left: 16.0, bottom: 8.0),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            height: 50,
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (p.activeConnection.value) {
                            _showPopup(context, availableWidth, availableHeight,
                                c.sheetSelected, dbHelper, c);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.5),
                            foregroundColor: Colors.white.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0))),
                        child: Obx(
                          () => Text(
                            (c.selectedFileName.value == "" ||
                                    c.submittedSheet.value == "")
                                ? 'Select sheet'
                                : c.selectedFileName.value,
                            maxLines: 1,
                            style: const TextStyle(
                                color: Color.fromARGB(255, 43, 64, 62),
                                fontFamily: 'Ubuntu'),
                          ),
                        ),
                      ),
                    )),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.only(right: 16.0),
                    alignment: Alignment.centerRight,
                    child: Obx(
                      () => Text(
                        p.activeConnection.value
                            ? 'Connected'
                            : 'Not Connected',
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Ubuntu',
                            color: Color(0xffFFCFA3)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 10,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8.0)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Obx(
                      () => Expanded(
                        flex: 7,
                        child: c.submittedSheet.value != ""
                            ? Container(
                                alignment: Alignment.topCenter,
                                child: ListView.builder(
                                    controller: _scrollController,
                                    scrollDirection: Axis.vertical,
                                    itemCount: c.messageCount.value,
                                    itemBuilder: (context, index) {
                                      if (index == 0) {
                                        if (!c.aioruser.contains("ai")) {
                                          c.aioruser.add("ai");
                                        }
                                        return AIMessageWidget(
                                          availableWidth: availableWidth,
                                          c: c,
                                          message: c.aiMessages.elementAt(0),
                                        );
                                      } else if (index != 0 &&
                                          index != 1 &&
                                          c.aioruser.elementAt(index - 1) ==
                                              "ai") {
                                        return AIMessageWidget(
                                          availableWidth: availableWidth,
                                          c: c,
                                          message: c.aiMessagesFromAPI
                                              .elementAt(index ~/ 2),
                                        );
                                      } else if (index != 0 &&
                                          index != 1 &&
                                          c.aioruser.elementAt(index - 1) ==
                                              "user") {
                                        if (c.userMessageIndexesObx
                                            .contains(index)) {
                                          return SenderMessageWidget(
                                              availableWidth: availableWidth,
                                              c: c,
                                              message: c.userMessagesObx
                                                  .elementAt(c
                                                      .userMessageIndexesObx
                                                      .indexOf(index)));
                                        }
                                      } else {
                                        if (!c.aioruser.contains("user")) {
                                          c.aioruser.add("user");
                                        }

                                        if (c.userMessageIndexesObx
                                            .contains(index)) {
                                          return SenderMessageWidget(
                                              availableWidth: availableWidth,
                                              c: c,
                                              message: c.userMessagesObx
                                                  .elementAt(c
                                                      .userMessageIndexesObx
                                                      .indexOf(index)));
                                        }
                                      }
                                      return null;
                                    }),
                              )
                            : Container(
                                alignment: Alignment.center,
                                child: const Text(
                                  'Select a sheet \nto connect to the chat ',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 35, 76, 65),
                                      fontFamily: 'Ubuntu',
                                      fontSize: 16),
                                ),
                              ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 10.0),
                      child: Row(children: [
                        Expanded(
                          flex: 6,
                          child: Container(
                            margin: const EdgeInsets.only(right: 8.0),
                            alignment: Alignment.center,
                            child: Obx(
                              () => TextField(
                                controller: textEditingController,
                                style: const TextStyle(
                                    fontSize: 14, color: Color(0xff034B40)),
                                cursorColor: const Color(0xff034B40),
                                decoration: InputDecoration(
                                  hintText: c.userMessage.value
                                      ? ''
                                      : (p.activeConnection.value
                                          ? 'Please wait...'
                                          : 'Not Connected'),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8.0)),
                                    borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 0.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8.0)),
                                    borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 0.0),
                                  ),
                                  disabledBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 2.0),
                                  ),
                                  fillColor: p.activeConnection.value
                                      ? (c.submittedSheet.value != ""
                                          ? (c.userMessage.value
                                              ? Colors.white.withOpacity(0.5)
                                              : Colors.grey.withOpacity(0.2))
                                          : const Color.fromARGB(
                                                  255, 125, 125, 125)
                                              .withOpacity(1))
                                      : const Color.fromARGB(255, 125, 125, 125)
                                          .withOpacity(1),
                                  filled: true,
                                  enabled: p.activeConnection.value
                                      ? (c.submittedSheet.value != ""
                                          ? c.userMessage.value
                                          : false)
                                      : false,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Obx(
                            () => ElevatedButton(
                              onPressed: () async {
                                await p.checkUserConnection();
                                if (p.activeConnection.value) {
                                  if (c.userMessage.value == false) {
                                    c.userMessage.value = true;
                                  }
                                  String message = textEditingController.text;
                                  if (message.isNotEmpty) {
                                    String res = "";
                                    // String jsonStr =
                                    //     await api.postData(message);
                                    // res = api.processData(jsonStr);

                                    if (res == "") {
                                      res = "Cannot process request";
                                    }

                                    c.aiMessagesFromAPI.add(res);

                                    c.userMessagesObx.add(message);
                                    if (c.messageCount.value == 1) {
                                      c.userMessageIndexesObx.removeAt(0);
                                      c.userMessagesObx.removeAt(0);
                                    }
                                    c.messageCount.value += 1;
                                    c.userMessageIndexesObx
                                        .add(c.messageCount.value - 1);
                                    textEditingController.clear();
                                    c.userMessage.value = false;
                                    c.processUsertoAI(message);
                                    c.aioruser.add("user");
                                  }
                                } else {
                                  c.userMessage.value = false;
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 19.0),
                                backgroundColor: p.activeConnection.value
                                    ? (c.submittedSheet.value != ""
                                        ? const Color(0xff034B40)
                                        : const Color.fromARGB(
                                            255, 119, 119, 119))
                                    : const Color.fromARGB(255, 119, 119, 119),
                              ),
                              child: const Icon(
                                Icons.send,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ]),
                    ),
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}

void _showPopup(BuildContext context, var availableWidth, var availableHeight,
    RxInt sheetSelected, DatabaseHelper dbHelper, Controller c) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        backgroundColor: const Color(0xffD9D9D9),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        content: Container(
          width: availableWidth,
          alignment: Alignment.center,
          height: availableHeight / 4,
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  alignment: Alignment.center,
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: dbHelper.getContacts(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container();
                        } else {
                          List<Map<String, dynamic>> contacts = snapshot.data!;
                          return ListView.builder(
                            itemCount: contacts.length,
                            itemBuilder: (context, index) {
                              return Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(bottom: 8.0),
                                padding: const EdgeInsets.only(left: 16.0),
                                decoration: BoxDecoration(
                                    color: const Color(0xff034B40),
                                    borderRadius: BorderRadius.circular(12.0)),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        contacts[index]['excelSheetName'],
                                        style: const TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontFamily: 'Ubuntu',
                                            color: Color.fromARGB(
                                                255, 255, 218, 184),
                                            fontSize: 14.0),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Obx(
                                        () => Radio<int>(
                                          toggleable: true,
                                          fillColor:
                                              MaterialStateProperty.all<Color?>(
                                                  const Color.fromARGB(
                                                      255, 225, 197, 139)),
                                          value: index,
                                          groupValue: sheetSelected.value,
                                          onChanged: (int? val) {
                                            if (val == null) {
                                              sheetSelected.value = -1;
                                              c.selectedFilePath.value = "";
                                              c.selectedFileName.value = "";
                                              c.aiMessagesFromAPI.clear();
                                            } else {
                                              int num = val;

                                              c.tempSelectedFilePath.value =
                                                  contacts[num]
                                                      ['excelFilePath'];
                                              c.tempSelectedFileName.value =
                                                  contacts[num]
                                                      ['excelSheetName'];

                                              sheetSelected.value = val;
                                            }
                                          },
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          );
                        }
                      }),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.only(top: 8.0, bottom: 2.0),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 20,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff405C5A),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0))),
                            onPressed: () {
                              if (c.sheetSelected.value == -1) {
                                c.submittedSheet.value = "";
                                c.selectedFileName.value = "";
                                c.selectedFilePath.value = "";
                              }
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Close',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(
                        flex: 2,
                      ),
                      Expanded(
                        flex: 20,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff405C5A),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0))),
                            onPressed: () {
                              if (c.sheetSelected.value == -1) {
                                c.selectedFileName.value = "";
                                c.selectedFilePath.value = "";
                                c.submittedSheet.value = "";
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("No sheet selected"),
                                ));

                                Navigator.of(context).pop();
                              } else {
                                c.selectedFilePath.value =
                                    c.tempSelectedFilePath.value;
                                c.selectedFileName.value =
                                    c.tempSelectedFileName.value;

                                c.messageCount.value = 1;
                                c.userMessagesObx.clear();
                                c.userMessagesObx.add("");
                                c.userMessageIndexesObx.clear();
                                c.userMessageIndexesObx.add(1);
                                c.aioruser.clear();
                                c.aioruser.add("");
                                c.aiMessagesFromAPI.clear();
                                c.aiMessagesFromAPI.add("");

                                c.submittedSheet.value =
                                    c.selectedFileName.value;
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("Sheet selected"),
                                ));
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text('Submit',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
