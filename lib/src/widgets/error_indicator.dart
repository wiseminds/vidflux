
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../vidflux.dart';


class ErrorIndicator extends StatefulWidget {
  final VoidCallback initController;

  const ErrorIndicator({Key key, this.initController}) : super(key: key);
  @override
  _ErrorWidgetState createState() => _ErrorWidgetState();
}

class _ErrorWidgetState extends State<ErrorIndicator> {
  @override
  Widget build(BuildContext context) {
    return Consumer<StateNotifier>(
        builder: (context, state, _) => state.hasError
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Text(
                      state.message ?? '',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w100,
                          letterSpacing: 2),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: RaisedButton(
                          color: Colors.white,
                          child: Text(
                            'Reload',
                            style: Theme.of(context)
                                .textTheme
                                .body1
                                .copyWith(color: Colors.black),
                          ),
                          onPressed: widget.initController),
                    ),
                    // Spacer(),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              )
            : SizedBox.shrink());
  }
}
