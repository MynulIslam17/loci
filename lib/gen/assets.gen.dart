// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsFontsGen {
  const $AssetsFontsGen();

  /// File path: assets/fonts/Inter.ttf
  String get inter => 'assets/fonts/Inter.ttf';

  /// List of all assets
  List<String> get values => [inter];
}

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/about.svg
  String get about => 'assets/icons/about.svg';

  /// File path: assets/icons/advanture.svg
  String get advanture => 'assets/icons/advanture.svg';

  /// File path: assets/icons/building.svg
  String get building => 'assets/icons/building.svg';

  /// File path: assets/icons/calander.svg
  String get calander => 'assets/icons/calander.svg';

  /// File path: assets/icons/care.svg
  String get care => 'assets/icons/care.svg';

  /// File path: assets/icons/comunity.svg
  String get comunity => 'assets/icons/comunity.svg';

  /// File path: assets/icons/event1.svg
  String get event1 => 'assets/icons/event1.svg';

  /// File path: assets/icons/foodie.svg
  String get foodie => 'assets/icons/foodie.svg';

  /// File path: assets/icons/helth.svg
  String get helth => 'assets/icons/helth.svg';

  /// File path: assets/icons/local.svg
  String get local => 'assets/icons/local.svg';

  /// File path: assets/icons/logout.svg
  String get logout => 'assets/icons/logout.svg';

  /// File path: assets/icons/map.svg
  String get map => 'assets/icons/map.svg';

  /// File path: assets/icons/non_profit.svg
  String get nonProfit => 'assets/icons/non_profit.svg';

  /// File path: assets/icons/paper.svg
  String get paper => 'assets/icons/paper.svg';

  /// File path: assets/icons/party.svg
  String get party => 'assets/icons/party.svg';

  /// File path: assets/icons/qr_code.svg
  String get qrCode => 'assets/icons/qr_code.svg';

  /// File path: assets/icons/qrown.svg
  String get qrown => 'assets/icons/qrown.svg';

  /// File path: assets/icons/rafel.svg
  String get rafel => 'assets/icons/rafel.svg';

  /// File path: assets/icons/repair.svg
  String get repair => 'assets/icons/repair.svg';

  /// File path: assets/icons/send.svg
  String get send => 'assets/icons/send.svg';

  /// File path: assets/icons/setting.svg
  String get setting => 'assets/icons/setting.svg';

  /// File path: assets/icons/ticket.svg
  String get ticket => 'assets/icons/ticket.svg';

  /// List of all assets
  List<String> get values => [
    about,
    advanture,
    building,
    calander,
    care,
    comunity,
    event1,
    foodie,
    helth,
    local,
    logout,
    map,
    nonProfit,
    paper,
    party,
    qrCode,
    qrown,
    rafel,
    repair,
    send,
    setting,
    ticket,
  ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/company_logo.png
  AssetGenImage get companyLogo =>
      const AssetGenImage('assets/images/company_logo.png');

  /// File path: assets/images/finedine.png
  AssetGenImage get finedine =>
      const AssetGenImage('assets/images/finedine.png');

  /// File path: assets/images/location.png
  AssetGenImage get location =>
      const AssetGenImage('assets/images/location.png');

  /// File path: assets/images/logo.png
  AssetGenImage get logoPng => const AssetGenImage('assets/images/logo.png');

  /// File path: assets/images/logo.svg
  String get logoSvg => 'assets/images/logo.svg';

  /// File path: assets/images/machine.png
  AssetGenImage get machine => const AssetGenImage('assets/images/machine.png');

  /// File path: assets/images/onback.svg
  String get onback => 'assets/images/onback.svg';

  /// File path: assets/images/onimg1.png
  AssetGenImage get onimg1 => const AssetGenImage('assets/images/onimg1.png');

  /// File path: assets/images/onimg2.png
  AssetGenImage get onimg2 => const AssetGenImage('assets/images/onimg2.png');

  /// File path: assets/images/onimg3.png
  AssetGenImage get onimg3 => const AssetGenImage('assets/images/onimg3.png');

  /// File path: assets/images/onimg4.png
  AssetGenImage get onimg4 => const AssetGenImage('assets/images/onimg4.png');

  /// File path: assets/images/onimg5.png
  AssetGenImage get onimg5 => const AssetGenImage('assets/images/onimg5.png');

  /// File path: assets/images/onimg6.png
  AssetGenImage get onimg6 => const AssetGenImage('assets/images/onimg6.png');

  /// File path: assets/images/restu.png
  AssetGenImage get restu => const AssetGenImage('assets/images/restu.png');

  /// File path: assets/images/user1.png
  AssetGenImage get user1 => const AssetGenImage('assets/images/user1.png');

  /// File path: assets/images/user2.png
  AssetGenImage get user2 => const AssetGenImage('assets/images/user2.png');

  /// File path: assets/images/user3.jpg
  AssetGenImage get user3 => const AssetGenImage('assets/images/user3.jpg');

  /// File path: assets/images/user4.jpg
  AssetGenImage get user4 => const AssetGenImage('assets/images/user4.jpg');

  /// List of all assets
  List<dynamic> get values => [
    companyLogo,
    finedine,
    location,
    logoPng,
    logoSvg,
    machine,
    onback,
    onimg1,
    onimg2,
    onimg3,
    onimg4,
    onimg5,
    onimg6,
    restu,
    user1,
    user2,
    user3,
    user4,
  ];
}

class Assets {
  const Assets._();

  static const $AssetsFontsGen fonts = $AssetsFontsGen();
  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
