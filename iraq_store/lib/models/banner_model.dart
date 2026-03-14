import 'package:pocketbase/pocketbase.dart';
import 'package:iraq_store/pocketbase_instance.dart';

class BannerModel {
  final String id;
  final String imageUrl;

  BannerModel({required this.id, required this.imageUrl});

  factory BannerModel.fromRecord(RecordModel record) {
    return BannerModel(
      id: record.id,
      imageUrl: pb.getFileUrl(record, record.data['image']).toString(),
    );
  }
}
