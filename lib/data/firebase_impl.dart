import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:latlong/latlong.dart';
import 'package:policjawsylwestra/domain/data_repository.dart';
import 'package:universal_platform/universal_platform.dart';

class FirebaseImpl extends DataRepository {
  FirebaseImpl() {
    Firebase.initializeApp();
  }
  @override
  Future<void> getNearestPolice(LatLng position, double radius) async {
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      Firebase.initializeApp();

      // GeoFlutterFire only for iOS/Android.
      final pointsFirebaseStream = Geoflutterfire()
          .collection(
              collectionRef: FirebaseFirestore.instance.collection('points'))
          .within(
              center: GeoFirePoint(position.latitude, position.longitude),
              radius: radius,
              field: 'position');

      final test = pointsFirebaseStream.map((snapShot) => snapShot.map((e) {
            final position = (e.data()['position']['geopoint'] as GeoPoint);
            return PolicePoint(
                position: LatLng(position.latitude, position.longitude),
                policeType: PoliceType.foot);
          }).toList());

      test.listen((event) {
        policePointsStream.add(event);
      });

      // policePointsStream.addStream(test);

      // final policePoints = [];
      // pointsFirebaseStream.listen((event) {
      //   for (final obj in event) {
      //     final position = obj.data()['position']['geopoint'] as GeoPoint;
      //     final policePoint = PolicePoint(
      //         position: LatLng(position.latitude, position.longitude),
      //         policeType: PoliceType.foot);
      //     policePoints.add(policePoint);
      //   }
      // });

      // return policePoints;
    }
  }

  @override
  Future<void> addPoint(LatLng position, PoliceType policeType) async {
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      // GeoFlutterFire only for iOS/Android.
      final GeoFirePoint geoFirePoint = Geoflutterfire()
          .point(latitude: position.latitude, longitude: position.longitude);

      FirebaseFirestore.instance
          .collection('points')
          .add({'policeType': policeType, 'position': geoFirePoint.data});
    }
  }
}
