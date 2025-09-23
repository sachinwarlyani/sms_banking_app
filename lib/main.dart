// This is a complete, self-contained Flutter application.
// To run this app, you need to add the following dependencies to your pubspec.yaml file:
// dependencies:
//   flutter:
//     sdk: flutter
//   url_launcher: ^6.1.10
//   flutter_secure_storage: ^9.0.0

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

// A data model class to hold beneficiary information.
class Beneficiary {
  final String name;
  final String accountNumber;
  final String? mobileNumber;
  final String? mmid;
  final String? ifscCode;

  Beneficiary({
    required this.name,
    required this.accountNumber,
    this.mobileNumber,
    this.mmid,
    this.ifscCode,
  });

  // Convert a Beneficiary object to a JSON map.
  Map<String, dynamic> toJson() => {
    'name': name,
    'accountNumber': accountNumber,
    'mobileNumber': mobileNumber,
    'mmid': mmid,
    'ifscCode': ifscCode,
  };

  // Create a Beneficiary object from a JSON map.
  factory Beneficiary.fromJson(Map<String, dynamic> json) {
    return Beneficiary(
      name: json['name'] as String,
      accountNumber: json['accountNumber'] as String,
      mobileNumber: json['mobileNumber'] as String?,
      mmid: json['mmid'] as String?,
      ifscCode: json['ifscCode'] as String?,
    );
  }
}

void main() {
  runApp(const SmsBankingApp());
}

class SmsBankingApp extends StatelessWidget {
  const SmsBankingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SMS Banking',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
      ),
      home: const SmsBankingScreen(),
    );
  }
}

class SmsBankingScreen extends StatefulWidget {
  const SmsBankingScreen({super.key});

  @override
  State<SmsBankingScreen> createState() => _SmsBankingScreenState();
}

class _SmsBankingScreenState extends State<SmsBankingScreen> {
  // Controllers for text fields.
  final TextEditingController _beneficiaryNameController = TextEditingController();
  final TextEditingController _beneficiaryIdController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _beneficiaryMobileNoController = TextEditingController();
  final TextEditingController _mpinController = TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();

  // Storage for sensitive data.
  final _storage = const FlutterSecureStorage();

  // List of saved beneficiaries and bank details.
  List<Beneficiary> _savedBeneficiaries = [];
  Beneficiary? _selectedBeneficiary;
  String? _selectedBank;
  final List<Map<String, String>> _banks = [
    {'name': 'Axis', 'number': '56161600'},
    {'name': 'SBI', 'number': '9223440000'},
    {'name': 'HDFC', 'number': '5676712'},
    {'name': 'ICICI', 'number': '5676766'},
    {'name': 'Kotak Mahindra', 'number': '9971056767'},
    {'name': 'PNB', 'number': '9264092640'},
    {'name': 'Bank of Baroda', 'number': '9223172101'},
    {'name': 'Canara Bank', 'number': '8585860015'},
    {'name': 'Union Bank of India', 'number': '9223008486'},
    {'name': 'Bank of India', 'number': '9211055555'},
    {'name': 'Indian Bank', 'number': '9444392444'},
    {'name': 'Central Bank of India', 'number': '9222250000'},
    {'name': 'Indian Overseas Bank', 'number': '9444392444'},
    {'name': 'IndusInd Bank', 'number': '9212299955'},
    {'name': 'YES Bank', 'number': '9223392233'},
    {'name': 'IDFC First Bank', 'number': '575757'},
    {'name': 'Federal Bank', 'number': '9895088888'},
    {'name': 'Bandhan Bank', 'number': '9223000555'},
  ];

  @override
  void initState() {
    super.initState();
    _loadBeneficiaries();
    _selectedBank = _banks.first['name'];
  }

