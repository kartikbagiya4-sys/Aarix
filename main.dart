
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AarixApp());
}

const blue = Color(0xFF1687FF);
const lightBlue = Color(0xFF54A9FF);
const bg = Color(0xFF050608);
const card = Color(0xFF0B0E13);
const muted = Color(0xFF9DA8B6);

class AarixApp extends StatelessWidget {
  const AarixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aarix',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: blue,
          secondary: lightBlue,
          surface: card,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class AppPost {
  String author;
  String text;
  int likes;
  bool liked;
  final List<String> comments;

  AppPost({
    required this.author,
    required this.text,
    this.likes = 0,
    this.liked = false,
    List<String>? comments,
  }) : comments = comments ?? [];
}

class LocalStore extends ChangeNotifier {
  String name = 'Aarix User';
  String email = 'demo@aarix.app';
  bool loggedIn = false;

  final List<AppPost> posts = [
    AppPost(
      author: 'Aarix',
      text: 'Welcome to Aarix — your privacy-first social space.',
      likes: 12,
      comments: ['Welcome!'],
    ),
    AppPost(
      author: 'Aarix Team',
      text: 'V2.1 is now interactive. Create posts, like, comment and edit your profile.',
      likes: 8,
    ),
  ];

  void login({String? newName, String? newEmail}) {
    if (newName != null && newName.trim().isNotEmpty) name = newName.trim();
    if (newEmail != null && newEmail.trim().isNotEmpty) email = newEmail.trim();
    loggedIn = true;
    notifyListeners();
  }

  void logout() {
    loggedIn = false;
    notifyListeners();
  }

  void createPost(String text) {
    final value = text.trim();
    if (value.isEmpty) return;
    posts.insert(0, AppPost(author: name, text: value));
    notifyListeners();
  }

  void toggleLike(AppPost post) {
    post.liked = !post.liked;
    post.likes += post.liked ? 1 : -1;
    notifyListeners();
  }

  void addComment(AppPost post, String comment) {
    final value = comment.trim();
    if (value.isEmpty) return;
    post.comments.add(value);
    notifyListeners();
  }

  void updateProfile(String newName, String newEmail) {
    if (newName.trim().isNotEmpty) name = newName.trim();
    if (newEmail.trim().isNotEmpty) email = newEmail.trim();
    notifyListeners();
  }
}

final store = LocalStore();

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AarixMark(size: 108),
          SizedBox(height: 22),
          Text('AARIX', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 8)),
          SizedBox(height: 8),
          Text('Privacy first. Always.', style: TextStyle(color: muted)),
        ],
      ),
    ),
  );
}

class AarixMark extends StatelessWidget {
  final double size;
  const AarixMark({super.key, required this.size});

  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: blue, width: 2),
      boxShadow: const [BoxShadow(color: Color(0x551687FF), blurRadius: 32, spreadRadius: 6)],
    ),
    child: Center(
      child: Text('A', style: TextStyle(color: lightBlue, fontSize: size * .57, fontWeight: FontWeight.w800)),
    ),
  );
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool login = true;
  bool obscure = true;
  bool accepted = false;
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    name.dispose(); email.dispose(); password.dispose();
    super.dispose();
  }

  void submit() {
    final e = email.text.trim();
    final validEmail = e.contains('@') && e.contains('.');
    final validPassword = password.text.length >= 8;
    if ((!login && name.text.trim().length < 2) || !validEmail || !validPassword || (!login && !accepted)) {
      final message = !login && name.text.trim().length < 2
          ? 'Enter your name.'
          : !validEmail ? 'Enter a valid email.'
          : !validPassword ? 'Password must contain at least 8 characters.'
          : 'Accept the privacy notice to continue.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    store.login(newName: name.text, newEmail: e);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell()));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.shield_outlined, size: 46, color: lightBlue),
                const SizedBox(height: 14),
                Text(login ? 'Welcome to Aarix' : 'Join Aarix',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text('No ads. Privacy-first by design.', textAlign: TextAlign.center, style: TextStyle(color: muted)),
                const SizedBox(height: 30),
                if (!login) ...[
                  field(name, 'Name', Icons.person_outline),
                  const SizedBox(height: 14),
                ],
                field(email, 'Email', Icons.mail_outline, type: TextInputType.emailAddress),
                const SizedBox(height: 14),
                TextField(
                  controller: password,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => obscure = !obscure),
                      icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                    ),
                  ),
                ),
                if (!login)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: accepted,
                    onChanged: (v) => setState(() => accepted = v ?? false),
                    title: const Text('I understand the privacy notice.'),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 54,
                  child: FilledButton(onPressed: submit, child: Text(login ? 'Login' : 'Create account')),
                ),
                TextButton(
                  onPressed: () => setState(() => login = !login),
                  child: Text(login ? 'Create a new account' : 'I already have an account'),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Demo authentication: credentials are not stored or sent to a server in this build.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF707987), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget field(TextEditingController c, String label, IconData icon, {TextInputType? type}) => TextField(
    controller: c, keyboardType: type,
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
  );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    store.addListener(_refresh);
  }

  @override
  void dispose() {
    store.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomePage(),
      const ExplorePage(),
      const CreatePage(),
      const ChatPage(),
      const ProfilePage(),
    ];
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        backgroundColor: const Color(0xFF080B10),
        indicatorColor: const Color(0x331687FF),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle), label: 'Create'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => page(
    'Aarix',
    ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: store.posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, i) => PostCard(post: store.posts[i]),
    ),
  );
}

