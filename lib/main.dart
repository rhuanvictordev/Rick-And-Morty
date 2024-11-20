import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


// Inicia a aplicação Flutter com a função runApp, passando o widget principal

void main() {
  runApp(MyApp());
}


// Mapas de tradução para cada filtro (Gênero, Status, Espécie e Origem)

final Map<String, String> genderTranslations = {
  'Todos': 'Todos',
  'Male': 'Masculino',
  'Female': 'Feminino',
};

final Map<String, String> statusTranslations = {
  'Todos': 'Todos',
  'Alive': 'Vivo',
  'Dead': 'Morto',
  'unknown': 'Desconhecido',
};

final Map<String, String> speciesTranslations = {
  'Todos': 'Todos',
  'Human': 'Humano',
  'Alien': 'Alienígena',
  'Humanoid': 'Humanoide',
};

final Map<String, String> originTranslations = {
  'unknown': 'Desconhecida',
};


// Widget principal da aplicação, que define o tema e a tela inicial
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(), // Define o tema escuro para a aplicação
      home: CharacterPage(), // A tela inicial é a CharacterPage
      debugShowCheckedModeBanner: false, // Desativa o banner de debug
    );
  }
}


// StatefulWidget para a página que lista os personagens

class CharacterPage extends StatefulWidget {
  @override
  _CharacterPageState createState() => _CharacterPageState();
}


// Estado da CharacterPage, onde os personagens são gerenciados e os filtros aplicados

class _CharacterPageState extends State<CharacterPage> {
  List<dynamic> _characters = [];
  List<dynamic> _allCharacters = [];

  // Variáveis de filtros

  String _selectedGender = 'Todos';
  String _selectedStatus = 'Todos';
  String _selectedSpecies = 'Todos';
  String _nameFilter = '';
  String _originFilter = '';

  @override
  void initState() {
    super.initState();
    fetchCharacters(); // Chama a função que busca os personagens da API
  }

