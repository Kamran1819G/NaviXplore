import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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

  @override
  void initState() {
    super.initState();
    setState(() {
      _isMyProfile = widget.isMyProfile;
    });
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildProfileInfo()),
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(_buildTabBar()),
            pinned: true,
          ),
          _buildTabBarView(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(
          'https://picsum.photos/seed/cover/800/400',
          fit: BoxFit.cover,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings, color: Colors.white),
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
              CircleAvatar(
                radius: 40,
                backgroundImage:
                    NetworkImage('https://picsum.photos/seed/avatar/200'),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kamran Khan',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '@kamran_khan',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildBioSection(),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn('Posts', '42'),
              _buildStatColumn('Followers', '1.2K'),
              _buildStatColumn('Following', '567'),
            ],
          ),
          SizedBox(height: 16),
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
        duration: Duration(milliseconds: 300),
        height: _isBioExpanded ? null : 80,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
              style: TextStyle(fontSize: 14),
              maxLines: _isBioExpanded ? null : 2,
              overflow: _isBioExpanded ? null : TextOverflow.ellipsis,
            ),
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildEditProfileButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        child: Text('Edit Profile'),
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
        onPressed: () {},
        child: Text('Follow'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Theme.of(context).primaryColor,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey,
        tabs: [
          Tab(icon: Icon(Icons.grid_on), text: 'Posts'),
          Tab(icon: Icon(Icons.favorite_border), text: 'Likes'),
          Tab(icon: Icon(Icons.bookmark_border), text: 'Saved'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildMasonryGrid(),
          _buildLikedPosts(),
          _buildSavedPosts(),
        ],
      ),
    );
  }

  Widget _buildMasonryGrid() {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      itemBuilder: (context, index) {
        return Image.network(
          'https://picsum.photos/seed/${index + 1}/300/${200 + (index % 3) * 100}',
          fit: BoxFit.cover,
        );
      },
    );
  }

  Widget _buildLikedPosts() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundImage:
                NetworkImage('https://picsum.photos/seed/liked${index}/200'),
          ),
          title: Text('Liked Post ${index + 1}'),
          subtitle: Text(
              'You liked this post on ${DateTime.now().subtract(Duration(days: index)).toString().split(' ')[0]}'),
        );
      },
    );
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
