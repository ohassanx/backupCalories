import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audio_fit/models/activity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audio_fit/models/food.dart';
import 'package:audio_fit/models/logged_nutrient.dart';
import 'package:audio_fit/models/nutrient.dart';
import 'package:audio_fit/models/settings.dart';
import 'package:audio_fit/models/medication.dart';
import 'package:audio_fit/models/medication_checklist.dart';
import 'package:audio_fit/shared/globals.dart' as globals;

class DatabaseService {
  final String id;
  var docId;
  var documentId;
  DatabaseService({this.id});

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference settingsCollection =
      FirebaseFirestore.instance.collection('settings');
  final CollectionReference entryCollection =
      FirebaseFirestore.instance.collection('entries');
  final CollectionReference foodCollection =
      FirebaseFirestore.instance.collection('foods');

  addUser(String email) {
    return userCollection
        .add({
          'email': email,
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));

    // Stream collectionStream = FirebaseFirestore.instance.collection('users').snapshots();
    // return settingsCollection.DocumentSnapshot(uid).snapshots();
  }

  Stream<QuerySnapshot> get settings {
    return settingsCollection.snapshots();
  }

  // Stream<List<Settings>> get userSettings {
  //   return FirebaseFirestore.instance
  //       .collection("settings")
  //       //.document(uid)
  //       .snapshots()
  //       .map(settingsListFromSnapshot);
  // }

  Future updateUserData(int kcalIntakeTarget, int kcalOutputTarget) async {
    //creating a new document in collection for user with id = uid
    return await settingsCollection.doc(id).set({
      'kcalIntakeTarget': kcalIntakeTarget,
      'kcalOutputTarget': kcalOutputTarget
    });
  }

  Stream<DocumentSnapshot> get testUserSettings {
    return settingsCollection.doc(id).snapshots();
  }

  //get userSettings Stream

  Stream<List<UserSettings>> get userSettings {
    return FirebaseFirestore.instance
        .collection("settings")
        //.document(uid)
        .snapshots()
        .map(settingsListFromSnapshot);
  }