  // Função que faz a requisição para a API e carrega os personagens
  Future<void> fetchCharacters() async {
    final url = Uri.parse('https://rickandmortyapi.com/api/character');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); // Decodifica o JSON da resposta
      setState(() {
        _allCharacters = data['results']; // Salva todos os personagens
        _characters = _allCharacters; // Exibe todos os personagens inicialmente
      });
    } else {
      throw Exception('Erro ao consultar API'); // Caso a requisição falhe
    }
  }

  // Função que aplica os filtros na lista de personagens
  void _applyFilters() {
    setState(() {
      _characters = _allCharacters.where((character) {

        // Verifica se o personagem atende aos critérios dos filtros
        bool matchesGender = _selectedGender == 'Todos' ||
            character['gender'] == _selectedGender;
        bool matchesStatus = _selectedStatus == 'Todos' ||
            character['status'] == _selectedStatus;
        bool matchesSpecies = _selectedSpecies == 'Todos' ||
            character['species'] == _selectedSpecies;
        bool matchesName = _nameFilter.isEmpty ||
            character['name'].toLowerCase().contains(_nameFilter.toLowerCase());
        bool matchesOrigin = _originFilter.isEmpty ||
            character['origin']['name']
                .toLowerCase()
                .contains(_originFilter.toLowerCase());

        return matchesGender &&
            matchesStatus &&
            matchesSpecies &&
            matchesName &&
            matchesOrigin;
      }).toList(); // Filtra os personagens
    });
  }

  // Função que exibe o diálogo de filtros
  void _showFilterDialog() {
    String tempSelectedGender = _selectedGender;
    String tempSelectedStatus = _selectedStatus;
    String tempSelectedSpecies = _selectedSpecies;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              backgroundColor: Color(0xFF737373),
              title: Text(
                'Aplicar filtro:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    // Filtro por Gênero
                    ExpansionTile(
                      title: Text(
                        "Gênero",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      children: [
                        ...genderTranslations.keys.map((value) {
                          return RadioListTile<String>(
                            value: value,
                            groupValue: tempSelectedGender,
                            title: Text(
                              genderTranslations[value]!,
                              style: TextStyle(color: Colors.white),
                            ),
                            activeColor: Colors.green,
                            onChanged: (newValue) {
                              setState(() {
                                tempSelectedGender = newValue!;
                              });
                            },
                          );
                        }).toList(),
                      ],
                    ),

                    // Filtro por Status
                    ExpansionTile(
                      title: Text(
                        "Status",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      children: [
                        ...statusTranslations.keys.map((value) {
                          return RadioListTile<String>(
                            value: value,
                            groupValue: tempSelectedStatus,
                            title: Text(
                              statusTranslations[value]!,
                              style: TextStyle(color: Colors.white),
                            ),
                            activeColor: Colors.green,
                            onChanged: (newValue) {
                              setState(() {
                                tempSelectedStatus = newValue!;
                              });
                            },
                          );
                        }).toList(),
                      ],
                    ),

                    // Filtro por Espécie
                    ExpansionTile(
                      title: Text(
                        "Espécie",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      children: [
                        ...speciesTranslations.keys.map((value) {
                          return RadioListTile<String>(
                            value: value,
                            groupValue: tempSelectedSpecies,
                            title: Text(
                              speciesTranslations[value]!,
                              style: TextStyle(color: Colors.white),
                            ),
                            activeColor: Colors.green,
                            onChanged: (newValue) {
                              setState(() {
                                tempSelectedSpecies = newValue!;
                              });
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[

                // Botão para aplicar os filtros selecionados
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFF80FF00),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Aplicar filtros',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedGender = tempSelectedGender;
                      _selectedStatus = tempSelectedStatus;
                      _selectedSpecies = tempSelectedSpecies;
                      _applyFilters(); // Aplica os filtros ao fechar o diálogo
                    });
                    Navigator.of(context).pop(); // Fecha o diálogo
                  },
                ),
              ],
            );



          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF212424),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120), // Aumenta a altura da AppBar
        child: AppBar(
          backgroundColor: Colors.black,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Center(
              child: Transform.scale(
                scale: 1.4, // Escala para 130%
                child: Image.asset(
                  'assets/images/appBarImage.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          IconButton(
            icon: Image(
              image: AssetImage("assets/images/filtro.png"),
              width: 36,
              height: 36,
            ),
            onPressed: _showFilterDialog, // Exibe o diálogo de filtros
          ),
          Expanded(
            child: _characters.isEmpty
                ? Center(child: CircularProgressIndicator())
                : GridView.builder(
              itemCount: _characters.length, // Número de personagens a exibir
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Define 2 colunas para o grid
                crossAxisSpacing: 0,
                mainAxisSpacing: 6,
                childAspectRatio: 1 / 1, // Proporção dos cards
              ),
              itemBuilder: (context, index) {
                final character = _characters[index]; // Obtém o personagem
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CharacterDetailPage(character: character),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.transparent,
                    elevation: 0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Image.network(character['image'],
                              fit: BoxFit.cover),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            character['name'],
                            style: TextStyle(color: Colors.lightGreenAccent),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Página de detalhes de um personagem
class CharacterDetailPage extends StatelessWidget {
  final Map<String, dynamic> character;

  CharacterDetailPage({required this.character});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF141515),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0.0),
        child: AppBar(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/appBarImage.png',
              fit: BoxFit.cover,
              width: 411,
              height: 50,
            ),
            Center(
              child: Image.network(
                character['image'],
                width: 380,
                height: 300,
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Nome: ${character['name']}',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'Status: ${statusTranslations[character['status']] ?? character['status']}',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'Espécie: ${speciesTranslations[character['species']] ?? character['species']}',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'Gênero: ${genderTranslations[character['gender']] ?? character['gender']}',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'Origem: ${originTranslations[character['origin']['name']] ?? character['origin']['name']}',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
