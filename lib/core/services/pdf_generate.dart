import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PDFGenerator {
  Future<Uint8List> generateHealthSummary({
    required String title,
    required String content,
    required Map<String, dynamic> metrices,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build:(pw.Context context){
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Generated: ${DateTime.now().toLocal()}',
                  style: pw.TextStyle(fontSize: 12,color: PdfColors.grey),
                ),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Health Summary',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold
                  ),
                ),
                pw.SizedBox(height: 10),
              pw.Text(content),
              pw.SizedBox(height: 20),
              pw.Text(
                'Metrics Overview',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              ...metrices.entries.map((entry) {
                return pw.Row(
                  children: [
                    pw.Expanded(child: pw.Text(entry.key),),
                    pw.Text(entry.value.toString()),
                  ],
                );
              }).toList(),
              pw.SizedBox(height: 20),
              pw.Text(
                'Recommendations',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Continue monitor your health Metrices Regularly'),
              pw.Text('Consult Your Personal Provider fo Personilized Advice'),
            ]
          );
        }
       )
      
    );
    return pdf.save();
  }
}