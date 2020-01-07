import 'dart:io';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:function_types/function_types.dart';
import 'package:git_bindings/git_bindings.dart';

import 'package:gitjournal/analytics.dart';
import 'package:gitjournal/apis/githost_factory.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/settings.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

import 'githostsetup_autoconfigure.dart';
import 'githostsetup_button.dart';
import 'githostsetup_clone.dart';
import 'githostsetup_clone_url.dart';
import 'githostsetup_sshkey.dart';

class GitHostSetupScreen extends StatefulWidget {
  final Func0<void> onCompletedFunction;

  GitHostSetupScreen(this.onCompletedFunction);

  @override
  GitHostSetupScreenState createState() {
    return GitHostSetupScreenState();
  }
}

enum PageChoice0 { Unknown, KnownProvider, CustomProvider }
enum PageChoice1 { Unknown, Manual, Auto }

class GitHostSetupScreenState extends State<GitHostSetupScreen> {
  var _pageCount = 1;

  var _pageChoice = [
    PageChoice0.Unknown,
    PageChoice1.Unknown,
  ];

  var _gitHostType = GitHostType.Unknown;
  var _gitCloneUrl = "";
  var gitCloneErrorMessage = "";
  var publicKey = "";

  var pageController = PageController();
  int _currentPageIndex = 0;

