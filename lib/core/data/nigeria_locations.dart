/// Nigerian Geographical Data for NORI Health & Nutrition Platform.
/// Covers all 36 States and the Federal Capital Territory (FCT),
/// mapped deterministically to the 6 Geopolitical Zones of Nigeria.
class NigeriaLocations {
  /// 6 Geopolitical Zones
  static const List<String> regions = [
    'North Central',
    'North East',
    'North West',
    'South East',
    'South South',
    'South West',
  ];

  /// All 36 States + FCT mapped to their Geopolitical Region
  static const Map<String, String> stateToRegion = {
    // North Central
    'Benue': 'North Central',
    'FCT (Abuja)': 'North Central',
    'Kogi': 'North Central',
    'Kwara': 'North Central',
    'Nasarawa': 'North Central',
    'Niger': 'North Central',
    'Plateau': 'North Central',

    // North East
    'Adamawa': 'North East',
    'Bauchi': 'North East',
    'Borno': 'North East',
    'Gombe': 'North East',
    'Taraba': 'North East',
    'Yobe': 'North East',

    // North West
    'Jigawa': 'North West',
    'Kaduna': 'North West',
    'Kano': 'North West',
    'Katsina': 'North West',
    'Kebbi': 'North West',
    'Sokoto': 'North West',
    'Zamfara': 'North West',

    // South East
    'Abia': 'South East',
    'Anambra': 'South East',
    'Ebonyi': 'South East',
    'Enugu': 'South East',
    'Imo': 'South East',

    // South South
    'Akwa Ibom': 'South South',
    'Bayelsa': 'South South',
    'Cross River': 'South South',
    'Delta': 'South South',
    'Edo': 'South South',
    'Rivers': 'South South',

    // South West
    'Ekiti': 'South West',
    'Lagos': 'South West',
    'Ogun': 'South West',
    'Ondo': 'South West',
    'Osun': 'South West',
    'Oyo': 'South West',
  };

  /// Sorted list of all Nigerian States + FCT
  static List<String> get states => stateToRegion.keys.toList()..sort();

