import 'package:chatdb/Chat/chat_api.dart';
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
  final RxBool isProcessing = false.obs;

  ChatAPI api = ChatAPI();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

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
                                      print('Building item at index: $index');
                                      print(
                                          'aioruser length: ${c.aioruser.length}');
                                      print(
                                          'messageCount: ${c.messageCount.value}');

                                      // First message is always the initial AI greeting
                                      if (index == 0) {
                                        print('Rendering initial AI message');
                                        return AIMessageWidget(
                                          availableWidth: availableWidth,
                                          c: c,
                                          message: c.aiMessages.elementAt(0),
                                        );
                                      }

                                      // For all other messages, check if it's a user or AI message
                                      // aioruser index matches message index
                                      if (index < c.aioruser.length) {
                                        String messageType = c.aioruser[index];
                                        print(
                                            'Message type at index $index: $messageType');

                                        if (messageType == "user") {
                                          // Find this message in userMessagesObx
                                          if (c.userMessageIndexesObx
                                              .contains(index)) {
                                            int msgIndex = c
                                                .userMessageIndexesObx
                                                .indexOf(index);
                                            print(
                                                'Rendering user message: msgIndex=$msgIndex');

                                            if (msgIndex <
                                                c.userMessagesObx.length) {
                                              return SenderMessageWidget(
                                                availableWidth: availableWidth,
                                                c: c,
                                                message: c.userMessagesObx
                                                    .elementAt(msgIndex),
                                              );
                                            }
                                          }
                                          print(
                                              'User message not found for index $index');
                                        } else if (messageType == "ai") {
                                          // AI messages from API (not the initial one)
                                          // Calculate which AI response this is (0-indexed)
                                          int aiResponseIndex = 0;
                                          for (int i = 1; i < index; i++) {
                                            if (i < c.aioruser.length &&
                                                c.aioruser[i] == "ai") {
                                              aiResponseIndex++;
                                            }
                                          }

                                          print(
                                              'Rendering AI response: aiResponseIndex=$aiResponseIndex');

                                          if (aiResponseIndex <
                                              c.aiMessagesFromAPI.length) {
                                            return AIMessageWidget(
                                              availableWidth: availableWidth,
                                              c: c,
                                              message: c.aiMessagesFromAPI
                                                  .elementAt(aiResponseIndex),
                                            );
                                          }
                                          print(
                                              'AI response not found for index $aiResponseIndex');
                                        }
                                      }

                                      print(
                                          'Returning empty widget for index $index');
                                      return const SizedBox.shrink();
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
                                enabled: p.activeConnection.value &&
                                    c.submittedSheet.value != "" &&
                                    !isProcessing.value,
                                style: const TextStyle(
                                    fontSize: 14, color: Color(0xff034B40)),
                                cursorColor: const Color(0xff034B40),
                                decoration: InputDecoration(
                                  hintText: isProcessing.value
                                      ? 'Processing...'
                                      : (p.activeConnection.value
                                          ? (c.submittedSheet.value != ""
                                              ? 'Type a message...'
                                              : 'Select a sheet first')
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
                                          ? (isProcessing.value
                                              ? Colors.grey.withOpacity(0.2)
                                              : Colors.white.withOpacity(0.5))
                                          : const Color.fromARGB(
                                                  255, 125, 125, 125)
                                              .withOpacity(1))
                                      : const Color.fromARGB(255, 125, 125, 125)
                                          .withOpacity(1),
                                  filled: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Obx(
                            () => ElevatedButton(
                              onPressed: isProcessing.value
                                  ? null
                                  : () async {
                                      print('=== SEND BUTTON PRESSED ===');
                                      await p.checkUserConnection();
                                      print(
                                          'Connection status: ${p.activeConnection.value}');
                                      print(
                                          'Sheet selected: ${c.submittedSheet.value}');

                                      if (p.activeConnection.value &&
                                          c.submittedSheet.value != "") {
                                        String message =
                                            textEditingController.text.trim();
                                        print('User message: "$message"');

                                        if (message.isNotEmpty) {
                                          // Set processing state
                                          print('Setting isProcessing to true');
                                          isProcessing.value = true;
                                          textEditingController.clear();

                                          // Add user message immediately
                                          print('Adding user message to lists');
                                          c.userMessagesObx.add(message);
                                          print(
                                              'userMessagesObx length: ${c.userMessagesObx.length}');

                                          if (c.messageCount.value == 1) {
                                            print(
                                                'First message - removing placeholder');
                                            c.userMessageIndexesObx.removeAt(0);
                                            c.userMessagesObx.removeAt(0);
                                          }

                                          c.messageCount.value += 1;
                                          print(
                                              'Message count: ${c.messageCount.value}');

                                          // Add the CURRENT message index (which is messageCount - 1)
                                          int currentUserMessageIndex =
                                              c.messageCount.value - 1;
                                          c.userMessageIndexesObx
                                              .add(currentUserMessageIndex);
                                          print(
                                              'Added user message at index: $currentUserMessageIndex');
                                          print(
                                              'userMessageIndexesObx: ${c.userMessageIndexesObx}');

                                          c.aioruser.add("user");
                                          print('aioruser: ${c.aioruser}');

                                          // Scroll to show user message
                                          _scrollToBottom();

                                          String res = "";
                                          print(
                                              'Selected file path: ${c.selectedFilePath.value}');

                                          // Check if file path is selected
                                          if (c.selectedFilePath.value
                                              .isNotEmpty) {
                                            try {
                                              print('Calling API...');
                                              // Call the API with file path and prompt
                                              res = await api.sendMessage(
                                                  c.selectedFilePath.value,
                                                  message);
                                              print('API Response: $res');
                                            } catch (e) {
                                              print('API Error: $e');
                                              res = "Error: ${e.toString()}";
                                            }
                                          } else {
                                            print('No file path selected');
                                            res = "Please select a sheet first";
                                          }

                                          if (res == "") {
                                            print(
                                                'Empty response, setting default error');
                                            res = "Cannot process request";
                                          }

                                          // Add AI response
                                          print('Adding AI response: $res');
                                          c.aiMessagesFromAPI.add(res);
                                          print(
                                              'aiMessagesFromAPI length: ${c.aiMessagesFromAPI.length}');

                                          c.messageCount.value += 1;
                                          print(
                                              'Message count after AI: ${c.messageCount.value}');

                                          c.aioruser.add("ai");
                                          print(
                                              'aioruser after AI: ${c.aioruser}');

                                          // Reset processing state
                                          print(
                                              'Setting isProcessing to false');
                                          isProcessing.value = false;

                                          // Scroll to show AI response
                                          _scrollToBottom();
                                          print('=== SEND COMPLETED ===\n');
                                        } else {
                                          print(
                                              'Message is empty, not sending');
                                        }
                                      } else {
                                        print(
                                            'Conditions not met - not sending');
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
                                disabledBackgroundColor:
                                    const Color(0xff034B40),
                              ),
                              child: isProcessing.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Icon(
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
