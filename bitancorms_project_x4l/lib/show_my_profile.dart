import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'main.dart';
import 'show_social_media.dart';
import 'package:http/http.dart' as http;
import 'models.dart';
import 'package:flutter/services.dart';

class ShowMyProfile extends StatefulWidget {
  final String token;
  final String username;
  final String firstName;
  final String lastName;
  final String password;

  const ShowMyProfile(
      this.token, this.username, this.firstName, this.lastName, this.password,
      {Key? key})
      : super(key: key);

  @override
  State<ShowMyProfile> createState() => _ShowMyProfileState();
}

class _ShowMyProfileState extends State<ShowMyProfile> {
  final TextEditingController _post =
      TextEditingController(); //controller for getting post
  final TextEditingController _text =
      TextEditingController(); //controller for getting text
  final TextEditingController _editText =
      TextEditingController(); //controller for getting text
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  late Future<List<Post>> privatePosts;
  DBHelper db = DBHelper();

  // For validating entries
  final bool _validate = false;

  // For toggling if user wants post to be public or not
  bool _isPublic = true;

  // For hiding containers
  bool scrollVisibility = true;

  // For pagination
  late List<Post> nextPosts;
  late List<Post> currentPosts;
  bool loading = false, allLoaded = false;

  late String nextId; // For getting latest id
  late Future<List<User>> friendsList;

  // For fetching new posts
  generateNewPosts() async {
    if (allLoaded) return; // Return if there's nothing to load
    setState(() {
      loading = true; // Set loading to true since you are fetching new posts
    });

    // Fetch new posts
    nextPosts = await db.fetchUserPosts(
        widget.username, http.Client(), widget.token, nextId);

    // Fetch current posts
    currentPosts = await privatePosts;

    // Append new posts to current
    if (nextPosts.isNotEmpty) {
      currentPosts.addAll(nextPosts);
    }

    // Pass current to private posts and loading to false since everything is done
    // to fetch posts
    setState(() {
      privatePosts = Future.value(currentPosts);
      loading = false;
      allLoaded = nextPosts.isEmpty;
    });
  }

