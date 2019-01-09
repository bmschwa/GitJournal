typedef NoteAdder(Note note);
typedef NoteRemover(Note note);
typedef NoteUpdator(Note note);

class Note implements Comparable {
  String id;
  DateTime created;
  String body;

  Note({this.created, this.body, this.id});

  factory Note.fromJson(Map<String, dynamic> json) {
    String id;
    if (json.containsKey("id")) {
      var val = json["id"];
      if (val.runtimeType == String) {
        id = val;
      } else {
        id = val.toString();
      }
    }

    return new Note(
      id: id,
      created: DateTime.parse(json['created']),
      body: json['body'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "created": created.toIso8601String(),
      "body": body,
      "id": id,
    };
  }

  @override
  int get hashCode => id.hashCode ^ created.hashCode ^ body.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          body == other.body &&
          created == other.created;

  @override
  String toString() {
    return 'Note{id: $id, body: $body, created: $created}';
  }

  @override
  int compareTo(other) {
    if (other == null) {
      return -1;
    }
    return created.compareTo(other.created);
  }
}

class AppState {
  bool isLoadingFromDisk;
  bool localStateModified;

  bool isLoadingRemoteState;
  bool remoteStateModified;

  List<Note> notes;

  AppState({
    this.isLoadingFromDisk = false,
    this.localStateModified = false,
    this.isLoadingRemoteState = false,
    this.remoteStateModified = false,
    this.notes = const [],
  });

  //factory AppState.loading() => AppState(isLoading: true);
}