  @override
  void dispose() {
    _beneficiaryNameController.dispose();
    _beneficiaryIdController.dispose();
    _amountController.dispose();
    _beneficiaryMobileNoController.dispose();
    _mpinController.dispose();
    _ifscCodeController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  // Load saved beneficiaries from secure storage.
  Future<void> _loadBeneficiaries() async {
    try {
      final String? beneficiariesJson = await _storage.read(key: 'beneficiaries');
      if (beneficiariesJson != null) {
        final List<dynamic> jsonList = json.decode(beneficiariesJson);
        setState(() {
          _savedBeneficiaries = jsonList.map((e) => Beneficiary.fromJson(e)).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load beneficiaries: $e'),
        ),
      );
    }
  }

  // Save a new beneficiary to secure storage.
  Future<void> _saveBeneficiary() async {
    final newBeneficiary = Beneficiary(
      name: _beneficiaryNameController.text,
      accountNumber: _beneficiaryIdController.text,
      mobileNumber: (_selectedBank == 'SBI' || _selectedBank == 'HDFC' || _selectedBank == 'Kotak Mahindra' || _selectedBank == 'PNB' || _selectedBank == 'Bank of Baroda' || _selectedBank == 'Canara Bank' || _selectedBank == 'Union Bank of India' || _selectedBank == 'Bank of India' || _selectedBank == 'Indian Bank' || _selectedBank == 'Central Bank of India' || _selectedBank == 'Indian Overseas Bank' || _selectedBank == 'IndusInd Bank' || _selectedBank == 'YES Bank' || _selectedBank == 'IDFC First Bank' || _selectedBank == 'Federal Bank' || _selectedBank == 'Bandhan Bank') ? _beneficiaryMobileNoController.text : null,
      mmid: (_selectedBank == 'SBI' || _selectedBank == 'HDFC' || _selectedBank == 'Kotak Mahindra' || _selectedBank == 'PNB' || _selectedBank == 'Bank of Baroda' || _selectedBank == 'Canara Bank' || _selectedBank == 'Union Bank of India' || _selectedBank == 'Bank of India' || _selectedBank == 'Indian Bank' || _selectedBank == 'Central Bank of India' || _selectedBank == 'Indian Overseas Bank' || _selectedBank == 'IndusInd Bank' || _selectedBank == 'YES Bank' || _selectedBank == 'IDFC First Bank' || _selectedBank == 'Federal Bank' || _selectedBank == 'Bandhan Bank') ? _beneficiaryIdController.text : null,
      ifscCode: _selectedBank == 'ICICI' ? _ifscCodeController.text : null,
    );

    // Check if beneficiary with the same name already exists
    if (_savedBeneficiaries.any((b) => b.name == newBeneficiary.name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Beneficiary with this name already exists!'),
        ),
      );
      return;
    }

    _savedBeneficiaries.add(newBeneficiary);
    try {
      final jsonList = _savedBeneficiaries.map((b) => b.toJson()).toList();
      await _storage.write(key: 'beneficiaries', value: json.encode(jsonList));
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Beneficiary saved securely!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save beneficiary: $e'),
        ),
      );
    }
  }

  // Asynchronous function to launch the SMS application with a pre-filled message.
  void _launchSmsApp() async {
    final String? bankSmsNumber = _banks.firstWhere(
            (bank) => bank['name'] == _selectedBank,
        orElse: () => {'number': ''}
    )['number'];

    if (bankSmsNumber == null || bankSmsNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a bank.'),
        ),
      );
      return;
    }

    String message = '';
    String beneficiaryId = _beneficiaryIdController.text;
    String amount = _amountController.text;
    String beneficiaryMobileNo = _beneficiaryMobileNoController.text;
    String mpin = _mpinController.text;
    String ifscCode = _ifscCodeController.text;

    // Construct the SMS message based on the selected bank.
    if (_selectedBank == 'Axis') {
      message = 'IMPS $amount $beneficiaryId';
    } else if (_selectedBank == 'SBI') {
      String purpose = _purposeController.text;
      message = 'IMPS $beneficiaryMobileNo $beneficiaryId $amount $mpin';
      if (purpose.isNotEmpty) {
        message += ' $purpose';
      }
    } else if (_selectedBank == 'HDFC') {
      message = 'IMPS $beneficiaryMobileNo $beneficiaryId $amount $mpin';
    } else if (_selectedBank == 'ICICI') {
      message = 'IMPS $beneficiaryId $amount $ifscCode $mpin';
    } else if (_selectedBank == 'Kotak Mahindra') {
      message = 'IMPS $beneficiaryMobileNo $beneficiaryId $amount $mpin';
    } else if (_selectedBank == 'PNB') {
      message = 'IMPS $beneficiaryMobileNo $beneficiaryId $amount $mpin';
    } else if (_selectedBank == 'Bank of Baroda') {
      message = 'IMPS $beneficiaryId $beneficiaryMobileNo $amount $mpin';
    } else if (_selectedBank == 'Canara Bank') {
      message = 'IMPS $beneficiaryMobileNo $beneficiaryId $amount $mpin';
    } else if (_selectedBank == 'Union Bank of India') {
      message = 'IMPS $beneficiaryMobileNo $beneficiaryId $amount';
    } else if (_selectedBank == 'Bank of India') {
      message = 'IMPS $beneficiaryMobileNo $beneficiaryId $amount $mpin';
    } else if (_selectedBank == 'Indian Bank') {
      message = 'IMPS $beneficiaryId $beneficiaryMobileNo $amount $mpin';
    } else if (_selectedBank == 'Central Bank of India') {
      message = 'IMPS $beneficiaryId $beneficiaryMobileNo $amount $mpin';
    } else if (_selectedBank == 'Indian Overseas Bank') {
      message = 'IMPS $beneficiaryId $beneficiaryMobileNo $amount $mpin';
    } else if (_selectedBank == 'IndusInd Bank') {
      message = 'IMPS $beneficiaryId $beneficiaryMobileNo $amount $mpin';
    } else if (_selectedBank == 'YES Bank') {
      message = 'IMPS $beneficiaryMobileNo $beneficiaryId $amount $mpin';
    } else if (_selectedBank == 'IDFC First Bank') {
      message = 'IMPS $beneficiaryMobileNo $beneficiaryId $amount $mpin';
    } else if (_selectedBank == 'Federal Bank') {
      message = 'IMPS $beneficiaryMobileNo $beneficiaryId $amount $mpin';
    } else if (_selectedBank == 'Bandhan Bank') {
      message = 'IMPS $beneficiaryId $beneficiaryMobileNo $amount $mpin';
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid bank selected.'),
        ),
      );
      return;
    }

    final Uri smsUri = Uri(
      scheme: 'sms',
      path: bankSmsNumber,
      queryParameters: {'body': message},
    );

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch SMS app. Please check your device settings.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool requiresMobileNumber = ['SBI', 'HDFC', 'Kotak Mahindra', 'PNB', 'Bank of Baroda', 'Canara Bank', 'Union Bank of India', 'Bank of India', 'Indian Bank', 'Central Bank of India', 'Indian Overseas Bank', 'IndusInd Bank', 'YES Bank', 'IDFC First Bank', 'Federal Bank', 'Bandhan Bank'].contains(_selectedBank);
    bool requiresMpin = ['SBI', 'HDFC', 'ICICI', 'Kotak Mahindra', 'PNB', 'Bank of Baroda', 'Canara Bank', 'Bank of India', 'Indian Bank', 'Central Bank of India', 'Indian Overseas Bank', 'IndusInd Bank', 'YES Bank', 'IDFC First Bank', 'Federal Bank', 'Bandhan Bank'].contains(_selectedBank);
    bool requiresIfsc = ['ICICI'].contains(_selectedBank);
    bool requiresPurpose = ['SBI'].contains(_selectedBank);
    bool requiresMMID = ['SBI', 'HDFC', 'Kotak Mahindra', 'PNB', 'Bank of Baroda', 'Canara Bank', 'Union Bank of India', 'Bank of India', 'Indian Bank', 'Central Bank of India', 'Indian Overseas Bank', 'IndusInd Bank', 'YES Bank', 'IDFC First Bank', 'Federal Bank', 'Bandhan Bank'].contains(_selectedBank);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Banking Initiator'),
        backgroundColor: Colors.blue.shade600,
        centerTitle: true,
        elevation: 4,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Initiate a Bank Transfer',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'This app will prepare an SMS for you to send to your bank. The SMS is not sent automatically.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Bank',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.account_balance_outlined),
                    ),
                    value: _selectedBank,
                    items: _banks.map((bank) {
                      return DropdownMenuItem<String>(
                        value: bank['name'],
                        child: Text(bank['name']!),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedBank = newValue;
                        _selectedBeneficiary = null;
                        _beneficiaryNameController.clear();
                        _beneficiaryIdController.clear();
                        _beneficiaryMobileNoController.clear();
                        _mpinController.clear();
                        _ifscCodeController.clear();
                        _purposeController.clear();
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<Beneficiary>(
                    decoration: InputDecoration(
                      labelText: 'Select Beneficiary',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    value: _selectedBeneficiary,
                    items: _savedBeneficiaries.map((beneficiary) {
                      return DropdownMenuItem<Beneficiary>(
                        value: beneficiary,
                        child: Text(beneficiary.name),
                      );
                    }).toList(),
                    onChanged: (Beneficiary? newBeneficiary) {
                      setState(() {
                        _selectedBeneficiary = newBeneficiary;
                        if (newBeneficiary != null) {
                          _beneficiaryNameController.text = newBeneficiary.name;
                          _beneficiaryIdController.text = newBeneficiary.accountNumber;
                          if (newBeneficiary.mobileNumber != null) {
                            _beneficiaryMobileNoController.text = newBeneficiary.mobileNumber!;
                          } else {
                            _beneficiaryMobileNoController.clear();
                          }
                          if (newBeneficiary.ifscCode != null) {
                            _ifscCodeController.text = newBeneficiary.ifscCode!;
                          } else {
                            _ifscCodeController.clear();
                          }
                          _selectedBank = _banks.firstWhere((b) =>
                          (b['name'] == 'ICICI' && newBeneficiary.ifscCode != null) ||
                              ((b['name'] == 'SBI' || b['name'] == 'HDFC' || b['name'] == 'Kotak Mahindra' || b['name'] == 'PNB' || b['name'] == 'Bank of Baroda' || b['name'] == 'Canara Bank' || b['name'] == 'Union Bank of India' || b['name'] == 'Bank of India' || b['name'] == 'Indian Bank' || b['name'] == 'Central Bank of India' || b['name'] == 'Indian Overseas Bank' || b['name'] == 'IndusInd Bank' || b['name'] == 'YES Bank' || b['name'] == 'IDFC First Bank' || b['name'] == 'Federal Bank' || b['name'] == 'Bandhan Bank') && newBeneficiary.mmid != null) ||
                              (b['name'] == 'Axis' && newBeneficiary.mmid == null && newBeneficiary.ifscCode == null)
                          )['name'];
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _beneficiaryNameController,
                    decoration: InputDecoration(
                      labelText: 'Beneficiary Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _beneficiaryIdController,
                    decoration: InputDecoration(
                      labelText: requiresMMID ? 'Beneficiary MMID' : 'Beneficiary Account No.',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.account_balance),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  if (requiresMobileNumber) ...[
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _beneficiaryMobileNoController,
                      decoration: InputDecoration(
                        labelText: 'Beneficiary Mobile No.',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                  if (requiresIfsc) ...[
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _ifscCodeController,
                      decoration: InputDecoration(
                        labelText: 'IFSC Code',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                    ),
                  ],
                  if (requiresMpin) ...[
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _mpinController,
                      decoration: InputDecoration(
                        labelText: 'MPIN',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (requiresPurpose) ...[
                    TextFormField(
                      controller: _purposeController,
                      decoration: InputDecoration(
                        labelText: 'Purpose (Optional)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.text_fields),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount (e.g., 500.00)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.currency_rupee),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _saveBeneficiary,
                        icon: const Icon(Icons.save, size: 18),
                        label: const Text('Save'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const BeneficiaryManagementPage()),
                          ).then((value) => _loadBeneficiaries());
                        },
                        icon: const Icon(Icons.list, size: 18),
                        label: const Text('Manage Beneficiaries'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _launchSmsApp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Prepare SMS to Send',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// New page for managing beneficiaries.
class BeneficiaryManagementPage extends StatefulWidget {
  const BeneficiaryManagementPage({super.key});

  @override
  State<BeneficiaryManagementPage> createState() => _BeneficiaryManagementPageState();
}

class _BeneficiaryManagementPageState extends State<BeneficiaryManagementPage> {
  final _storage = const FlutterSecureStorage();
  List<Beneficiary> _beneficiaries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBeneficiaries();
  }

  Future<void> _loadBeneficiaries() async {
    try {
      final String? beneficiariesJson = await _storage.read(key: 'beneficiaries');
      if (beneficiariesJson != null) {
        final List<dynamic> jsonList = json.decode(beneficiariesJson);
        setState(() {
          _beneficiaries = jsonList.map((e) => Beneficiary.fromJson(e)).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load beneficiaries: $e'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteBeneficiary(Beneficiary beneficiary) async {
    setState(() {
      _beneficiaries.removeWhere((b) => b.name == beneficiary.name);
    });
    try {
      final jsonList = _beneficiaries.map((b) => b.toJson()).toList();
      await _storage.write(key: 'beneficiaries', value: json.encode(jsonList));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${beneficiary.name} deleted successfully.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete beneficiary: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Beneficiaries'),
        backgroundColor: Colors.red.shade600,
        centerTitle: true,
        elevation: 4,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _beneficiaries.isEmpty
          ? const Center(
        child: Text(
          'No beneficiaries saved.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: _beneficiaries.length,
        itemBuilder: (context, index) {
          final beneficiary = _beneficiaries[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: Text(beneficiary.name),
              subtitle: Text(beneficiary.accountNumber),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteBeneficiary(beneficiary),
              ),
            ),
          );
        },
      ),
    );
  }
}
