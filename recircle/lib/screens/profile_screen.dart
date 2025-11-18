import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'item_detail_screen.dart';

class ProfileScreen extends HookWidget {
  const ProfileScreen({super.key});

  // Helper method: Build stat item
  // Helper method: Build info row
  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method: Build item grid tile
  Widget _buildItemGridTile(BuildContext context, Item item) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemDetailScreen(item: item),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: item.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.error),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            // Item Info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: item.isForBorrow
                          ? Colors.blue[50]
                          : Colors.orange[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.typeLabel,
                      style: TextStyle(
                        fontSize: 10,
                        color: item.isForBorrow
                            ? Colors.blue[700]
                            : Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build user stats section
  // Build compact user stats section
  Widget _buildCompactStats(List<Item> userItems) {
    return Container(
      padding: const EdgeInsets.all(12), // Smaller padding
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCompactStatItem(
            count: userItems.length,
            label: 'Items',
            icon: Icons.recycling,
          ),
          _buildCompactStatItem(
            count: 12, // Mock data
            label: 'Connects',
            icon: Icons.people,
          ),
          _buildCompactStatItem(
            count: 3, // Mock data
            label: 'Reviews',
            icon: Icons.star,
          ),
        ],
      ),
    );
  }

  // Build compact stat item
  Widget _buildCompactStatItem({
    required int count,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6), // Smaller padding
          decoration: BoxDecoration(
            color: Colors.green[100],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: Colors.green[700]), // Smaller icon
        ),
        const SizedBox(height: 2),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 14, // Smaller font
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10, // Smaller font
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // Build user info section
  Widget _buildUserInfo(User? user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user?.hasBio ?? false) ...[
            const Text(
              'About Me',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(user!.bio!, style: const TextStyle(fontSize: 16, height: 1.5)),
            const SizedBox(height: 16),
          ],
          _buildInfoRow(Icons.email, 'Email', user?.email ?? ''),
          if (user?.hasLocation ?? false)
            _buildInfoRow(Icons.location_on, 'Location', user!.location!),
          if (user?.phoneNumber != null)
            _buildInfoRow(Icons.phone, 'Phone', user!.phoneNumber!),
          _buildInfoRow(
            Icons.calendar_today,
            'Member since',
            user?.joinDate ?? '',
          ),
        ],
      ),
    );
  }

  // Build items grid
  Widget _buildItemsGrid(BuildContext context, List<Item> userItems) {
    if (userItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No items shared yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start sharing items to build your profile!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Share First Item'),
              onPressed: () {
                Navigator.pushNamed(context, '/create_item').then((_) {
                  // Refresh after potentially adding item
                  // We'll need to pass a callback or use state management
                });
              },
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: userItems.length,
      itemBuilder: (context, index) {
        final item = userItems[index];
        return _buildItemGridTile(context, item);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = useState<User?>(null);
    final userItems = useState<List<Item>>([]);
    final isLoading = useState(true);
    final errorMessage = useState<String?>(null);

    // Fetch user profile and their items
    Future<void> fetchUserData() async {
      try {
        isLoading.value = true;
        errorMessage.value = null;

        // For now, we'll use the current user. Later we can fetch by ID
        final currentUsername = await AuthService.getUsername();

        // In a real app, we'd fetch user by ID from API
        // For now, we'll create a mock user from stored data
        final userData = User(
          id: 1,
          username: currentUsername ?? 'Unknown User',
          email: 'user@example.com', // We'd get this from API
          bio: 'Eco-warrior fighting for a circular economy! ♻️',
          location: 'Sicily, Italy',
          phoneNumber: '+39 123 456 7890',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        );

        user.value = userData;

        // Fetch user's items
        final response = await ApiService().fetchItems();
        final allItems = response.map((data) => Item.fromJson(data)).toList();

        // Filter to show only current user's items (simplified)
        userItems.value = allItems
            .where((item) => item.owner.username == currentUsername)
            .toList();
      } catch (e) {
        errorMessage.value = 'Failed to load profile: $e';
        print('Profile error: $e');
      } finally {
        isLoading.value = false;
      }
    }

    // Initial load
    useEffect(() {
      fetchUserData();
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit profile screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit profile coming soon!')),
              );
            },
          ),
        ],
      ),
      body: isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.value != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(errorMessage.value!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: fetchUserData,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            )
          : DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  // Profile Header
                  // Profile Header
                  Container(
                    padding: const EdgeInsets.all(16), // Reduced padding
                    decoration: BoxDecoration(
                      color: Colors.green,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.green[700]!, Colors.green[400]!],
                      ),
                    ),
                    child: Column(
                      children: [
                        // Avatar and Name in a row for more compact layout
                        Row(
                          children: [
                            // Avatar
                            Container(
                              width: 80, // Smaller avatar
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 48, // Smaller icon
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Name and basic info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.value?.displayName ?? 'Unknown User',
                                    style: const TextStyle(
                                      fontSize: 20, // Slightly smaller
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.value?.joinDate ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Compact Stats
                        _buildCompactStats(userItems.value),
                      ],
                    ),
                  ),
                  // Tab Bar
                  Container(
                    color: Colors.white,
                    child: const TabBar(
                      labelColor: Colors.green,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.green,
                      tabs: [
                        Tab(text: 'My Items'),
                        Tab(text: 'About'),
                      ],
                    ),
                  ),
                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      children: [
                        // My Items Tab
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildItemsGrid(context, userItems.value),
                        ),
                        // About Tab
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildUserInfo(user.value),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
