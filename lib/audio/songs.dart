const List<Song> songs = [
  Song('bit_forrest.mp3', 'Bit Forrest', artist: 'bertz'),
];

class Song {
  final String filename;

  final String name;

  final String? artist;

  const Song(this.filename, this.name, {this.artist});

  @override
  String toString() => 'Song<$filename>';
}
