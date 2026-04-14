import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'application_provider.dart';

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
              'isAdmin': data['isAdmin'] ?? false,
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
              'isAdmin': data['isAdmin'] ?? false,
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
            'isAdmin': data['isAdmin'] ?? false,
            'isJobPost': true,
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
            'isAdmin': data['isAdmin'] ?? false,
            'isJobPost': true,
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

final unifiedFeedProvider = StreamProvider((ref) {
  return FirebaseFirestore.instance
      .collection('posts')
      .snapshots()
      .map((snapshot) {
        final docs = snapshot.docs.map((doc) {
          final data = doc.data();
          final bool isJob = data['isJobPost'] == true;

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
            'isAdmin': data['isAdmin'] ?? false,
            'isJobPost': isJob,
            'isAvailabilityPost': data['isAvailabilityPost'] ?? false,
            'jobTitle': data['jobTitle'] ?? 'Job Posting',
            'jobSalary': data['jobSalary'] ?? 'Negotiable',
            'likes': data['likes'] ?? 0,
            'comments': data['comments'] ?? 0,
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

final userPostsProvider = StreamProvider.autoDispose.family<List<Map<String, dynamic>>, String>((ref, uid) {
  if (uid.isEmpty) return Stream.value([]);
  
  return FirebaseFirestore.instance
      .collection('posts')
      .where('uid', isEqualTo: uid)
      .snapshots()
      .map((snapshot) {
        final docs = snapshot.docs.map((doc) {
          final data = doc.data();
          final bool isJob = data['isJobPost'] == true;
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
            'isAdmin': data['isAdmin'] ?? false,
            'isJobPost': isJob,
            'isAvailabilityPost': data['isAvailabilityPost'] ?? false,
            'jobTitle': data['jobTitle'] ?? 'Job Posting',
            'jobSalary': data['jobSalary'] ?? 'Negotiable',
            'likes': data['likes'] ?? 0,
            'comments': data['comments'] ?? 0,
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

final workerAppliedJobsProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final applicationsAsync = ref.watch(userApplicationsProvider);
  
  return applicationsAsync.when(
    data: (applications) async* {
      if (applications.isEmpty) {
        yield [];
        return;
      }

      final List<Future<DocumentSnapshot>> futures = applications.map((app) {
        final jobId = app['jobId'] as String;
        return FirebaseFirestore.instance.collection('posts').doc(jobId).get();
      }).toList();

      final jobSnapshots = await Future.wait(futures);
      
      final List<Map<String, dynamic>> appliedJobs = [];
      for (var doc in jobSnapshots) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          appliedJobs.add({
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
            'isAdmin': data['isAdmin'] ?? false,
            'isJobPost': true,
            'jobTitle': data['jobTitle'] ?? 'Job Posting',
            'jobSalary': data['jobSalary'] ?? 'Negotiable',
            'likes': data['likes'] ?? 0,
            'comments': data['comments'] ?? 0,
            'createdAt': data['createdAt'],
          });
        }
      }
      yield appliedJobs;
    },
    loading: () => Stream.value(<Map<String, dynamic>>[]),
    error: (e, st) => Stream.error(e),
  );
});

final systemAnnouncementsProvider = StreamProvider((ref) {
  final auth = ref.watch(authProvider);
  final currentUid = auth?.uid;

  return FirebaseFirestore.instance
      .collection('announcements')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'title': data['title'] ?? 'Official Update',
              'message': data['message'] ?? '',
              'createdAt': data['createdAt'],
              'type': data['type'] ?? 'general',
              'postId': data['postId'],
              'targetUid': data['targetUid'],
            };
          })
          .where((msg) {
            final target = msg['targetUid'];
            // Show if it's a global announcement OR targeted specifically to this user
            return target == null || target == 'all' || target == 'global' || target == currentUid;
          })
          .toList());
});