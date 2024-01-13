import 'package:pub_api_client/pub_api_client.dart';

Future<PubPackage?> getInfo(String id) async {
  try {
    return await PubClient().packageInfo(id);
  } catch (e) {
    return null;
  }
}

Future<PackagePublisher?> getPublisher(String id) async {
  try {
    return await PubClient().packagePublisher(id);
  } catch (e) {
    return null;
  }
}
