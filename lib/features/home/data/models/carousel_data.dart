class CarouselData {
  final String placeName;
  final String placeLocation;
  final String placeWeather;
  final String placeImage;
  final String placeImageUrl;
  final String linkUrl;

  CarouselData({
    required this.placeName,
    required this.placeLocation,
    required this.placeWeather,
    this.placeImage = '',
    this.placeImageUrl = '',
    this.linkUrl = '',
  });
}
