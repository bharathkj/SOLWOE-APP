class Slot {
  final String time;
  bool isLunch;
  bool isAvailable;
  bool isBooked;
  bool selected;

  Slot({required this.time, this.isLunch = false, this.isAvailable = true,this.isBooked = false, this.selected = false});
}