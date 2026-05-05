import 'package:latlong2/latlong.dart';

class PakistanProvince {
  final String name;
  final String code;
  final LatLng defaultLocation;
  final List<String> cities;

  const PakistanProvince({
    required this.name,
    required this.code,
    required this.defaultLocation,
    required this.cities,
  });
}

class PakistanLocationConfig {
  static const String defaultCurrency = 'PKR';
  static const String defaultCurrencySymbol = 'Rs.';
  
  static const List<PakistanProvince> provinces = [
    // Punjab - Most populated province
    PakistanProvince(
      name: 'Punjab',
      code: 'PB',
      defaultLocation: LatLng(31.5204, 74.3587), // Lahore
      cities: [
        // Major Cities
        'Lahore', 'Faisalabad', 'Rawalpindi', 'Multan', 'Gujranwala',
        'Sialkot', 'Bahawalpur', 'Sargodha', 'Sheikhupura', 'Jhang',
        
        // District Headquarters & Major Towns
        'Sahiwal', 'Kasur', 'Okara', 'Gujrat', 'Rahim Yar Khan',
        'Chiniot', 'Kamoke', 'Sadiqabad', 'Burewala', 'Jaranwala',
        'Khanewal', 'Hafizabad', 'Mandi Bahauddin', 'Ahmadpur East',
        'Kamalia', 'Muridke', 'Jhelum', 'Khanpur', 'Gojra', 'Mian Channu',
        'Bahawalnagar', 'Samundri', 'Khushab', 'Muzaffargarh', 'Wazirabad',
        'Mianwali', 'Attock', 'Vehari', 'Chakwal', 'Daska', 'Kharian',
        'Kot Addu', 'Dera Ghazi Khan', 'Pakpattan', 'Tando Adam',
        'Chishtian', 'Hasilpur', 'Layyah', 'Bhakkar', 'Rajanpur',
        'Lodhran', 'Mailsi', 'Kabirwala', 'Chunian', 'Nankana Sahib',
        'Pattoki', 'Renala Khurd', 'Shakargarh', 'Narowal', 'Zafarwal',
        'Pasrur', 'Sambrial', 'Dullewala', 'Pindi Bhattian', 'Murree',
        'Gujar Khan', 'Talagang', 'Taxila', 'Wah Cantt', 'Hassan Abdal',
        'Kotli Loharan', 'Phalia', 'Malakwal', 'Mamoori', 'Pind Dadan Khan',
        'Dina', 'Sohawa', 'Pindi Gheb', 'Kallar Syedan', 'Choa Saidan Shah',
        'Fateh Jang', 'Hazro', 'Kamra', 'Havelian', 'Khoi Ratta',
        'Jahanian', 'Jatoi', 'Abdul Hakim', 'Alipur', 'Chak Jhumra',
        'Feroza', 'Kamoke', 'Tandlianwala', 'Dunyapur', 'Fort Abbas',
        'Haroonabad', 'Liaquatpur', 'Minchinabad', 'Yazman', 'Ahmedpur Sial',
        'Jalalpur Pirwala', 'Shorkot', 'Jauharabad', 'Phool Nagar',
        'Ferozewala', 'Shahdara', 'Raiwind', 'Manga Mandi', 'Depalpur',
        'Arifwala', 'Chichawatni', 'Harunabad', 'Khurrianwala',
      ],
    ),
    
    // Sindh - Second most populated
    PakistanProvince(
      name: 'Sindh',
      code: 'SD',
      defaultLocation: LatLng(24.8607, 67.0011), // Karachi
      cities: [
        // Major Cities
        'Karachi', 'Hyderabad', 'Sukkur', 'Larkana', 'Nawabshah',
        'Mirpur Khas', 'Jacobabad', 'Shikarpur', 'Khairpur', 'Dadu',
        
        // District Headquarters & Major Towns
        'Thatta', 'Badin', 'Tando Allahyar', 'Matiari', 'Tando Muhammad Khan',
        'Sanghar', 'Umerkot', 'Tharparkar', 'Mithi', 'Jamshoro',
        'Shahdadkot', 'Kashmore', 'Ghotki', 'Daharki', 'New Saeedabad',
        'Qambar', 'Kandhkot', 'Ratodero', 'Naushahro Feroze', 'Moro',
        'Sakrand', 'Shahdadpur', 'Hala', 'Sehwan', 'Mehar',
        'Johi', 'Kotri', 'Tando Adam', 'Bulri', 'Kunri',
        'Samaro', 'Digri', 'Kot Ghulam Muhammad', 'Hussain Bux Marri',
        'Sinjhoro', 'Hala', 'Matli', 'Saeedabad', 'Naukot',
        'Keti Bandar', 'Gharo', 'Shah Bandar', 'Sita Road', 'Mirwah',
        'Talhar', 'Chamber', 'Gambat', 'Mehrabpur', 'Garhi Khairo',
        'Dokri', 'Kandiaro', 'Khairpur Nathan Shah', 'Setharja',
        'Pir Jo Goth', 'Khadro', 'Khanot', 'Rohri', 'Pano Aqil',
        'Darya Khan Marri', 'Ubauro', 'Khanpur Mahar', 'Ranipur',
        'Sobhodero', 'Naudero', 'Warah', 'Garhi Yasin', 'Thul',
        'Kambar', 'Qubo Saeed Khan', 'Mirpur Mathelo', 'Sadiqabad',
        'Naushahro Feroze', 'Bhiria', 'Padidan', 'Tando Jam',
        'Jhol', 'Bhan Saeedabad', 'Kadhan', 'Kunri', 'Jhudo',
      ],
    ),
    
    // Khyber Pakhtunkhwa
    PakistanProvince(
      name: 'Khyber Pakhtunkhwa',
      code: 'KP',
      defaultLocation: LatLng(34.0151, 71.5249), // Peshawar
      cities: [
        // Major Cities
        'Peshawar', 'Mardan', 'Mingora', 'Kohat', 'Abbottabad',
        'Mansehra', 'Dera Ismail Khan', 'Swabi', 'Bannu', 'Charsadda',
        
        // District Headquarters & Major Towns
        'Nowshera', 'Haripur', 'Karak', 'Hangu', 'Lakki Marwat',
        'Tank', 'Parachinar', 'Chitral', 'Dir', 'Timergara',
        'Batkhela', 'Alpurai', 'Daggar', 'Saidu Sharif', 'Shangla',
        'Khwazakhela', 'Bahrain', 'Kalam', 'Madyan', 'Bisham',
        'Balakot', 'Oghi', 'Shinkiari', 'Baffa', 'Battagram',
        'Havelian', 'Ghazi', 'Topi', 'Pabbi', 'Akora Khattak',
        'Jehangira', 'Risalpur', 'Sardaryab', 'Shabqadar', 'Tangi',
        'Utmanzai', 'Rustam', 'Takht Bhai', 'Shergarh', 'Katlang',
        'Dargai', 'Malakand', 'Chakdara', 'Thana', 'Thal',
        'Darra Adam Khel', 'Lachi', 'Banda Daud Shah', 'Kulachi',
        'Paharpur', 'Domel', 'Serai Naurang', 'Tall', 'Sadda',
        'Landikotal', 'Jamrud', 'Bara', 'Landi Kotal', 'Ali Masjid',
        'Drosh', 'Booni', 'Mastuj', 'Garam Chashma', 'Ayun',
        'Bumburat', 'Kalash', 'Upper Dir', 'Lower Dir', 'Munda',
        'Khall', 'Tormang', 'Darora', 'Alizai', 'Adezai',
        'Utman Khel', 'Matani', 'Badaber', 'Hayatabad', 'Bara Banda',
      ],
    ),
    
    // Balochistan - Largest by area
    PakistanProvince(
      name: 'Balochistan',
      code: 'BA',
      defaultLocation: LatLng(30.1798, 66.9750), // Quetta
      cities: [
        // Major Cities
        'Quetta', 'Gwadar', 'Turbat', 'Khuzdar', 'Chaman',
        'Hub', 'Zhob', 'Sibi', 'Loralai', 'Dera Murad Jamali',
        
        // District Headquarters & Major Towns
        'Pishin', 'Qila Saifullah', 'Qila Abdullah', 'Mastung', 'Kalat',
        'Kharan', 'Awaran', 'Lasbela', 'Uthal', 'Bela',
        'Ormara', 'Pasni', 'Jiwani', 'Panjgur', 'Nushki',
        'Dalbandin', 'Taftan', 'Chagai', 'Washuk', 'Kharan',
        'Dera Bugti', 'Sui', 'Kohlu', 'Barkhan', 'Musakhel',
        'Ziarat', 'Harnai', 'Duki', 'Mach', 'Sanjawi',
        'Qalat', 'Mangochar', 'Surab', 'Wadh', 'Zehri',
        'Jhal Magsi', 'Gandawa', 'Nasirabad', 'Jaffarabad', 'Usta Muhammad',
        'Kachhi', 'Bolan', 'Lehri', 'Dhadar', 'Bhag',
        'Bakhtiarabad', 'Mach', 'Khost', 'Khanozai', 'Muslim Bagh',
        'Bostan', 'Gulistan', 'Kuchlak', 'Saranan', 'Chamaman',
        'Akhtarabad', 'Khojak', 'Shelabagh', 'Kan Mehtarzai', 'Ziarat',
        'Mekhtar', 'Anambar', 'Girdi Jungle', 'Mango Pir', 'Sonmiani',
        'Winder', 'Gadani', 'Gaddani Beach', 'Kund Malir', 'Hingol',
        'Jewani', 'Mand', 'Buleda', 'Dasht', 'Zamuran',
      ],
    ),
    
    // Islamabad Capital Territory
    PakistanProvince(
      name: 'Islamabad Capital Territory',
      code: 'IS',
      defaultLocation: LatLng(33.6844, 73.0479), // Islamabad
      cities: [
        'Islamabad',
        'Rawat',
        'Sihala',
        'Tarlai',
        'Bhara Kahu',
        'Bani Gala',
        'Saidpur',
        'Nurpur Shahan',
        'Malpur',
        'Lohi Bher',
        'Kirpa',
        'Shahpur',
        'Tarnol',
        'Pind Begwal',
        'Humak',
        'Chak Shahzad',
        'Bani Gala',
        'Golra Sharif',
        'Sohan',
        'Rawal Town',
      ],
    ),
    
    // Azad Jammu & Kashmir
    PakistanProvince(
      name: 'Azad Jammu & Kashmir',
      code: 'AK',
      defaultLocation: LatLng(33.9259, 73.7240), // Muzaffarabad
      cities: [
        // Major Cities and Districts
        'Muzaffarabad', 'Mirpur', 'Bhimber', 'Kotli', 'Rawalakot',
        'Bagh', 'Neelum', 'Jhelum Valley', 'Hattian Bala', 'Haveli',
        
        // Major Towns
        'Dadyal', 'Barnala', 'Chaksawari', 'Islamgarh', 'Pallandri',
        'Hajira', 'Abbaspur', 'Forward Kahuta', 'Sudhanoti', 'Athmuqam',
        'Sharda', 'Kel', 'Taobat', 'Chikar', 'Sehnsa',
        'Chakswari', 'Samahni', 'Mangla', 'New Mirpur City', 'Dadyal',
        'Khuiratta', 'Fatehpur Thakiala', 'Nakyal', 'Charhoi',
        'Jandrot', 'Thorar', 'Holar', 'Rawalakot', 'Hajeera',
        'Pallandri', 'Tatta Pani', 'Goi', 'Nomanpura', 'Chella Bandi',
        'Kharick', 'Leepa', 'Chinari', 'Tattapani', 'Kundal Shahi',
        'Dhirkot', 'Ramkot', 'Chikar', 'Seher Mandi', 'Arja',
      ],
    ),
    
    // Gilgit-Baltistan
    PakistanProvince(
      name: 'Gilgit-Baltistan',
      code: 'GB',
      defaultLocation: LatLng(35.9208, 74.3082), // Gilgit
      cities: [
        // Major Cities and Districts
        'Gilgit', 'Skardu', 'Hunza', 'Nagar', 'Ghizer',
        'Diamer', 'Astore', 'Ghanche', 'Shigar', 'Kharmang',
        
        // Major Towns and Valleys
        'Karimabad', 'Aliabad', 'Gulmit', 'Passu', 'Gojal',
        'Khunjerab', 'Nilt', 'Murtazabad', 'Chalt', 'Nomal',
        'Danyor', 'Jutial', 'Naltar', 'Bagrot', 'Haramosh',
        'Shimshal', 'Gupis', 'Yasin', 'Ishkoman', 'Puniyal',
        'Phander', 'Singal', 'Chilas', 'Darel', 'Tangir',
        'Babusar', 'Astor Valley', 'Rama', 'Minimarg', 'Rattu',
        'Godai', 'Doyan', 'Bunji', 'Eidgah', 'Daghoni',
        'Khaplu', 'Keris', 'Hushe', 'Mashabrum', 'Saling',
        'Shigar Fort', 'Skardu Fort', 'Sadpara', 'Satpara',
        'Deosai', 'Machulo', 'Kachura', 'Kharmang Valley',
        'Tolti', 'Parkuta', 'Thak', 'Sermik', 'Kondus',
        'Saltoro', 'Turtuk', 'Thang', 'Haldi', 'Mehdiabad',
      ],
    ),
  ];

  // Helper methods
  static PakistanProvince? getProvinceByCode(String code) {
    try {
      return provinces.firstWhere((p) => p.code == code);
    } catch (e) {
      return null;
    }
  }

  static List<String> getCitiesByProvinceCode(String provinceCode) {
    final province = getProvinceByCode(provinceCode);
    return province?.cities ?? [];
  }

  static String formatCurrency(double amount) {
    return '$defaultCurrencySymbol ${amount.toStringAsFixed(0)}';
  }
}
