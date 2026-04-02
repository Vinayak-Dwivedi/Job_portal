import 'package:cloud_firestore/cloud_firestore.dart';

class EmployerModel {
  final String uid;
  final String companyName;
  final String businessType;
  final String? website;
  final String contactPersonName;
  final String phone;
  final String? email;
  final String officeAddress;
  final GeoPoint? officeLatLng;
  final String? logoUrl;
  final String? gstCertificateUrl;
  final String? govtIdUrl;
  final bool isVerified;
  final int credits;

  EmployerModel({
    required this.uid,
    required this.companyName,
    required this.businessType,
    this.website,
    required this.contactPersonName,
    required this.phone,
    this.email,
    required this.officeAddress,
    this.officeLatLng,
    this.logoUrl,
    this.gstCertificateUrl,
    this.govtIdUrl,
    this.isVerified = false,
    this.credits = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'businessType': businessType,
      'website': website,
      'contactPersonName': contactPersonName,
      'phone': phone,
      'email': email,
      'officeAddress': officeAddress,
      'officeLatLng': officeLatLng,
      'logoUrl': logoUrl,
      'gstCertificateUrl': gstCertificateUrl,
      'govtIdUrl': govtIdUrl,
      'isVerified': isVerified,
      'credits': credits,
    };
  }

  factory EmployerModel.fromMap(Map<String, dynamic> map, String uid) {
    return EmployerModel(
      uid: uid,
      companyName: map['companyName'] ?? '',
      businessType: map['businessType'] ?? '',
      website: map['website'],
      contactPersonName: map['contactPersonName'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      officeAddress: map['officeAddress'] ?? '',
      officeLatLng: map['officeLatLng'],
      logoUrl: map['logoUrl'],
      gstCertificateUrl: map['gstCertificateUrl'],
      govtIdUrl: map['govtIdUrl'],
      isVerified: map['isVerified'] ?? false,
      credits: map['credits'] ?? 0,
    );
  }
}
