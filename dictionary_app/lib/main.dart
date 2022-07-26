import 'package:dictionary_app/pages/mean_list_page.dart';
import 'package:dictionary_app/viewmodels/meaning_list_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dictionary_app/models/eng_model.dart';
import 'package:dictionary_app/services/eng_dictionary_service.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class TrDictionary extends StatelessWidget {
  const TrDictionary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home:  ChangeNotifierProvider(
        create: (context) => MeaningListViewModel(),
        child: const MeanListPage(),
      ),

    );
    
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Türkçe-İngilizce Sözlük"), backgroundColor: Colors.red,),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            ElevatedButton(
              child:const Text("Türkçe Sözlük", style: TextStyle(fontSize: 20)),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TrDictionary()),),
            ),
            ElevatedButton(
              child: const Text("İngilizce Sözlük", style: TextStyle(fontSize: 20)),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => App()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      
      home: HomePage(),
    );
  }
}
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController controller = TextEditingController();

  AudioPlayer? audioPlayer;

  @override
  void initState() {
    super.initState();
    setState(() {
      audioPlayer = AudioPlayer();
    });
  }

  void playAudio(String music) {
    audioPlayer!.stop();

    audioPlayer!.play(music);
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('English Dictionary'), backgroundColor: Colors.red,
        
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(10),
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller,
                            decoration: const InputDecoration(
                              hintText: 'Search Query',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (controller.text.isNotEmpty) {
                              setState(() {});
                            }
                          },
                          icon: const Icon(Icons.search),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  ///FutureBuilder
                  controller.text.isEmpty
                      ? const SizedBox(child: Text('Search for something'))
                      : FutureBuilder(
                          future: DictionaryService()
                              .getMeaning(word: controller.text),
                          builder: (context,
                              AsyncSnapshot<List<DictionaryModel>> snapshot) {
                            print("Data $snapshot");
                            if (snapshot.hasData) {
                              return Expanded(
                                child: ListView(
                                  children: List.generate(snapshot.data!.length,
                                      (index) {
                                    final data = snapshot.data![index];
                                    return Container(
                                      child: Column(
                                        children: [
                                          Container(
                                            child: ListTile(
                                              title: Text(data.word!),
                                              subtitle: Text(
                                                  data.phonetics![index].text!),
                                              trailing: IconButton(
                                                  onPressed: () {
                                                    final path = data
                                                        .phonetics![index]
                                                        .audio;

                                                    playAudio("https:$path");
                                                  },
                                                  icon: const Icon(
                                                      Icons.audiotrack)),
                                            ),
                                          ),
                                          Container(
                                            child: ListTile(
                                              title: Text(data
                                                  .meanings![index]
                                                  .definitions![index]
                                                  .definition!),
                                              subtitle: Text(data
                                                  .meanings![index]
                                                  .partOfSpeech!),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Text(snapshot.error.toString());
                            } else {
                              return const CircularProgressIndicator();
                            }
                          },
                        )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}