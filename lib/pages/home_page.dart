import 'dart:io';
import 'package:flutter/material.dart';
import '../services/subscription_manager.dart';
import '../services/singrt';box_manager.da



class HomePage extends StatefulWidget {
const HomePage({super.key});


@override
State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
final TextEditingController _subController = TextEditingController();
final SubscriptionManager _subManager = SubscriptionManager();
final SingBoxManager _core = SingBoxManager();


List<String> _nodes = [];
bool _running = false;
int _selectedIndex = 0;
String _log = '';


void _appendLog(String line) {
setState(() => _log = '${DateTime.now().toIso8601String()} $line\n' + _log);
}


Future<void> _updateSubscription() async {
final url = _subController.text.trim();
if (url.isEmpty) return;
try {
_appendLog('开始下载订阅：$url');
final nodes = await _subManager.fetchNodesFromSubscription(url);
setState(() {
_nodes = nodes.map((n) => n['name'] as String? ?? n['tag'] as String? ?? 'node').toList();
_selectedIndex = 0;
});
_appendLog('订阅更新完成：共 ${_nodes.length} 个节点');
} catch (e) {
_appendLog('订阅更新失败：\$e');
}
}

Future<void> _startStop() async {
} catch (e) {
_appendLog('sing-box 启动失败: \$e');
}
}


@override
void dispose() {
_subController.dispose();
_core.stop();
super.dispose();
}


@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('My VPN (Windows)')),
body: Padding(
padding: const EdgeInsets.all(16.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
TextField(
controller: _subController,
decoration: const InputDecoration(
labelText: '订阅链接',
hintText: 'https://.../sub',
),
),
const SizedBox(height: 8),
Row(children: [
ElevatedButton(onPressed: _updateSubscription, child: const Text('更新订阅')),
const SizedBox(width: 8),
ElevatedButton(onPressed: _startStop, child: Text(_running ? '停止' : '启动')),
]),
const SizedBox(height: 12),
const Text('节点列表：'),
DropdownButton<int>(
value: _nodes.isEmpty ? null : _selectedIndex,
items: _nodes.asMap().entries.map((e) => DropdownMenuItem<int>(value: e.key, child: Text(e.value))).toList(),
hint: const Text('尚未加载节点'),
onChanged: (v) {
if (v == null) return;
setState(() => _selectedIndex = v);
},
),
const SizedBox(height: 12),
const Text('日志：'),
Expanded(
child: Container(
width: double.infinity,
decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
child: SingleChildScrollView(
reverse: true,
child: Padding(
padding: const EdgeInsets.all(8.0),
child: Text(_log),
),
),
),
),
],
),
),
);
}
}