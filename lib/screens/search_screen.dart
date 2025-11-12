import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SearchScreen extends StatefulWidget {
  final Map<String, dynamic> user; // JSON au lieu de User

  const SearchScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _apiService = ApiService();

  List<dynamic> _products = []; // Liste JSON
  int _totalQuantity = 0;
  bool _isLoading = false;
  bool _hasSearched = false;

  final List<String> _quickQuestions = [
    "Combien me reste-t-il d'œufs ?",
    "Ai-je du lait ?",
    "Quels légumes ai-je ?",
    "Combien de fromages ?",
    "Produits bientôt périmés",
  ];

  String _getCategoryEmoji(String categorie) {
    const map = {
      'Fruits': '🍎',
      'Légumes': '🥕',
      'Viandes': '🥩',
      'Poissons': '🐟',
      'Produits laitiers': '🥛',
      'Boissons': '🥤',
      'Condiments': '🧂',
    };
    return map[categorie] ?? '📦';
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    final result = await _apiService.searchProducts(query);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        setState(() {
          _products = result['products']; // Liste JSON
          _totalQuantity = result['total_quantity'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interroger mon frigo'),
        backgroundColor: const Color(0xFF667eea),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Posez votre question...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF667eea)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF667eea)),
                        onPressed: () => _search(_searchController.text),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: _search,
                  ),
                ),
                const SizedBox(height: 16),

                // Quick Questions
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '💡 Questions rapides',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _quickQuestions.map((question) {
                    return InkWell(
                      onTap: () {
                        _searchController.text = question;
                        _search(question);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Text(
                          question,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasSearched
                ? _products.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.inbox_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucun produit trouvé',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
                : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header Result
                if (_totalQuantity > 0)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_products.length} produit(s) trouvé(s)',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Quantité totale : $_totalQuantity',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Products List - Accès JSON direct
                ..._products.map((product) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7FAFC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            _getCategoryEmoji(product['categorie']),
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                      title: Text(
                        product['nom'], // JSON direct
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('📍 ${product['refrigerateur']}'),
                          Text('📂 ${product['categorie']}'),
                          Text('📅 Expire le ${product['date_peremption']}'),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${product['quantite']}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF667eea),
                            ),
                          ),
                          Text(
                            product['unite'] ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            )
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.search,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Posez une question sur vos produits',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}