class Membership {
  String? membershipId;
  String? membershipName;
  String? membershipDescription;
  String? membershipPrice;
// name, picture, description, quantity, price, etc
  Membership(
      {this.membershipId,
      this.membershipName,
      this.membershipDescription,
      this.membershipPrice,});

  Membership.fromJson(Map<String, dynamic> json) {
    membershipId = json['membership_id'];
    membershipName = json['membership_name'];
    membershipDescription = json['membership_description'];
    membershipPrice = json['membership_price_RM'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['membership_id'] = membershipId;
    data['membership_name'] = membershipName;
    data['membership_description'] = membershipDescription;
    data['membership_price_RM'] = membershipPrice;
    return data;
  }
}