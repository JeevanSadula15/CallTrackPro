import 'dart:convert';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import '../models/student.dart';

class ExcelService {
  static Future<List<Student>> parseExcelFile(Uint8List bytes, {String? fileName}) async {
    if (fileName != null && fileName.toLowerCase().endsWith('.csv')) {
      return _parseCsvFile(bytes);
    }
    return _parseExcelFile(bytes);
  }

  static Future<List<Student>> _parseCsvFile(Uint8List bytes) async {
    try {
      final csvString = utf8.decode(bytes);
      final lines = csvString.split('\n');
      final students = <Student>[];
      
      // Skip header row (index 0)
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        
        final fields = line.split(',');
        if (fields.length >= 5) {
          final name = fields[0].trim();
          final standard = fields[1].trim();
          final mobile = fields[2].trim();
          final address = fields[3].trim();
          final school = fields[4].trim();
          
          if (name.isNotEmpty && mobile.isNotEmpty) {
            print('Adding CSV student: $name, $mobile');
            students.add(Student(
              id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
              name: name,
              standard: standard,
              mobile: mobile,
              address: address,
              school: school,
              createdAt: DateTime.now(),
            ));
          }
        }
      }
      
      return students;
    } catch (e) {
      throw Exception('Error parsing CSV file: $e');
    }
  }

  static Future<List<Student>> _parseExcelFile(Uint8List bytes) async {
    try {
      final excel = Excel.decodeBytes(bytes);
      final students = <Student>[];
      
      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table]!;
        
        print('Sheet: $table, Rows: ${sheet.maxRows}, Cols: ${sheet.maxCols}');
        
        // Skip header row (index 0)
        for (int i = 1; i < sheet.maxRows; i++) {
          final row = sheet.rows[i];
          print('Row $i: ${row.map((cell) => cell?.value).toList()}');
          
          if (row.isNotEmpty && row.length >= 5) {
            final name = row[0]?.value?.toString().trim() ?? '';
            final standard = row[1]?.value?.toString().trim() ?? '';
            final mobile = row[2]?.value?.toString().trim() ?? '';
            final address = row[3]?.value?.toString().trim() ?? '';
            final school = row[4]?.value?.toString().trim() ?? '';
            
            print('Parsed: name=$name, mobile=$mobile');
            
            if (name.isNotEmpty && mobile.isNotEmpty) {
              print('Adding student: $name, $mobile');
              students.add(Student(
                id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
                name: name,
                standard: standard,
                mobile: mobile,
                address: address,
                school: school,
                createdAt: DateTime.now(),
              ));
            }
          }
        }
      }
      
      return students;
    } catch (e) {
      throw Exception('Error parsing Excel file: $e');
    }
  }
}