class PostCard extends StatelessWidget {
  final AppPost post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF171D26))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const CircleAvatar(backgroundColor: Color(0xFF0F3152), child: Icon(Icons.person, color: lightBlue)),
        const SizedBox(width: 12),
        Expanded(child: Text(post.author, style: const TextStyle(fontWeight: FontWeight.w700))),
      ]),
      const SizedBox(height: 16),
      Text(post.text, style: const TextStyle(fontSize: 16)),
      const SizedBox(height: 18),
      Row(children: [
        IconButton(
          onPressed: () => store.toggleLike(post),
          icon: Icon(post.liked ? Icons.favorite : Icons.favorite_border, color: post.liked ? Colors.redAccent : null),
        ),
        Text('${post.likes}'),
        const SizedBox(width: 12),
        IconButton(onPressed: () => showComments(context, post), icon: const Icon(Icons.chat_bubble_outline)),
        Text('${post.comments.length}'),
        const Spacer(),
        IconButton(onPressed: () => shareDialog(context), icon: const Icon(Icons.share_outlined)),
      ]),
    ]),
  );
}

Future<void> showComments(BuildContext context, AppPost post) async {
  final controller = TextEditingController();
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 18, bottom: MediaQuery.of(ctx).viewInsets.bottom + 16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Comments', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        if (post.comments.isEmpty)
          const Padding(padding: EdgeInsets.all(18), child: Text('No comments yet.'))
        else
          ...post.comments.map((c) => ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text(c))),
        Row(children: [
          Expanded(child: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Write a comment...'))),
          IconButton(
            onPressed: () {
              store.addComment(post, controller.text);
              controller.clear();
              Navigator.pop(ctx);
            },
            icon: const Icon(Icons.send, color: lightBlue),
          ),
        ]),
      ]),
    ),
  );
}

Future<void> shareDialog(BuildContext context) async {
  await showDialog(context: context, builder: (_) => AlertDialog(
    title: const Text('Share'),
    content: const Text('Sharing is prepared for the next backend/media phase.'),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
  ));
}

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});
  @override
  Widget build(BuildContext context) => page('Explore', const EmptyState(icon: Icons.explore_outlined, text: 'Explore discovery will connect to public content in the backend phase.'));
}

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});
  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final controller = TextEditingController();
  @override
  void dispose() { controller.dispose(); super.dispose(); }

  void create() {
    if (controller.text.trim().isEmpty) return;
    store.createPost(controller.text);
    controller.clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post created locally.')));
  }

  @override
  Widget build(BuildContext context) => page('Create', Column(children: [
    TextField(
      controller: controller,
      maxLines: 6,
      maxLength: 500,
      decoration: const InputDecoration(
        hintText: 'What do you want to share?',
        alignLabelWithHint: true,
      ),
    ),
    const SizedBox(height: 12),
    SizedBox(width: double.infinity, height: 52, child: FilledButton.icon(
      onPressed: create,
      icon: const Icon(Icons.send),
      label: const Text('Publish post'),
    )),
    const SizedBox(height: 18),
    const EmptyState(icon: Icons.photo_library_outlined, text: 'Photo/video upload will be added after secure media storage is configured.'),
  ]));

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});
  @override
  Widget build(BuildContext context) => page('Chat', Column(children: [
    ListTile(
      leading: const CircleAvatar(backgroundColor: Color(0xFF0F3152), child: Icon(Icons.shield, color: lightBlue)),
      title: const Text('Aarix Support'),
      subtitle: const Text('Secure chat foundation — local demo'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatDemoPage())),
    ),
    const SizedBox(height: 10),
    const EmptyState(icon: Icons.lock_outline, text: 'Real private messaging will require a secure backend and server-side access rules.'),
  ]));
}

