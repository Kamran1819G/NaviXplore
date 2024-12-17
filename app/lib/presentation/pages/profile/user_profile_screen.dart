import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:navixplore/presentation/controllers/user_profile_controller.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final bool isMyProfile;

  const UserProfileScreen(
      {Key? key, required this.userId, required this.isMyProfile})
      : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool? _isMyProfile;
  bool _isBioExpanded = false;
  late final UserProfileController _profileController;

  // Default cover image URL
  static const String _defaultCoverImageUrl =
      'https://picsum.photos/seed/cover/800/400';

  @override
  void initState() {
    super.initState();
    _profileController = Get.put(UserProfileController(userId: widget.userId));
    setState(() {
      _isMyProfile = widget.isMyProfile;
    });
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    Get.delete<UserProfileController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
            () => _profileController.isLoading
            ? const Center(child: CircularProgressIndicator())
            : NestedScrollView( // Use NestedScrollView for smoother scrolling
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _buildSliverAppBar(),
              SliverToBoxAdapter(child: _buildProfileInfo()),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(_buildTabBar()),
                pinned: true,
              ),
            ];
          },
          body: _buildTabBarView(),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(
          _defaultCoverImageUrl,
          fit: BoxFit.cover,
        ),
      ),
      actions: [
        if (_isMyProfile!)
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // TODO: Implement settings action
            },
          ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Obx(() => CircleAvatar(
                radius: 40,
                backgroundImage: _profileController.user?.profileImage ==
                    null
                    ? const NetworkImage(
                    'https://picsum.photos/seed/avatar/200')
                    : NetworkImage(_profileController.user!.profileImage!),
              )),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                      _profileController.user?.displayName ?? '',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    )),
                    Obx(() => Text(
                      '@${_profileController.user?.username?.replaceAll(' ', '_').toLowerCase()}',
                      style:
                      const TextStyle(fontSize: 16, color: Colors.grey),
                    )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBioSection(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Obx(() => _buildStatColumn(
                  'Posts', _profileController.user?.postCount.toString() ?? '0')),
              Obx(() => _buildStatColumn('Followers',
                  _profileController.user?.followerCount.toString() ?? '0')),
              Obx(() => _buildStatColumn('Following',
                  _profileController.user?.followingCount.toString() ?? '0')),
            ],
          ),
          const SizedBox(height: 16),
          _isMyProfile! ? _buildEditProfileButton() : _buildFollowButton(),
        ],
      ),
    );
  }

  Widget _buildBioSection() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isBioExpanded = !_isBioExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isBioExpanded ? null : 80,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
              _profileController.user?.bio ?? '',
              style: const TextStyle(fontSize: 14),
              maxLines: _isBioExpanded ? null : 2,
              overflow: _isBioExpanded ? null : TextOverflow.ellipsis,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(count,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildEditProfileButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        child: const Text('Edit Profile'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).primaryColor,
          side: BorderSide(color: Theme.of(context).primaryColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildFollowButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleFollowUnfollow,
        child: Obx(() => Text(_profileController.isFollowing ? 'Unfollow' : 'Follow')),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  void _handleFollowUnfollow() {
    if (_profileController.isFollowing) {
      _profileController.unfollowUser();
    } else {
      _profileController.followUser();
    }
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Theme.of(context).primaryColor,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(icon: Icon(Icons.grid_on), text: 'Posts'),
          Tab(icon: Icon(Icons.bookmark_border), text: 'Saved'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildMasonryGrid(),
        _buildSavedPosts(),
      ],
    );
  }

  Widget _buildMasonryGrid() {
    return Obx(() => MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      itemCount: _profileController.posts.length,
      itemBuilder: (context, index) {
        return Image.network(
          _profileController.posts[index].imageUrl,
          fit: BoxFit.cover,
        );
      },
    ));
  }

  Widget _buildSavedPosts() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundImage:
            NetworkImage('https://picsum.photos/seed/saved${index}/200'),
          ),
          title: Text('Saved Post ${index + 1}'),
          subtitle: Text(
              'You saved this post on ${DateTime.now().subtract(Duration(days: index)).toString().split(' ')[0]}'),
          trailing: Icon(Icons.bookmark, color: Theme.of(context).primaryColor),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => 56.0;

  @override
  double get maxExtent => 56.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}