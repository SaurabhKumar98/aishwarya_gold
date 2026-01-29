// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:aishwarya_gold/res/constants/app_color.dart';
// import 'package:aishwarya_gold/res/widgets/custom_button.dart';
// import 'package:aishwarya_gold/data/models/settingmodels/nominee_models.dart';
// import 'package:aishwarya_gold/view_models/nominee_provider/nominee_provider.dart';
// import 'package:aishwarya_gold/view_models/nominee_provider/nominee_details_provider.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';

// class NomineeDetailsScreen extends StatefulWidget {
//   final String userId;
  
//   const NomineeDetailsScreen({
//     super.key,
//     required this.userId,
//   });

//   @override
//   State<NomineeDetailsScreen> createState() => _NomineeDetailsScreenState();
// }

// class _NomineeDetailsScreenState extends State<NomineeDetailsScreen> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _relationController = TextEditingController();
//   final TextEditingController _dobController = TextEditingController();
//   final TextEditingController _contactController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();

//   String _selectedPlan = 'One Time';
//   DateTime? _selectedDate;
//   bool _showForm = false;

//   final _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _fetchNomineeDetails();
//     });
//   }

//   void _fetchNomineeDetails() {
//     final provider = Provider.of<NomineeDetailsProvider>(context, listen: false);
//     provider.fetchNomineeDetails(pageNumber: 1);
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _relationController.dispose();
//     _dobController.dispose();
//     _contactController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }

//   List<String> _getPlanTypeForAPI(String selectedPlan) {
//     switch (selectedPlan) {
//       case 'One Time':
//         return ['OneTimeInvestment'];
//       case 'SIP':
//         return ['SIPPlan'];
//       case 'AG Plan':
//         return ['AgPlan'];
//       default:
//         return ['OneTimeInvestment'];
//     }
//   }

//   String _formatPlanType(List<String>? planTypes) {
//     if (planTypes == null || planTypes.isEmpty) return 'N/A';
    
//     return planTypes.map((plan) {
//       switch (plan) {
//         case 'OneTimeInvestment':
//           return 'One Time';
//         case 'SIPPlan':
//           return 'SIP';
//         case 'AgPlan':
//           return 'AG Plan';
//         default:
//           return plan;
//       }
//     }).join(', ');
//   }

//   void _saveNominee() async {
//     if (_formKey.currentState!.validate()) {
//       final nomineeProvider = Provider.of<NomineeProvider>(context, listen: false);

//       final nominee = Nominee(
//         userId: widget.userId,
//         name: _nameController.text.trim(),
//         relation: _relationController.text.trim(),
//         dob: _selectedDate,
//         contactNo: _contactController.text.trim(),
//         address: _addressController.text.trim(),
//         planType: _getPlanTypeForAPI(_selectedPlan),
//       );

//       debugPrint('=== Nominee API Request ===');
//       debugPrint('Request Body: ${nomineeToJson(nominee)}');
//       debugPrint('========================\n');

//       try {
//         await nomineeProvider.createNominee(nominee);

//         debugPrint('=== Nominee API Response ===');
//         debugPrint('Response: ${nomineeProvider.response}');
//         debugPrint('===========================\n');

//         if (nomineeProvider.response != null && mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: const Text("Nominee added successfully!"),
//               backgroundColor: AppColors.coinBrown,
//               behavior: SnackBarBehavior.floating,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               margin: const EdgeInsets.all(16),
//             ),
//           );

//           // Clear form
//           _nameController.clear();
//           _relationController.clear();
//           _dobController.clear();
//           _contactController.clear();
//           _addressController.clear();
//           _selectedDate = null;
//           _selectedPlan = 'One Time';

//           setState(() {
//             _showForm = false;
//           });

//           // Refresh the list
//           _fetchNomineeDetails();
//         } else if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: const Text("Failed to save nominee details."),
//               backgroundColor: Colors.red,
//               behavior: SnackBarBehavior.floating,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               margin: const EdgeInsets.all(16),
//             ),
//           );
//         }
//       } catch (e) {
//         debugPrint('=== Nominee API Error ===');
//         debugPrint('Error: $e');
//         debugPrint('========================\n');

