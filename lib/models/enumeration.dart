part of '../flutter_scandit.dart';


enum Anchor{
  TOP_LEFT,
  TOP_CENTER,
  TOP_RIGHT,
  CENTER_LEFT,
  CENTER,
  CENTER_RIGHT,
  BOTTOM_LEFT,
  BOTTOM_CENTER,
  BOTTOM_RIGHT
}

enum VideoResolution{
  HD,
  FULL_HD,
  UHD4K,
  AUTO
}

enum CameraPosition{
  WORLD_FACING,
  USER_FACING,
  UNSPECIFIED
}

enum Direction{
  LEFT_TO_RIGHT,
  RIGHT_TO_LEFT,
  HORIZONTAL,
  TOP_TO_BOTTOM,
  BOTTOM_TO_TOP,
  VERTICAL,
  NONE
}

enum FrameSourceState{
  ON,
  OFF,
  STARTING,
  STOPPING
}

enum Checksum{
  MOD10,
  MOD11,
  MOD16,
  MOD43,
  MOD47,
  MOD103,
  MOD10_AND_MOD11,
  MOD10_AND_MOD10
}

enum CompositeFlag{
  NONE,
  UNKNOWN,
  LINKED,
  GS1_TYPE_A,
  GS1_TYPE_B,
  GS1_TYPE_C
}
