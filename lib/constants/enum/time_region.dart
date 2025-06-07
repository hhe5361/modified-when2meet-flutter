enum TimeRegion{
  asiaSeoul('Asia/Seoul'),
  utc('UTC'),
  america('America/New_York'),
  europe('Europe/London');


  final String value;
  const TimeRegion(this.value);
}