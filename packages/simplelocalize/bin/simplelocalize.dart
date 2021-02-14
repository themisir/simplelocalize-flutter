import 'package:path/path.dart' as path;
import 'package:simplelocalize/simplelocalize.dart';

void main(List<String> arguments) async {
  final app = SimplelocalizeGenerator();

  await app.readConfig(path.join(path.current, 'pubspec.yaml'));

  switch (arguments[0]) {
    case 'download':
    case 'd':
      await app.download();
      break;

    case 'upload':
    case 'u':
      await app.upload(
        publish: arguments.contains('--publish') || arguments.contains('-p'),
      );
      break;

    default:
      app.error(1, 'Invalid command');
      break;
  }
}
