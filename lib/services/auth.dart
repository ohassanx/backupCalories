import 'package:firebase_auth/firebase_auth.dart';
import 'package:audio_fit/services/database.dart';
import 'package:audio_fit/models/user.dart';
import 'package:audio_fit/screens/home/home.dart';
import 'package:audio_fit/screens/home/wrapper.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserApp _userFromFirebaseUser(User user) {
    return user != null ? UserApp(uid: user.uid) : null;
  }

  // auth change user stream
  Stream<UserApp> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // _userFromFirebaseUser(user) {
  //   return user != null ? User(user.id) : null;
  // }

  // User(user) {
  //   return user != null ? User(user.id) : null;
  // }

//sign out
  Future signOut() async {
    await FirebaseAuth.instance.signOut();
    //   runApp(
    //     new MaterialApp(
    //       home: new Home(),
    //     ));
    // }
  }

  Future registerWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      //create userSettings document for the new user
      await DatabaseService(id: user.uid).addUser(email);
      await DatabaseService(id: user.uid).updateUserData(2500, 2500);
      await DatabaseService(id: user.uid).createNewEntry(getCurrentDate());
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      await DatabaseService(id: user.uid).addUser(email);
      await DatabaseService(id: user.uid).createNewEntry(getCurrentDate());
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  String getCurrentDate() {
    var date = new DateTime.now().toString();
    var dateParse = DateTime.parse(date);
    var formattedDate = "${dateParse.day}/${dateParse.month}/${dateParse.year}";
    return formattedDate;
  }
}
