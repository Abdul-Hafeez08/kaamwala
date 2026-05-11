import 'dart:io';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/cloudinary_service.dart';

class WorkerController {
  final FirestoreService _firestoreService = FirestoreService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  Future<WorkerModel?> getWorkerProfile(String workerId) async {
    return await _firestoreService.getWorkerDocument(workerId);
  }

  Stream<WorkerModel?> streamWorkerProfile(String workerId) {
    return _firestoreService.streamWorkerDocument(workerId);
  }

  Future<void> submitWorkerProfile({
    required String workerId,
    required String name,
    required String email,
    required String phone,
    required String profileImage,
    required String serviceType,
    required String experience,
    required String skills,
    required String location,
    required bool availability,
    required String nic,
    String pricingType = 'fixed',
    double hourlyRate = 0.0,
  }) async {
    final Map<String, dynamic> workerData = {
      'workerId': workerId,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'serviceType': serviceType,
      'experience': experience,
      'skills': skills,
      'location': location,
      'availability': availability,
      'nic': nic,
      'pricingType': pricingType,
      'hourlyRate': hourlyRate,
    };

    await _firestoreService.updateWorkerDocument(workerId, workerData);
  }

  Future<void> updateAvailability(String workerId, bool isAvailable) async {
    await _firestoreService.updateWorkerDocument(workerId, {
      'availability': isAvailable,
    });
  }

  Future<String?> pickAndUploadImage() async {
    final File? imageFile = await _cloudinaryService.pickImageFromGallery();

    if (imageFile == null) {
      return null;
    }

    final String imageUrl = await _cloudinaryService.uploadImage(imageFile: imageFile);
    return imageUrl;
  }

  Future<String?> pickAndUploadImageFromCamera() async {
    final File? imageFile = await _cloudinaryService.pickImageFromCamera();

    if (imageFile == null) {
      return null;
    }

    final String imageUrl = await _cloudinaryService.uploadImage(imageFile: imageFile);
    return imageUrl;
  }

  Future<void> updateJobStatus(String jobId, String status, {double? price}) async {
    final Map<String, dynamic> data = {'status': status};
    
    if (status == 'working') {
      data['startedAt'] = DateTime.now();
    } else if (status == 'completed') {
      data['completedAt'] = DateTime.now();
    }

    if (price != null) {
      data['price'] = price;
    }
    await _firestoreService.updateJob(jobId, data);
  }

  Future<void> acceptOpenJob({
    required String jobId,
    required String workerId,
    required String workerName,
    required String workerImage,
  }) async {
    await _firestoreService.updateJob(jobId, {
      'workerId': workerId,
      'workerName': workerName,
      'workerImage': workerImage,
      'status': 'accepted',
      'isGeneralRequest': false,
    });
  }
}
