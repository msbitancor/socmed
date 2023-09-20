import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'main.dart';
import 'show_my_profile.dart';
import 'models.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class ShowSocialMedia extends StatefulWidget {
  final String token;
  final String username;
  final String firstName;
  final String lastName;
  final String password;

  const ShowSocialMedia(
      this.token, this.username, this.firstName, this.lastName, this.password,
      {Key? key})
      : super(key: key);

  @override
  State<ShowSocialMedia> createState() => _ShowSocialMediaState();
}

class _ShowSocialMediaState extends State<ShowSocialMedia> {
  final ScrollController _scrollController = ScrollController();
  DBHelper db = DBHelper();

  // For pagination
  late Future<List<Post>> publicPosts;
  late List<Post> nextPosts;
  late List<Post> currentPosts;
  bool loading = false, allLoaded = false;

  late int postCount = 30; // Limit of the posts
  late String nextId; // For getting latest id

  final TextEditingController _user =
      TextEditingController(); //controller for getting title
  final TextEditingController _editText =
      TextEditingController(); //controller for getting text

  late Future<List<User>> friendsList;

  // For fetching new posts
  generateNewPosts() async {
    if (allLoaded) return;
    setState(() {
      loading = true;
    });

    // Fetch new posts
    nextPosts = await db.fetchPublicPosts(
        http.Client(), widget.token, nextId, postCount);

    // Fetch current posts from public posts
    currentPosts = await publicPosts;

    // Append new posts to current
    if (nextPosts.isNotEmpty) {
      currentPosts.addAll(nextPosts);
    }

    // Pass to publicPosts to list posts via pagination
    setState(() {
      publicPosts = Future.value(currentPosts);
      loading = false;
      allLoaded = nextPosts.isEmpty;
    });
  }