  @override
  void initState() {
    super.initState();

    // Get first batch of posts
    privatePosts =
        db.fetchUserPosts(widget.username, http.Client(), widget.token, '');

    // Get friends list
    friendsList = db.fetchFriends(http.Client(), widget.token);

    _scrollController.addListener(() {
      // Generate new posts if end of the scroll
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !loading) {
        generateNewPosts();
      }

      // Hide container if user scrolls down
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
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.amber),
        ),
        actions: [
          // Icon for viewing a post
          IconButton(
            icon: const Icon(Icons.search_outlined),
            tooltip: "View a Post",
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                      title: const Text("VIEW A POST"),
                      content: TextField(
                        style: const TextStyle(color: Colors.amber),
                        autofocus: true, // keyboard pops up automatically
                        controller: _post,
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
                            _post.clear();
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
                                  content: Text('Searching Post...')),
                            );

                            // HTTP request to get a post
                            final credentials =
                                await db.getPost(_post.text, widget.token);

                            // Success; returns an alert dialog with username and text of post
                            if (credentials[0] == '200') {
                              await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                      title: Row(
                                        children: [
                                          // Profile of user
                                          CircleAvatar(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    170, 125, 25, 53),
                                            child: Text(
                                              credentials[1][0].toUpperCase(),
                                              style: const TextStyle(
                                                  color: Colors.amber),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          // Display username
                                          Text('@${credentials[1]}',
                                              style: const TextStyle(
                                                  color: Colors.amber)),
                                        ],
                                      ),

                                      // Display text in a scroll view
                                      content: SingleChildScrollView(
                                          child: Text(
                                        credentials[2],
                                        style: const TextStyle(
                                            color: Colors.amber),
                                      )),
                                      titleTextStyle:
                                          const TextStyle(color: Colors.amber),
                                      backgroundColor:
                                          const Color.fromARGB(255, 66, 5, 22),
                                      actions: <Widget>[
                                        // Go back to profile if OK is pressed
                                        TextButton(
                                          child: const Text(
                                            'OK',
                                            style:
                                                TextStyle(color: Colors.amber),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ]);
                                },
                              );

                              // Return error alert dialog if invalid id of post is given
                            } else {
                              await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                      title: Text(
                                        'Error ${credentials[0]}',
                                        style: const TextStyle(
                                            color: Colors.amber),
                                      ),
                                      content: Text(
                                        credentials[1],
                                        style: const TextStyle(
                                            color: Colors.amber),
                                      ),
                                      titleTextStyle:
                                          const TextStyle(color: Colors.amber),
                                      backgroundColor:
                                          const Color.fromARGB(255, 66, 5, 22),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text(
                                            'OK',
                                            style:
                                                TextStyle(color: Colors.amber),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ]);
                                },
                              );
                            }

                            _post.clear();
                          },
                        ),
                      ]);
                },
              );
            },
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        verticalDirection: VerticalDirection.down,
        children: [
          // User profile
          Visibility(
            visible: scrollVisibility,
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.only(top: 20),
              child: Column(children: <Widget>[
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color.fromARGB(170, 125, 25, 53),
                    child: Text(
                      widget.firstName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.amber),
                      textScaleFactor: 2,
                    ),
                  ),
                ),

                // For updating profile
                IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    color: Colors.amber,
                    tooltip: 'Customize Your Profile',
                    iconSize: 20,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CustomizeProfile(
                                  widget.token,
                                  widget.username,
                                  widget.firstName,
                                  widget.lastName,
                                  widget.password)));
                    }),
                Text(
                  '${widget.firstName} ${widget.lastName}',
                  style: const TextStyle(color: Colors.amber),
                  textScaleFactor: 1.5,
                ),
                const Divider(),
                Text(
                  '@${widget.username}',
                  style: const TextStyle(color: Colors.amber),
                  textScaleFactor: 1.25,
                ),
                const Divider(),

                // For creating a post
                Form(
                    key: _formKey,
                    child: Container(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(
                              height: 4,
                            ),
                            TextFormField(
                              controller: _text,
                              style: const TextStyle(color: Colors.amber),
                              decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                      tooltip: _isPublic
                                          ? 'Post as Public'
                                          : 'Post For-Friends',
                                      onPressed: () {
                                        setState(() {
                                          _isPublic =
                                              !_isPublic; // For toggling if a post should be public or not
                                        });
                                      },
                                      color: Colors.amber,
                                      icon: _isPublic
                                          ? const Icon(Icons.public_outlined)
                                          : const Icon(
                                              Icons.people_alt_outlined)),
                                  labelStyle:
                                      const TextStyle(color: Colors.amber),
                                  errorStyle:
                                      const TextStyle(color: Colors.amber),
                                  filled: true,
                                  fillColor:
                                      const Color.fromARGB(255, 66, 5, 22),
                                  contentPadding: const EdgeInsets.all(10),
                                  border: OutlineInputBorder(
                                      borderSide:
                                          const BorderSide(color: Colors.white),
                                      borderRadius: BorderRadius.circular(20)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          const BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.circular(20)),
                                  labelText: 'Create a Post',
                                  errorText: _validate
                                      ? 'Value can\'t be empty'
                                      : null),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Field is required!';
                                }

                                return null;
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                buildPostButton(), // Post button
                              ],
                            )
                          ],
                        ))),
              ]),
            ),
          ),
          const Divider(),
          viewPrivatePosts(), // For viewing private posts done by a user
        ],
      ),
      backgroundColor: const Color.fromARGB(170, 125, 25, 53),

      // Navigation menu
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
    );
  }

  /*
    Description: For building the ListView of public posts

    Parameters: none
    Returns an Expanded of the FutureBuilder that builds the List View
  */
  Widget viewPrivatePosts() {
    return Expanded(
      child: FutureBuilder(
          future: privatePosts,
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

  Widget buildPosts(List<Post> privatePost) {
    return ListView.builder(
      shrinkWrap: true, // To avoid constraint errors
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: privatePost.length + (allLoaded ? 1 : 0),
      itemBuilder: (context, int index) {
        if (index < privatePost.length) {
          if (privatePost[index].public == true) {
            return const Divider(height: 0);
          }

          // Get the current id to be passed on fetching next posts
          nextId = privatePost[index].id;

          return Center(
              child: Container(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color.fromARGB(170, 125, 25, 53),
                      child: Text(
                        privatePost[index].username[0].toUpperCase(),
                        style: const TextStyle(color: Colors.amber),
                      ),
                    ),

                    // Copy to clipboard to get id of post
                    onLongPress: () {
                      final data = ClipboardData(text: privatePost[index].id);
                      Clipboard.setData(data);

                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied to Clipboard')));
                    },
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    // Username as title
                    title: Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Text(
                          '@${privatePost[index].username}',
                          style: const TextStyle(
                              color: Colors.amber, fontWeight: FontWeight.bold),
                        )),
                    // Post as subtitle
                    subtitle: Text(
                      privatePost[index].text.trim(),
                      style: const TextStyle(color: Colors.amber),
                    ),
                    trailing: Wrap(
                      children: [
                        // Icon for editing post
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
                                      style:
                                          const TextStyle(color: Colors.amber),
                                      autofocus:
                                          true, // keyboard pops up automatically
                                      controller: _editText,
                                      decoration: const InputDecoration(
                                        filled: true,
                                        fillColor:
                                            Color.fromARGB(255, 66, 5, 22),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.amber),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.amber),
                                        ),
                                      ),
                                    ),
                                    titleTextStyle:
                                        const TextStyle(color: Colors.amber),
                                    backgroundColor:
                                        const Color.fromARGB(255, 66, 5, 22),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text(
                                          'CANCEL',
                                          style: TextStyle(color: Colors.amber),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _editText.clear();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text(
                                          'EDIT AS PUBLIC',
                                          style: TextStyle(color: Colors.amber),
                                        ),
                                        onPressed: () async {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text('Editing Post...')),
                                          );

                                          // Request for editing post as public
                                          final String response =
                                              await db.updatePost(
                                                  _editText.text,
                                                  true,
                                                  widget.token,
                                                  privatePost[index].id);

                                          _editText.clear();

                                          // Edit successful
                                          if (response == "200") {
                                            await showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                      title: const Text(
                                                          "Post Edited!"),
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
                                                                color: Colors
                                                                    .amber),
                                                          ),
                                                          onPressed: () {
                                                            // To update post feed after creating a post
                                                            setState(() {
                                                              privatePosts =
                                                                  db.fetchUserPosts(
                                                                      widget
                                                                          .username,
                                                                      http
                                                                          .Client(),
                                                                      widget
                                                                          .token,
                                                                      '');
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

                                            // Failed to update post
                                          } else {
                                            await showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                      title: Text(response),
                                                      content: const Text(
                                                        "Cannot edit post!",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.amber),
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
                                          style: TextStyle(color: Colors.amber),
                                        ),
                                        onPressed: () async {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text('Editing Post...')),
                                          );

                                          // Request to edit post as private
                                          final String response =
                                              await db.updatePost(
                                                  _editText.text,
                                                  false,
                                                  widget.token,
                                                  privatePost[index].id);

                                          _editText.clear();

                                          // Edit successful
                                          if (response == "200") {
                                            await showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                      title: const Text(
                                                          "Post Edited!"),
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
                                                                color: Colors
                                                                    .amber),
                                                          ),
                                                          onPressed: () {
                                                            // To update post feed after creating a post
                                                            setState(() {
                                                              privatePosts =
                                                                  db.fetchUserPosts(
                                                                      widget
                                                                          .username,
                                                                      http
                                                                          .Client(),
                                                                      widget
                                                                          .token,
                                                                      '');
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

                                            // Edit post failed
                                          } else {
                                            await showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                      title: Text(response),
                                                      content: const Text(
                                                        "Cannot edit post!",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.amber),
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

                        // For deleting a post
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
                                      style: TextStyle(color: Colors.amber),
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
                                            style:
                                                TextStyle(color: Colors.amber),
                                          ),
                                          onPressed: () async {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content:
                                                      Text('Deleting Post...')),
                                            );

                                            // Request to delete post
                                            final List<String> delete =
                                                await db.deletePost(
                                                    widget.token,
                                                    privatePost[index].id);

                                            // Delete successful
                                            if (delete[0] == '200') {
                                              await showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
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
                                                            color:
                                                                Colors.amber),
                                                      )),
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
                                                                color: Colors
                                                                    .amber),
                                                          ),
                                                          onPressed: () {
                                                            setState(() {
                                                              privatePosts =
                                                                  db.fetchUserPosts(
                                                                      widget
                                                                          .username,
                                                                      http
                                                                          .Client(),
                                                                      widget
                                                                          .token,
                                                                      '');
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
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                      title: Text(
                                                        'Error ${delete[0]}',
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.amber),
                                                      ),
                                                      content: Text(
                                                        delete[1],
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.amber),
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
                        ),
                      ],
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

  /*
    Description: a Post button that lets the user create a post to the web

    Parameters: none
    Returns an ElevatedButton that lets the User enter its message to create a post
    to the web
  */
  Widget buildPostButton() {
    return ElevatedButton(
      onPressed: () async {
        // User inputs all required fields and password and confirm password match
        if (_formKey.currentState!.validate()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Creating Post...')),
          );

          // Request to create post
          final String res =
              await db.createPost(_text.text, _isPublic, widget.token);

          // Clear controllers
          _text.clear();

          // Post successful
          if (res == "200") {
            await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                      title: const Text("Post Created!"),
                      titleTextStyle: const TextStyle(color: Colors.amber),
                      backgroundColor: const Color.fromARGB(255, 66, 5, 22),
                      actions: <Widget>[
                        TextButton(
                          child: const Text(
                            'OK',
                            style: TextStyle(color: Colors.amber),
                          ),
                          onPressed: () {
                            // To update post feed after creating a post
                            setState(() {
                              privatePosts = db.fetchUserPosts(widget.username,
                                  http.Client(), widget.token, '');
                            });

                            Navigator.of(context).pop();
                          },
                        ),
                      ]);
                });
          } else {
            await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                      title: Text(res),
                      content: const Text(
                        "Cannot create post!",
                        style: TextStyle(color: Colors.amber),
                      ),
                      titleTextStyle: const TextStyle(color: Colors.amber),
                      backgroundColor: const Color.fromARGB(255, 66, 5, 22),
                      actions: <Widget>[
                        TextButton(
                          child: const Text(
                            'OK',
                            style: TextStyle(color: Colors.amber),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ]);
                });
          }
        }
      },
      style: ElevatedButton.styleFrom(
        primary: const Color.fromARGB(255, 66, 5, 22),
        side: const BorderSide(color: Colors.red),
      ),
      child: const Text(
        'Post',
        style: TextStyle(color: Colors.amber),
      ),
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
                  Icons.login_outlined,
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