class ChatDemoPage extends StatefulWidget {
  const ChatDemoPage({super.key});
  @override
  State<ChatDemoPage> createState() => _ChatDemoPageState();
}
class _ChatDemoPageState extends State<ChatDemoPage> {
  final controller = TextEditingController();
  final messages = <String>['Welcome to Aarix Support.'];
  @override
  void dispose() { controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Aarix Support')),
    body: Column(children: [
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: messages.length,
        itemBuilder: (_, i) => Align(
          alignment: i.isEven ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: i.isEven ? card : const Color(0xFF0F3152), borderRadius: BorderRadius.circular(16)),
            child: Text(messages[i]),
          ),
        ),
      )),
      SafeArea(child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          Expanded(child: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Message...'))),
          IconButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              setState(() { messages.add(controller.text.trim()); controller.clear(); });
            },
            icon: const Icon(Icons.send, color: lightBlue),
          ),
        ]),
      )),
    ]),
  );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => page('Profile', Column(children: [
    const CircleAvatar(radius: 44, backgroundColor: Color(0xFF0F3152), child: Icon(Icons.person, size: 46, color: lightBlue)),
    const SizedBox(height: 12),
    Text(store.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
    const SizedBox(height: 4),
    Text(store.email, style: const TextStyle(color: muted)),
    const SizedBox(height: 20),
    ListTile(
      leading: const Icon(Icons.edit_outlined),
      title: const Text('Edit profile'),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage())),
    ),
    ListTile(
      leading: const Icon(Icons.privacy_tip_outlined),
      title: const Text('Privacy & Security'),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPage())),
    ),
    ListTile(
      leading: const Icon(Icons.settings_outlined),
      title: const Text('Settings'),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
    ),
    const SizedBox(height: 10),
    OutlinedButton.icon(
      onPressed: () {
        store.logout();
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthScreen()), (_) => false);
      },
      icon: const Icon(Icons.logout),
      label: const Text('Log out'),
    ),
  ]));

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}
class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController name = TextEditingController(text: store.name);
  late final TextEditingController email = TextEditingController(text: store.email);
  @override
  void dispose() { name.dispose(); email.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Edit profile')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Center(child: CircleAvatar(radius: 48, backgroundColor: Color(0xFF0F3152), child: Icon(Icons.person, size: 50, color: lightBlue))),
      const SizedBox(height: 24),
      TextField(controller: name, decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_outline))),
      const SizedBox(height: 14),
      TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline))),
      const SizedBox(height: 20),
      FilledButton(onPressed: () {
        store.updateProfile(name.text, email.text);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated locally.')));
      }, child: const Text('Save changes')),
    ]),
  );
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: ListView(padding: const EdgeInsets.all(8), children: [
      SwitchListTile(value: true, onChanged: (_) {}, title: const Text('Privacy mode'), subtitle: const Text('Aarix is designed privacy-first.')),
      ListTile(leading: const Icon(Icons.notifications_outlined), title: const Text('Notifications'), onTap: () => showInfo(context, 'Notification controls will be connected later.')),
      ListTile(leading: const Icon(Icons.language_outlined), title: const Text('Language'), subtitle: const Text('English (demo)'), onTap: () => showInfo(context, 'More languages will be added in a later release.')),
      ListTile(leading: const Icon(Icons.info_outline), title: const Text('About Aarix'), subtitle: const Text('V2.1 local functional foundation')),
    ]),
  );
}

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Privacy & Security')),
    body: ListView(padding: const EdgeInsets.all(16), children: const [
      SecurityCard(icon: Icons.lock_outline, title: 'Private by default', text: 'This V2.1 build does not send credentials to a server.'),
      SecurityCard(icon: Icons.visibility_off_outlined, title: 'Minimal permissions', text: 'Camera, microphone and media permissions are not requested by this build.'),
      SecurityCard(icon: Icons.delete_outline, title: 'Account deletion', text: 'A real deletion flow will be implemented with the production backend.'),
    ]),
  );
}

class SecurityCard extends StatelessWidget {
  final IconData icon; final String title; final String text;
  const SecurityCard({super.key, required this.icon, required this.title, required this.text});
  @override
  Widget build(BuildContext context) => Card(
    color: card,
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      contentPadding: const EdgeInsets.all(14),
      leading: Icon(icon, color: lightBlue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text(text)),
    ),
  );
}

Widget page(String title, Widget child) => SafeArea(
  child: CustomScrollView(slivers: [
    SliverAppBar(pinned: true, backgroundColor: bg, title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
    SliverPadding(padding: const EdgeInsets.all(16), sliver: SliverToBoxAdapter(child: child)),
  ]),
);

class EmptyState extends StatelessWidget {
  final IconData icon; final String text;
  const EmptyState({super.key, required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(20)),
    child: Column(children: [
      Icon(icon, size: 42, color: lightBlue),
      const SizedBox(height: 14),
      Text(text, textAlign: TextAlign.center, style: const TextStyle(color: muted)),
    ]),
  );
}

Future<void> showInfo(BuildContext context, String text) => showDialog(
  context: context,
  builder: (_) => AlertDialog(
    content: Text(text),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
  ),
);
