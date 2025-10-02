import 'package:chatdb/Chat/chat_api.dart';
import 'package:chatdb/Chat/message_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Database/databasehelper.dart';
import '../Elements/checkinternet.dart';
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
  final ChatAPI api = ChatAPI();

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

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    print('\n=== SEND MESSAGE ===');
    print('Message: "$message"');
    print('Before - messageCount: ${c.messageCount.value}');
    print('Before - aioruser: ${c.aioruser}');
    print('Before - userMessageIndexesObx: ${c.userMessageIndexesObx}');

    try {
      // Set processing state and clear input
      isProcessing.value = true;
      textEditingController.clear();

      // Add user message
      c.userMessagesObx.add(message);
      if (c.messageCount.value == 1) {
        // Remove placeholder on first message
        print('Removing placeholders');
        c.userMessageIndexesObx.removeAt(0);
        c.userMessagesObx.removeAt(0);
      }

      c.messageCount.value++;
      int userMessageIndex = c.messageCount.value - 1;
      c.userMessageIndexesObx.add(userMessageIndex);
      c.aioruser.add("user");

      print('After user add - messageCount: ${c.messageCount.value}');
      print('After user add - aioruser: ${c.aioruser}');
      print('After user add - userMessageIndex: $userMessageIndex');

      _scrollToBottom();

      // Call API
      String response = "";
      if (c.selectedFilePath.value.isNotEmpty) {
        response = await api.sendMessage(c.selectedFilePath.value, message);
        print('API Response: "$response"');
      } else {
        response = "Please select a sheet first";
      }

      if (response.isEmpty) {
        response = "Cannot process request";
      }

      // Add AI response
      c.aiMessagesFromAPI.add(response);
      c.messageCount.value++;
      c.aioruser.add("ai");

      print('After AI add - messageCount: ${c.messageCount.value}');
      print('After AI add - aioruser: ${c.aioruser}');
      print(
          'After AI add - aiMessagesFromAPI length: ${c.aiMessagesFromAPI.length}');
      print('=== END SEND MESSAGE ===\n');

      _scrollToBottom();
    } catch (e) {
      print('Error sending message: $e');
      // Add error message as AI response
      c.aiMessagesFromAPI.add("Error: ${e.toString()}");
      c.messageCount.value++;
      c.aioruser.add("ai");
    } finally {
      isProcessing.value = false;
    }
  }

  Widget _buildMessage(int index, double availableWidth) {
    print('_buildMessage: index=$index, aioruser.length=${c.aioruser.length}');
    if (index < c.aioruser.length) {
      print('  aioruser[$index]="${c.aioruser[index]}"');
    }

    // First message is always AI greeting
    if (index == 0) {
      return AIMessageWidget(
        availableWidth: availableWidth,
        c: c,
        message: c.aiMessages.elementAt(0),
      );
    }

    // Get message type from aioruser array
    if (index >= c.aioruser.length) {
      print('  Index out of bounds, returning empty');
      return const SizedBox.shrink();
    }

    String messageType = c.aioruser[index];
    print('  messageType="$messageType"');

    if (messageType == "user") {
      // Find user message by index
      if (c.userMessageIndexesObx.contains(index)) {
        int msgIndex = c.userMessageIndexesObx.indexOf(index);
        print(
            '  User message found: msgIndex=$msgIndex, total=${c.userMessagesObx.length}');
        if (msgIndex < c.userMessagesObx.length) {
          return SenderMessageWidget(
            availableWidth: availableWidth,
            c: c,
            message: c.userMessagesObx[msgIndex],
          );
        }
      }
      print('  User message not found for index $index');
    } else if (messageType == "ai") {
      // Count AI messages before this index (excluding initial greeting)
      int aiCount = 0;
      for (int i = 1; i < index; i++) {
        if (i < c.aioruser.length && c.aioruser[i] == "ai") {
          aiCount++;
        }
      }

      print(
          '  AI response: aiCount=$aiCount, total=${c.aiMessagesFromAPI.length}');

      if (aiCount < c.aiMessagesFromAPI.length) {
        return AIMessageWidget(
          availableWidth: availableWidth,
          c: c,
          message: c.aiMessagesFromAPI[aiCount],
        );
      }
      print('  AI response not found for aiCount $aiCount');
    } else {
      print('  Unknown message type: "$messageType"');
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double availableWidth = mediaQueryData.size.width;
    double availableHeight = mediaQueryData.size.height;

    p.checkUserConnection();

    return Container(
      margin: const EdgeInsets.only(right: 16.0, left: 16.0, bottom: 8.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Column(
        children: [
          _buildTopBar(context, availableWidth, availableHeight),
          Expanded(
            flex: 10,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildMessageList(availableWidth),
                  _buildInputArea(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, double width, double height) {
    return Container(
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
                    _showPopup(
                        context, width, height, c.sheetSelected, dbHelper, c);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.5),
                  foregroundColor: Colors.white.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Obx(
                  () => Text(
                    (c.selectedFileName.value.isEmpty ||
                            c.submittedSheet.value.isEmpty)
                        ? 'Select sheet'
                        : c.selectedFileName.value,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 43, 64, 62),
                      fontFamily: 'Ubuntu',
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.only(right: 16.0),
              alignment: Alignment.centerRight,
              child: Obx(
                () => Text(
                  p.activeConnection.value ? 'Connected' : 'Not Connected',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Ubuntu',
                    color: Color(0xffFFCFA3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(double availableWidth) {
    return Obx(
      () => Expanded(
        flex: 7,
        child: c.submittedSheet.value.isNotEmpty
            ? ListView.builder(
                controller: _scrollController,
                itemCount: c.messageCount.value,
                itemBuilder: (context, index) =>
                    _buildMessage(index, availableWidth),
              )
            : Container(
                alignment: Alignment.center,
                child: const Text(
                  'Select a sheet \nto connect to the chat ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromARGB(255, 35, 76, 65),
                    fontFamily: 'Ubuntu',
                    fontSize: 16,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              margin: const EdgeInsets.only(right: 8.0),
              child: Obx(
                () => TextField(
                  controller: textEditingController,
                  enabled: p.activeConnection.value &&
                      c.submittedSheet.value.isNotEmpty &&
                      !isProcessing.value,
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xff034B40)),
                  cursorColor: const Color(0xff034B40),
                  decoration: InputDecoration(
                    hintText: _getHintText(),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.2),
                        width: 0.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.2),
                        width: 0.0,
                      ),
                    ),
                    disabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: Colors.grey, width: 2.0),
                    ),
                    fillColor: _getTextFieldColor(),
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
                onPressed: _canSendMessage()
                    ? () => _sendMessage(textEditingController.text)
                    : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 19.0),
                  backgroundColor: _getSendButtonColor(),
                  disabledBackgroundColor: const Color(0xff034B40),
                ),
                child: isProcessing.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getHintText() {
    if (isProcessing.value) return 'Processing...';
    if (!p.activeConnection.value) return 'Not Connected';
    if (c.submittedSheet.value.isEmpty) return 'Select a sheet first';
    return 'Type a message...';
  }

  Color _getTextFieldColor() {
    if (!p.activeConnection.value || c.submittedSheet.value.isEmpty) {
      return const Color.fromARGB(255, 125, 125, 125).withOpacity(1);
    }
    return isProcessing.value
        ? Colors.grey.withOpacity(0.2)
        : Colors.white.withOpacity(0.5);
  }

  Color _getSendButtonColor() {
    if (!p.activeConnection.value || c.submittedSheet.value.isEmpty) {
      return const Color.fromARGB(255, 119, 119, 119);
    }
    return const Color(0xff034B40);
  }

  bool _canSendMessage() {
    return !isProcessing.value &&
        p.activeConnection.value &&
        c.submittedSheet.value.isNotEmpty;
  }
}

void _showPopup(
    BuildContext context,
    double availableWidth,
    double availableHeight,
    RxInt sheetSelected,
    DatabaseHelper dbHelper,
    Controller c) {
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
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: dbHelper.getContacts(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

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
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  contacts[index]['excelSheetName'],
                                  style: const TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontFamily: 'Ubuntu',
                                    color: Color.fromARGB(255, 255, 218, 184),
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Obx(
                                  () => Radio<int>(
                                    toggleable: true,
                                    fillColor:
                                        MaterialStateProperty.all<Color?>(
                                      const Color.fromARGB(255, 225, 197, 139),
                                    ),
                                    value: index,
                                    groupValue: sheetSelected.value,
                                    onChanged: (int? val) {
                                      if (val == null) {
                                        sheetSelected.value = -1;
                                        c.selectedFilePath.value = "";
                                        c.selectedFileName.value = "";
                                        c.aiMessagesFromAPI.clear();
                                      } else {
                                        c.tempSelectedFilePath.value =
                                            contacts[val]['excelFilePath'];
                                        c.tempSelectedFileName.value =
                                            contacts[val]['excelSheetName'];
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
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.only(top: 8.0, bottom: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 20,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff405C5A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: () {
                            if (c.sheetSelected.value == -1) {
                              c.submittedSheet.value = "";
                              c.selectedFileName.value = "";
                              c.selectedFilePath.value = "";
                            }
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close',
                              style: TextStyle(fontSize: 14)),
                        ),
                      ),
                      const Spacer(flex: 2),
                      Expanded(
                        flex: 20,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff405C5A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: () {
                            if (c.sheetSelected.value == -1) {
                              c.selectedFileName.value = "";
                              c.selectedFilePath.value = "";
                              c.submittedSheet.value = "";
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("No sheet selected")),
                              );
                            } else {
                              c.selectedFilePath.value =
                                  c.tempSelectedFilePath.value;
                              c.selectedFileName.value =
                                  c.tempSelectedFileName.value;

                              // Reset chat
                              c.messageCount.value = 1;
                              c.userMessagesObx.clear();
                              c.userMessagesObx.add("");
                              c.userMessageIndexesObx.clear();
                              c.userMessageIndexesObx.add(1);
                              c.aioruser.clear();
                              c.aioruser.add("");
                              c.aiMessagesFromAPI.clear();

                              c.submittedSheet.value = c.selectedFileName.value;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Sheet selected")),
                              );
                            }
                            Navigator.of(context).pop();
                          },
                          child: const Text('Submit',
                              style: TextStyle(fontSize: 14)),
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
