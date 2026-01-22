// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math' as math;

/// Generates the app icon PNG files
/// Run with: dart run tool/generate_icon.dart
void main() async {
  print('Generating AXYN app icons...');
  
  // Generate main icon (1024x1024)
  final mainIcon = generateIcon(1024);
  await File('assets/icon/app_icon.png').writeAsBytes(encodePng(mainIcon));
  print('✓ Generated assets/icon/app_icon.png');
  
  // Generate foreground for adaptive icon (1024x1024 with padding)
  final foreground = generateIconForeground(1024);
  await File('assets/icon/app_icon_foreground.png').writeAsBytes(encodePng(foreground));
  print('✓ Generated assets/icon/app_icon_foreground.png');
  
  print('\nDone! Now run:');
  print('  flutter pub get');
  print('  dart run flutter_launcher_icons');
}

/// Simple PNG encoder
List<int> encodePng(List<List<int>> pixels) {
  final width = pixels[0].length ~/ 4;
  final height = pixels.length;
  
  // PNG signature
  final signature = [137, 80, 78, 71, 13, 10, 26, 10];
  
  // IHDR chunk
  final ihdr = _createIHDRChunk(width, height);
  
  // IDAT chunk (image data)
  final idat = _createIDATChunk(pixels, width, height);
  
  // IEND chunk
  final iend = _createIENDChunk();
  
  return [...signature, ...ihdr, ...idat, ...iend];
}

List<int> _createIHDRChunk(int width, int height) {
  final data = [
    ...intToBytes(width, 4),
    ...intToBytes(height, 4),
    8, // bit depth
    6, // color type (RGBA)
    0, // compression
    0, // filter
    0, // interlace
  ];
  return _createChunk('IHDR', data);
}

List<int> _createIDATChunk(List<List<int>> pixels, int width, int height) {
  // Raw image data with filter byte
  final rawData = <int>[];
  for (int y = 0; y < height; y++) {
    rawData.add(0); // filter type: none
    rawData.addAll(pixels[y]);
  }
  
  // Compress using deflate
  final compressed = _deflate(rawData);
  return _createChunk('IDAT', compressed);
}

List<int> _createIENDChunk() {
  return _createChunk('IEND', []);
}

List<int> _createChunk(String type, List<int> data) {
  final length = intToBytes(data.length, 4);
  final typeBytes = type.codeUnits;
  final crc = _crc32([...typeBytes, ...data]);
  return [...length, ...typeBytes, ...data, ...intToBytes(crc, 4)];
}

List<int> intToBytes(int value, int length) {
  final bytes = <int>[];
  for (int i = length - 1; i >= 0; i--) {
    bytes.add((value >> (i * 8)) & 0xFF);
  }
  return bytes;
}

// Simple deflate implementation (store only, no compression for simplicity)
List<int> _deflate(List<int> data) {
  final result = <int>[];
  
  // zlib header
  result.addAll([0x78, 0x01]);
  
  // Split into blocks
  int offset = 0;
  while (offset < data.length) {
    final remaining = data.length - offset;
    final blockSize = remaining > 65535 ? 65535 : remaining;
    final isLast = offset + blockSize >= data.length;
    
    result.add(isLast ? 0x01 : 0x00); // BFINAL + BTYPE
    result.add(blockSize & 0xFF);
    result.add((blockSize >> 8) & 0xFF);
    result.add((~blockSize) & 0xFF);
    result.add(((~blockSize) >> 8) & 0xFF);
    result.addAll(data.sublist(offset, offset + blockSize));
    
    offset += blockSize;
  }
  
  // Adler-32 checksum
  final adler = _adler32(data);
  result.addAll(intToBytes(adler, 4));
  
  return result;
}

int _adler32(List<int> data) {
  int a = 1;
  int b = 0;
  for (final byte in data) {
    a = (a + byte) % 65521;
    b = (b + a) % 65521;
  }
  return (b << 16) | a;
}

// CRC32 table
final _crcTable = List<int>.generate(256, (n) {
  int c = n;
  for (int k = 0; k < 8; k++) {
    if ((c & 1) != 0) {
      c = 0xEDB88320 ^ (c >> 1);
    } else {
      c = c >> 1;
    }
  }
  return c;
});

int _crc32(List<int> data) {
  int crc = 0xFFFFFFFF;
  for (final byte in data) {
    crc = _crcTable[(crc ^ byte) & 0xFF] ^ (crc >> 8);
  }
  return crc ^ 0xFFFFFFFF;
}

/// Generate the main app icon
List<List<int>> generateIcon(int size) {
  final pixels = List.generate(size, (_) => List<int>.filled(size * 4, 0));
  
  final centerX = size / 2;
  final centerY = size / 2;
  final radius = size * 0.45;
  final cornerRadius = size * 0.22;
  
  // Draw each pixel
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final dx = x - centerX;
      final dy = y - centerY;
      
      // Check if inside rounded rectangle
      final inShape = isInsideRoundedRect(
        x.toDouble(), y.toDouble(),
        centerX - radius, centerY - radius,
        radius * 2, radius * 2,
        cornerRadius,
      );
      
      if (inShape) {
        // Blue gradient from top-left to bottom-right
        final gradientPos = (dx + dy + radius * 2) / (radius * 4);
        final r = lerpColor(0x19, 0x0D, gradientPos);
        final g = lerpColor(0x76, 0x47, gradientPos);
        final b = lerpColor(0xD2, 0xA1, gradientPos);
        
        setPixel(pixels, x, y, r, g, b, 255);
      }
    }
  }
  
  // Draw "AXYN" text
  drawText(pixels, size, 'AXYN', size * 0.18);
  
  return pixels;
}