  @override
  void initState() {
    super.initState();

    // Fetch first batch of posts
    publicPosts =
        db.fetchPublicPosts(http.Client(), widget.token, '', postCount);

    // Get friends list
    friendsList = db.fetchFriends(http.Client(), widget.token);

    // Generate posts if end of the scroll
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !loading) {
        generateNewPosts();
      }
    });
  }

  // Dispose controller
  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.amber),
        backgroundColor: const Color.fromARGB(255, 66, 5, 22),
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.amber),
        ),
        actions: [
          // For searching a user
          IconButton(
            icon: const Icon(Icons.search_outlined),
            tooltip: 'Search a User',
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                      title: const Text("VIEW A PROFILE"),
                      content: TextField(
                        style: const TextStyle(color: Colors.amber),
                        autofocus: true, // keyboard pops up automatically
                        controller: _user,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color.fromARGB(255, 66, 5, 22),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.amber),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.amber),
                          ),
                        ),
                      ),
                      titleTextStyle: const TextStyle(color: Colors.amber),
                      backgroundColor: const Color.fromARGB(255, 66, 5, 22),
                      actions: <Widget>[
                        TextButton(
                          child: const Text(
                            'CANCEL',
                            style: TextStyle(color: Colors.amber),
                          ),
                          onPressed: () {
                            _user.clear();
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text(
                            'SEARCH',
                            style: TextStyle(color: Colors.amber),
                          ),
                          onPressed: () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Searching User...')),
                            );

                            // Request to get a user with its id
                            final credentials =
                                await db.getUser(_user.text, widget.token);

                            if (credentials[0] == '200') {
                              final userUsername = credentials[1];
                              final userFirstName = credentials[2];
                              final userLastName = credentials[3];

                              // Fetch friends list first
                              friendsList =
                                  db.fetchFriends(http.Client(), widget.token);

                              // Assign to friends
                              final friends = await friendsList;

                              // For checking if friend
                              bool isFriend = false;

                              for (int i = 0; i < friends.length; i++) {
                                if (friends[i].username == userUsername) {
                                  isFriend =
                                      true; // set isFriend to true if friend
                                }
                              }
                              // Go to next page
                              // Await first before going back to homepage
                              Future.delayed(Duration.zero).then((_) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ShowUserProfile(
                                              widget.token,
                                              userUsername,
                                              userFirstName,
                                              userLastName,
                                              isFriend,
                                            )));
                              });
                            } else {
                              Future.delayed(Duration.zero).then((_) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Cannot Find User!')),
                                );
                              });
                            }

                            _user.clear();
                          },
                        ),
                      ]);
                },
              );
            },
          )
        ],
      ),
      backgroundColor: const Color.fromARGB(170, 125, 25, 53),

      // Navigation bar
      drawer: Drawer(
          backgroundColor: const Color.fromARGB(170, 125, 25, 53),
          child: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              buildHeader(context),
              buildMenuItems(context),
            ],
          ))),

      // News feed
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            const Divider(),
            viewPublicPosts(),
          ]),
    );
  }

  /*
    Description: For building the ListView of public posts

    Parameters: none
    Returns an Expanded of the FutureBuilder that builds the List View
  */
  Widget viewPublicPosts() {
    return Expanded(
      child: FutureBuilder(
          future: publicPosts,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return buildPosts(snapshot.data as List<Post>);
            } else {
              return const Center(
                  child:
                      CircularProgressIndicator(value: null, strokeWidth: 7.0));
            }
          }),
    );
  }

  /*
    Description: Builds the List VIew of public posts

    Parameters: publicPosts (function parameter)
    
    Returns a ListView builder containing all public posts
  */
  Widget buildPosts(List<Post> publicPost) {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: publicPost.length + (allLoaded ? 1 : 0),
      itemBuilder: (context, int index) {
        if (index < publicPost.length) {
          // Do not get private posts by users
          if (publicPost[index].public == false) {
            return const Divider(height: 0);
          }

          // Get the current id to be passed on fetching next posts
          nextId = publicPost[index].id;

          return Center(
              child: Container(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color.fromARGB(170, 125, 25, 53),
                      child: Text(
                        publicPost[index].username[0].toUpperCase(),
                        style: const TextStyle(color: Colors.amber),
                      ),
                    ),
                    onLongPress: () {
                      final data = ClipboardData(text: publicPost[index].id);
                      Clipboard.setData(data);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to Clipboard')),
                      );
                    },
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    title: Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Text(
                          '@${publicPost[index].username}',
                          style: const TextStyle(
                              color: Colors.amber, fontWeight: FontWeight.bold),
                        )),
                    subtitle: Text(
                      publicPost[index].text.trim(),
                      style: const TextStyle(color: Colors.amber),
                    ),
                    trailing: publicPost[index].username == widget.username
                        ? Wrap(
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Icons.edit_note_outlined),
                                tooltip: 'Edit Post',
                                color: Colors.amber,
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                          title: const Text("EDIT POST"),
                                          content: TextField(
                                            style: const TextStyle(
                                                color: Colors.amber),
                                            autofocus:
                                                true, // keyboard pops up automatically
                                            controller: _editText,
                                            decoration: const InputDecoration(
                                              filled: true,
                                              fillColor: Color.fromARGB(
                                                  255, 66, 5, 22),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.amber),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.amber),
                                              ),
                                            ),
                                          ),
                                          titleTextStyle: const TextStyle(
                                              color: Colors.amber),
                                          backgroundColor: const Color.fromARGB(
                                              255, 66, 5, 22),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text(
                                                'CANCEL',
                                                style: TextStyle(
                                                    color: Colors.amber),
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                _editText.clear();
                                              },
                                            ),

                                            // Edit post as public
                                            TextButton(
                                              child: const Text(
                                                'EDIT AS PUBLIC',
                                                style: TextStyle(
                                                    color: Colors.amber),
                                              ),
                                              onPressed: () async {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          'Editing Post...')),
                                                );

                                                // Request to edit post as public
                                                final String response =
                                                    await db.updatePost(
                                                        _editText.text,
                                                        true,
                                                        widget.token,
                                                        publicPost[index].id);

                                                _editText.clear();

                                                // Edit successful
                                                if (response == "200") {
                                                  await showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                            title: const Text(
                                                                "Post Edited!"),
                                                            titleTextStyle:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .amber),
                                                            backgroundColor:
                                                                const Color
                                                                        .fromARGB(
                                                                    255,
                                                                    66,
                                                                    5,
                                                                    22),
                                                            actions: <Widget>[
                                                              TextButton(
                                                                child:
                                                                    const Text(
                                                                  'OK',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .amber),
                                                                ),
                                                                onPressed: () {
                                                                  // To update post feed after creating a post
                                                                  setState(() {
                                                                    publicPosts = db.fetchPublicPosts(
                                                                        http
                                                                            .Client(),
                                                                        widget
                                                                            .token,
                                                                        '',
                                                                        postCount);
                                                                  });

                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                              ),
                                                            ]);
                                                      });

                                                  // Edit error
                                                } else {
                                                  await showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                            title:
                                                                Text(response),
                                                            content: const Text(
                                                              "Cannot edit post!",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .amber),
                                                            ),
                                                            titleTextStyle:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .amber),
                                                            backgroundColor:
                                                                const Color
                                                                        .fromARGB(
                                                                    255,
                                                                    66,
                                                                    5,
                                                                    22),
                                                            actions: <Widget>[
                                                              TextButton(
                                                                child:
                                                                    const Text(
                                                                  'OK',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .amber),
                                                                ),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                              ),
                                                            ]);
                                                      });
                                                }
                                              },
                                            ),

                                            // Edit post as private
                                            TextButton(
                                              child: const Text(
                                                'EDIT AS PRIVATE',
                                                style: TextStyle(
                                                    color: Colors.amber),
                                              ),
                                              onPressed: () async {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          'Editing Post...')),
                                                );

                                                // Request to edit post as private
                                                final String response =
                                                    await db.updatePost(
                                                        _editText.text,
                                                        false,
                                                        widget.token,
                                                        publicPost[index].id);

                                                _editText.clear();

                                                // Edit successful
                                                if (response == "200") {
                                                  await showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                            title: const Text(
                                                                "Post Edited!"),
                                                            titleTextStyle:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .amber),
                                                            backgroundColor:
                                                                const Color
                                                                        .fromARGB(
                                                                    255,
                                                                    66,
                                                                    5,
                                                                    22),
                                                            actions: <Widget>[
                                                              TextButton(
                                                                child:
                                                                    const Text(
                                                                  'OK',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .amber),
                                                                ),
                                                                onPressed: () {
                                                                  // To update post feed after creating a post
                                                                  setState(() {
                                                                    publicPosts = db.fetchPublicPosts(
                                                                        http
                                                                            .Client(),
                                                                        widget
                                                                            .token,
                                                                        '',
                                                                        postCount);
                                                                  });

                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                              ),
                                                            ]);
                                                      });

                                                  // Edit unsuccessful
                                                } else {
                                                  await showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                            title:
                                                                Text(response),
                                                            content: const Text(
                                                              "Cannot edit post!",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .amber),
                                                            ),
                                                            titleTextStyle:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .amber),
                                                            backgroundColor:
                                                                const Color
                                                                        .fromARGB(
                                                                    255,
                                                                    66,
                                                                    5,
                                                                    22),
                                                            actions: <Widget>[
                                                              TextButton(
                                                                child:
                                                                    const Text(
                                                                  'OK',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .amber),
                                                                ),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                              ),
                                                            ]);
                                                      });
                                                }
                                              },
                                            ),
                                          ]);
                                    },
                                  );
                                },
                              ),

                              // Delete a post
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'Delete Post',
                                color: Colors.amber,
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                          title: const Text("DELETE POST"),
                                          content: const Text(
                                            "Are you sure you want to delete this post?",
                                            style:
                                                TextStyle(color: Colors.amber),
                                          ),
                                          titleTextStyle: const TextStyle(
                                              color: Colors.amber),
                                          backgroundColor: const Color.fromARGB(
                                              255, 66, 5, 22),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text(
                                                'NO',
                                                style: TextStyle(
                                                    color: Colors.amber),
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                            TextButton(
                                                child: const Text(
                                                  'YES',
                                                  style: TextStyle(
                                                      color: Colors.amber),
                                                ),
                                                onPressed: () async {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Deleting Post...')),
                                                  );

                                                  // Request to delete a post
                                                  final List<String> delete =
                                                      await db.deletePost(
                                                          widget.token,
                                                          publicPost[index].id);

                                                  // Delete successful
                                                  if (delete[0] == '200') {
                                                    await showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                            title: const Text(
                                                                "POST DELETE",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .amber)),
                                                            content:
                                                                const SingleChildScrollView(
                                                                    child: Text(
                                                              "Post deleted successfully!",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .amber),
                                                            )),
                                                            titleTextStyle:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .amber),
                                                            backgroundColor:
                                                                const Color
                                                                        .fromARGB(
                                                                    255,
                                                                    66,
                                                                    5,
                                                                    22),
                                                            actions: <Widget>[
                                                              TextButton(
                                                                child:
                                                                    const Text(
                                                                  'OK',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .amber),
                                                                ),
                                                                onPressed: () {
                                                                  setState(() {
                                                                    // Update public post
                                                                    publicPosts = db.fetchPublicPosts(
                                                                        http
                                                                            .Client(),
                                                                        widget
                                                                            .token,
                                                                        '',
                                                                        postCount);
                                                                  });
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                              ),
                                                            ]);
                                                      },
                                                    );

                                                    // Delete unsuccessful
                                                  } else {
                                                    await showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                            title: Text(
                                                              'Error ${delete[0]}',
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .amber),
                                                            ),
                                                            content: Text(
                                                              delete[1],
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .amber),
                                                            ),
                                                            titleTextStyle:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .amber),
                                                            backgroundColor:
                                                                const Color
                                                                        .fromARGB(
                                                                    255,
                                                                    66,
                                                                    5,
                                                                    22),
                                                            actions: <Widget>[
                                                              TextButton(
                                                                child:
                                                                    const Text(
                                                                  'OK',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .amber),
                                                                ),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                              ),
                                                            ]);
                                                      },
                                                    );
                                                  }
                                                }),
                                          ]);
                                    },
                                  );
                                },
                              )
                            ],
                          )
                        : null,
                    tileColor: const Color.fromARGB(255, 66, 5, 22),
                  )));
        }
        return const Divider(
          height: 0,
        );
      },
    );
  }

  /*
    Description: Builds a header for the navbar

    Parameters: context (function parameter)

    Returns a container containing a profile icon, full name, and username
    to the web
  */
  Widget buildHeader(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(top: 1),
        child: UserAccountsDrawerHeader(
          accountName: Text(
            "${widget.firstName} ${widget.lastName}",
            style: const TextStyle(color: Colors.amber),
          ),
          accountEmail: Text(
            '@${widget.username}',
            style: const TextStyle(color: Colors.amber),
          ),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 66, 5, 22),
          ),
          currentAccountPicture: CircleAvatar(
            backgroundColor: const Color.fromARGB(170, 125, 25, 53),
            child: Text(
              widget.firstName[0].toUpperCase(),
              style: const TextStyle(color: Colors.amber),
              textScaleFactor: 2,
            ),
          ),
        ));
  }

  /*
    Description: Builds a navigation per Icon for navbar 

    Parameters: context (function parameter)
    
    Returns a container that holds the icon of the navigation and text
  */
  Widget buildMenuItems(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(left: 5),
        child: Column(
          children: [
            // Home button
            ListTile(
              leading: const Icon(
                Icons.home_outlined,
                color: Colors.amber,
              ),
              title: const Text("Home",
                  style: TextStyle(
                    color: Colors.amber,
                  )),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ShowSocialMedia(
                            widget.token,
                            widget.username,
                            widget.firstName,
                            widget.lastName,
                            widget.password)));
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.account_circle_outlined,
                color: Colors.amber,
              ),
              title: const Text("My Profile",
                  style: TextStyle(
                    color: Colors.amber,
                  )),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ShowMyProfile(
                            widget.token,
                            widget.username,
                            widget.firstName,
                            widget.lastName,
                            widget.password)));
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.people_rounded,
                color: Colors.amber,
              ),
              title: const Text("Friends List",
                  style: TextStyle(
                    color: Colors.amber,
                  )),
              onTap: () async {
                friendsList = db.fetchFriends(http.Client(), widget.token);
                List<User> friends = await friendsList;

                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title: const Text("FRIENDS LIST"),
                        content: SizedBox(
                            width: double.maxFinite,
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: friends.length,
                                itemBuilder: (context, int index) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: const Color.fromARGB(
                                          170, 125, 25, 53),
                                      child: Text(
                                        friends[index]
                                            .username[0]
                                            .toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.amber),
                                      ),
                                    ),
                                    title: Text(
                                      '${friends[index].firstName} ${friends[index].lastName}',
                                      style:
                                          const TextStyle(color: Colors.amber),
                                    ),
                                    subtitle: Text(
                                      '@${friends[index].username}',
                                      style:
                                          const TextStyle(color: Colors.amber),
                                    ),
                                  );
                                })),
                        titleTextStyle: const TextStyle(color: Colors.amber),
                        backgroundColor: const Color.fromARGB(255, 66, 5, 22),
                        actions: <Widget>[
                          TextButton(
                            child: const Text(
                              'OK',
                              style: TextStyle(color: Colors.amber),
                            ),
                            onPressed: () async {
                              Navigator.pop(context);
                            },
                          ),
                        ]);
                  },
                );
              },
            ),
            // Logout Button
            ListTile(
                leading: const Icon(
                  Icons.logout_outlined,
                  color: Colors.amber,
                ),
                title: const Text("Logout",
                    style: TextStyle(
                      color: Colors.amber,
                    )),
                onTap: () async {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                          title: const Text("LOGOUT"),
                          content: const Text(
                            "Are you sure you want to logout?",
                            style: TextStyle(color: Colors.amber),
                          ),
                          titleTextStyle: const TextStyle(color: Colors.amber),
                          backgroundColor: const Color.fromARGB(255, 66, 5, 22),
                          actions: <Widget>[
                            TextButton(
                              child: const Text(
                                'CANCEL',
                                style: TextStyle(color: Colors.amber),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text(
                                'YES',
                                style: TextStyle(color: Colors.amber),
                              ),
                              onPressed: () async {
                                // Call logoutUser to request logout
                                // Get the success code from request
                                final String success =
                                    await db.logoutUser(widget.token);

                                // Logout successful
                                if (success == "200") {
                                  // Await first before going back to homepage
                                  Future.delayed(Duration.zero).then((_) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const MyApp()));
                                  });
                                }
                              },
                            ),
                          ]);
                    },
                  );
                }),
          ],
        ));
  }
}

