/// Konversi angka lantai internal (1/2/3) ke label yang ditampilkan ke user.
/// Internal 1 = Lantai Dasar, 2 = Lantai 1, 3 = Lantai 2
String floorLabelShort(int floor) {
  switch (floor) {
    case 1: return 'Dasar';
    case 2: return 'Lt. 1';
    case 3: return 'Lt. 2';
    default: return 'Lt. $floor';
  }
}

String floorLabelFull(int floor) {
  switch (floor) {
    case 1: return 'Lantai Dasar';
    case 2: return 'Lantai 1';
    case 3: return 'Lantai 2';
    default: return 'Lantai $floor';
  }
}