//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text("Error: ${e.toString()}"),
//               backgroundColor: Colors.red,
//               behavior: SnackBarBehavior.floating,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               margin: const EdgeInsets.all(16),
//             ),
//           );
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text(
//           "Nominee Details",
//           style: TextStyle(color: Colors.black),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.black),
//         actions: [
//           IconButton(
//             icon: Icon(
//               _showForm ? Icons.close : Icons.add,
//               color: AppColors.primaryGold,
//             ),
//             onPressed: () {
//               setState(() {
//                 _showForm = !_showForm;
//               });
//             },
//           ),
//         ],
//       ),
//       body: Consumer2<NomineeDetailsProvider, NomineeProvider>(
//         builder: (context, detailsProvider, nomineeProvider, child) {
//           return Stack(
//             children: [
//               RefreshIndicator(
//                 onRefresh: () async {
//                   _fetchNomineeDetails();
//                 },
//                 child: SingleChildScrollView(
//                   physics: const AlwaysScrollableScrollPhysics(),
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Add Nominee Form
//                       if (_showForm)
//                         Container(
//                           margin: const EdgeInsets.only(bottom: 20),
//                           padding: const EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: Colors.grey[50],
//                             borderRadius: BorderRadius.circular(16),
//                             border: Border.all(color: Colors.grey[300]!),
//                           ),
//                           child: Form(
//                             key: _formKey,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   "Add New Nominee",
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 15),

//                                 _buildTextField(_nameController, "Name"),
//                                 const SizedBox(height: 15),

//                                 _buildTextField(_relationController, "Relation"),
//                                 const SizedBox(height: 15),

//                                 GestureDetector(
//                                   onTap: () async {
//                                     DateTime? pickedDate = await showDatePicker(
//                                       context: context,
//                                       initialDate: DateTime(2000, 1, 1),
//                                       firstDate: DateTime(1900),
//                                       lastDate: DateTime.now(),
//                                     );

//                                     if (pickedDate != null) {
//                                       String formattedDate =
//                                           "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
//                                       setState(() {
//                                         _selectedDate = pickedDate;
//                                         _dobController.text = formattedDate;
//                                       });
//                                     }
//                                   },
//                                   child: AbsorbPointer(
//                                     child: _buildTextField(
//                                         _dobController, "Date of Birth (DD/MM/YYYY)"),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 15),

//                                 _buildTextField(_contactController, "Contact Number",
//                                     keyboardType: TextInputType.phone),
//                                 const SizedBox(height: 15),

//                                 _buildTextField(_addressController, "Address", maxLines: 3),
//                                 const SizedBox(height: 15),

//                                 Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(12),
//                                     color: Colors.white,
//                                   ),
//                                   child: DropdownButtonHideUnderline(
//                                     child: DropdownButton2<String>(
//                                       isExpanded: true,
//                                       value: _selectedPlan,
//                                       items: ['One Time', 'SIP', 'AG Plan']
//                                           .map((plan) => DropdownMenuItem(
//                                                 value: plan,
//                                                 child: Text(plan),
//                                               ))
//                                           .toList(),
//                                       onChanged: (value) {
//                                         setState(() {
//                                           _selectedPlan = value!;
//                                         });
//                                       },
//                                       buttonStyleData: const ButtonStyleData(
//                                         padding: EdgeInsets.symmetric(horizontal: 0),
//                                       ),
//                                       dropdownStyleData: DropdownStyleData(
//                                         maxHeight: 150,
//                                         width: double.infinity,
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(12),
//                                           color: Colors.white,
//                                         ),
//                                         offset: const Offset(0, 0),
//                                       ),
//                                     ),
//                                   ),
//                                 ),

//                                 const SizedBox(height: 20),

//                                 CustomButton(
//                                   text: "Save Nominee",
//                                   color: AppColors.primaryGold,
//                                   onPressed: nomineeProvider.isLoading ? null : _saveNominee,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),

//                       // Nominee List Title
//                       if (!_showForm)
//                         const Padding(
//                           padding: EdgeInsets.only(bottom: 16),
//                           child: Text(
//                             "Your Nominees",
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                             ),
//                           ),
//                         ),