// Another class for viewing a profile of another user
class ShowUserProfile extends StatefulWidget {
  final String token;
  final String userUsername;
  final String userFirstName;
  final String userLastName;
  final bool isFriend;

  const ShowUserProfile(this.token, this.userUsername, this.userFirstName,
      this.userLastName, this.isFriend,
      {Key? key})
      : super(key: key);

  @override
  State<ShowUserProfile> createState() => _ShowUserProfileState();
}

class _ShowUserProfileState extends State<ShowUserProfile> {
  DBHelper db = DBHelper();

  // For pagination
  final ScrollController _scrollController = ScrollController();
  late Future<List<Post>> privatePosts;
  late List<Post> nextPosts;
  late List<Post> currentPosts;
  bool loading = false, allLoaded = false;
  late bool _isFriend = widget.isFriend;

  // For hiding container
  bool scrollVisibility = true;
  late String nextId; // For getting latest id

  late Future<List<User>> friendsList;

  // For fetching new posts
  generateNewPosts() async {
    if (allLoaded) return;
    setState(() {
      loading = true;
    });

    // Fetch new posts
    nextPosts = await db.fetchUserPosts(
        widget.userUsername, http.Client(), widget.token, nextId);

    // Fetch current posts
    currentPosts = await privatePosts;

    // Append new posts to current
    if (nextPosts.isNotEmpty) {
      currentPosts.addAll(nextPosts);
    }

    // Pass current to privatePosts
    setState(() {
      privatePosts = Future.value(currentPosts);
      loading = false;
      allLoaded = nextPosts.isEmpty;
    });
  }

