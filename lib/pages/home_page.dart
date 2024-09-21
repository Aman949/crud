import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud/services/database.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Database database = Database();

  final TextEditingController textEditingController = TextEditingController();
  void openNoteBox({String? docID}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textEditingController,
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      if(docID == null){
                        database.addNote(textEditingController.text);
                      }
                      else{
                        database.updateNote(docID, textEditingController.text);
                      }
                      textEditingController.clear();
                      Navigator.pop(context);
                    },
                    child: Text("Add"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openNoteBox();
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder(
          stream: database.getNotes(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List notesList = snapshot.data!.docs;
              return ListView.builder(
                  itemCount: notesList.length,
                  itemBuilder: (context, index) {
                    //get each individual doc
                    DocumentSnapshot documentSnapshot = notesList[index];
                    String docID = documentSnapshot.id;
                    //get note from each doc
                    Map<String, dynamic> data =
                        documentSnapshot.data() as Map<String, dynamic>;
                    String noteText = data['note'];

                    return ListTile(
                      title: Text(noteText),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                        onPressed: ()=>{
                          openNoteBox(docID: docID)
                        }, 
                        icon: Icon(Icons.settings)),

                        IconButton(
                        onPressed: ()=>{
                          database.deleteNote(docID)
                        }, 
                        icon: Icon(Icons.delete)),
                        ],
                      )
                    );
                  });
            } else {
              return Text("no notes....");
            }
          }),
    );
  }
}
