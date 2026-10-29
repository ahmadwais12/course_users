import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class ExportService {
  static Future<File?> exportToPDF({
    required String title,
    required List<List<String>> data,
    required List<String> headers,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(title,
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: headers,
                data: data,
                border: pw.TableBorder.all(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ],
          ),
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final file = File(
          '${dir.path}/${title}_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());
      return file;
    } catch (e) {
      return null;
    }
  }

  static Future<File?> exportToCSV({
    required String title,
    required List<List<String>> data,
    required List<String> headers,
  }) async {
    try {
      final buffer = StringBuffer();
      buffer.writeln(headers.join(','));
      for (var row in data) {
        buffer.writeln(row.map((e) => '"$e"').join(','));
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File(
          '${dir.path}/${title}_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(buffer.toString());
      return file;
    } catch (e) {
      return null;
    }
  }
}