/// Generate foreground icon for adaptive icon (with safe zone padding)
List<List<int>> generateIconForeground(int size) {
  final pixels = List.generate(size, (_) => List<int>.filled(size * 4, 0));
  
  final centerX = size / 2;
  final centerY = size / 2;
  // Smaller size to fit in adaptive icon safe zone (66% of total)
  final radius = size * 0.30;
  final cornerRadius = size * 0.15;
  
  // Draw each pixel
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final dx = x - centerX;
      final dy = y - centerY;
      
      final inShape = isInsideRoundedRect(
        x.toDouble(), y.toDouble(),
        centerX - radius, centerY - radius,
        radius * 2, radius * 2,
        cornerRadius,
      );
      
      if (inShape) {
        // White/light color for foreground on blue background
        setPixel(pixels, x, y, 255, 255, 255, 255);
      }
    }
  }
  
  // Draw "AXYN" text in blue
  drawTextColored(pixels, size, 'AXYN', size * 0.12, 0x15, 0x65, 0xC0);
  
  return pixels;
}

bool isInsideRoundedRect(double px, double py, double x, double y, double w, double h, double r) {
  // Clamp point to rectangle
  final cx = px.clamp(x + r, x + w - r);
  final cy = py.clamp(y + r, y + h - r);
  
  // Check corners
  if (px < x + r && py < y + r) {
    return math.sqrt(math.pow(px - (x + r), 2) + math.pow(py - (y + r), 2)) <= r;
  }
  if (px > x + w - r && py < y + r) {
    return math.sqrt(math.pow(px - (x + w - r), 2) + math.pow(py - (y + r), 2)) <= r;
  }
  if (px < x + r && py > y + h - r) {
    return math.sqrt(math.pow(px - (x + r), 2) + math.pow(py - (y + h - r), 2)) <= r;
  }
  if (px > x + w - r && py > y + h - r) {
    return math.sqrt(math.pow(px - (x + w - r), 2) + math.pow(py - (y + h - r), 2)) <= r;
  }
  
  // Inside main rectangle
  return px >= x && px <= x + w && py >= y && py <= y + h;
}

int lerpColor(int a, int b, double t) {
  return (a + (b - a) * t.clamp(0, 1)).round().clamp(0, 255);
}

void setPixel(List<List<int>> pixels, int x, int y, int r, int g, int b, int a) {
  if (y >= 0 && y < pixels.length && x >= 0 && x < pixels[0].length ~/ 4) {
    final idx = x * 4;
    pixels[y][idx] = r;
    pixels[y][idx + 1] = g;
    pixels[y][idx + 2] = b;
    pixels[y][idx + 3] = a;
  }
}

// Simple bitmap font for "AXYN"
final Map<String, List<String>> font = {
  'A': [
    '  ##  ',
    ' #  # ',
    '#    #',
    '######',
    '#    #',
    '#    #',
    '#    #',
  ],
  'X': [
    '#    #',
    ' #  # ',
    '  ##  ',
    '  ##  ',
    ' #  # ',
    '#    #',
    '#    #',
  ],
  'Y': [
    '#    #',
    ' #  # ',
    '  ##  ',
    '   #  ',
    '   #  ',
    '   #  ',
    '   #  ',
  ],
  'N': [
    '#    #',
    '##   #',
    '# #  #',
    '#  # #',
    '#   ##',
    '#    #',
    '#    #',
  ],
};

void drawText(List<List<int>> pixels, int size, String text, double fontSize) {
  drawTextColored(pixels, size, text, fontSize, 255, 255, 255);
}

void drawTextColored(List<List<int>> pixels, int size, String text, double fontSize, int r, int g, int b) {
  final charWidth = fontSize * 0.8;
  final charHeight = fontSize;
  final totalWidth = text.length * charWidth + (text.length - 1) * fontSize * 0.15;
  final startX = (size - totalWidth) / 2;
  final startY = (size - charHeight) / 2;
  
  double currentX = startX;
  
  for (final char in text.split('')) {
    final pattern = font[char];
    if (pattern != null) {
      drawChar(pixels, pattern, currentX, startY, charWidth, charHeight, r, g, b);
    }
    currentX += charWidth + fontSize * 0.15;
  }
}

void drawChar(List<List<int>> pixels, List<String> pattern, double x, double y, double width, double height, int r, int g, int b) {
  final patternHeight = pattern.length;
  final patternWidth = pattern[0].length;
  
  final scaleX = width / patternWidth;
  final scaleY = height / patternHeight;
  
  for (int py = 0; py < patternHeight; py++) {
    for (int px = 0; px < patternWidth; px++) {
      if (pattern[py][px] == '#') {
        // Fill the scaled rectangle
        final startPx = (x + px * scaleX).round();
        final startPy = (y + py * scaleY).round();
        final endPx = (x + (px + 1) * scaleX).round();
        final endPy = (y + (py + 1) * scaleY).round();
        
        for (int fillY = startPy; fillY < endPy; fillY++) {
          for (int fillX = startPx; fillX < endPx; fillX++) {
            setPixel(pixels, fillX, fillY, r, g, b, 255);
          }
        }
      }
    }
  }
}
