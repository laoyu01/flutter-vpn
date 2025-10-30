import 'dart:convert';
// 尽量根据 net 字段设置 transport
'transport': {
'type': (m['net'] == 'ws') ? 'ws' : 'tcp'
}
};
parsed.add({'name': name, 'outbound': outbound});
} catch (e) {
// 忽略解析错误
}
}
if (parsed.isNotEmpty) {
nodes = parsed;
return nodes;
}
}


// 3) 尝试当作 Clash YAML（简单支持）
try {
final dyn = loadYaml(body);
if (dyn is Map && dyn['proxies'] is List) {
final pList = (dyn['proxies'] as List);
final parsed = pList.map<Map<String, dynamic>>((p) {
final map = Map<String, dynamic>.from(p);
final name = map['name'] ?? '${map['server']}:${map['port']}';
// 这里只做简单映射：支持 vmess/trojan/shadowsocks
Map<String, dynamic> outbound = {};
final type = map['type'];
if (type == 'vmess') {
outbound = {
'type': 'vmess',
'tag': name,
'server': map['server'],
'server_port': map['port'],
'uuid': map['uuid'] ?? map['id'],
'alter_id': map['alterId'] ?? 0,
'transport': { 'type': map['network'] == 'ws' ? 'ws' : 'tcp' }
};
} else if (type == 'trojan') {
outbound = {
'type': 'trojan',
'tag': name,
'server': map['server'],
'server_port': map['port'],
'password': map['password'] ?? map['passwd'],
'tls': { 'enabled': map['tls'] == true }
};
}
return {'name': name, 'outbound': outbound};
}).where((e) => e['outbound'].isNotEmpty).toList();


if (parsed.isNotEmpty) {
nodes = parsed;
return nodes;
}
}
} catch (e) {
// 忽略
}


throw Exception('无法识别的订阅格式');
}


// 将当前 nodes 写入 sing-box config 文件，selectedIndex 指选择的最终出站
Future<String> writeSingboxConfig(String appDirPath, {int selectedIndex = 0}) async {
if (nodes.isEmpty) throw Exception('没有可用节点，请先更新订阅');
final outbounds = <Map<String, dynamic>>[];
for (var i = 0; i < nodes.length; i++) {
final node = nodes[i];
final tag = 'node\$i';
final outbound = Map<String, dynamic>.from(node['outbound'] as Map);
outbound['tag'] = tag;
outbounds.add(outbound);
}


final chosenTag = outbounds[selectedIndex]['tag'];


final config = {
'log': {'level': 'info'},
'inbounds': [
{