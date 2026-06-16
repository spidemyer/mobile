import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/contact_model.dart';
import '../models/field_model.dart';

class ContactController extends ChangeNotifier { //gerencia o estado dos contatos
  List<Contact> _contacts = [];
  List<Contact> _recentContacts = [];
  List<AdditionalField> _currentFields = [];
  bool _isLoading = false;
  bool _isDarkMode = false; // Estado do tema escuro e claro

  List<Contact> get contacts => _contacts;
  List<Contact> get recentContacts => _recentContacts;
  List<AdditionalField> get currentFields => _currentFields;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;

  final _dbHelper = DatabaseHelper.instance;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  Future<void> fetchContacts() async { //método para buscar os contatos do banco de dados
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _dbHelper.queryAllContactsOrdered();
      _contacts = data.map((e) => Contact.fromMap(e)).toList();
      
      final recentData = await _dbHelper.queryRecentContacts();
      _recentContacts = recentData.map((e) => Contact.fromMap(e)).toList();
    } catch (e) {
      debugPrint("Erro ao buscar contatos: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveContact(Contact contact) async { //método para salvar e atualizar os contatos
    try {
      if (contact.id == null) {
        await _dbHelper.insertContact(contact.toMap());
      } else {
        await _dbHelper.updateContact(contact.toMap());
      }
      await fetchContacts();
      return true;
    } catch (e) {
      debugPrint("Erro ao salvar contato: $e");
      return false;
    }
  }

  Future<bool> removeContact(int id) async { //método para apagar o contato
    try {
      await _dbHelper.deleteContact(id);
      await fetchContacts();
      return true;
    } catch (e) {
      debugPrint("Erro ao deletar contato: $e");
      return false;
    }
  }

  Future<void> fetchFieldsForContact(int contactId) async { //método para buscar os campos de um contato
    try {
      final data = await _dbHelper.queryFieldsForContact(contactId);
      _currentFields = data.map((e) => AdditionalField.fromMap(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao buscar subelementos: $e");
    }
  }

  Future<bool> addAdditionalField(int contactId, String type, String value) async { //método para adicionar um campo para um contato
    try {
      final field = AdditionalField(
        contactId: contactId,
        fieldType: type,
        fieldValue: value,
      );
      await _dbHelper.insertField(field.toMap());
      await fetchFieldsForContact(contactId);
      return true;
    } catch (e) {
      debugPrint("Erro ao inserir subelemento: $e");
      return false;
    }
  }
}