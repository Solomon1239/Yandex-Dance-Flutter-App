import 'dart:async';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yandex_dance/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const _CreateOneEventApp());
}

class _CreateOneEventApp extends StatefulWidget {
  const _CreateOneEventApp();

  @override
  State<_CreateOneEventApp> createState() => _CreateOneEventAppState();
}

class _CreateOneEventAppState extends State<_CreateOneEventApp> {
  String _status = 'Подготовка...';

  @override
  void initState() {
    super.initState();
    unawaited(_createOne());
  }

  Future<void> _createOne() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _status = 'CREATE_ERROR: пользователь не авторизован';
      });
      return;
    }

    try {
      final now = DateTime.now();
      final doc = await FirebaseFirestore.instance.collection('events').add({
        'title': 'Open Dance Practice',
        'description':
            'Тестовое мероприятие: разминка, базовая техника и практика в парах.',
        'danceStyle': 'house',
        'dateTime': Timestamp.fromDate(now.add(const Duration(days: 1))),
        'address': 'Москва, Тверская 7',
        'latitude': 55.7558,
        'longitude': 37.6173,
        'maxParticipants': 20,
        'participantIds': [uid],
        'ageRestriction': '16+',
        'promoVideoUrl': null,
        'promoVideoThumbUrl': null,
        'promoVideoStoragePath': null,
        'promoVideoThumbStoragePath': null,
        'coverUrl': null,
        'coverThumbUrl': null,
        'coverStoragePath': null,
        'coverThumbStoragePath': null,
        'creatorId': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('CREATE_DONE: ${doc.id}');
      if (mounted) {
        setState(() {
          _status = 'CREATE_DONE: ${doc.id}';
        });
      }
    } on FirebaseException catch (e, st) {
      debugPrint('CREATE_FIREBASE_ERROR code=${e.code} message=${e.message}');
      debugPrint(st.toString());
      if (mounted) {
        setState(() {
          _status = 'CREATE_ERROR: ${e.code} ${e.message ?? ''}'.trim();
        });
      }
      return;
    } catch (e, st) {
      debugPrint('CREATE_ERROR type=${e.runtimeType} error=$e');
      debugPrint(st.toString());
      if (mounted) {
        setState(() {
          _status = 'CREATE_ERROR: ${e.runtimeType}: $e';
        });
      }
      return;
    }

    await Future<void>.delayed(const Duration(seconds: 2));
    if (Platform.isIOS || Platform.isAndroid) {
      await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