  /// Prominent LGAs per state (used for dependent suggestion/filtering)
  static const Map<String, List<String>> stateToSampleLgas = {
    'Abia': ['Aba North', 'Aba South', 'Umuahia North', 'Umuahia South', 'Osisioma', 'Ohafia'],
    'Adamawa': ['Yola North', 'Yola South', 'Mubi North', 'Mubi South', 'Numan', 'Girei'],
    'Akwa Ibom': ['Uyo', 'Ikot Ekpene', 'Eket', 'Oron', 'Abak', 'Ibeno'],
    'Anambra': ['Awka North', 'Awka South', 'Onitsha North', 'Onitsha South', 'Nnewi North', 'Nnewi South', 'Idemili North'],
    'Bauchi': ['Bauchi', 'Katagum', 'Misau', 'Jama\'are', 'Tafawa Balewa', 'Dass'],
    'Bayelsa': ['Yenagoa', 'Brass', 'Ogbia', 'Sagbama', 'Southern Ijaw', 'Nembe'],
    'Benue': ['Makurdi', 'Gboko', 'Otukpo', 'Katsina-Ala', 'Gwer East', 'Vandeikya'],
    'Borno': ['Maiduguri', 'Jere', 'Biu', 'Bama', 'Gwoza', 'Monguno'],
    'Cross River': ['Calabar Municipal', 'Calabar South', 'Akamkpa', 'Ikom', 'Ogoja', 'Obudu'],
    'Delta': ['Warri South', 'Warri North', 'Oshimili South (Asaba)', 'Ughelli North', 'Sapele', 'Uvwie'],
    'Ebonyi': ['Abakaliki', 'Afikpo North', 'Afikpo South', 'Ebonyi', 'Ezza North', 'Ohaozara'],
    'Edo': ['Oredo (Benin City)', 'Ikpoba Okha', 'Egor', 'Esan West (Ekpoma)', 'Etsako West (Auchi)', 'Ovia North-East'],
    'Ekiti': ['Ado Ekiti', 'Ikere', 'Ijero', 'Oye', 'Gbonyin', 'Ekiti South-West'],
    'Enugu': ['Enugu North', 'Enugu South', 'Enugu East', 'Nsukka', 'Udi', 'Nkanu West'],
    'FCT (Abuja)': ['Abuja Municipal (AMAC)', 'Bwari', 'Gwagwalada', 'Kuje', 'Kwali', 'Abaji'],
    'Gombe': ['Gombe', 'Akko', 'Yamaltu/Deba', 'Kaltungo', 'Billiri', 'Dukku'],
    'Imo': ['Owerri Municipal', 'Owerri North', 'Owerri West', 'Orlu', 'Okigwe', 'Mbaitoli'],
    'Jigawa': ['Dutse', 'Hadejia', 'Kazaure', 'Gumel', 'Ringim', 'Birnin Kudu'],
    'Kaduna': ['Kaduna North', 'Kaduna South', 'Chikun', 'Zaria', 'Sabon Gari', 'Jema\'a (Kafanchan)'],
    'Kano': ['Kano Municipal', 'Fagge', 'Dala', 'Nassarawa', 'Tarauni', 'Gwale', 'Kumbotso', 'Ungogo'],
    'Katsina': ['Katsina', 'Daura', 'Funtua', 'Malumfashi', 'Kankia', 'Mani'],
    'Kebbi': ['Birnin Kebbi', 'Argungu', 'Yauri', 'Zuru', 'Jega', 'Bunza'],
    'Kogi': ['Lokoja', 'Okene', 'Idah', 'Kabba/Bunu', 'Ankpa', 'Ajaokuta'],
    'Kwara': ['Ilorin West', 'Ilorin East', 'Ilorin South', 'Offa', 'Edu', 'Kaiama'],
    'Lagos': ['Ikeja', 'Lagos Island', 'Lagos Mainland', 'Surulere', 'Eti-Osa', 'Alimosho', 'Oshodi-Isolo', 'Kosofe', 'Ikorodu', 'Badagry', 'Epe'],
    'Nasarawa': ['Lafia', 'Keffi', 'Akwanga', 'Karu', 'Nasarawa', 'Doma'],
    'Niger': ['Chanchaga (Minna)', 'Bida', 'Suleja', 'Kontagora', 'Mokwa', 'Bosso'],
    'Ogun': ['Abeokuta South', 'Abeokuta North', 'Ado-Odo/Ota', 'Ijebu Ode', 'Sagamu', 'Ifo', 'Obafemi Owode'],
    'Ondo': ['Akure South', 'Akure North', 'Ondo West', 'Owo', 'Ikare Akoko', 'Okitipupa'],
    'Osun': ['Osogbo', 'Ilesa East', 'Ife Central', 'Ede North', 'Ila Orangun', 'Iwo'],
    'Oyo': ['Ibadan North', 'Ibadan South-West', 'Ibadan North-West', 'Ibarapa Central', 'Ogbomosho North', 'Oyo East', 'Saki West'],
    'Plateau': ['Jos North', 'Jos South', 'Jos East', 'Barkin Ladi', 'Mangu', 'Pankshin', 'Shendam'],
    'Rivers': ['Port Harcourt', 'Obio/Akpor', 'Eleme', 'Ikwerre', 'Bonny', 'Oyigbo'],
    'Sokoto': ['Sokoto North', 'Sokoto South', 'Wamako', 'Bodinga', 'Gwadabawa', 'Goronyo'],
    'Taraba': ['Jalingo', 'Wukari', 'Bali', 'Takum', 'Sardauna (Mambilla)', 'Gashaka'],
    'Yobe': ['Damaturu', 'Potiskum', 'Gashua (Bade)', 'Nguru', 'Geidam', 'Fika'],
    'Zamfara': ['Gusau', 'Kaura Namoda', 'Talata Mafara', 'Anka', 'Maru', 'Tsafe'],
  };

  /// Returns suggested LGAs for a selected state
  static List<String> getSampleLgasForState(String state) {
    return stateToSampleLgas[state] ?? [];
  }

  /// Returns geopolitical region for a selected state
  static String? getRegionForState(String state) {
    return stateToRegion[state];
  }
}
