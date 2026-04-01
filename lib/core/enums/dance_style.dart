enum DanceStyle {
  hipHop,
  house,
  vogue,
  dancehall,
  contemporary,
  breaking,
  heels,
}

extension DanceStyleX on DanceStyle {
  String get code => switch (this) {
        DanceStyle.hipHop => 'hip_hop',
        DanceStyle.house => 'house',
        DanceStyle.vogue => 'vogue',
        DanceStyle.dancehall => 'dancehall',
        DanceStyle.contemporary => 'contemporary',
        DanceStyle.breaking => 'breaking',
        DanceStyle.heels => 'heels',
      };

  String get title => switch (this) {
        DanceStyle.hipHop => 'Hip-Hop',
        DanceStyle.house => 'House',
        DanceStyle.vogue => 'Vogue',
        DanceStyle.dancehall => 'Dancehall',
        DanceStyle.contemporary => 'Contemporary',
        DanceStyle.breaking => 'Breaking',
        DanceStyle.heels => 'Heels',
      };

  static DanceStyle fromCode(String code) => switch (code) {
        'hip_hop' => DanceStyle.hipHop,
        'house' => DanceStyle.house,
        'vogue' => DanceStyle.vogue,
        'dancehall' => DanceStyle.dancehall,
        'contemporary' => DanceStyle.contemporary,
        'breaking' => DanceStyle.breaking,
        'heels' => DanceStyle.heels,
        _ => DanceStyle.hipHop,
      };
}