//                       // Display Nominee Details
//                       if (detailsProvider.isLoading)
//                         const Center(
//                           child: Padding(
//                             padding: EdgeInsets.all(40),
//                             child: CircularProgressIndicator(
//                               valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
//                             ),
//                           ),
//                         )
//                       else if (detailsProvider.nomineeDetails?.data == null ||
//                           detailsProvider.nomineeDetails!.data!.isEmpty)
//                         Center(
//                           child: Padding(
//                             padding: const EdgeInsets.all(40),
//                             child: Column(
//                               children: [
//                                 Icon(
//                                   Icons.person_outline,
//                                   size: 64,
//                                   color: Colors.grey[400],
//                                 ),
//                                 const SizedBox(height: 16),
//                                 Text(
//                                   "No nominees added yet",
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: Colors.grey[600],
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 TextButton(
//                                   onPressed: () {
//                                     setState(() {
//                                       _showForm = true;
//                                     });
//                                   },
//                                   child: const Text(
//                                     "Add your first nominee",
//                                     style: TextStyle(
//                                       color: AppColors.primaryGold,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         )
//                       else
//                         ListView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: detailsProvider.nomineeDetails!.data!.length,
//                           itemBuilder: (context, index) {
//                             final nominee = detailsProvider.nomineeDetails!.data![index];
//                             return _buildNomineeCard(nominee);
//                           },
//                         ),
//                     ],
//                   ),
//                 ),
//               ),

//               // Loading Overlay for POST request
//               if (nomineeProvider.isLoading)
//                 Container(
//                   color: Colors.black.withOpacity(0.3),
//                   child: const Center(
//                     child: CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
//                     ),
//                   ),
//                 ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildNomineeCard(dynamic nominee) {
//     String formatDate(DateTime? date) {
//       if (date == null) return 'N/A';
//       return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
//     }

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.15),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: AppColors.primaryGold.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.person,
//                   color: AppColors.primaryGold,
//                   size: 24,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       nominee.name ?? 'N/A',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       nominee.relation ?? 'N/A',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const Divider(height: 24),
//           _buildDetailRow("Date of Birth", formatDate(nominee.dob)),
//           _buildDetailRow("Contact", nominee.contactNo ?? 'N/A'),
//           _buildDetailRow("Address", nominee.address ?? 'N/A'),
//           _buildDetailRow("Plan Type", _formatPlanType(nominee.planType)),
          
//           if (nominee.createdAt != null)
//             Padding(
//               padding: const EdgeInsets.only(top: 12),
//               child: Text(
//                 "Added on: ${formatDate(nominee.createdAt)}",
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[500],
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 110,
//             child: Text(
//               "$label:",
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//                 color: Colors.black87,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w400,
//                 fontSize: 14,
//                 color: Colors.black54,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField(TextEditingController controller, String hint,
//       {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       maxLines: maxLines,
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return "$hint cannot be empty";
//         }
//         if (hint.contains("Contact") && value.length != 10) {
//           return "Contact number must be 10 digits";
//         }
//         return null;
//       },
//       decoration: InputDecoration(
//         hintText: hint,
//         filled: true,
//         fillColor: Colors.white,
//         contentPadding:
//             const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/res/widgets/custom_button.dart';
import 'package:aishwarya_gold/data/models/settingmodels/nominee_models.dart';
import 'package:aishwarya_gold/view_models/nominee_provider/nominee_provider.dart';
import 'package:aishwarya_gold/view_models/nominee_provider/nominee_details_provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class NomineeDetailsScreen extends StatefulWidget {
  final String userId;
  
  const NomineeDetailsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<NomineeDetailsScreen> createState() => _NomineeDetailsScreenState();
}

