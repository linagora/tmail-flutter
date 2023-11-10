
import 'package:core/utils/app_logger.dart';
import 'package:dns_client/dns_client.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/login_exception.dart';

class DNSService {
  static const String _jmapServiceName = '_jmap._tcp';

  Future<String> _dnsLookupToUrlFromSRVType({required String hostName}) async {
    try {
      final url = await _dnsLookupToUrlByGoogle(hostName: hostName);
      if (url.isEmpty) {
        return await _dnsLookupToUrlByCloudflare(hostName: hostName);
      }
      return url;
    } catch (e) {
      return await _dnsLookupToUrlByCloudflare(hostName: hostName);
    }
  }

  Future<String> _dnsLookupToUrlByGoogle({required String hostName}) async {
    final dns = DnsOverHttps.google();
    final listData = await dns.lookupDataByRRType(hostName, RRType.SRVType);
    if (listData.isEmpty) {
      throw NotFoundDataResourceRecordException();
    }
    return _parsingUrlFromDataResourceRecord(listData.first);
  }

  Future<String> _dnsLookupToUrlByCloudflare({required String hostName}) async {
    final dns = DnsOverHttps.cloudflare();
    final listData = await dns.lookupDataByRRType(hostName, RRType.SRVType);
    if (listData.isEmpty) {
      throw NotFoundDataResourceRecordException();
    }
    return _parsingUrlFromDataResourceRecord(listData.first);
  }

  String _parsingUrlFromDataResourceRecord(String data) {
    if (data.isEmpty) {
      throw NotFoundDataResourceRecordException();
    }
    final listFieldData = data.split(' ');
    if (listFieldData.isEmpty) {
      throw NotFoundUrlException();
    }
    final url = _removeDotAtEndOfString(listFieldData.last);
    log('DNSService::_parsingUrlFromDataResourceRecord:url: $url');
    if (url.trim().isEmpty) {
      throw NotFoundUrlException();
    }
    return url;
  }

  Future<String> getJmapUrl(String emailAddress) async {
   final domainName = emailAddress.split('@')[1];
   final jmapHostName = '$_jmapServiceName.$domainName';
   log('DNSHandler::getJmapUrl:jmapHostName: $jmapHostName');
   return await _dnsLookupToUrlFromSRVType(hostName: jmapHostName);
  }

  String _removeDotAtEndOfString(String value) {
    if (value.lastIndexOf('.') == value.length - 1) {
      return value.substring(0, value.length - 1);
    }
    return value;
  }
}
