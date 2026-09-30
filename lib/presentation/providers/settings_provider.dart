import 'package:flutter/material.dart'; import 'package:shared_preferences/shared_preferences.dart';
class SettingsProvider extends ChangeNotifier { static const _darkKey='settings.dark',_langKey='settings.language',_dwellKey='settings.dwellMs'; bool darkMode=false; Locale locale=const Locale('ar'); int dwellMs=900;
Future<void> load() async{final p=await SharedPreferences.getInstance();darkMode=p.getBool(_darkKey)??false;locale=Locale(p.getString(_langKey)??'ar');dwellMs=p.getInt(_dwellKey)??900;notifyListeners();}
Future<void> setDarkMode(bool v) async{darkMode=v;notifyListeners();final p=await SharedPreferences.getInstance();await p.setBool(_darkKey,v);}
Future<void> setLanguage(String v) async{locale=Locale(v);notifyListeners();final p=await SharedPreferences.getInstance();await p.setString(_langKey,v);}
Future<void> setDwellMs(int v) async{dwellMs=v.clamp(500,2000);notifyListeners();final p=await SharedPreferences.getInstance();await p.setInt(_dwellKey,dwellMs);}}