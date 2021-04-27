import 'package:alan_voice/alan_voice.dart';
import 'package:flutter/material.dart';

import 'Product/addProduct.dart';
import 'Product/databaseService.dart';
import 'Product/newItem.dart';
import 'Product/editProduct.dart';
import 'Product/listHome.dart';
import 'Product/item.dart';
import 'Product/previewProduct.dart';

class AlanAI {
  DatabaseService databaseService = new DatabaseService();
  BuildContext context;
  dynamic page;
  NewItem newItem;
  Item deleteItem;
  TextEditingController searchController = TextEditingController();

  // android/app/build.gradle change minSdkVersion to 21
  void initAlanButton() async {
    AlanVoice.addButton(
        "36e2d97001aae4fab5bf6e3fe4fb8e492e956eca572e1d8b807a3e2338fdd0dc/stage");
    AlanVoice.callbacks.add((command) => _handleCommand(command.data));
  }

  void resetButton() async {
    AlanVoice.deactivate();
    //AlanVoice.hideButton();
  }

  void setVisuals(String screen, String response) {
    String visual = "{\"screen\" : \"$screen\"\, \"response\" : \"$response\"}";
    print('visual' + visual);
    AlanVoice.setVisualState(visual);
  }

  void _handleCommand(Map<String, dynamic> command) async {
    switch (command['command']) {
      case 'goBack':
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => ListHome(this)),
            (Route<dynamic> route) => false);
        break;

      //Add Item
      case 'addItem':
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => AddProduct(this)),
            (Route<dynamic> route) => false);
        break;
      case 'addName':
        newItem.nameController.text = command['value'];
        newItem.name = command['value'];
        setVisuals('addPage', 'category');
        break;
      case 'addCategory':
        newItem.categoryController.text = command['value'];
        newItem.category = command['value'];
        setVisuals('addPage', 'aisle');
        break;
      case 'addAisle':
        newItem.aisleController.text = command['value'];
        newItem.aisle = command['value'];
        setVisuals('addPage', 'quantity');
        break;
      case 'addQuantity':
        newItem.quantityController.text = command['value'];
        newItem.quantity = command['value'];
        setVisuals('addPage', 'price');
        break;
      case 'addPrice':
        newItem.priceController.text = command['value'];
        newItem.price = command['value'];
        setVisuals('addPage', 'notes');
        break;
      case 'addNotes':
        newItem.notesController.text = command['value'];
        newItem.notes = command['value'];
        setVisuals('addPage', null);
        break;
      case 'addSubmit':
        var result = await page.addSubmit();
        if (!result) {
          setVisuals('addPage', 'invalidInput');
        }
        break;

      //Preview Item
      case 'previewItem':
        Item item = page.getItem(command['value']);
        if (item == null) {
          AlanVoice.playText('Item does not exist');
        } else {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => PreviewProduct(item, this)),
              (Route<dynamic> route) => false);
        }
        break;
      case 'previewMode':
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => PreviewProduct(page.item, this)),
            (Route<dynamic> route) => false);
        break;

      //Edit Item
      case 'editItem':
        Item item = page.getItem(command['value']);
        if (item == null) {
          AlanVoice.playText('Item does not exist');
        } else {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => EditProduct(item, this)),
              (Route<dynamic> route) => false);
        }
        break;
      case 'editName':
        newItem.nameController.text = command['value'];
        newItem.name = command['value'];
        break;
      case 'editCategory':
        newItem.categoryController.text = command['value'];
        newItem.category = command['value'];
        break;
      case 'editAisle':
        newItem.aisleController.text = command['value'];
        newItem.aisle = command['value'];
        break;
      case 'editQuantity':
        newItem.quantityController.text = command['value'];
        newItem.quantity = command['value'];
        break;
      case 'editPrice':
        newItem.priceController.text = command['value'];
        newItem.price = command['value'];
        break;
      case 'editNotes':
        newItem.notesController.text = command['value'];
        newItem.notes = command['value'];
        break;
      case 'editSubmit':
        var result = await page.editSubmit();
        if (!result) {
          setVisuals('editPage', 'invalidInput');
        }
        break;
      case 'editMode':
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => EditProduct(page.item, this)),
            (Route<dynamic> route) => false);
        break;

      //Search
      case 'searchItem':
        searchController.text = command['value'];
        page.searchVal = command['value'];
        page.search();
        break;

      //Delete Item
      case 'deleteItem':
        deleteItem = page.getItem(command['value']);
        if (deleteItem == null) {
          AlanVoice.playText('Item does not exist');
        } else {
          deleteItem.verifyDelete(context, this);
        }
        break;
      case 'verifyYes':
        await DatabaseService().deleteItemData(deleteItem.uid);
        Navigator.of(context).pop();
        setVisuals('listPage', null);
        break;
      case 'verifyNo':
        Navigator.of(context).pop();
        setVisuals('listPage', null);
        break;
    }
  }
}
