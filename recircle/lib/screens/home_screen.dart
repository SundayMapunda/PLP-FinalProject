import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = useState<List<Item>>([]);
    final isLoading = useState(true);
    final errorMessage = useState<String?>(null);
    final refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

    // Fetch items from API
    Future<void> fetchItems() async {
      try {
        isLoading.value = true;
        errorMessage.value = null;

        final response = await ApiService().fetchItems();
        final itemList = (response as List)
            .map((data) => Item.fromJson(data))
            .toList();

        items.value = itemList;
      } catch (e) {
        errorMessage.value = 'Failed to load items: $e';
        print('Error fetching items: $e');
      } finally {
        isLoading.value = false;
      }
    }

    // Initial load
    useEffect(() {
      fetchItems();
      return null;
    }, []);

    // Build item card
    Widget _buildItemCard(Item item) {
      return Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Image
            if (item.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
            // Item Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Category
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.category.replaceAll('_', ' '),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    item.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Location and Type
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.location,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: item.isForBorrow
                              ? Colors.blue[50]
                              : Colors.orange[50],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          item.typeLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: item.isForBorrow
                                ? Colors.blue[700]
                                : Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Owner info
                  Row(
                    children: [
                      Icon(Icons.person, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        'Posted by ${item.owner.username}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ReCircle'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        key: refreshIndicatorKey,
        onRefresh: fetchItems,
        child: Builder(
          builder: (context) {
            if (isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (errorMessage.value != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage.value!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: fetchItems,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            if (items.value.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No items yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Be the first to share something!',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to create item screen
                      },
                      child: const Text('Add First Item'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: items.value.length,
              itemBuilder: (context, index) {
                final item = items.value[index];
                return _buildItemCard(item);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create_item').then((refresh) {
            if (refresh == true) {
              fetchItems();
            }
          });
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
