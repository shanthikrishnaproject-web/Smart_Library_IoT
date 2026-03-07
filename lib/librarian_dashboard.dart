import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class LibrarianWebAdmin extends StatefulWidget {
  const LibrarianWebAdmin({super.key});

  @override
  State<LibrarianWebAdmin> createState() => _LibrarianWebAdminState();
}

class _LibrarianWebAdminState extends State<LibrarianWebAdmin> {
  final TextEditingController _adminId = TextEditingController();
  final TextEditingController _adminPass = TextEditingController();
  bool _isLoggedIn = false;
  String _currentView = "HOME";

  void _handleLogin() {
    // Basic Admin Credentials
    if (_adminId.text == "admin123" && _adminPass.text == "lib@2026") {
      setState(() => _isLoggedIn = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid Admin Credentials")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) return _buildLoginBox();

    return Scaffold(
      appBar: AppBar(
        title: Text(_getViewTitle()),
        backgroundColor: Colors.indigo,
        leading: _currentView != "HOME"
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _currentView = "HOME"),
              )
            : null,
      ),
      body: _getScreen(),
    );
  }

  String _getViewTitle() {
    switch (_currentView) {
      case "REGISTER_STUDENT":
        return "Add New Student";
      case "REGISTER_BOOK":
        return "Add New Book & IoT Setup";
      case "SEARCH_HUB":
        return "Manage Students & Fines";
      default:
        return "Librarian Central Command";
    }
  }

  Widget _getScreen() {
    switch (_currentView) {
      case "HOME":
        return _buildMainDashboard();
      case "REGISTER_STUDENT":
        return const RegistrationForm();
      case "REGISTER_BOOK":
        return const BookRegistrationForm();
      case "SEARCH_HUB":
        return const UnifiedSearchHub();
      default:
        return _buildMainDashboard();
    }
  }

