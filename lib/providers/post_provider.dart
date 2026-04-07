import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final feedProvider = StreamProvider((ref) {
  return FirebaseFirestore.instance
      .collection('posts')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();

            return {
              'id': doc.id,
              'uid': data['uid'] ?? '',
              'name': data['name'] ?? '',
              'text': data['text'] ?? data['description'] ?? '',
              'imageUrl': data['imageUrl'],
              'location': data['location'] ?? '',
              'role': data['role'] ?? data['userRole'] ?? '',
              'profilePhotoUrl': data['profilePhotoUrl'] ?? data['userPhotoUrl'] ?? '',
              'isVerified': data['isVerified'] ?? data['isUserVerified'] ?? false,
              'likes': data['likes'] ?? 0,
              'comments': data['comments'] ?? 0,
              'createdAt': data['createdAt'],
            };
          }).toList());
});

final pendingPostsProvider = StreamProvider((ref) {
  return FirebaseFirestore.instance
      .collection('posts')
      .where('status', isEqualTo: 'pending')
      .orderBy('createdAt', descending: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();

            return {
              'id': doc.id,
              'uid': data['uid'] ?? '',
              'name': data['name'] ?? '',
              'text': data['text'] ?? data['description'] ?? '',
              'imageUrl': data['imageUrl'],
              'location': data['location'] ?? '',
              'role': data['role'] ?? data['userRole'] ?? '',
              'profilePhotoUrl': data['profilePhotoUrl'] ?? data['userPhotoUrl'] ?? '',
              'isVerified': data['isVerified'] ?? data['isUserVerified'] ?? false,
              'likes': data['likes'] ?? 0,
              'comments': data['comments'] ?? 0,
              'createdAt': data['createdAt'],
            };
          }).toList());
});

final jobFeedProvider = StreamProvider((ref) {
  return FirebaseFirestore.instance
      .collection('posts')
      .where('isJobPost', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
        final docs = snapshot.docs.map((doc) {
          final data = doc.data();

          return {
            'id': doc.id,
            'uid': data['uid'] ?? '',
            'name': data['name'] ?? '',
            'companyName': data['companyName'] ?? data['name'] ?? '',
            'text': data['text'] ?? data['description'] ?? '',
            'imageUrl': data['imageUrl'],
            'location': data['location'] ?? '',
            'role': data['role'] ?? data['userRole'] ?? '',
            'profilePhotoUrl': data['profilePhotoUrl'] ?? data['userPhotoUrl'] ?? '',
            'isVerified': data['isVerified'] ?? data['isUserVerified'] ?? false,
            'jobTitle': data['jobTitle'] ?? 'Job Posting',
            'jobSalary': data['jobSalary'] ?? 'Negotiable',
            'createdAt': data['createdAt'],
          };
        }).toList();

        docs.sort((a, b) {
          final aTime = a['createdAt'] as Timestamp?;
          final bTime = b['createdAt'] as Timestamp?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });

        return docs;
      });
});

final employerJobsProvider = StreamProvider.autoDispose.family<List<Map<String, dynamic>>, String>((ref, uid) {
  if (uid.isEmpty) return Stream.value([]);
  
  return FirebaseFirestore.instance
      .collection('posts')
      .where('isJobPost', isEqualTo: true)
      .where('uid', isEqualTo: uid)
      .snapshots()
      .map((snapshot) {
        final docs = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'uid': data['uid'] ?? '',
            'name': data['name'] ?? '',
            'companyName': data['companyName'] ?? data['name'] ?? '',
            'text': data['text'] ?? data['description'] ?? '',
            'imageUrl': data['imageUrl'],
            'location': data['location'] ?? '',
            'role': data['role'] ?? data['userRole'] ?? '',
            'profilePhotoUrl': data['profilePhotoUrl'] ?? data['userPhotoUrl'] ?? '',
            'isVerified': data['isVerified'] ?? data['isUserVerified'] ?? false,
            'jobTitle': data['jobTitle'] ?? 'Job Posting',
            'jobSalary': data['jobSalary'] ?? 'Negotiable',
            'createdAt': data['createdAt'],
          };
        }).toList();

        docs.sort((a, b) {
          final aTime = a['createdAt'] as Timestamp?;
          final bTime = b['createdAt'] as Timestamp?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });

        return docs;
      });
});