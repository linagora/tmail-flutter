import 'dart:io';

Future<int> readFileLength(String path) => File(path).length();