  Widget _buildMainDashboard() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.5,
        children: [
          _menuCard(
            "Register Student",
            Icons.person_add,
            Colors.blue,
            "REGISTER_STUDENT",
          ),
          _menuCard(
            "Register Book",
            Icons.library_add,
            const Color.fromARGB(255, 223, 4, 91),
            "REGISTER_BOOK",
          ),
          _menuCard(
            "Search & Fines",
            Icons.person_search,
            Colors.green,
            "SEARCH_HUB",
          ),
        ],
      ),
    );
  }

  Widget _menuCard(String title, IconData icon, Color color, String viewName) {
    return InkWell(
      onTap: () => setState(() => _currentView = viewName),
      child: Card(
        color: color.withValues(alpha: 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginBox() {
    return Scaffold(
      body: Center(
        child: Card(
          elevation: 10,
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  size: 60,
                  color: Colors.indigo,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Librarian Login",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _adminId,
                  decoration: const InputDecoration(
                    labelText: "Admin ID",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _adminPass,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    child: const Text("Enter Dashboard"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- BOOK REGISTRATION (WITH SHELF & LED) ---
class BookRegistrationForm extends StatefulWidget {
  const BookRegistrationForm({super.key});
  @override
  State<BookRegistrationForm> createState() => _BookRegistrationFormState();
}

class _BookRegistrationFormState extends State<BookRegistrationForm> {
  final _bId = TextEditingController();
  final _bTitle = TextEditingController();
  final _bAuthor = TextEditingController();
  final _bShelf = TextEditingController();
  bool _ledStatus = false;

  void _saveBook() {
    if (_bId.text.isEmpty || _bTitle.text.isEmpty) return;

    FirebaseDatabase.instance
        .ref()
        .child("books")
        .child(_bId.text.toUpperCase())
        .set({
          "title": _bTitle.text,
          "author": _bAuthor.text,
          "shelf": _bShelf.text,
          "ledStatus": _ledStatus,
          "isAvailable": true,
        });

    _bId.clear();
    _bTitle.clear();
    _bAuthor.clear();
    _bShelf.clear();
    setState(() => _ledStatus = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Book & IoT Settings Saved!")));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            TextField(
              controller: _bId,
              decoration: const InputDecoration(
                labelText: "Book ID / ISBN",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bTitle,
              decoration: const InputDecoration(
                labelText: "Book Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bAuthor,
              decoration: const InputDecoration(
                labelText: "Author Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bShelf,
              decoration: const InputDecoration(
                labelText: "Shelf Location (e.g. S-102)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text("Activate Shelf LED"),
              subtitle: const Text("IoT Signal for physical hardware"),
              value: _ledStatus,
              activeColor: Colors.orange,
              onChanged: (val) => setState(() => _ledStatus = val),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveBook,
              child: const Text("REGISTER BOOK"),
            ),
          ],
        ),
      ),
    );
  }
}

// --- UNIFIED SEARCH HUB & FINE MANAGEMENT ---
class UnifiedSearchHub extends StatefulWidget {
  const UnifiedSearchHub({super.key});
  @override
  State<UnifiedSearchHub> createState() => _UnifiedSearchHubState();
}

class _UnifiedSearchHubState extends State<UnifiedSearchHub> {
  final _searchController = TextEditingController();
  List<DataSnapshot> _allStudents = [];
  List<DataSnapshot> _filteredStudents = [];
  DataSnapshot? _selectedStudent;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() {
    FirebaseDatabase.instance.ref().child("students").onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _allStudents = event.snapshot.children.toList();
          _filteredStudents = _allStudents;
          // Refresh selected student data if it updates in Firebase
          if (_selectedStudent != null) {
            _selectedStudent = _allStudents.firstWhere(
              (s) => s.key == _selectedStudent!.key,
            );
          }
        });
      }
    });
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredStudents = _allStudents.where((s) {
        final name = s.child("name").value.toString().toLowerCase();
        final id = s.key!.toLowerCase();
        return name.contains(query.toLowerCase()) ||
            id.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterSearch,
                  decoration: const InputDecoration(
                    hintText: "Search ID or Name...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredStudents.length,
                  itemBuilder: (context, i) => ListTile(
                    title: Text(
                      _filteredStudents[i].child("name").value.toString(),
                    ),
                    subtitle: Text("ID: ${_filteredStudents[i].key}"),
                    onTap: () =>
                        setState(() => _selectedStudent = _filteredStudents[i]),
                    selected: _selectedStudent?.key == _filteredStudents[i].key,
                    selectedTileColor: Colors.indigo.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(),
        Expanded(
          flex: 3,
          child: _selectedStudent == null
              ? const Center(
                  child: Text("Select a student from the list to view details"),
                )
              : _buildStudentDetails(),
        ),
      ],
    );
  }

  Widget _buildStudentDetails() {
    final name = _selectedStudent!.child("name").value.toString();
    final dept = _selectedStudent!.child("dept").value.toString();
    final dynamic fineVal = _selectedStudent!.child("fine").value;
    final int fine = (fineVal is int)
        ? fineVal
        : int.tryParse(fineVal.toString()) ?? 0;

    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          Text("Department: $dept", style: const TextStyle(fontSize: 18)),
          Text(
            "Student ID: ${_selectedStudent!.key}",
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const Divider(height: 50),

          const Text(
            "Financial Status",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: fine > 0 ? Colors.red[50] : Colors.green[50],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: fine > 0 ? Colors.red : Colors.green),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Accumulated Fine"),
                    Text(
                      "₹$fine",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: fine > 0 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
                if (fine > 0)
                  ElevatedButton.icon(
                    onPressed: () {
                      FirebaseDatabase.instance
                          .ref()
                          .child("students")
                          .child(_selectedStudent!.key!)
                          .update({"fine": 0});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Fine Cleared Successfully"),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text("MARK AS PAID"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- STUDENT REGISTRATION FORM ---
class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});
  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _sId = TextEditingController();
  final _sName = TextEditingController();
  final _sDept = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 500,
        child: Column(
          children: [
            const SizedBox(height: 30),
            TextField(
              controller: _sId,
              decoration: const InputDecoration(
                labelText: "Student ID (e.g. A102)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _sName,
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _sDept,
              decoration: const InputDecoration(
                labelText: "Department",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_sId.text.isEmpty) return;
                  FirebaseDatabase.instance
                      .ref()
                      .child("students")
                      .child(_sId.text.toUpperCase())
                      .set({
                        "name": _sName.text,
                        "dept": _sDept.text,
                        "fine": 0,
                      });
                  _sId.clear();
                  _sName.clear();
                  _sDept.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("New Student Added to Database"),
                    ),
                  );
                },
                child: const Text("REGISTER STUDENT"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
