import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mini Facebook',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        primaryColor: const Color(0xFF1877F2),
      ),
      home: const AuthWrapper(),
    );
  }
}

// --- AUTH TRAFFIC CONTROLLER ---
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        if (snapshot.hasData) {
          return const HomePage();
        }
        return const LoginScreen();
      },
    );
  }
}

// --- 1. SPLASH SCREEN ---
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Icon(Icons.facebook, color: Color(0xFF1877F2), size: 100),
      ),
    );
  }
}

// --- 2. LOGIN SCREEN ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLogin = true;

  Future<void> _handleAuth() async {
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 80),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(hintText: "Email or Phone"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(hintText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1877F2),
                  foregroundColor: Colors.white,
                ),
                onPressed: _handleAuth,
                child: Text(isLogin ? "Log In" : "Sign Up"),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(isLogin ? "Create New Account" : "Back to Login"),
            ),
            const Divider(height: 40),
            OutlinedButton.icon(
              onPressed: _signInWithGoogle,
              icon: const Icon(Icons.g_mobiledata, size: 30),
              label: const Text("Continue with Google"),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 3. HOME PAGE (The Perfect Facebook Look) ---
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? userPhoto = user?.photoURL;

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "facebook",
            style: TextStyle(
              color: Color(0xFF1877F2),
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: -1.2,
            ),
          ),
          actions: [
            _actionButton(Icons.add_circle),
            _actionButton(Icons.search),
            _actionButton(Icons.messenger),
          ],
          bottom: const TabBar(
            indicatorColor: Color(0xFF1877F2),
            labelColor: Color(0xFF1877F2),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.home, size: 28)),
              Tab(icon: Icon(Icons.group, size: 28)),
              Tab(icon: Icon(Icons.ondemand_video, size: 28)),
              Tab(icon: Icon(Icons.storefront, size: 28)),
              Tab(icon: Icon(Icons.notifications_none, size: 28)),
              Tab(icon: Icon(Icons.menu, size: 28)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildHomeFeed(context, userPhoto),
            const Center(child: Text("Friends Page")),
            const Center(child: Text("Watch Page")),
            const Center(child: Text("Marketplace")),
            const Center(child: Text("Notifications")),
            const Center(child: Text("Menu")),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black, size: 22),
        onPressed: () {},
      ),
    );
  }

  Widget _buildHomeFeed(BuildContext context, String? userPhoto) {
    return CustomScrollView(
      slivers: [
        // Create Post Area
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: userPhoto != null
                            ? NetworkImage(userPhoto)
                            : null,
                        child: userPhoto == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // MAKE THIS EXPANDED SECTION CLICKABLE
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showCreatePostModal(context, userPhoto),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text("What's on your mind?"),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.photo_library, color: Colors.green),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Divider(thickness: 8, color: Color(0xFFF0F2F5), height: 8),
        ),
        // Stories
        SliverToBoxAdapter(child: _buildStories(userPhoto)),
        const SliverToBoxAdapter(
          child: Divider(thickness: 8, color: Color(0xFFF0F2F5), height: 8),
        ),
        // Posts
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildPostCard(context, index),
            childCount: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildStories(String? userPhoto) {
    return Container(
      height: 200,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        itemBuilder: (context, index) {
          if (index == 0) return _buildCreateStoryCard(userPhoto);
          return _buildStoryCard(index);
        },
      ),
    );
  }

  Widget _buildCreateStoryCard(String? photo) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                image: DecorationImage(
                  image: NetworkImage(photo ?? 'https://i.pravatar.cc/150'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                const Positioned(
                  top: -15,
                  child: CircleAvatar(
                    backgroundColor: Color(0xFF1877F2),
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ),
                const Positioned(
                  bottom: 5,
                  child: Text(
                    "Create\nStory",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(int index) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage('https://picsum.photos/200/400?random=$index'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Color(0xFF1877F2),
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 15,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?u=$index',
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 8,
            left: 8,
            child: Text(
              "User Name",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, int index) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                'https://i.pravatar.cc/150?u=$index',
              ),
            ),
            title: Text(
              "Friend $index",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("52m • 🌎"),
            trailing: const Icon(Icons.more_horiz),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text("This is a beautiful post on my mini facebook app!"),
          ),
          Image.network('https://picsum.photos/600/400?random=${index + 10}'),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text("👍 1.2K"), Text("45 Comments • 12 Shares")],
            ),
          ),
          const Divider(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _postActionButton(Icons.thumb_up_alt_outlined, "Like"),
              _postActionButton(Icons.chat_bubble_outline, "Comment"),
              _postActionButton(Icons.share_outlined, "Share"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _postActionButton(IconData icon, String label) {
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.grey[600]),
      label: Text(label, style: TextStyle(color: Colors.grey[600])),
    );
  }

  void _showCreatePostModal(BuildContext context, String? userPhoto) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(
            context,
          ).viewInsets.bottom, // Moves up with keyboard
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Create Post",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Divider(),
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: userPhoto != null
                      ? NetworkImage(userPhoto)
                      : null,
                ),
                const SizedBox(width: 10),
                const Text(
                  "Your Name",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            TextField(
              autofocus: true,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1877F2),
                ),
                onPressed: () {
                  // Here is where you would normally save to Firebase
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Post shared successfully!")),
                  );
                },
                child: const Text(
                  "Post",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// --- 4. PROFILE PAGE ---
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(Icons.photo, size: 50),
                ),
                Positioned(
                  bottom: -60,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 75,
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 70),
            Text(
              user?.displayName ?? "User Name",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1877F2),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Add to Story"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                  ),
                  child: const Text("Edit Profile"),
                ),
              ],
            ),
            const Divider(thickness: 5, height: 40),
            const ListTile(
              leading: Icon(Icons.work),
              title: Text("Software Engineer"),
            ),
            const ListTile(
              leading: Icon(Icons.school),
              title: Text("Studied at University"),
            ),
            const ListTile(
              leading: Icon(Icons.home),
              title: Text("Lives in Addis Ababa"),
            ),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pop(
                  context,
                ); // Optional: closes profile and goes back to login
              },
            ),
          ],
        ),
      ),
    );
  }
}
