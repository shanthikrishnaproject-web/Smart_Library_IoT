import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'librarian_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAIKkaZqsxo6xGPR8dCKw0cpJDfhd_gpzA",
        appId: "1:426570633533:web:9125cca8adc8081503b554",
        messagingSenderId: "426570633533",
        projectId: "library-automation-syste-2844f",
        databaseURL:
            "https://library-automation-syste-2844f-default-rtdb.firebaseio.com",
        storageBucket: "library-automation-syste-2844f.firebasestorage.app",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const LibrarySystem());
}

class LibrarySystem extends StatelessWidget {
  const LibrarySystem({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kariyavattom Library',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: kIsWeb ? const LibrarianWebAdmin() : const StudentLoginScreen(),
    );
  }
}

// --- STUDENT LOGIN SCREEN ---
class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});
  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final TextEditingController _idController = TextEditingController();

  void _login() async {
    String id = _idController.text.trim().toUpperCase();
    if (id.isEmpty) return;

    DataSnapshot snap = await FirebaseDatabase.instance
        .ref()
        .child("students")
        .child(id)
        .get();

    if (snap.exists) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationSplash(studentData: snap),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ID not found. Contact Librarian.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.library_books, size: 80, color: Colors.indigo),
            const Text(
              "Campus Read",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _idController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: "Enter ID Number (e.g. A102)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _login,
                child: const Text("LOGIN"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 2-SECOND VERIFICATION SCREEN ---
class VerificationSplash extends StatefulWidget {
  final DataSnapshot studentData;
  const VerificationSplash({super.key, required this.studentData});
  @override
  State<VerificationSplash> createState() => _VerificationSplashState();
}

class _VerificationSplashState extends State<VerificationSplash> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              StudentHomePage(studentData: widget.studentData),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              "Verified Successfully",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ],
        ),
      ),
    );
  }
}

// --- UPDATED STUDENT HOME PAGE ---
class StudentHomePage extends StatefulWidget {
  final DataSnapshot studentData;
  const StudentHomePage({super.key, required this.studentData});
  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int _selectedIndex = 0;
  String _searchQuery = "";

  // 1. HOME TAB WITH SEARCH DROPDOWN
  Widget _buildHomeTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: (value) =>
                setState(() => _searchQuery = value.trim().toUpperCase()),
            decoration: InputDecoration(
              hintText: "Search Book Title or ID...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
        ),

        // Dynamic search results list
        if (_searchQuery.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 250),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: StreamBuilder(
              stream: FirebaseDatabase.instance.ref().child("books").onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null)
                  return const ListTile(title: Text("No books available"));

                List<DataSnapshot> books = snapshot.data!.snapshot.children
                    .where((b) {
                      return b
                              .child("title")
                              .value
                              .toString()
                              .toUpperCase()
                              .contains(_searchQuery) ||
                          b.key!.toUpperCase().contains(_searchQuery);
                    })
                    .toList();

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: books.length,
                  itemBuilder: (context, i) => ListTile(
                    leading: const Icon(Icons.book),
                    title: Text(books[i].child("title").value.toString()),
                    subtitle: Text("ID: ${books[i].key}"),
                    onTap: () => _showBookDetails(books[i]),
                  ),
                );
              },
            ),
          ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Categories",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _catIcon(Icons.science, "Science"),
              _catIcon(Icons.computer, "IT"),
              _catIcon(Icons.history, "History"),
              _catIcon(Icons.calculate, "Math"),
            ],
          ),
        ),
        const Divider(),
        const Expanded(
          child: Center(child: Text("Search for books above to see details")),
        ),
      ],
    );
  }

  // 2. PROFILE TAB WITH REAL FINE DATA
  Widget _buildProfileTab() {
    String name = widget.studentData.child("name").value.toString();
    String dept = widget.studentData.child("dept").value.toString();
    String id = widget.studentData.key.toString();

    return StreamBuilder(
      stream: FirebaseDatabase.instance
          .ref()
          .child("students")
          .child(id)
          .onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        int fine = 0;
        if (snapshot.hasData &&
            snapshot.data!.snapshot.child("fine").value != null) {
          fine = int.parse(
            snapshot.data!.snapshot.child("fine").value.toString(),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 20),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("Dept: $dept | ID: $id"),
              const SizedBox(height: 30),
              Card(
                color: fine > 0 ? Colors.red[50] : Colors.green[50],
                child: ListTile(
                  leading: Icon(
                    Icons.currency_rupee,
                    color: fine > 0 ? Colors.red : Colors.green,
                  ),
                  title: const Text("Current Fine Balance"),
                  trailing: Text(
                    "₹$fine",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: fine > 0 ? Colors.red : Colors.green,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBookDetails(DataSnapshot book) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              book.child("title").value.toString(),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              "Author: ${book.child("author").value}",
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const Divider(height: 40),
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: book.child("isAvailable").value == true
                      ? Colors.green
                      : Colors.red,
                ),
                const SizedBox(width: 10),
                Text(
                  book.child("isAvailable").value == true
                      ? "Available for Issue"
                      : "Checked Out",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: book.child("isAvailable").value == true
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _catIcon(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          CircleAvatar(child: Icon(icon)),
          Text(label),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, ${widget.studentData.child("name").value}"),
        backgroundColor: Colors.indigo,
      ),
      body: [
        _buildHomeTab(),
        const Center(child: Text("Borrowed Books History")),
        _buildProfileTab(),
      ][_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "My Books"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
