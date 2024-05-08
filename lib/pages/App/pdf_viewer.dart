import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';

class PdfViewerScreenState extends StatefulWidget {
  final String pdfUrl;
  final String title;
  const PdfViewerScreenState({super.key, required this.pdfUrl, required this.title});

  @override
  State<PdfViewerScreenState> createState() => _PdfViewerScreenStateState();
}

class _PdfViewerScreenStateState extends State<PdfViewerScreenState> {

  PDFDocument? document;

  void initialisePdf() async{

    document = await PDFDocument.fromURL(widget.pdfUrl);
    setState(() {
      document = document;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialisePdf();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SafeArea(child: Text(widget.title, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600))),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color(0xFF040C23),
      ),
      body: document != null? PDFViewer(
        document: document!,
        pickerButtonColor: Color(0xFFA44AFF),
        
        

      ) : Center(child: CircularProgressIndicator(),),
    );
  }
}