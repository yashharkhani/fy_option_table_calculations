import 'package:flutter/material.dart';
import 'package:option_chain_renderer/grid_two_dimensional_scroller.dart';
import 'package:option_chain_renderer/option_chain.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
          // Mouse dragging enabled for this demo
          // dragDevices: PointerDeviceKind.values.toSet(),
          ),
      debugShowCheckedModeBanner: false,
      home: const OptionChain(),
      // home: const GridTwoDimensionalScroller(),
      // home: const OptionChain(),
    );
  }
}