  List<UserSettings> settingsListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return UserSettings(
          kcalInput: doc['kcalIntakeTarget'] ?? 0,
          kcalOutput: doc['kcalOutputTarget'] ?? 0);
    }).toList();
  }

  //entering user profile info
  Future enterUserCountry(String country) async {
    return await settingsCollection.doc(id).update({
      'country': country,
    });
  }

  Future enterUserAge(int age) async {
    return await settingsCollection.doc(id).update({
      'age': age,
    });
  }

  Future enterUserWeight(int weight) async {
    return await settingsCollection.doc(id).update({
      'weight': weight,
    });
  }

  //entry creation
  Future createNewEntry(String date) async {
    var entryName = reformatDate(getCurrentDate());
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('entries')
        .doc(entryName)
        .set({
      'entryDate': date,
    });
  }

  Future updateKcalIntakeTarget(int kcal) async {
    return await settingsCollection.doc(id).update({
      'kcalIntakeTarget': kcal,
    });
  }

  Future updateKcalOutputTarget(int kcal) async {
    return await settingsCollection.doc(id).update({
      'kcalOutputTarget': kcal,
    });
  }

  //food
  Future addNewFood(
      String foodName, int calories, String mealId, String date) async {
    //creating a new document in collection for user with id = uid
    await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("entries")
        .where('entryDate', isEqualTo: date)
        .get()
        .then((QuerySnapshot querySnapshot) {
      print(querySnapshot.docs);
      querySnapshot.docs.forEach((result) {
        docId = result.id;
      });
    });
    var entryName = reformatDate(getCurrentDate());
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('entries')
        .doc(entryName)
        .collection('foods')
        .doc(foodName)
        .set({
      'foodName': foodName,
      'calories': calories,
      'mealId': mealId,
    });
  }

  // Future addWater(int quantity, String date) async {
  //   var entryName;
  //   if (globals.selectedDate != getCurrentDate()) {
  //     entryName = reformatDate(globals.selectedDate);
  //   } else {
  //     entryName = reformatDate(getCurrentDate());
  //   }
  //   return await Firestore.instance
  //       .collection('users')
  //       .document(uid)
  //       .collection('entries')
  //       .document(entryName)
  //       .collection('foods')
  //       .doc('water')
  //       .setData({
  //     'quantity': quantity,
  //   });
  // }

  // Stream<QuerySnapshot> get water {
  //   var entryName = reformatDate(getCurrentDate());
  //   return Firestore.instance
  //       .collection("users")
  //       .docid
  //       .collection('entries')
  //       .doc(entryName)
  //       .collection('foods')
  //       .where('mealId', isEqualTo: 'breakfast')
  //       .snapshots();
  //
  //       //.map(foodListFromSnapshot);
  // }
  Stream<List<Food>> get allFoods {
    var entryName;
    if (globals.selectedDate != getCurrentDate()) {
      entryName = reformatDate(globals.selectedDate);
    } else {
      entryName = reformatDate(getCurrentDate());
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('entries')
        .doc(entryName)
        .collection('foods')
        .snapshots()
        .map(foodListFromSnapshot);
  }

  Stream<List<Food>> get breakFastFoods {
    //check if entry exists before trying to retrieve it?
    var entryName;
    if (globals.selectedDate != getCurrentDate()) {
      entryName = reformatDate(globals.selectedDate);
    } else {
      entryName = reformatDate(getCurrentDate());
    }
    return FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection('entries')
        .doc(entryName)
        .collection('foods')
        .where('mealId', isEqualTo: 'breakfast')
        .snapshots()
        .map(foodListFromSnapshot);
  }

  Stream<List<Food>> get lunchFoods {
    var entryName;
    if (globals.selectedDate != getCurrentDate()) {
      entryName = reformatDate(globals.selectedDate);
    } else {
      entryName = reformatDate(getCurrentDate());
    }
    return FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection('entries')
        .doc(entryName)
        .collection('foods')
        .where('mealId', isEqualTo: 'lunch')
        .snapshots()
        .map(foodListFromSnapshot);
  }

  Stream<List<Food>> get dinnerFoods {
    var entryName;
    if (globals.selectedDate != getCurrentDate()) {
      entryName = reformatDate(globals.selectedDate);
    } else {
      entryName = reformatDate(getCurrentDate());
    }
    return FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection('entries')
        .doc(entryName)
        .collection('foods')
        .where('mealId', isEqualTo: 'dinner')
        .snapshots()
        .map(foodListFromSnapshot);
  }

  Stream<List<Food>> get snacks {
    var entryName;
    if (globals.selectedDate != getCurrentDate()) {
      entryName = reformatDate(globals.selectedDate);
    } else {
      entryName = reformatDate(getCurrentDate());
    }
    return FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection('entries')
        .doc(entryName)
        .collection('foods')
        .where('mealId', isEqualTo: 'snack')
        .snapshots()
        .map(foodListFromSnapshot);
  }

  //food list from a snapshot
  List<Food> foodListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Food(
        foodName: doc['foodName'] ?? '',
        calories: doc['calories'] ?? 0,
        mealId: doc['mealId'] ?? '',
      );
    }).toList();
  }

  updateFoodDetails(String foodName, int calories) async {
    var entryName;
    if (globals.selectedDate != getCurrentDate()) {
      entryName = reformatDate(globals.selectedDate);
    } else {
      entryName = reformatDate(getCurrentDate());
    }
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('entries')
        .doc(entryName)
        .collection('foods')
        .doc(foodName)
        .update({
      'foodName': foodName,
      'calories': calories,
    });
  }

  deleteFood(foodName) async {
    var entryName;
    if (globals.selectedDate != getCurrentDate()) {
      entryName = reformatDate(globals.selectedDate);
    } else {
      entryName = reformatDate(getCurrentDate());
    }
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('entries')
        .doc(entryName)
        .collection('foods')
        .doc(foodName)
        .delete();
  }

  //medication
  Future addMedication(String medName, String time) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('medications')
        .doc(medName)
        .set({
      'medicationName': medName,
      'timeToTake': time,
    });
  }

  Stream<List<Medication>> get medications {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection('medications')
        .snapshots()
        .map(medicationListFromSnapshot);
  }

  List<Medication> medicationListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Medication(
        medicineName: doc['medicationName'] ?? '',
        timeToTake: doc['timeToTake'] ?? '',
      );
    }).toList();
  }

  medTaken(String medName, bool checked) async {
    var entryName;
    if (globals.selectedDate != getCurrentDate()) {
      entryName = reformatDate(globals.selectedDate);
    } else {
      entryName = reformatDate(getCurrentDate());
    }
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('entries')
        .doc(entryName)
        .collection('medChecklist')
        .doc(medName)
        .set({
      'medicationName': medName,
      'taken': checked,
      'timeTaken': getCurrentTime(),
    });
  }

  updateMedicationDetails(
      String originalMedName, String newMedName, String timeToTake) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('medications')
        .doc(originalMedName)
        .delete();
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('medications')
        .doc(newMedName)
        .update({
      'medicationName': newMedName,
      'timeToTake': timeToTake,
    });
  }

  updateMedicationTime(String medName, String timeToTake) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('medications')
        .doc(medName)
        .update({
      'medicationName': medName,
      'timeToTake': timeToTake,
    });
  }

  updateTimeTaken(String medName) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('medications')
        .doc(medName)
        .update({
      'timeTaken': getCurrentTime(),
    });
  }

  //this function works if the med name has not been previously edited
  deleteMedication(String medName) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('medications')
        .doc(medName)
        .delete();
  }

  Stream<List<MedicationChecklist>> getLoggedMedications() {
    var entryName;
    if (globals.selectedDate != getCurrentDate()) {
      entryName = reformatDate(globals.selectedDate);
    } else {
      entryName = reformatDate(getCurrentDate());
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('entries')
        .doc(entryName)
        .collection('medChecklist')
        .snapshots()
        .map(medicationChecklistFromSnapshot);
  }

  List<MedicationChecklist> medicationChecklistFromSnapshot(
      QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return MedicationChecklist(
        medicineName: doc['medicationName'] ?? '',
        taken: doc['taken'] ?? '',
        timeTaken: doc['timeTaken'] ?? '',
      );
    }).toList();
  }

  Stream<List<Nutrient>> get nutrientContent {
    return FirebaseFirestore.instance
        .collection("checklist")
        .snapshots()
        .map(nutrientListFromSnapshot);
  }

  List<Nutrient> nutrientListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Nutrient(
        id: doc.id ?? 0,
        tileContent: doc['content'] ?? 0,
        hintText: doc['hintText'] ?? 0,
      );
    }).toList();
  }

  checkNutrientTile(String id, bool checked) async {
    var entryName;
    if (globals.selectedDate != getCurrentDate()) {
      entryName = reformatDate(globals.selectedDate);
    } else {
      entryName = reformatDate(getCurrentDate());
    }
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('entries')
        .doc(entryName)
        .collection('nutrientChecklist')
        .doc(id)
        .set({
      'id': id,
      'taken': checked,
    });
  }

  Stream<List<LoggedNutrient>> getLoggedNutrients() {
    var entryName;
    if (globals.selectedDate != getCurrentDate()) {
      entryName = reformatDate(globals.selectedDate);
    } else {
      entryName = reformatDate(getCurrentDate());
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('entries')
        .doc(entryName)
        .collection('nutrientChecklist')
        .snapshots()
        .map(loggedNutrientListFromSnapshot);
  }

  List<LoggedNutrient> loggedNutrientListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return LoggedNutrient(
        id: doc.id ?? '',
        taken: doc['taken'] ?? false,
      );
    }).toList();
  }

  //activity diary
  Future addActivity(String activityType, double distance, double duration,
      double calories) async {
    var roundedDistanceString = distance.toStringAsExponential(2);
    double roundedDistance = double.parse(roundedDistanceString);
    var roundedDurationString = duration.toStringAsExponential(2);
    double roundedDuration = double.parse(roundedDurationString);
    var roundedCaloriesString = calories.toStringAsExponential(2);
    double roundedCalories = double.parse(roundedCaloriesString);

    var entryName = getEntryName();
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('entries')
        .doc(entryName)
        .collection('activities')
        .add({
      'type': activityType,
      'distance': roundedDistance,
      'duration': roundedDuration,
      'calories': roundedCalories,
    });
  }

  //not working but same functionality as med checklist
  Stream<List<Activity>> get activities {
    var entryName = getEntryName();
    return FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection('entries')
        .doc(entryName)
        .collection('activities')
        .snapshots()
        .map(activityListFromSnapshot);
  }

  List<Activity> activityListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Activity(
        activityType: doc['type'] ?? '',
        distance: doc['distance'] ?? 0,
        duration: doc['duration'] ?? 0,
        calories: doc['calories'] ?? 0,
        docId: doc.id,
      );
    }).toList();
  }

  deleteActivity(String docId) async {
    var entryName = getEntryName();
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('entries')
        .doc(entryName)
        .collection('activities')
        .doc(docId)
        .delete();
  }

  updateActivity(String docId, String type, double distance, double duration,
      double calories) async {
    var entryName = getEntryName();
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('entries')
        .doc(entryName)
        .collection('activities')
        .doc(id)
        .update({
      'type': type,
      'distance': distance,
      'duration': duration,
      'calories': calories,
    });
  }

  //misc
  String getEntryName() {
    var entryName;
    if (globals.selectedDate != getCurrentDate()) {
      entryName = reformatDate(globals.selectedDate);
    } else {
      entryName = reformatDate(getCurrentDate());
    }
    return entryName;
  }

  //misc
  String getCurrentTime() {
    var time = new DateTime.now().toString();
    var timeParse = DateTime.parse(time);
    String minute = timeParse.minute.toString();
    if (timeParse.minute < 10) {
      minute = "0${minute}";
    }
    var formattedTime = "${timeParse.hour}:${minute}";
    return formattedTime;
  }

  String getCurrentDate() {
    var date = new DateTime.now().toString();
    var dateParse = DateTime.parse(date);
    var formattedDate = "${dateParse.day}/${dateParse.month}/${dateParse.year}";
    return formattedDate;
  }

  String reformatDate(String date) {
    var newDateArr = date.split("/");
    String newDate = "";
    newDate = newDate + newDateArr[0] + newDateArr[1] + newDateArr[2];
    return newDate;
  }
}
