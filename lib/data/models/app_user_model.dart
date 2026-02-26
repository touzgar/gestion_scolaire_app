import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/user_role.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.uid,
    required super.nom,
    required super.prenom,
    required super.email,
    super.photoUrl,
    super.telephone,
    required super.role,
    super.isActive,
    required super.dateCreation,
  });

  factory AppUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUserModel(
      uid: doc.id,
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      telephone: data['telephone'],
      role: UserRoleExtension.fromString(data['role'] ?? 'eleve'),
      isActive: data['isActive'] ?? true,
      dateCreation:
          (data['dateCreation'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'photoUrl': photoUrl,
      'telephone': telephone,
      'role': role.firestoreValue,
      'isActive': isActive,
      'dateCreation': Timestamp.fromDate(dateCreation),
    };
  }

  factory AppUserModel.fromEntity(AppUser user) {
    return AppUserModel(
      uid: user.uid,
      nom: user.nom,
      prenom: user.prenom,
      email: user.email,
      photoUrl: user.photoUrl,
      telephone: user.telephone,
      role: user.role,
      isActive: user.isActive,
      dateCreation: user.dateCreation,
    );
  }
}
