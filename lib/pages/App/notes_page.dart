import 'package:chemgital/models/userdata.dart';
import 'package:chemgital/pages/widgets/drawer.dart';
import 'package:chemgital/services/firebase_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:chemgital/services/pdf_service.dart';
import 'package:chemgital/pages/App/pdf_viewer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late PdfService _pdfService;
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? role;

  @override
  void initState() {
    super.initState();
    loadUserData();
    _pdfService = Provider.of<PdfService>(context, listen: false);
    _pdfService.getAllPdf().then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> loadUserData() async{
    UserData _userData = await FirebaseAuthService().getUserData();
    setState(() {
      role = _userData.role;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: SafeArea(
          child: Text(
            'Notes',
            style: GoogleFonts.poppins(
              fontSize: 23,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.sort, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        backgroundColor: Color(0xFF040C23),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Container(
            color: Color(0xFFA44AFF),
            height: 4.0,
          ),
        ),
      ),
      backgroundColor: const Color(0xFF040C23),
      drawer: CustomDrawer(),
      body: Consumer<PdfService>(
        builder: (context, pdfService, _) {
          if (_isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } 
          else if (pdfService.pdfData.isEmpty) {
            return Center(
              child: Text(
                'No Notes available',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            );
          } else {
            return _buildPdfList(pdfService);
          }
        },
      ),
      floatingActionButton: 
    role == 'admin'
      ? Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0, .6, 1],
              colors: [
                Color(0xFFDF98FA),
                Color(0xFFB070FD),
                Color(0xFF9055FF)
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: FractionallySizedBox(
            child: FloatingActionButton(
              onPressed: () async{
                setState(() {
                  _isLoading = true;
                });
                
                await _pdfService.pickFile();
            
                setState(() {
                  _isLoading = false;
                });
            
              },
              child: const Icon(Icons.add, color: Colors.white),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
        )
      : null,
    );
  }

  Widget _buildPdfList(PdfService pdfService) {
  return Padding(
    padding: const EdgeInsets.only(left: 15, right: 15),
    child: GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
      ),
      itemCount: pdfService.pdfData.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(top : 15),
          child: Card(
            elevation: 3,
            child: Stack(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.all(10), 
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.picture_as_pdf, color: Color(0xFFA44AFF), size: 55), 
                      SizedBox(height: 20), 
                      Text(
                        pdfService.pdfData[index]['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ), 
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PdfViewerScreenState(
                          pdfUrl: pdfService.pdfData[index]['link'],
                          title: pdfService.pdfData[index]['name'],
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'download') {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Download ' + pdfService.pdfData[index]['name']),
                              content: Text('Are you sure you want to download this Note?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      _isLoading = true;
                                    });
          
                                    await pdfService.downloadPdf(
                                      pdfService.pdfData[index]['link'],
                                      pdfService.pdfData[index]['name'],
                                    );
          
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  },
                                  child: Text('Download'),
                                ),
                              ],
                            );
                          },
                        );
                      } else if (value == 'delete') {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Delete ' + pdfService.pdfData[index]['name']),
                              content: Text('Are you sure you want to delete this Note?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      _isLoading = true;
                                    });
          
                                    await pdfService.deletePdf(
                                      pdfService.pdfData[index]['id'],
                                    );
          
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  },
                                  child: Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        height: 40,
                        value: 'download',
                        child: Text('Download', style: GoogleFonts.poppins(color: Colors.deepPurpleAccent),),
                      ),
                      if (role == 'admin')...[
                        const PopupMenuDivider(),
                        PopupMenuItem<String>(
                          height: 40,
                          value: 'delete',
                          child: Text('Delete', style: GoogleFonts.poppins(color: Colors.deepPurpleAccent),),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}


}
