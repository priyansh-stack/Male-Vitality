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
              }),
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

  Future<Uint8List> generateMedicationSummary({
    required String userName,
    required String cohort,
    required List<Map<String, dynamic>> medications,
  }) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('MaleVitality Clinical Rx Record',
                      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800)),
                  pw.Text('CONFIDENTIAL',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.red700)),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Text('Patient: $userName • Cohort: $cohort • DOB: Sep 17, 2004 (22 YRS)',
                  style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
              pw.Text('Report Generated: ${DateTime.now().toLocal().toString().split(".")[0]}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 12),
              pw.Text('Active Medications & Prescriptions',
                  style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              ...medications.map((med) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 8),
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(med['name']?.toString() ?? 'Medication',
                              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                          pw.Text('${med['dosage'] ?? ''} • ${med['frequency'] ?? ''}',
                              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                        ],
                      ),
                      pw.Text(med['prescriber']?.toString() ?? 'Dr. Marcus Vance',
                          style: pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey700)),
                    ],
                  ),
                );
              }),
              pw.SizedBox(height: 16),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 8),
              pw.Text('Clinical Advisory:',
                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
              pw.Text(
                'This document is generated for personal health record keeping and clinical consultation review under HIPAA Privacy Rule 45 CFR Section 164.524. Verify all dosages with your licensed physician before altering any regimen.',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }
}