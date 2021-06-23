import 'package:contacts_service/contacts_service.dart';

List<Contact> contacts = [];

getAllContacts()async{
  List<Contact> _contacts = (await ContactsService.getContacts()).toList();
  contacts = _contacts;
}