  Widget _buildPage(BuildContext context, int pos) {
    assert(_pageCount >= 1);

    if (pos == 0) {
      return GitHostChoicePage(
        onKnownGitHost: (GitHostType gitHostType) {
          setState(() {
            _gitHostType = gitHostType;
            _pageChoice[0] = PageChoice0.KnownProvider;
            _pageCount = pos + 2;
            _nextPage();
          });
        },
        onCustomGitHost: () {
          setState(() {
            _pageChoice[0] = PageChoice0.CustomProvider;
            _pageCount = pos + 2;
            _nextPage();
          });
        },
      );
    }

    if (pos == 1) {
      assert(_pageChoice[0] != PageChoice0.Unknown);

      if (_pageChoice[0] == PageChoice0.CustomProvider) {
        return GitCloneUrlPage(
          doneFunction: (String sshUrl) {
            setState(() {
              _gitCloneUrl = sshUrl;

              _pageCount = pos + 2;
              _nextPage();
              _generateSshKey(context);
            });
          },
          initialValue: _gitCloneUrl,
        );
      }

      return GitHostAutoConfigureChoicePage(
        onDone: (GitHostSetupType setupType) {
          if (setupType == GitHostSetupType.Manual) {
            setState(() {
              _pageCount = pos + 2;
              _pageChoice[1] = PageChoice1.Manual;
              _nextPage();
            });
          } else if (setupType == GitHostSetupType.Auto) {
            setState(() {
              _pageCount = pos + 2;
              _pageChoice[1] = PageChoice1.Auto;
              _nextPage();
            });
          }
        },
      );
    }

    if (pos == 2) {
      if (_pageChoice[0] == PageChoice0.CustomProvider) {
        return GitHostSetupSshKeyUnknownProvider(
          doneFunction: () {
            setState(() {
              _pageCount = pos + 2;
              _nextPage();
              _startGitClone(context);
            });
          },
          publicKey: publicKey,
          copyKeyFunction: _copyKeyToClipboard,
        );
      }

      assert(_pageChoice[1] != PageChoice1.Unknown);

      if (_pageChoice[1] == PageChoice1.Manual) {
        return GitCloneUrlKnownProviderPage(
          doneFunction: (String sshUrl) {
            setState(() {
              _pageCount = pos + 2;
              _gitCloneUrl = sshUrl;

              _nextPage();
              _generateSshKey(context);
            });
          },
          launchCreateUrlPage: _launchCreateRepoPage,
          gitHostType: _gitHostType,
          initialValue: _gitCloneUrl,
        );
      } else if (_pageChoice[1] == PageChoice1.Auto) {
        return GitHostSetupAutoConfigure(
          gitHostType: _gitHostType,
          onDone: (String gitCloneUrl) {
            setState(() {
              _gitCloneUrl = gitCloneUrl;
              _pageCount = pos + 2;

              _nextPage();
              _startGitClone(context);
            });
          },
        );
      }
    }

    if (pos == 3) {
      if (_pageChoice[0] == PageChoice0.CustomProvider) {
        return GitHostSetupGitClone(errorMessage: gitCloneErrorMessage);
      }

      if (_pageChoice[1] == PageChoice1.Manual) {
        // FIXME: Create a new page with better instructions
        return GitHostSetupSshKeyKnownProvider(
          doneFunction: () {
            setState(() {
              _pageCount = 6;

              _nextPage();
              _startGitClone(context);
            });
          },
          regenerateFunction: () {
            setState(() {
              publicKey = "";
            });
            _generateSshKey(context);
          },
          publicKey: publicKey,
          copyKeyFunction: _copyKeyToClipboard,
          openDeployKeyPage: _launchDeployKeyPage,
        );
      } else if (_pageChoice[1] == PageChoice1.Auto) {
        return GitHostSetupGitClone(errorMessage: gitCloneErrorMessage);
      }

      assert(false);
    }

    if (pos == 4) {
      if (_pageChoice[1] == PageChoice1.Manual) {
        return GitHostSetupGitClone(errorMessage: gitCloneErrorMessage);
      }
    }

    assert(_pageChoice[0] != PageChoice0.CustomProvider);

    assert(false);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var pageView = PageView.builder(
      controller: pageController,
      itemBuilder: _buildPage,
      itemCount: _pageCount,
      onPageChanged: (int pageNum) {
        setState(() {
          _currentPageIndex = pageNum;
          _pageCount = _currentPageIndex + 1;
        });
      },
    );

    var body = Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        alignment: FractionalOffset.bottomCenter,
        children: <Widget>[
          pageView,
          DotsIndicator(
            dotsCount: _pageCount,
            position: _currentPageIndex,
            decorator: DotsDecorator(
              activeColor: Theme.of(context).primaryColorDark,
            ),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
    );

    var scaffold = Scaffold(
      body: Stack(
        children: <Widget>[
          body,
          if (Platform.isIOS)
            InkWell(
              child: Container(
                child: const Icon(Icons.arrow_back, size: 32.0),
                padding: const EdgeInsets.all(8.0),
              ),
              onTap: () => Navigator.of(context).pop(),
            ),
        ],
      ),
    );

    return WillPopScope(
      onWillPop: () async {
        if (_currentPageIndex != 0) {
          pageController.previousPage(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeIn,
          );
          return false;
        }

        return true;
      },
      child: scaffold,
    );
  }

  void _nextPage() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeIn,
    );
  }

  void _generateSshKey(BuildContext context) {
    if (publicKey.isNotEmpty) {
      return;
    }

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

  void _copyKeyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: publicKey));
    showSnackbar(context, "Public Key copied to Clipboard");
  }

  void _launchDeployKeyPage() async {
    var canLaunch = _gitCloneUrl.startsWith("git@github.com:") ||
        _gitCloneUrl.startsWith("git@gitlab.com:");
    if (!canLaunch) {
      return;
    }

    var lastIndex = _gitCloneUrl.lastIndexOf(".git");
    if (lastIndex == -1) {
      lastIndex = _gitCloneUrl.length;
    }

    var repoName =
        _gitCloneUrl.substring(_gitCloneUrl.lastIndexOf(":") + 1, lastIndex);

    final gitHubUrl = 'https://github.com/' + repoName + '/settings/keys/new';
    final gitLabUrl = 'https://gitlab.com/' +
        repoName +
        '/settings/repository/#js-deploy-keys-settings';

    try {
      if (_gitCloneUrl.startsWith("git@github.com:")) {
        await launch(gitHubUrl);
      } else if (_gitCloneUrl.startsWith("git@gitlab.com:")) {
        await launch(gitLabUrl);
      }
    } catch (err, stack) {
      Fimber.d('_launchDeployKeyPage: ' + err.toString());
      Fimber.d(stack.toString());
    }
  }

  void _launchCreateRepoPage() async {
    assert(_gitHostType != GitHostType.Unknown);

    try {
      if (_gitHostType == GitHostType.GitHub) {
        await launch("https://github.com/new");
      } else if (_gitHostType == GitHostType.GitLab) {
        await launch("https://gitlab.com/projects/new");
      }
    } catch (err, stack) {
      // FIXME: Error handling?
      Fimber.d("_launchCreateRepoPage: " + err.toString());
      Fimber.d(stack.toString());
    }
  }

  void _startGitClone(BuildContext context) async {
    setState(() {
      gitCloneErrorMessage = "";
    });

    var appState = StateContainer.of(context).appState;
    var basePath = appState.gitBaseDirectory;

    // Just in case it was half cloned because of an error
    await _removeExistingClone(basePath);

    String repoPath = p.join(basePath, "journal");
    String error;
    try {
      Fimber.d("Cloning " + _gitCloneUrl);
      await GitRepo.clone(repoPath, _gitCloneUrl);
    } on GitException catch (e) {
      error = e.cause;
    }

    if (error != null && error.isNotEmpty) {
      setState(() {
        getAnalytics().logEvent(
          name: "onboarding_gitClone_error",
          parameters: <String, dynamic>{
            'error': error,
          },
        );
        gitCloneErrorMessage = error;
      });
      return;
    }

    //
    // Add a GitIgnore file. This way we always at least have one commit
    // It makes doing a git pull and push easier
    //
    var gitIgnorePath = p.join(repoPath, ".gitignore");
    var ignoreFile = File(gitIgnorePath);
    if (!ignoreFile.existsSync()) {
      ignoreFile.createSync();

      var repo = GitRepo(
        folderPath: repoPath,
        authorName: Settings.instance.gitAuthor,
        authorEmail: Settings.instance.gitAuthorEmail,
      );
      await repo.add('.gitignore');
      await repo.commit(message: "Add gitignore file");
    }

    getAnalytics().logEvent(
      name: "onboarding_complete",
      parameters: <String, dynamic>{},
    );
    Navigator.pop(context);
    widget.onCompletedFunction();
  }

  Future _removeExistingClone(String baseDirPath) async {
    var baseDir = Directory(p.join(baseDirPath, "journal"));
    var dotGitDir = Directory(p.join(baseDir.path, ".git"));
    bool exists = dotGitDir.existsSync();
    if (exists) {
      Fimber.d("Removing " + baseDir.path);
      await baseDir.delete(recursive: true);
      await baseDir.create();
    }
  }
}