// Separate class for customization of profile page
class CustomizeProfile extends StatefulWidget {
  final String token;
  final String username;
  final String firstName;
  final String lastName;
  final String password;

  const CustomizeProfile(
      this.token, this.username, this.firstName, this.lastName, this.password,
      {Key? key})
      : super(key: key);

  @override
  State<CustomizeProfile> createState() => _CustomizeProfileState();
}

class _CustomizeProfileState extends State<CustomizeProfile> {
  final TextEditingController _oldPassword =
      TextEditingController(); //controller for getting old password
  final TextEditingController _newPassword =
      TextEditingController(); //controller for getting new password
  final TextEditingController _confirmPassword =
      TextEditingController(); //controller for getting confirm password
  final TextEditingController _firstName =
      TextEditingController(); //controller for getting first name
  final TextEditingController _lastName =
      TextEditingController(); //controller for getting last name

  final _formKey = GlobalKey<FormState>();

  DBHelper db = DBHelper();
  final bool _validate = false;

  // For hiding password
  bool _isObscure1 = true;
  bool _isObscure2 = true;
  bool _isObscure3 = true;

  // For getting request message from http
  List<String> success = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.amber),
        backgroundColor: const Color.fromARGB(255, 66, 5, 22),
        title: const Text(
          "Customize Profile",
          style: TextStyle(color: Colors.amber),
        ),
      ),
      // Form for updating profile
      body: Form(
          key: _formKey,
          child: Container(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 4,
                  ),
                  buildTextField('First Name', _firstName), // First name field
                  const SizedBox(
                    height: 4,
                  ),
                  buildTextField('Last Name', _lastName), // Last name field
                  const SizedBox(
                    height: 4,
                  ),
                  buildOldPasswordField(
                      'Old Password', _oldPassword), // Old password field
                  const SizedBox(
                    height: 4,
                  ),
                  buildNewPasswordField(
                      'New Password', _newPassword), // New password field
                  const SizedBox(
                    height: 4,
                  ),
                  buildConfirmPasswordField('Confirm Password',
                      _confirmPassword), // Confirm password field
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildSaveButton(), // Save button
                    ],
                  )
                ],
              ))),
      backgroundColor: const Color.fromARGB(170, 125, 25, 53),
    );
  }

  /*
    Description: buildTextField widget that creates a textfield

    Parameters: label with String type (function parameter) and _controller
    as a TextEditingController

    Returns a TextFormField that lets you input a String on a form field
  */
  Widget buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.amber),
      decoration: InputDecoration(
          labelStyle: const TextStyle(color: Colors.amber),
          errorStyle: const TextStyle(color: Colors.amber),
          filled: true,
          fillColor: const Color.fromARGB(255, 66, 5, 22),
          contentPadding: const EdgeInsets.all(10),
          border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(20)),
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(20)),
          labelText: label,
          errorText: _validate ? 'Value can\'t be empty' : null),
    );
  }

  /*
    Description: buildTextField widget that creates a textfield for password

    Parameters: label with String type (function parameter) and _controller
    as a TextEditingController

    Returns a TextFormField that lets you input a String on a form field
  */
  Widget buildOldPasswordField(String label, TextEditingController controller) {
    return TextFormField(
      obscureText: _isObscure1, // For hiding text
      style: const TextStyle(color: Colors.amber),
      controller: controller,
      decoration: InputDecoration(
          labelStyle: const TextStyle(color: Colors.amber),
          errorStyle: const TextStyle(color: Colors.amber),
          filled: true,
          fillColor: const Color.fromARGB(255, 66, 5, 22),
          contentPadding: const EdgeInsets.all(10),
          border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(20)),
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(20)),
          labelText: label,
          errorText: _validate ? 'Value can\'t be empty' : null,
          suffixIcon: IconButton(
              icon: Icon(_isObscure1 ? Icons.visibility : Icons.visibility_off),
              color: Colors.amber,
              onPressed: () {
                setState(() {
                  _isObscure1 =
                      !_isObscure1; // Icon changes when pressed and hides/unhides input
                });
              })),
    );
  }

  /*
    Description: buildTextField widget that creates a textfield for confirm password

    Parameters: label with String type (function parameter) and _controller
    as a TextEditingController

    Returns a TextFormField that lets you input a String on a form field
  */

  Widget buildNewPasswordField(String label, TextEditingController controller) {
    return TextFormField(
      obscureText: _isObscure2, // For hiding text
      style: const TextStyle(color: Colors.amber),
      controller: controller,
      decoration: InputDecoration(
          labelStyle: const TextStyle(color: Colors.amber),
          errorStyle: const TextStyle(color: Colors.amber),
          filled: true,
          fillColor: const Color.fromARGB(255, 66, 5, 22),
          contentPadding: const EdgeInsets.all(10),
          border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(20)),
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(20)),
          labelText: label,
          errorText: _validate ? 'Value can\'t be empty' : null,
          suffixIcon: IconButton(
              icon: Icon(_isObscure2 ? Icons.visibility : Icons.visibility_off),
              color: Colors.amber,
              onPressed: () {
                setState(() {
                  _isObscure2 =
                      !_isObscure2; // Icon changes when pressed and hides/unhides input
                });
              })),
    );
  }

  /*
    Description: buildTextField widget that creates a textfield for confirm password

    Parameters: label with String type (function parameter) and _controller
    as a TextEditingController

    Returns a TextFormField that lets you input a String on a form field
  */

  Widget buildConfirmPasswordField(
      String label, TextEditingController controller) {
    return TextFormField(
      obscureText: _isObscure3, // For hiding text
      style: const TextStyle(color: Colors.amber),
      controller: controller,
      decoration: InputDecoration(
          labelStyle: const TextStyle(color: Colors.amber),
          errorStyle: const TextStyle(color: Colors.amber),
          filled: true,
          fillColor: const Color.fromARGB(255, 66, 5, 22),
          contentPadding: const EdgeInsets.all(10),
          border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(20)),
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(20)),
          labelText: label,
          errorText: _validate ? 'Value can\'t be empty' : null,
          suffixIcon: IconButton(
              icon: Icon(_isObscure3 ? Icons.visibility : Icons.visibility_off),
              color: Colors.amber,
              onPressed: () {
                setState(() {
                  _isObscure3 =
                      !_isObscure3; // Icon changes when pressed and hides/unhides input
                });
              })),
    );
  }

  /*
    Description: a Register button that lets the user register to the web

    Parameters: none
    Returns an ElevatedButton that lets the User enter its credentials to register
    to the web
  */
  Widget buildSaveButton() {
    return ElevatedButton(
      onPressed: () async {
        // Change First and/or Last Name only
        if (_oldPassword.text == '' &&
            _newPassword.text == '' &&
            _confirmPassword.text == '') {
          if (_firstName.text == '' && _lastName.text == '') return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Updating Profile...')),
          );
          if (_firstName.text == '') _firstName.text = widget.firstName;
          if (_lastName.text == '') _lastName.text = widget.lastName;

          success = await db.updateUser(
              widget.token, _firstName.text, _lastName.text, widget.username);

          // Clear controllers
          _firstName.clear();
          _lastName.clear();

          // Profile Update successful
          if (success[0] == "200") {
            await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                      title: const Text("Profile Update Success!"),
                      titleTextStyle: const TextStyle(color: Colors.amber),
                      backgroundColor: const Color.fromARGB(255, 66, 5, 22),
                      actions: <Widget>[
                        TextButton(
                          child: const Text(
                            'OK',
                            style: TextStyle(color: Colors.amber),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ShowMyProfile(
                                        widget.token,
                                        widget.username,
                                        success[1],
                                        success[2],
                                        widget.password)));
                          },
                        ),
                      ]);
                });
          } else {
            await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                      title: Text("Error ${success[0]}"),
                      titleTextStyle: const TextStyle(color: Colors.amber),
                      content: Text(
                        success[1],
                        style: const TextStyle(color: Colors.amber),
                      ),
                      backgroundColor: const Color.fromARGB(255, 66, 5, 22),
                      actions: <Widget>[
                        TextButton(
                          child: const Text(
                            'OK',
                            style: TextStyle(color: Colors.amber),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ]);
                });
          }
        } else {
          // Change name and password or password only
          if ((_oldPassword.text == widget.password) &&
              (_confirmPassword.text == _newPassword.text)) {
            // No input from new password; return and alert user to input new password
            if (_newPassword.text == '') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Please input your New Password!')),
              );
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Updating Profile...')),
            );
            // If password and/or first or last name only
            if (_firstName.text == '') _firstName.text = widget.firstName;
            if (_lastName.text == '') _lastName.text = widget.lastName;

            success = await db.updateUserPass(
                widget.token,
                _oldPassword.text,
                _newPassword.text,
                _firstName.text,
                _lastName.text,
                widget.username);

            final newPass = _newPassword.text;

            // Clear controllers
            _firstName.clear();
            _lastName.clear();
            _oldPassword.clear();
            _newPassword.clear();
            _confirmPassword.clear();

            // Profile Update successful
            if (success[0] == "200") {
              await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title: const Text("Profile Update Success!"),
                        titleTextStyle: const TextStyle(color: Colors.amber),
                        backgroundColor: const Color.fromARGB(255, 66, 5, 22),
                        actions: <Widget>[
                          TextButton(
                            child: const Text(
                              'OK',
                              style: TextStyle(color: Colors.amber),
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ShowMyProfile(
                                          widget.token,
                                          widget.username,
                                          success[1],
                                          success[2],
                                          newPass)));
                            },
                          ),
                        ]);
                  });
            } else {
              await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title: Text("Error ${success[0]}"),
                        titleTextStyle: const TextStyle(color: Colors.amber),
                        content: Text(
                          success[1],
                          style: const TextStyle(color: Colors.amber),
                        ),
                        backgroundColor: const Color.fromARGB(255, 66, 5, 22),
                        actions: <Widget>[
                          TextButton(
                            child: const Text(
                              'OK',
                              style: TextStyle(color: Colors.amber),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ]);
                  });
            }

            // Old password and current password do not match
          } else if (_oldPassword.text != widget.password) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Old password does not match the current password!')),
            );

            // Confirm password and password do not match
          } else if (_confirmPassword.text != _newPassword.text) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Confirm password does not match the new password!')),
            );
          }
        }
      },
      style: ElevatedButton.styleFrom(
        primary: const Color.fromARGB(255, 66, 5, 22),
        side: const BorderSide(color: Colors.red),
      ),
      child: const Text(
        'Save',
        style: TextStyle(color: Colors.amber),
      ),
    );
  }
}
