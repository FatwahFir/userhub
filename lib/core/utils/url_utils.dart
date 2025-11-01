import 'package:flutter_dotenv/flutter_dotenv.dart';

String? normalizeAvatarUrl(String? rawUrl) {
  if (rawUrl == null || rawUrl.isEmpty) {
    return null;
  }

  final overrideHost = dotenv.env['ASSET_HOST'];
  if (overrideHost == null || overrideHost.isEmpty) {
    return rawUrl;
  }

  try {
    final overrideUri = Uri.parse(overrideHost);
    final uri = Uri.parse(rawUrl);

    // If backend returns relative path.
    if (!uri.hasScheme) {
      return overrideUri.resolve(rawUrl).toString();
    }

    final host = uri.host.toLowerCase();
    if (host == 'localhost' || host == '127.0.0.1') {
      final normalized = uri.replace(
        scheme: overrideUri.scheme.isNotEmpty ? overrideUri.scheme : uri.scheme,
        host: overrideUri.host,
        port: overrideUri.hasPort ? overrideUri.port : null,
      );
      return normalized.toString();
    }

    return rawUrl;
  } catch (_) {
    return rawUrl;
  }
}