class GitHostChoicePage extends StatelessWidget {
  final Func1<GitHostType, void> onKnownGitHost;
  final Func0<void> onCustomGitHost;

  GitHostChoicePage({
    @required this.onKnownGitHost,
    @required this.onCustomGitHost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            "Select a Git Hosting Provider -",
            style: Theme.of(context).textTheme.headline,
          ),
          const SizedBox(height: 16.0),
          GitHostSetupButton(
            text: "GitHub",
            iconUrl: 'assets/icon/github-icon.png',
            onPressed: () {
              onKnownGitHost(GitHostType.GitHub);
            },
          ),
          const SizedBox(height: 8.0),
          GitHostSetupButton(
            text: "GitLab",
            iconUrl: 'assets/icon/gitlab-icon.png',
            onPressed: () async {
              onKnownGitHost(GitHostType.GitLab);
            },
          ),
          const SizedBox(height: 8.0),
          GitHostSetupButton(
            text: "Custom",
            onPressed: () async {
              onCustomGitHost();
            },
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}

enum GitHostSetupType {
  Auto,
  Manual,
}

class GitHostAutoConfigureChoicePage extends StatelessWidget {
  final Func1<GitHostSetupType, void> onDone;

  GitHostAutoConfigureChoicePage({@required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            "How do you want to do this?",
            style: Theme.of(context).textTheme.headline,
          ),
          const SizedBox(height: 16.0),
          GitHostSetupButton(
            text: "Setup Automatically",
            onPressed: () {
              onDone(GitHostSetupType.Auto);
            },
          ),
          const SizedBox(height: 8.0),
          GitHostSetupButton(
            text: "Let me do it manually",
            onPressed: () async {
              onDone(GitHostSetupType.Manual);
            },
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}
