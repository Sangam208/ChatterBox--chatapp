import 'package:chatterbox/colors.dart';
import 'package:chatterbox/components/my_toast.dart';
import 'package:chatterbox/models/error_model.dart';
import 'package:chatterbox/models/message_model.dart';
import 'package:chatterbox/models/user_model.dart';
import 'package:chatterbox/preferences/theme_preference.dart';
import 'package:chatterbox/providers/selected_user_provider.dart';
import 'package:chatterbox/repository/auth_repository.dart';
import 'package:chatterbox/repository/socket_repository.dart';
import 'package:chatterbox/services/chat_services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String senderID;
  final String receiverID;
  const ChatScreen({
    super.key,
    required this.senderID,
    required this.receiverID,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  String message = '';
  ErrorModel? errorModel;
  bool _isButtonEnabled = false;
  late final UserModel? receiver;
  Future<void>? _future;

  late SocketRepository _socketRepository;

  @override
  void initState() {
    super.initState();
    _socketRepository = SocketRepository();
    _messageController.addListener(_updateButtonState);
    receiver = ref.read(selectedUserProvider);
    _future = getMessages();

    // join room
    _socketRepository.joinRoom(ref.read(userProvider)!.uid, receiver!.uid);

    _socketRepository.userJoinedListener((message) {
      debugPrint(message['message']);
    });

    // listen for new messages from the socket
    _socketRepository.messageListener((message) {
      final newMessage = MessageModel.fromMap(message);
      ref
          .read(messagesListProvider.notifier)
          .update((state) => [newMessage, ...state]);
    });
  }

  @override
  void dispose() {
    _messageController.removeListener(_updateButtonState);
    _messageController.dispose();
    _socketRepository.removeListener();
    _socketRepository.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Row(
          spacing: 4,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20.0,
              backgroundImage: AssetImage('assets/images/default_avatar.png'),
            ),
            Expanded(
              child: Text(
                receiver!.name,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () => myToast(), icon: const Icon(Icons.call)),
          IconButton(
            onPressed: () => myToast(),
            icon: const Icon(FontAwesomeIcons.video),
          ),
          IconButton(onPressed: () => myToast(), icon: const Icon(Icons.info)),
        ],
        actionsPadding: const EdgeInsets.only(right: 15),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return _buildMessageList();
                },
              ),
            ),
            _buildUserInput(),
          ],
        ),
      ),
    );
  }

  void saveMessage(String message) async {
    final senderId = ref.read(userProvider)!.uid;

    // Save message to DB
    errorModel = await ref
        .read(chatServicesProvider)
        .saveMessage(
          token: ref.read(userProvider)!.token,
          ref: ref,
          senderId: senderId,
          receiverId: receiver!.uid,
          message: message,
        );

    if (errorModel == null || errorModel!.data == null) {
      Fluttertoast.showToast(msg: '${errorModel!.error}');
    }

    // Send message via Socket
    _socketRepository.sendMessage(message, senderId, receiver!.uid);
  }

  Future<void> getMessages() async {
    errorModel = await ref
        .read(chatServicesProvider)
        .getMessages(
          ref.read(userProvider)!.token,
          ref.read(userProvider)!.uid,
          receiver!.uid,
        );
    if (errorModel != null && errorModel!.data != null) {
      ref
          .read(messagesListProvider.notifier)
          .update((state) => errorModel!.data);
    }
  }

  Widget _buildMessageList() {
    final messages = ref.watch(messagesListProvider);
    return messages.isEmpty
        ? const Center(child: Text("No messages yet"))
        : ListView.builder(
          padding: EdgeInsets.only(bottom: 8.0),
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(messages, index);
          },
        );
  }

  Widget _buildMessageItem(List<MessageModel> messages, int index) {
    final message = messages[index];
    final isSender = message.senderId == ref.read(userProvider)!.uid;
    return Align(
      alignment: isSender ? Alignment.bottomRight : Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
        child: GestureDetector(
          onLongPress:
              () => showModalBottomSheet(
                constraints: BoxConstraints(
                  maxWidth: double.infinity,
                  maxHeight: 70,
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                context: context,
                builder:
                    (context) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: message.message),
                              );
                              Navigator.pop(context);
                              Fluttertoast.showToast(
                                msg: 'Copied To Clipboard',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                              );
                            },
                            icon: Icon(Icons.copy, size: 32),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: Visibility(
                                visible: isSender,
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(Icons.delete, size: 32),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.cancel, size: 32),
                          ),
                        ],
                      ),
                    ),
              ),
          child: Container(
            padding: EdgeInsets.all(10),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color:
                  isSender ? kSenderChatBubbleColor : kReceiverChatBubbleColor,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Text(
              message.message,
              style: TextStyle(color: kWhiteColor, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _messageController.text.trim().isNotEmpty;
    });
  }

  Widget _buildUserInput() {
    final theme = ref.watch(themeProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => myToast(),
            icon: Icon(FontAwesomeIcons.camera),
          ),
          IconButton(onPressed: () => myToast(), icon: Icon(Icons.upload_file)),
          IconButton(
            onPressed: () => myToast(),
            icon: Icon(FontAwesomeIcons.microphone),
          ),
          Expanded(
            child: TextField(
              cursorColor: theme ? kWhiteColor : null,
              onSubmitted: (value) {
                if (_isButtonEnabled) {
                  saveMessage(value);
                  _messageController.clear();
                }
              },
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Message",
                hintStyle: TextStyle(
                  color: !theme ? kGreyColor : kWhiteColorLight,
                  fontSize: 18,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: !theme ? Colors.grey[200] : Colors.grey[600],
                hoverColor: !theme ? Colors.grey[200] : Colors.grey[600],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              style: TextStyle(
                color: !theme ? kBlackColor : kWhiteColor,
                fontSize: 18,
              ),
            ),
          ),
          IconButton(
            onPressed:
                _isButtonEnabled
                    ? () {
                      saveMessage(_messageController.text.trim());
                      _messageController.clear();
                    }
                    : null,
            icon: Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
