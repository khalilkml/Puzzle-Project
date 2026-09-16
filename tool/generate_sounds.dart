import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() {
  final dir = Directory('assets/sounds');
  dir.createSync(recursive: true);
  _writeTone(File('${dir.path}/place.wav'), freqs: [740], duration: 0.07, volume: 0.28);
  _writeTone(File('${dir.path}/clear.wav'), freqs: [523, 784], duration: 0.16, volume: 0.3);
  _writeTone(
    File('${dir.path}/combo.wav'),
    freqs: [523, 659, 784, 1046],
    duration: 0.24,
    volume: 0.3,
  );
  _writeTone(
    File('${dir.path}/game_over.wav'),
    freqs: [349, 277, 220],
    duration: 0.38,
    volume: 0.3,
  );
  _writeTone(
    File('${dir.path}/revive.wav'),
    freqs: [392, 523, 659, 784],
    duration: 0.22,
    volume: 0.3,
  );
  _writeTone(File('${dir.path}/invalid.wav'), freqs: [180], duration: 0.09, volume: 0.22);
  stdout.writeln('Generated ${dir.listSync().length} wav files');
}

void _writeTone(
  File file, {
  required List<double> freqs,
  required double duration,
  double volume = 0.3,
  int sampleRate = 22050,
}) {
  final n = (sampleRate * duration).round();
  final samples = Int16List(n);
  for (var i = 0; i < n; i++) {
    final t = i / sampleRate;
    final attack = i < n * 0.08 ? i / (n * 0.08) : 1.0;
    final env = attack * pow(1.0 - i / n, 1.4);
    var s = 0.0;
    for (final f in freqs) {
      s += sin(2 * pi * f * t);
    }
    s /= freqs.length;
    samples[i] = (s * env * volume * 32767).round().clamp(-32767, 32767);
  }

  final dataSize = n * 2;
  final bytes = BytesBuilder();
  void writeString(String value) => bytes.add(value.codeUnits);
  void write32(int value) {
    bytes.add([
      value & 0xff,
      (value >> 8) & 0xff,
      (value >> 16) & 0xff,
      (value >> 24) & 0xff,
    ]);
  }

  void write16(int value) {
    bytes.add([value & 0xff, (value >> 8) & 0xff]);
  }

  writeString('RIFF');
  write32(36 + dataSize);
  writeString('WAVE');
  writeString('fmt ');
  write32(16);
  write16(1);
  write16(1);
  write32(sampleRate);
  write32(sampleRate * 2);
  write16(2);
  write16(16);
  writeString('data');
  write32(dataSize);
  bytes.add(samples.buffer.asUint8List());
  file.writeAsBytesSync(bytes.takeBytes());
}
