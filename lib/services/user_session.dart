class UserSession {
  // Static variables to cache user data and prevent redundant DB calls
  static String? name;
  static String? weight;
  static String? height;
  static String? dob;
  static String? condition;

  /// Returns true if the cache has data
  static bool get isDataCached => name != null;

  /// Clears the cache on logout
  static void clear() {
    name = null;
    weight = null;
    height = null;
    dob = null;
    condition = null;
  }

  /// Updates the local cache with new data
  static void update({
    String? newName,
    String? newWeight,
    String? newHeight,
    String? newDob,
    String? newCondition,
  }) {
    if (newName != null) name = newName;
    if (newWeight != null) weight = newWeight;
    if (newHeight != null) height = newHeight;
    if (newDob != null) dob = newDob;
    if (newCondition != null) condition = newCondition;
  }
}
