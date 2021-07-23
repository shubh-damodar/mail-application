import 'dart:async';

class Place {
  String city, state, district, country, type, id;
  Place({this.city, this.state, this.district, this.country, this.type, this.id});

  Place.fromJSONCity(Map<String, dynamic> map)  {
    city=map['city'];
    state=map['state'];
    district=map['district'];
    country=map['country'];
    type=map['type'];
    id=map['id'];
  }
  Place.fromJSONCountry(Map<String, dynamic> map)  {
    country=map['country'];
    type=map['type'];
    id=map['id'];
  }
  Map<String, String> toJSON() {
    return {
      "city": this.city,
      "state": this.state,
      "district": this.district,
      "country": this.country,
      "type": this.type,
      "id": this.id,
    };
  }
}