  @override
  void initState() {
    super.initState();

    // Fetch first batch of posts
    privatePosts =
        db.fetchUserPosts(widget.userUsername, http.Client(), widget.token, '');

    // Get friends list
    friendsList = db.fetchFriends(http.Client(), widget.token);

    _scrollController.addListener(() {
      // Generate new posts if end of the scroll
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !loading) {
        generateNewPosts();
      }

      // Hide container when user scrolls down
      if (_scrollController.position.pixels > 0 ||
          _scrollController.position.pixels <
              _scrollController.position.maxScrollExtent) {
        scrollVisibility = false;
      } else {
        scrollVisibility = true;
      }

      setState(() {});
    });
  }

  // Dispose controller
  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.amber),
        backgroundColor: const Color.fromARGB(255, 66, 5, 22),
        title: Text(
          '${widget.userFirstName}\'s Profile',
          style: const TextStyle(color: Colors.amber),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          // Profile to be hidden if scrolled down
          Visibility(
            visible: scrollVisibility,
            child: Container(
              padding: const EdgeInsets.only(top: 20),
              child: Column(children: <Widget>[
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color.fromARGB(170, 125, 25, 53),
                    child: Text(
                      widget.userFirstName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.amber),
                      textScaleFactor: 2,
                    ),
                  ),
                ),
                _isFriend == true
                    ?

                    // For unfollowing a user
                    IconButton(
                        icon: const Icon(Icons.group_off),
                        color: Colors.amber,
                        tooltip: 'Unfollow User',
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                  title: const Text("UNFOLLOW USER"),
                                  content: Text(
                                    "Are you sure you want to unfollow ${widget.userFirstName}?",
                                    style: const TextStyle(color: Colors.amber),
                                  ),
                                  titleTextStyle:
                                      const TextStyle(color: Colors.amber),
                                  backgroundColor:
                                      const Color.fromARGB(255, 66, 5, 22),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text(
                                        'NO',
                                        style: TextStyle(color: Colors.amber),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    TextButton(
                                        child: const Text(
                                          'YES',
                                          style: TextStyle(color: Colors.amber),
                                        ),
                                        onPressed: () async {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Unfollowing User...')),
                                          );

                                          // Request to unfollow a friend
                                          final List<String> delete =
                                              await db.unfollowUser(
                                                  widget.token,
                                                  widget.userUsername);

                                          // Delete successful
                                          if (delete[0] == '200') {
                                            await showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                    title: Text(
                                                        "${widget.userFirstName} unfollowed",
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.amber)),
                                                    titleTextStyle:
                                                        const TextStyle(
                                                            color:
                                                                Colors.amber),
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255, 66, 5, 22),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: const Text(
                                                          'OK',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.amber),
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            // Update friends list
                                                            friendsList =
                                                                db.fetchFriends(
                                                              http.Client(),
                                                              widget.token,
                                                            );

                                                            // Make _isFriend to false
                                                            _isFriend = false;
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ]);
                                              },
                                            );

                                            // Delete unsuccessful
                                          } else {
                                            await showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                    title: Text(
                                                      'Error ${delete[0]}',
                                                      style: const TextStyle(
                                                          color: Colors.amber),
                                                    ),
                                                    content: Text(
                                                      delete[1],
                                                      style: const TextStyle(
                                                          color: Colors.amber),
                                                    ),
                                                    titleTextStyle:
                                                        const TextStyle(
                                                            color:
                                                                Colors.amber),
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255, 66, 5, 22),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: const Text(
                                                          'OK',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.amber),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ]);
                                              },
                                            );
                                          }
                                        }),
                                  ]);
                            },
                          );
                        })
                    :

                    // For following a user
                    IconButton(
                        icon: const Icon(Icons.group_add),
                        color: Colors.amber,
                        tooltip: 'Follow User',
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                  title: const Text("FOLLOW USER"),
                                  content: Text(
                                    "Follow ${widget.userFirstName}?",
                                    style: const TextStyle(color: Colors.amber),
                                  ),
                                  titleTextStyle:
                                      const TextStyle(color: Colors.amber),
                                  backgroundColor:
                                      const Color.fromARGB(255, 66, 5, 22),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text(
                                        'NO',
                                        style: TextStyle(color: Colors.amber),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    TextButton(
                                        child: const Text(
                                          'YES',
                                          style: TextStyle(color: Colors.amber),
                                        ),
                                        onPressed: () async {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text('Following User...')),
                                          );

                                          // Request to follow a User
                                          final List<String> follow =
                                              await db.followUser(widget.token,
                                                  widget.userUsername);

                                          // Follow successful
                                          if (follow[0] == '200') {
                                            await showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                    title: Text(
                                                        "You are now following ${widget.userFirstName}",
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.amber)),
                                                    titleTextStyle:
                                                        const TextStyle(
                                                            color:
                                                                Colors.amber),
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255, 66, 5, 22),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: const Text(
                                                          'OK',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.amber),
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            // Update public post
                                                            friendsList =
                                                                db.fetchFriends(
                                                              http.Client(),
                                                              widget.token,
                                                            );

                                                            _isFriend = true;
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ]);
                                              },
                                            );

                                            // Follow unsuccessful
                                          } else {
                                            await showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                    title: Text(
                                                      'Error ${follow[0]}',
                                                      style: const TextStyle(
                                                          color: Colors.amber),
                                                    ),
                                                    content: Text(
                                                      follow[1],
                                                      style: const TextStyle(
                                                          color: Colors.amber),
                                                    ),
                                                    titleTextStyle:
                                                        const TextStyle(
                                                            color:
                                                                Colors.amber),
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255, 66, 5, 22),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: const Text(
                                                          'OK',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.amber),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ]);
                                              },
                                            );
                                          }
                                        }),
                                  ]);
                            },
                          );
                        }),
                Text(
                  '${widget.userFirstName} ${widget.userLastName}',
                  style: const TextStyle(color: Colors.amber),
                  textScaleFactor: 1.5,
                ),
                const Divider(),
                Text(
                  '@${widget.userUsername}',
                  style: const TextStyle(color: Colors.amber),
                  textScaleFactor: 1.25,
                ),
              ]),
            ),
          ),
          const Divider(),
          // Private posts by a user
          viewPrivatePosts(),
        ],
      ),
      backgroundColor: const Color.fromARGB(170, 125, 25, 53),
    );
  }

  /*
    Description: For building the ListView of private posts

    Parameters: none
    Returns an Expanded of the FutureBuilder that builds the List View
  */
  Widget viewPrivatePosts() {
    return Expanded(
        child: _isFriend == true
            ? FutureBuilder(
                future: privatePosts,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return buildPosts(snapshot.data as List<Post>);
                  } else {
                    return const Center(
                        child: CircularProgressIndicator(
                            value: null, strokeWidth: 7.0));
                  }
                })
            : const Text(
                "Private posts cannot be accessed by a non-follower",
                style:
                    TextStyle(color: Colors.amber, fontStyle: FontStyle.italic),
              ));
  }

  /*
    Description: Builds the List View of private posts made by other users

    Parameters: publicPosts (function parameter)
    
    Returns a ListView builder containing all private posts made by other users
  */
  Widget buildPosts(List<Post> privatePosts) {
    return ListView.builder(
      shrinkWrap: true, // To avoid constraint errors
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: privatePosts.length + (allLoaded ? 1 : 0),
      itemBuilder: (context, int index) {
        if (index < privatePosts.length) {
          if (privatePosts[index].public == true) {
            return const Divider(height: 0);
          }

          // Get the current id to be passed on fetching next posts
          nextId = privatePosts[index].id;

          return Center(
              child: Container(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color.fromARGB(170, 125, 25, 53),
                      child: Text(
                        privatePosts[index].username[0].toUpperCase(),
                        style: const TextStyle(color: Colors.amber),
                      ),
                    ),
                    onLongPress: () {
                      final data = ClipboardData(text: privatePosts[index].id);
                      Clipboard.setData(data);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to Clipboard')),
                      );
                    },
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    title: Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Text(
                          '@${privatePosts[index].username}',
                          style: const TextStyle(
                              color: Colors.amber, fontWeight: FontWeight.bold),
                        )),
                    subtitle: Text(
                      privatePosts[index].text.trim(),
                      style: const TextStyle(color: Colors.amber),
                    ),
                    tileColor: const Color.fromARGB(255, 66, 5, 22),
                  )));
        }
        return const Divider(
          height: 0,
        );
      },
    );
  }
}
