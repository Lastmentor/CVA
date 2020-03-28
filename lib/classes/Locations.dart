class Locations {
  final String id;
  final String lat;
  final String long;
  final String country;
  final int latestCases;
  final int latestDeaths;
  final int latestRecovers;
  final String province;

  const Locations(
      this.id, this.lat, this.long, this.country, this.latestCases, this.latestDeaths, this.latestRecovers, this.province);
}