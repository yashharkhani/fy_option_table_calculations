import 'package:flutter/material.dart';
import 'package:option_chain_renderer/option_chain_table/option_chain_table.dart';

class OptionChain extends StatefulWidget {
  const OptionChain({super.key});

  @override
  State<OptionChain> createState() => _OptionChainState();
}

class _OptionChainState extends State<OptionChain> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Option chain',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.white,
        child: Center(
          child: OptionChainTable(
            tableWidth: size.width * 0.8,
            tableHeight: size.height * 0.6,
          ),
        ),
      ),
    );
  }
}
