import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'models.dart';

class DBHelper {
  /*
    Description: Function that lets a User register with the following credentials

    Parameters: username, password, firstName, lastName (function parameters)

    Returns the statusCode to determine if successful or not
  */

  Future<String> registerUser(String username, String password,
      String firstName, String lastName) async {
    final response = await http.post(
      Uri.parse('https://cmsc-23-2022-bfv6gozoca-as.a.run.app/api/user'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization':
            'Bearer Zxi!!YbZ4R9GmJJ!h5tJ9E5mghwo4mpBs@*!BLoT6MFLHdMfUA%'
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
        'firstName': firstName,
        'lastName': lastName
      }),
    );
    if (response.statusCode == 200) {
      // If the server did return a 200 CREATED response,
      // then parse the JSON.

      String result = '${response.statusCode}';
      return result;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      String result = '${response.statusCode}';
      return result;
    }
  }

  /*
    Description: Function that lets a User register login to the web with the
    following credentials

    Parameters: username, password (function parameters)

    Returns the statusCode and token if successful, else statusCode and message
    will be returned
  */

  Future<List<String>> loginUser(String username, String password) async {
    final response = await http.post(
      Uri.parse('https://cmsc-23-2022-bfv6gozoca-as.a.run.app/api/login'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      // If the server did return a 200 CREATED response,
      // then parse the JSON.

      List<String> result = [
        '${response.statusCode}',
        '${jsonDecode(response.body)['data']['token']}',
      ];
      return result;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      List<String> result = [
        '${response.statusCode}',
        '${jsonDecode(response.body)['message']}',
      ];
      return result;
    }
  }

  /*
    Description: Function that lets a User logout from the social media page

    Parameters: token (function parameters)

    Returns the statusCode to determine if successful or not
  */

  Future<String> logoutUser(String token) async {
    final response = await http.post(
        Uri.parse("https://cmsc-23-2022-bfv6gozoca-as.a.run.app/api/logout"),
        headers: <String, String>{'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      // If the server did return a 200 CREATED response,
      // then parse the JSON.

      String result = '${response.statusCode}';
      return result;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.

      String result = '${response.statusCode}';
      return result;
    }
  }

  /*
    Description: Function that lets a User register search a User via the web

    Parameters: id, token (function parameters)

    Returns the statusCode, username, first name, and last name for getting 
    credentials
  */

  Future<List<String>> getUser(String id, String token) async {
    final response = await http.get(
        Uri.parse('https://cmsc-23-2022-bfv6gozoca-as.a.run.app/api/user/$id'),
        headers: <String, String>{'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      // If the server did return a 200 CREATED response,
      // then parse the JSON.

      List<String> result = [
        '${response.statusCode}',
        '${jsonDecode(response.body)['data']['username']}',
        '${jsonDecode(response.body)['data']['firstName']}',
        '${jsonDecode(response.body)['data']['lastName']}',
      ];
      return result;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      List<String> result = [
        '${response.statusCode}',
        '${jsonDecode(response.body)['message']}',
      ];
      return result;
    }
  }

  /*
    Description: Function that lets a User update first name and/or last name

    Parameters: token, firstName, lastName, id (function parameters)

    Returns the statusCode, first name, and last name for getting 
    credentials
  */

  Future<List<String>> updateUser(
      String token, String firstName, String lastName, String id) async {
    final response = await http.put(
      Uri.parse('https://cmsc-23-2022-bfv6gozoca-as.a.run.app/api/user/$id'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'firstName': firstName,
        'lastName': lastName,
      }),
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 CREATED response,
      // then parse the JSON.

      List<String> result = [
        '${response.statusCode}',
        '${jsonDecode(response.body)['data']['firstName']}',
        '${jsonDecode(response.body)['data']['lastName']}',
      ];
      return result;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      List<String> result = [
        '${response.statusCode}',
        '${jsonDecode(response.body)['message']}',
      ];
      return result;
    }
  }

  /*
    Description: Function that lets a User update their password and/or first name
    or last name

    Parameters: token, oldPassword, newPassword, firstName, lastName, id (function parameters)

    Returns the statuscode and first name and last name for credentials
  */

  Future<List<String>> updateUserPass(String token, String oldPassword,
      String newPassword, String firstName, String lastName, String id) async {
    final response = await http.put(
      Uri.parse('https://cmsc-23-2022-bfv6gozoca-as.a.run.app/api/user/$id'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'firstName': firstName,
        'lastName': lastName,
      }),
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 CREATED response,
      // then parse the JSON.

      List<String> result = [
        '${response.statusCode}',
        '${jsonDecode(response.body)['data']['firstName']}',
        '${jsonDecode(response.body)['data']['lastName']}',
      ];
      return result;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      List<String> result = [
        '${response.statusCode}',
        '${jsonDecode(response.body)['message']}',
      ];
      return result;
    }
  }

  /*
    Description: Function that lets a User fetch posts

    Parameters: client, token, next, postCount (function parameters)

    Returns the list of posts by all users
  */
  Future<List<Post>> fetchPublicPosts(
      http.Client client, String token, String next, int postCount) async {
    final response = await client.get(
      Uri.parse(
          'https://cmsc-23-2022-bfv6gozoca-as.a.run.app/api/post?limit=$postCount&next=$next'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    return parsePublicPosts(response.body);
  }

  /*
    Description: Function that lets a User fetch next posts

    Parameters: client, token, next (function parameters)

    Returns the list of posts by a user
  */
  Future<List<Post>> fetchUserPosts(
      String username, http.Client client, String token, String next) async {
    final response = await client.get(
      Uri.parse(
          'https://cmsc-23-2022-bfv6gozoca-as.a.run.app/api/post?next=$next&username=$username'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );
    return parsePublicPosts(response.body);
  }

  /*
    Description: Function that lets a User parse posts

    Parameters: responseBody (function parameters)

    Returns the parsed list of posts
  */
  List<Post> parsePublicPosts(String responseBody) {
    final parsed =
        jsonDecode(responseBody)['data'].cast<Map<String, dynamic>>();

    return parsed.map<Post>((json) => Post.fromJson(json)).toList();
  }

  /*
    Description: Function that lets a User get a specific post

    Parameters: id, token (function parameters)

    Returns the statuscode, username, and text to view the contents of the post
  */
  Future<List<String>> getPost(String id, String token) async {
    final response = await http.get(
        Uri.parse('https://cmsc-23-2022-bfv6gozoca-as.a.run.app/api/post/$id'),
        headers: <String, String>{'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      // If the server did return a 200 CREATED response,
      // then parse the JSON.

      List<String> result = [
        '${response.statusCode}',
        '${jsonDecode(response.body)['data']['username']}',
        '${jsonDecode(response.body)['data']['text']}',
      ];
      return result;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      List<String> result = [
        '${response.statusCode}',
        '${jsonDecode(response.body)['message']}',
      ];
      return result;
    }
  }

  /*
    Description: Function that lets a User create a post

    Parameters: text, public, token (function parameters)

    Returns the status code
  */
  Future<String> createPost(String text, bool public, String token) async {
    final response = await http.post(
      Uri.parse('https://cmsc-23-2022-bfv6gozoca-as.a.run.app/api/post'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'text': text,
        'public': public,
      }),
    );
    if (response.statusCode == 200) {
      // If the server did return a 200 CREATED response,
      // then parse the JSON.

      String result = '${response.statusCode}';

      return result;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      String result = '${response.statusCode}';
      return result;
    }
  }

  /*
    Description: Function that lets a User update a post

    Parameters: text, public, token, id (function parameters)

    Returns the status code
  */
  Future<String> updatePost(
      String text, bool public, String token, String id) async {
    final response = await http.put(
      Uri.parse('https://cmsc-23-2022-bfv6gozoca-as.a.run.app/api/post/$id'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'text': text,
        'public': public,
      }),
    );
    if (response.statusCode == 200) {
      // If the server did return a 200 CREATED response,
      // then parse the JSON.

      String result = '${response.statusCode}';

      return result;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      String result = '${response.statusCode}';
      return result;
    }
  }

  /*
    Description: Function that lets a User delete a post

    Parameters: text, public, token, id (function parameters)

    Returns the status code
  */
  Future<List<String>> deletePost(String token, String id) async {
    final response = await http.delete(
      Uri.parse('https://cmsc-23-2022-bfv6gozoca-as.a.run.app/api/post/$id'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      // If the server did return a 200 CREATED response,
      // then parse the JSON.

      List<String> result = ['${response.statusCode}'];

      return result;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      List<String> result = [
        '${response.statusCode}',
        '${jsonDecode(response.body)['message']}',
      ];
      return result;
    }
  }

  /*
    Description: Function that lets a User fetch friends list

    Parameters: client, token (function parameters)

    Returns the list of followers of user
  */
  Future<List<User>> fetchFriends(http.Client client, String token) async {
    final response = await client.get(
      Uri.parse(
          'https://cmsc-23-2022-bfv6gozoca-as.a.run.app/api/user?friends=true'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );
    return parseFriendsList(response.body);
  }

  /*
    Description: Function that lets a User parse users as friends

    Parameters: responseBody (function parameters)

    Returns the parsed list of users as friends
  */
  List<User> parseFriendsList(String responseBody) {
    final parsed =
        jsonDecode(responseBody)['data'].cast<Map<String, dynamic>>();

    return parsed.map<User>((json) => User.fromJson(json)).toList();
  }

  /*
    Description: Function that lets a User unfollow a user

    Parameters: token, id (function parameters)

    Returns the status code
  */
  Future<List<String>> unfollowUser(String token, String id) async {
    final response = await http.delete(
      Uri.parse('https://cmsc-23-2022-bfv6gozoca-as.a.run.app/api/follow/$id'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      // If the server did return a 200 CREATED response,
      // then parse the JSON.

      List<String> result = ['${response.statusCode}'];

      return result;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      List<String> result = [
        '${response.statusCode}',
        '${jsonDecode(response.body)['message']}',
      ];
      return result;
    }
  }

  /*
    Description: Function that lets a User follow a user

    Parameters: token, id (function parameters)

    Returns the status code
  */
  Future<List<String>> followUser(String token, String id) async {
    final response = await http.post(
      Uri.parse('https://cmsc-23-2022-bfv6gozoca-as.a.run.app/api/follow/$id'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      // If the server did return a 200 CREATED response,
      // then parse the JSON.

      List<String> result = ['${response.statusCode}'];

      return result;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      List<String> result = [
        '${response.statusCode}',
        '${jsonDecode(response.body)['message']}',
      ];
      return result;
    }
  }
}
