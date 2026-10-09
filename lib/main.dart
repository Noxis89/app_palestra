import 'package:flutter/material.dart';

void main() {
  runApp(const MyAppPalestra());
}

class MyAppPalestra extends StatelessWidget {
  const MyAppPalestra({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracker Palestra Personale',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Lista globale degli allenamenti registrati (Storico)
  final List<Map<String, dynamic>> _storicoAllenamenti = [];

  @override
  Widget build(BuildContext context) {
    final screens = [
      GiorniSettimanaScreen(
        onAggiungiAllenamento: (nuovoAllenamento) {
          setState(() {
            _storicoAllenamenti.insert(0, nuovoAllenamento);
          });
        },
      ),
      StoricoScreen(
        storico: _storicoAllenamenti,
        onModificaElimina: () => setState(() {}),
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fitness_center),
            label: 'Allenamenti',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'Storico',
          ),
        ],
      ),
    );
  }
}

// 1. Schermata dei Giorni della Settimana
class GiorniSettimanaScreen extends StatelessWidget {
  final Function(Map<String, dynamic>) onAggiungiAllenamento;

  const GiorniSettimanaScreen({super.key, required this.onAggiungiAllenamento});

  final List<String> _giorni = const [
    'Lunedì',
    'Martedì',
    'Mercoledì',
    'Giovedì',
    'Venerdì',
    'Sabato',
    'Domenica',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('I Miei Giorni di Allenamento 💪'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _giorni.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final giorno = _giorni[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(
                giorno,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: const Text('Tocca per registrare o gestire la sessione'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GiornoDettaglioScreen(
                      giorno: giorno,
                      onAggiungiAllenamento: onAggiungiAllenamento,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Modello di supporto per le singole serie
class SerieItem {
  TextEditingController pesoController;
  TextEditingController repsController;

  SerieItem({String peso = '', String reps = ''})
      : pesoController = TextEditingController(text: peso),
        repsController = TextEditingController(text: reps);
}

// 2. Dettaglio del singolo giorno
class GiornoDettaglioScreen extends StatefulWidget {
  final String giorno;
  final Function(Map<String, dynamic>) onAggiungiAllenamento;

  const GiornoDettaglioScreen({
    super.key,
    required this.giorno,
    required this.onAggiungiAllenamento,
  });

  @override
  State<GiornoDettaglioScreen> createState() => _GiornoDettaglioScreenState();
}

class _GiornoDettaglioScreenState extends State<GiornoDettaglioScreen> {
  final List<Map<String, dynamic>> _allenamentiDelGiorno = [];

  void _apriForm({Map<String, dynamic>? elementoEsistente, int? index}) {
    final now = DateTime.now();
    final dataOdierna = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    final nomeWorkoutController = TextEditingController(
      text: elementoEsistente != null ? elementoEsistente['nomeWorkout'] as String : '',
    );
    final nomeEsercizioController = TextEditingController(
      text: elementoEsistente != null ? elementoEsistente['nomeEsercizio'] as String : '',
    );
    final noteController = TextEditingController(
      text: elementoEsistente != null ? elementoEsistente['note'] as String : '',
    );

    // Gestione della lista dinamica delle serie
    List<SerieItem> serieList = [];
    if (elementoEsistente != null && elementoEsistente['serie'] != null) {
      final List<Map<String, String>> serieSalvate = List<Map<String, String>>.from(elementoEsistente['serie']);
      for (var s in serieSalvate) {
        serieList.add(SerieItem(peso: s['peso'] ?? '', reps: s['reps'] ?? ''));
      }
    } else {
      // Partiamo di default con una serie vuota pronta per essere compilata
      serieList.add(SerieItem());
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(index == null ? 'Nuovo Esercizio (${widget.giorno})' : 'Modifica Esercizio'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nomeWorkoutController,
                      decoration: const InputDecoration(labelText: 'Nome Allenamento (es. Petto & Tricipiti)'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nomeEsercizioController,
                      decoration: const InputDecoration(labelText: 'Nome Esercizio (es. Panca Piana)'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Gestione Serie (Peso e Ripetizioni):',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.deepOrangeAccent),
                    ),
                    const SizedBox(height: 8),

                    // Lista dinamica delle righe di serie
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: serieList.length,
                      itemBuilder: (context, sIndex) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Text('#${sIndex + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: serieList[sIndex].pesoController,
                                  decoration: const InputDecoration(labelText: 'Peso (es. 50 kg)', isDense: true),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: serieList[sIndex].repsController,
                                  decoration: const InputDecoration(labelText: 'Reps (es. 10)', isDense: true),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                onPressed: () {
                                  if (serieList.length > 1) {
                                    setStateDialog(() {
                                      serieList.removeAt(sIndex);
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Devi lasciare almeno una serie.')),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setStateDialog(() {
                          serieList.add(SerieItem());
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Aggiungi un\'altra serie'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(labelText: 'Note Personali (es. Ottimo pump)'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              if (index != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _allenamentiDelGiorno.removeAt(index);
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Esercizio eliminato con successo!')),
                    );
                  },
                  child: const Text('Elimina', style: TextStyle(color: Colors.red)),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annulla'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nomeEsercizioController.text.isNotEmpty) {
                    // Mappiamo le serie inserite dall'utente
                    List<Map<String, String>> serieSalvate = serieList.map((s) {
                      return {
                        'peso': s.pesoController.text.isEmpty ? '0 kg' : s.pesoController.text,
                        'reps': s.repsController.text.isEmpty ? '0' : s.repsController.text,
                      };
                    }).toList();

                    final Map<String, dynamic> nuovoDato = {
                      'giorno': widget.giorno,
                      'data': dataOdierna,
                      'nomeWorkout': nomeWorkoutController.text.isEmpty ? 'Allenamento' : nomeWorkoutController.text,
                      'nomeEsercizio': nomeEsercizioController.text,
                      'serie': serieSalvate,
                      'note': noteController.text.isEmpty ? 'Nessuna nota' : noteController.text,
                    };

                    setState(() {
                      if (index == null) {
                        _allenamentiDelGiorno.add(nuovoDato);
                        widget.onAggiungiAllenamento(nuovoDato);
                      } else {
                        _allenamentiDelGiorno[index] = nuovoDato;
                      }
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Salva'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Funzione di supporto per formattare visivamente le serie nelle card
  String _formattaSerie(dynamic serieData) {
    if (serieData == null) return '';
    List<Map<String, String>> list = List<Map<String, String>>.from(serieData);
    List<String> righe = [];
    for (int i = 0; i < list.length; i++) {
      righe.add('Serie ${i + 1}: ${list[i]['peso']} - ${list[i]['reps']} reps');
    }
    return righe.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.giorno),
        centerTitle: true,
      ),
      body: _allenamentiDelGiorno.isEmpty
          ? Center(
        child: Text('Nessun esercizio registrato per ${widget.giorno}.'),
      )
          : ListView.builder(
        itemCount: _allenamentiDelGiorno.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final item = _allenamentiDelGiorno[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(
                '${item['data']} - ${item['nomeWorkout']}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  'Esercizio: ${item['nomeEsercizio']}\n${_formattaSerie(item['serie'])}\nNote: ${item['note']}',
                  style: const TextStyle(color: Colors.grey, height: 1.3),
                ),
              ),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                onPressed: () => _apriForm(elementoEsistente: item, index: index),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _apriForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// 3. Schermata dello Storico Globale
class StoricoScreen extends StatelessWidget {
  final List<Map<String, dynamic>> storico;
  final VoidCallback onModificaElimina;

  const StoricoScreen({
    super.key,
    required this.storico,
    required this.onModificaElimina,
  });

  String _formattaSerie(dynamic serieData) {
    if (serieData == null) return '';
    List<Map<String, String>> list = List<Map<String, String>>.from(serieData);
    List<String> righe = [];
    for (int i = 0; i < list.length; i++) {
      righe.add('Serie ${i + 1}: ${list[i]['peso']} - ${list[i]['reps']} reps');
    }
    return righe.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storico Allenamenti 📊'),
        centerTitle: true,
      ),
      body: storico.isEmpty
          ? const Center(
        child: Text('Ancora nessun allenamento nello storico.'),
      )
          : ListView.builder(
        itemCount: storico.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final item = storico[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(
                '${item['data']} (${item['giorno']}) - ${item['nomeWorkout']}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  'Esercizio: ${item['nomeEsercizio']}\n${_formattaSerie(item['serie'])}\nNote: ${item['note']}',
                  style: const TextStyle(color: Colors.grey, height: 1.3),
                ),
              ),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => storico.removeAt(index),
              ),
            ),
          );
        },
      ),
    );
  }
}