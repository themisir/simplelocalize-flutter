import 'package:path/path.dart' as path;
import 'package:simplelocalize/simplelocalize.dart';

const helpText = 'SimpeLocalize.io - Dart CLI v0.2.0\n'
    'Commands:\n'
    'simplelocalize download               Download translations from CDN.\n'
    'simplelocalize d\n\n'
    'simplelocalize upload [--publish|-p]  Upload translations to simplelocalize.\n'
    'simplelocalize u';

void main(List<String> arguments) async {
  final app = SimplelocalizeGenerator();

  if (arguments.isEmpty) {
    app.error(1, helpText);
  }

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
