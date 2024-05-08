import 'dart:io';
import 'package:chemgital/global/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';


class PdfService extends ChangeNotifier{

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _pdfData = [];
  List<Map<String, dynamic>> get pdfData => _pdfData;

  Future<String> uploadPdf(String fileName, File file) async {
    
    final reference = FirebaseStorage.instance.ref().child("pdfs/notes/$fileName.pdf");

    final uploadTask = reference.putFile(file);

    await uploadTask.whenComplete(() {});

    final downloadLink = await reference.getDownloadURL();

    return downloadLink;

  }
  

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files[0].path!);
      String fileName = result.files[0].name;
      String date = DateTime.now().toString();
      DocumentReference docRef = _firestore.collection('pdfs').doc();
      String docId = docRef.id;

      final downloadLink = await uploadPdf(docId, file);
      await docRef.set({
        'id': docId,
        'name': fileName,
        'link': downloadLink,
        'date': date,
      });

      _pdfData.add({
        'id': docId,
        'name': fileName,
        'link': downloadLink,
        'date': date,
      });
      
      notifyListeners();
      showToast(message: 'File uploaded successfully');

    }

  }

  Future getAllPdf() async {
    final results = await _firestore.collection('pdfs').orderBy('date').get();
    _pdfData = results.docs.map((e) => e.data() ).toList();
  }

  Future<void> deletePdf(String pdfId) async {
    
    final reference = FirebaseStorage.instance.ref().child("pdfs/notes/$pdfId.pdf");
    await reference.delete();

    await _firestore.collection('pdfs').doc(pdfId).delete();

    _pdfData.removeWhere((element) => element['id'] == pdfId);

    notifyListeners();

    showToast(message: 'PDF deleted successfully');

  }

  Future<void> downloadPdf(String link, String fileName) async {
    FileDownloader.downloadFile(
      url: link,
      name: fileName,
      onDownloadError: (error) {
        showToast(message: 'Error downloading file');
      },
      onProgress: (fileName, progress) {
        showToast(message: 'Downloading file ' + progress.toString() + '%' );
      },
      onDownloadCompleted: (path) {
        showToast(message: 'File downloaded successfully');
      },
    );
    
  }
  
}