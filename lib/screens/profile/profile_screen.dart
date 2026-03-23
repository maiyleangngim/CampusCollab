// =============================================================================
// PROFILE SCREEN
// Owner: [assign to teammate]
// TODO: Build the profile UI here
// =============================================================================

import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('CampusCollab Profile'),
          actions: [
            IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: "About"),
              Tab(text: "Academic"),
              Tab(text: "Collaboration"), // Replaces Progress
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBasicTab(context),
            _buildAcademicTab(),
            _buildCollabTab(), // Updated to focus on P2P
          ],
        ),
      ),
    );
  }

  // --- TAB 1: BASIC (Identity & Contact) ---
  Widget _buildBasicTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildAvatar(context),
          const SizedBox(height: 16),
          const Text("John Doe", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("@johndoe_24", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          _buildInfoTile(Icons.school_outlined, "University", "City Campus University"),
          _buildInfoTile(Icons.email_outlined, "Student Email", "j.doe@campus.edu"),
          _buildInfoTile(Icons.chat_bubble_outline, "Communication", "Prefers In-person & Discord"),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "\"Always down to study for CS midterms. I have great notes for Data Structures!\"",
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: ACADEMIC (Skills & Peer Mentoring) ---
  Widget _buildAcademicTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Study Level"),
          const ListTile(
            leading: Icon(Icons.workspace_premium, color: Colors.blue),
            title: Text("Computer Science Major"),
            subtitle: Text("3rd Year Undergraduate"),
          ),
          const Divider(),
          _buildSectionTitle("I Can Help With:"), // Peer-to-peer focused
          Wrap(
            spacing: 8,
            children: ["Java", "Mobile Dev", "Calculus I"]
                .map((label) => Chip(
                backgroundColor: Colors.blue[50],
                label: Text(label, style: const TextStyle(color: Colors.blue))
            )).toList(),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle("I'm Looking for Help In:"), // Collaboration focused
          Wrap(
            spacing: 8,
            children: ["Discrete Math", "Machine Learning"]
                .map((label) => Chip(
                backgroundColor: Colors.orange[50],
                label: Text(label, style: const TextStyle(color: Colors.orange))
            )).toList(),
          ),
        ],
      ),
    );
  }

  // --- TAB 3: COLLABORATION (Stats & Contribution) ---
  Widget _buildCollabTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard("12", "Groups Joined", Icons.group, Colors.blue),
              _buildStatCard("4.8", "Peer Rating", Icons.star, Colors.amber),
              _buildStatCard("15", "Resourced Shared", Icons.file_present, Colors.green),
            ],
          ),
          const SizedBox(height: 30),
          _buildSectionTitle("Recent Collaboration Activity"),
          _buildActivityItem("Shared 'Exam Prep PDF' in Python Group"),
          _buildActivityItem("Joined 'Late Night Coffee Study' Session"),
          _buildActivityItem("Voted 'Most Helpful' in Algorithms Chat"),
          const SizedBox(height: 24),
          _buildSectionTitle("My Study Badges"),
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Tooltip(message: "Early Bird", child: Icon(Icons.wb_sunny, size: 45, color: Colors.orange)),
              SizedBox(width: 15),
              Tooltip(message: "Top Contributor", child: Icon(Icons.auto_awesome, size: 45, color: Colors.purple)),
              SizedBox(width: 15),
              Tooltip(message: "Verified Student", child: Icon(Icons.verified, size: 45, color: Colors.blue)),
            ],
          )
        ],
      ),
    );
  }

  // --- REUSABLE COMPONENTS ---

  Widget _buildAvatar(BuildContext context) {
    return Stack(
      children: [
        const CircleAvatar(
          radius: 55,
          backgroundColor: Colors.blue,
          child: CircleAvatar(radius: 52, backgroundImage: NetworkImage('https://via.placeholder.com/150')),
        ),
        Positioned(
          bottom: 0, right: 0,
          child: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            radius: 18,
            child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _buildActivityItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
