import 'package:flutter/material.dart';
import 'package:function_types/function_types.dart';

import 'githostsetup_button.dart';
import 'githostsetup_loading.dart';

class GitHostSetupSshKeyKnownProvider extends StatelessWidget {
  final Func0<void> doneFunction;
  final Func0<void> regenerateFunction;
  final Func1<BuildContext, void> copyKeyFunction;
  final String publicKey;

  final Func0<void> openDeployKeyPage;

  GitHostSetupSshKeyKnownProvider({
    @required this.doneFunction,
    @required this.regenerateFunction,
    @required this.copyKeyFunction,
    @required this.openDeployKeyPage,
    @required this.publicKey,
  });

  @override
  Widget build(BuildContext context) {
    if (publicKey == null || publicKey.isEmpty) {
      return GitHostSetupLoadingPage("Generating SSH Key ...");
    }

    var columns = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'In order to access this repository, this public key must be copied as a deploy key',
          style: Theme.of(context).textTheme.title,
        ),
        const SizedBox(height: 32.0),

        // Step 1
        Text(
          '1. Copy the key',
          style: Theme.of(context).textTheme.subtitle,
        ),
        const SizedBox(height: 8.0),
        PublicKeyWidget(publicKey),
        const SizedBox(height: 8.0),

        GitHostSetupButton(
          text: "Copy Key",
          onPressed: () => copyKeyFunction(context),
        ),
        GitHostSetupButton(
          text: "Regenerate Key",
          onPressed: regenerateFunction,
        ),
        const SizedBox(height: 16.0),

        // Step 2
        Text(
          '2. Open webpage, and paste the deploy key. Make sure it is given Write Access. ',
          style: Theme.of(context).textTheme.subtitle,
        ),
        const SizedBox(height: 8.0),
        GitHostSetupButton(
          text: "Open Deploy Key Webpage",
          onPressed: openDeployKeyPage,
        ),
        const SizedBox(height: 16.0),

        // Step 3
        Text(
          '3. Try Cloning ..',
          style: Theme.of(context).textTheme.subtitle,
        ),
        const SizedBox(height: 8.0),
        GitHostSetupButton(
          text: "Clone Repo",
          onPressed: doneFunction,
        ),
      ],
    );

    return Center(
      child: SingleChildScrollView(
        child: columns,
      ),
    );
  }
}

class GitHostSetupSshKeyUnknownProvider extends StatelessWidget {
  final Func0<void> doneFunction;
  final Func1<BuildContext, void> copyKeyFunction;
  final String publicKey;

  GitHostSetupSshKeyUnknownProvider({
    @required this.doneFunction,
    @required this.copyKeyFunction,
    @required this.publicKey,
  });

  @override
  Widget build(BuildContext context) {
    if (publicKey == null || publicKey.isEmpty) {
      return GitHostSetupLoadingPage("Generating SSH Key ...");
    }

    var columns = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'In order to access this repository, this public key must be copied as a deploy key',
          style: Theme.of(context).textTheme.title,
        ),
        const SizedBox(height: 32.0),

        // Step 1
        Text(
          '1. Copy the key',
          style: Theme.of(context).textTheme.subtitle,
        ),
        const SizedBox(height: 8.0),
        PublicKeyWidget(publicKey),
        const SizedBox(height: 8.0),
        GitHostSetupButton(
          text: "Copy Key",
          onPressed: () => copyKeyFunction(context),
        ),
        const SizedBox(height: 16.0),

        // Step 2
        Text(
          '2. Give this SSH Key access to the git repo. (You need to figure it out yourself)',
          style: Theme.of(context).textTheme.subtitle,
        ),
        const SizedBox(height: 16.0),

        // Step 3
        Text(
          '3. Try Cloning ..',
          style: Theme.of(context).textTheme.subtitle,
        ),
        const SizedBox(height: 8.0),
        GitHostSetupButton(
          text: "Clone Repo",
          onPressed: doneFunction,
        ),
      ],
    );

    return Center(
      child: SingleChildScrollView(
        child: columns,
      ),
    );
  }
}

class PublicKeyWidget extends StatelessWidget {
  final String publicKey;

  PublicKeyWidget(this.publicKey);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 160.0,
      child: Container(
        color: Theme.of(context).buttonColor,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              publicKey,
              textAlign: TextAlign.left,
              maxLines: null,
              style: Theme.of(context).textTheme.body1,
            ),
          ),
        ),
      ),
    );
  }
}