class _NomineeDetailsScreenState extends State<NomineeDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _selectedPlan;
  DateTime? _selectedDate;
  bool _showForm = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchNomineeDetails();
    });
  }

  void _fetchNomineeDetails() {
    final provider = Provider.of<NomineeDetailsProvider>(context, listen: false);
    provider.fetchNomineeDetails(pageNumber: 1);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationController.dispose();
    _dobController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  List<String> _getPlanTypeForAPI(String selectedPlan) {
    switch (selectedPlan) {
      case 'One Time':
        return ['OneTimeInvestment'];
      case 'SIP':
        return ['SIPPlan'];
      case 'AG Plan':
        return ['AgPlan'];
      default:
        return ['OneTimeInvestment'];
    }
  }

  String _formatPlanType(List<String>? planTypes) {
    if (planTypes == null || planTypes.isEmpty) return 'N/A';
    
    return planTypes.map((plan) {
      switch (plan) {
        case 'OneTimeInvestment':
          return 'One Time';
        case 'SIPPlan':
          return 'SIP';
        case 'AgPlan':
          return 'AG Plan';
        default:
          return plan;
      }
    }).join(', ');
  }

  // Get available plans (excluding already used ones)
  List<String> _getAvailablePlans() {
    final detailsProvider = Provider.of<NomineeDetailsProvider>(context, listen: false);
    final allPlans = ['One Time', 'SIP', 'AG Plan'];
    
    if (detailsProvider.nomineeDetails?.data == null || 
        detailsProvider.nomineeDetails!.data!.isEmpty) {
      return allPlans;
    }

    // Get all used plan types
    Set<String> usedPlans = {};
    for (var nominee in detailsProvider.nomineeDetails!.data!) {
      if (nominee.planType != null && nominee.planType!.isNotEmpty) {
        for (var apiPlan in nominee.planType!) {
          switch (apiPlan) {
            case 'OneTimeInvestment':
              usedPlans.add('One Time');
              break;
            case 'SIPPlan':
              usedPlans.add('SIP');
              break;
            case 'AgPlan':
              usedPlans.add('AG Plan');
              break;
          }
        }
      }
    }

    // Return only available plans
    return allPlans.where((plan) => !usedPlans.contains(plan)).toList();
  }

  void _saveNominee() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedPlan == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Please select a plan type"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        return;
      }

      final nomineeProvider = Provider.of<NomineeProvider>(context, listen: false);

      final nominee = Nominee(
        userId: widget.userId,
        name: _nameController.text.trim(),
        relation: _relationController.text.trim(),
        dob: _selectedDate,
        contactNo: _contactController.text.trim(),
        address: _addressController.text.trim(),
        planType: _getPlanTypeForAPI(_selectedPlan!),
      );

      debugPrint('=== Nominee API Request ===');
      debugPrint('Request Body: ${nomineeToJson(nominee)}');
      debugPrint('========================\n');

      try {
        await nomineeProvider.createNominee(nominee);

        debugPrint('=== Nominee API Response ===');
        debugPrint('Response: ${nomineeProvider.response}');
        debugPrint('===========================\n');

        if (nomineeProvider.response != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Nominee added successfully!"),
              backgroundColor: AppColors.coinBrown,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );

          // Clear form
          _nameController.clear();
          _relationController.clear();
          _dobController.clear();
          _contactController.clear();
          _addressController.clear();
          _selectedDate = null;
          _selectedPlan = null;

          setState(() {
            _showForm = false;
          });

          // Refresh the list
          _fetchNomineeDetails();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Failed to save nominee details."),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      } catch (e) {
        debugPrint('=== Nominee API Error ===');
        debugPrint('Error: $e');
        debugPrint('========================\n');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${e.toString()}"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Nominee Details",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Consumer<NomineeDetailsProvider>(
            builder: (context, detailsProvider, child) {
              final availablePlans = _getAvailablePlans();
              final canAddMore = availablePlans.isNotEmpty;
              
              return IconButton(
                icon: Icon(
                  _showForm ? Icons.close : Icons.add,
                  color: canAddMore ? AppColors.primaryGold : Colors.grey,
                ),
                onPressed: canAddMore ? () {
                  setState(() {
                    _showForm = !_showForm;
                    if (_showForm) {
                      // Reset selected plan when opening form
                      _selectedPlan = null;
                    }
                  });
                } : null,
              );
            },
          ),
        ],
      ),
      body: Consumer2<NomineeDetailsProvider, NomineeProvider>(
        builder: (context, detailsProvider, nomineeProvider, child) {
          final availablePlans = _getAvailablePlans();
          final canAddMore = availablePlans.isNotEmpty;

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  _fetchNomineeDetails();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Add Nominee Form
                      if (_showForm)
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Add New Nominee",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 15),

                                _buildTextField(_nameController, "Name"),
                                const SizedBox(height: 15),

                                _buildTextField(_relationController, "Relation"),
                                const SizedBox(height: 15),

                                GestureDetector(
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime(2000, 1, 1),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
                                    );

                                    if (pickedDate != null) {
                                      String formattedDate =
                                          "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                                      setState(() {
                                        _selectedDate = pickedDate;
                                        _dobController.text = formattedDate;
                                      });
                                    }
                                  },
                                  child: AbsorbPointer(
                                    child: _buildTextField(
                                        _dobController, "Date of Birth (DD/MM/YYYY)"),
                                  ),
                                ),
                                const SizedBox(height: 15),

                                _buildTextField(_contactController, "Contact Number",
                                    keyboardType: TextInputType.phone),
                                const SizedBox(height: 15),

                                _buildTextField(_addressController, "Address", maxLines: 3),
                                const SizedBox(height: 15),

                                // Plan Type Dropdown
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: availablePlans.isEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          child: Text(
                                            "All plans have nominees assigned",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        )
                                      : DropdownButtonHideUnderline(
                                          child: DropdownButton2<String>(
                                            isExpanded: true,
                                            hint: Text(
                                              "Select Plan Type",
                                              style: TextStyle(color: Colors.grey[600]),
                                            ),
                                            value: _selectedPlan,
                                            items: availablePlans
                                                .map((plan) => DropdownMenuItem(
                                                      value: plan,
                                                      child: Text(plan),
                                                    ))
                                                .toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedPlan = value;
                                              });
                                            },
                                            buttonStyleData: const ButtonStyleData(
                                              padding: EdgeInsets.symmetric(horizontal: 0),
                                            ),
                                            dropdownStyleData: DropdownStyleData(
                                              maxHeight: 150,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                color: Colors.white,
                                              ),
                                              offset: const Offset(0, 0),
                                            ),
                                          ),
                                        ),
                                ),

                                const SizedBox(height: 20),

                                CustomButton(
                                  text: "Save Nominee",
                                  color: AppColors.primaryGold,
                                  onPressed: nomineeProvider.isLoading ? null : _saveNominee,
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Message when all plans are used
                      if (!_showForm && !canAddMore && detailsProvider.nomineeDetails?.data != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.coinBrown),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: AppColors.coinBrown),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "All plan types have nominees assigned",
                                  style: TextStyle(
                                    color: AppColors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Nominee List Title
                      if (!_showForm)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            "Your Nominees",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                      // Display Nominee Details
                      if (detailsProvider.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
                            ),
                          ),
                        )
                      else if (detailsProvider.nomineeDetails?.data == null ||
                          detailsProvider.nomineeDetails!.data!.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "No nominees added yet",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _showForm = true;
                                    });
                                  },
                                  child: const Text(
                                    "Add your first nominee",
                                    style: TextStyle(
                                      color: AppColors.primaryGold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: detailsProvider.nomineeDetails!.data!.length,
                          itemBuilder: (context, index) {
                            final nominee = detailsProvider.nomineeDetails!.data![index];
                            return _buildNomineeCard(nominee);
                          },
                        ),
                    ],
                  ),
                ),
              ),

              // Loading Overlay for POST request
              if (nomineeProvider.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNomineeCard(dynamic nominee) {
    String formatDate(DateTime? date) {
      if (date == null) return 'N/A';
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primaryGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nominee.name ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nominee.relation ?? 'N/A',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildDetailRow("Date of Birth", formatDate(nominee.dob)),
          _buildDetailRow("Contact", nominee.contactNo ?? 'N/A'),
          _buildDetailRow("Address", nominee.address ?? 'N/A'),
          _buildDetailRow("Plan Type", _formatPlanType(nominee.planType)),
          
          if (nominee.createdAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                "Added on: ${formatDate(nominee.createdAt)}",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$hint cannot be empty";
        }
        if (hint.contains("Contact") && value.length != 10) {
          return "Contact number must be 10 digits";
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
    );
  }
}