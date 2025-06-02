import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vender_tracker/common/constants/img_constants.dart';

class NoDataFoundPage extends StatelessWidget {

  const NoDataFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Lottie.asset(ImgConst.noDataLottie));
  }
}


class LoadingPage extends StatelessWidget {

  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Lottie.asset(ImgConst.loaderLottie));
  }
}


class ErrorPage extends StatelessWidget {

  final VoidCallback? onRetry;
  const ErrorPage({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Lottie.asset(ImgConst.errorLottie),

        GestureDetector(
          onTap: () => onRetry?.call(),
          child: Container(
            width: 200,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              border: Border.all(color: Colors.red, width: 2),
            ),
            child: Text(
              "Retry",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}