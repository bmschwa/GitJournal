import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fimber/fimber.dart';

import 'package:git_bindings/git_bindings.dart';
import 'package:gitjournal/screens/githostsetup_sshkey.dart';
import 'package:gitjournal/utils.dart';

class GitRemoteSettingsScreen extends StatefulWidget {
  @override
  _GitRemoteSettingsScreenState createState() =>
      _GitRemoteSettingsScreenState();
}

class _GitRemoteSettingsScreenState extends State<GitRemoteSettingsScreen> {
  String publicKey = "";

  @override
  void initState() {
    super.initState();
    getSSHPublicKey().then((String val) {
      setState(() {
        publicKey = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    var body = Column(
      children: <Widget>[
        Text(
          "SSH Public Key -",
          style: textTheme.body2,
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 16.0),
        PublicKeyWidget(publicKey),
        const SizedBox(height: 16.0),
        const Divider(),
        Button(
          text: "Copy Key",
          onPressed: () => _copyKeyToClipboard(context),
        ),
        Button(
          text: "Regnerate Key",
          onPressed: () => _generateSshKey(context),
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Git Remote Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: body,
      ),
    );
  }

  void _copyKeyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: publicKey));
    showSnackbar(context, "Public Key copied to Clipboard");
  }

  void _generateSshKey(BuildContext context) {
    var comment = "GitJournal " +
        Platform.operatingSystem +
        " " +
        DateTime.now().toIso8601String().substring(0, 10); // only the date

    generateSSHKeys(comment: comment).then((String publicKey) {
      setState(() {
        this.publicKey = publicKey;
        Fimber.d("PublicKey: " + publicKey);
        _copyKeyToClipboard(context);
      });
    });
  }
}

class Button extends StatelessWidget {
  final String text;
  final Function onPressed;

  Button({@required this.text, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: RaisedButton(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.button,
        ),
        color: Theme.of(context).primaryColor,
        onPressed: onPressed,
      ),
    );
  }
}
