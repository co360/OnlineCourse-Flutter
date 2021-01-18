library page;

import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

import '../../bloc/bloc.dart';
import '../../injector.dart';
import '../../service/service.dart';
import '../component/component.dart';

part 'home.dart';
part 'entry.dart';
part 'login.dart';

abstract class Page<T extends Bloc> extends StatefulWidget {

  Page({
    Key key,
    this.hasNetworkSnack = false
  }) : super(key: key);

  final T bloc = injector.getBloc<T>();
  final bool hasNetworkSnack; 

  @override
  _PageState createState() => _PageState();

  @protected
  Widget build(BuildContext context);

  @protected
  void init();

  @protected
  void dispose();
}

class _PageState extends State<Page> {
  bool hasOffline = false;
  bool hasOnline = false;

  @override
  void initState() {
    super.initState();
    widget.init();
    widget.bloc.init();
  }

  @override
  void dispose() {
    super.dispose();
    widget.dispose();
    widget.bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ConnectionStatus>(
      valueListenable: injector.getService<ConnectionService>().networkStatusNotifier,
      builder: (context, value, child) {
        if (widget.hasNetworkSnack) {
          if (value == ConnectionStatus.offline && !hasOnline) {
            Future.delayed(const Duration(milliseconds: 500))
              .whenComplete(() => showFlash(
                context: context,
                duration: const Duration(seconds: 3),
                builder: (context, controller) => SnackFlashBar(
                  controller: controller,
                  contentMessage: 'OFFLINE',
                  actionMessage: 'DISMISS',
                )
              ));
            hasOffline = true;
          } else if (hasOffline) {
            Future.delayed(const Duration(milliseconds: 500))
              .whenComplete(() => showFlash(
                context: context,
                duration: const Duration(seconds: 1),
                builder: (context, controller) => SnackFlashBar(
                  controller: controller,
                  contentMessage: 'ONLINE',
                  actionMessage: 'DISMISS',
                )
              ));
            hasOnline = true;
          }
        }
        return child;
      },
      child: widget.build(context),
    );
  }
}