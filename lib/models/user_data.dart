class UserLicenseData {
  PUC? pUC;
  InsuranceDetails? insuranceDetails;
  LicenseDetails? licenseDetails;
  String? userId;

  UserLicenseData(
      {this.pUC, this.insuranceDetails, this.licenseDetails, this.userId});

  UserLicenseData.fromJson(Map<String, dynamic> json) {
    pUC = json['PUC'] != null ? PUC.fromJson(json['PUC']) : null;
    insuranceDetails = json['insuranceDetails'] != null
        ? InsuranceDetails.fromJson(json['insuranceDetails'])
        : null;
    licenseDetails = json['licenseDetails'] != null
        ? LicenseDetails.fromJson(json['licenseDetails'])
        : null;
    userId = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (pUC != null) {
      data['PUC'] = pUC!.toJson();
    }
    if (insuranceDetails != null) {
      data['insuranceDetails'] = insuranceDetails!.toJson();
    }
    if (licenseDetails != null) {
      data['licenseDetails'] = licenseDetails!.toJson();
    }
    data['id'] = userId;
    return data;
  }
}

class PUC {
  String? certificateNumber;
  String? dateOfExpiry;
  String? dateOfIssue;

  PUC({this.certificateNumber, this.dateOfExpiry, this.dateOfIssue});

  PUC.fromJson(Map<String, dynamic> json) {
    certificateNumber = json['certificateNumber'];
    dateOfExpiry = json['dateOfExpiry'];
    dateOfIssue = json['dateOfIssue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['certificateNumber'] = certificateNumber;
    data['dateOfExpiry'] = dateOfExpiry;
    data['dateOfIssue'] = dateOfIssue;
    return data;
  }
}

class InsuranceDetails {
  String? address;
  String? dateOfExpiry;
  String? dateOfIssue;
  String? insuranceCompany;
  String? name;
  String? policyNumber;
  VehicleDetails? vehicleDetails;

  InsuranceDetails(
      {this.address,
      this.dateOfExpiry,
      this.dateOfIssue,
      this.insuranceCompany,
      this.name,
      this.policyNumber,
      this.vehicleDetails});

  InsuranceDetails.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    dateOfExpiry = json['dateOfExpiry'];
    dateOfIssue = json['dateOfIssue'];
    insuranceCompany = json['insuranceCompany'];
    name = json['name'];
    policyNumber = json['policyNumber'];
    vehicleDetails = json['vehicleDetails'] != null
        ? VehicleDetails.fromJson(json['vehicleDetails'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['address'] = address;
    data['dateOfExpiry'] = dateOfExpiry;
    data['dateOfIssue'] = dateOfIssue;
    data['insuranceCompany'] = insuranceCompany;
    data['name'] = name;
    data['policyNumber'] = policyNumber;
    if (vehicleDetails != null) {
      data['vehicleDetails'] = vehicleDetails!.toJson();
    }
    return data;
  }
}

class VehicleDetails {
  String? engineNumber;
  String? vehicleModel;
  String? vehicleName;
  String? vehicleNumber;

  VehicleDetails(
      {this.engineNumber,
      this.vehicleModel,
      this.vehicleName,
      this.vehicleNumber});

  VehicleDetails.fromJson(Map<String, dynamic> json) {
    engineNumber = json['engineNumber'];
    vehicleModel = json['vehicleModel'];
    vehicleName = json['vehicleName'];
    vehicleNumber = json['vehicleNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['engineNumber'] = engineNumber;
    data['vehicleModel'] = vehicleModel;
    data['vehicleName'] = vehicleName;
    data['vehicleNumber'] = vehicleNumber;
    return data;
  }
}

class LicenseDetails {
  String? dLNO;
  String? dOE;
  String? dOI;
  String? pIN;
  String? address;
 
  String? name;

  LicenseDetails(
      {this.dLNO,
      this.dOE,
      this.dOI,
      this.pIN,
      this.address,
      this.name});

  LicenseDetails.fromJson(Map<String, dynamic> json) {
    dLNO = json['dlNo'];
    dOE = json['doe'];
    dOI = json['doi'];
    pIN = json['pin'];
    address = json['address'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['dlNo'] = dLNO;
    data['doe'] = dOE;
    data['doi'] = dOI;
    data['pin'] = pIN;
    data['address'] = address;
    data['name'] = name;
    return data;
  }
}
