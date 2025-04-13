import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickalert/quickalert.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  String _criticalityValue = 'low';
  bool _isEmailValid = true;
  bool _isSubmitting = false;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _issueDescriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Enhanced email validation
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      setState(() => _isEmailValid = false);
      return 'Email is required';
    }

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      setState(() => _isEmailValid = false);
      return 'Please enter a valid professional email address';
    }

    setState(() => _isEmailValid = true);
    return null;
  }

  // Submit issue to Firestore
  Future<void> _submitIssue() async {
    FocusScope.of(context).unfocus(); // Dismiss keyboard

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _firestore.collection('issues').add({
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'criticality': _criticalityValue,
        'issueDescription': _issueDescriptionController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      _showSuccessMessage();
      _resetForm();
    } catch (e) {
      _showErrorMessage(e);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  // Success alert
  void _showSuccessMessage() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'Issue Reported',
      text: 'Thank you for helping us improve NaviXplore!',
      confirmBtnText: 'Awesome',
      confirmBtnColor: Colors.green,
    );
  }

  // Error alert
  void _showErrorMessage(e) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Submission Error',
      text: 'We couldn\'t submit your issue. Please try again.',
      confirmBtnText: 'Retry',
      confirmBtnColor: Colors.red,
    );
  }

  // Reset form fields
  void _resetForm() {
    _fullNameController.clear();
    _emailController.clear();
    _issueDescriptionController.clear();
    setState(() {
      _criticalityValue = 'low';
      _isEmailValid = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: BackButton(
          color: Theme.of(context).primaryColor,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Report an Issue",
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBranding(),
                const SizedBox(height: 24),
                _buildSubheading(),
                const SizedBox(height: 32),
                _buildFullNameField(),
                const SizedBox(height: 16),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildCriticalityDropdown(),
                const SizedBox(height: 16),
                _buildIssueDescriptionField(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // Branding widget with animated entry
  Widget _buildBranding() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Navi",
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontFamily: "Fredoka",
                fontWeight: FontWeight.bold,
                fontSize: 48)),
        Text("X",
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontFamily: "Fredoka",
                fontWeight: FontWeight.bold,
                fontSize: 60)),
        Text("plore",
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontFamily: "Fredoka",
                fontWeight: FontWeight.bold,
                fontSize: 48)),
      ],
    ).animate().slideY(begin: 0.5, end: 0).fadeIn(duration: 500.ms);
  }

  // Subheading with animated entry
  Widget _buildSubheading() {
    return Text(
      "Your feedback helps us create a better app experience. Please share the details of the issue you encountered.",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[700],
        fontStyle: FontStyle.italic,
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  // Full name input field
  Widget _buildFullNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Full Name",
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _fullNameController,
          decoration: InputDecoration(
            hintText: "Enter your full name",
            prefixIcon:
                Icon(Icons.person, color: Theme.of(context).primaryColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
          ),
          keyboardType: TextInputType.name,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Email input field with validation
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Email Address",
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: "email@example.com",
            prefixIcon: Icon(Icons.email,
                color: _isEmailValid
                    ? Theme.of(context).primaryColor
                    : Colors.red),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: _isEmailValid
                      ? Theme.of(context).primaryColor
                      : Colors.red,
                  width: 2),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
        ),
      ],
    );
  }

  // Criticality level dropdown
  Widget _buildCriticalityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Criticality Level",
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.error_outline,
                color: Theme.of(context).primaryColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
          ),
          value: _criticalityValue,
          items: [
            DropdownMenuItem(
                value: 'high',
                child: Text("High", style: TextStyle(color: Colors.red[700]))),
            DropdownMenuItem(
                value: 'medium',
                child: Text("Medium",
                    style: TextStyle(color: Colors.orange[700]))),
            DropdownMenuItem(
                value: 'low',
                child: Text("Low", style: TextStyle(color: Colors.green[700]))),
          ],
          onChanged: (String? newValue) {
            setState(() {
              _criticalityValue = newValue!;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a criticality level';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Issue description input field
  Widget _buildIssueDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Describe The Issue",
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _issueDescriptionController,
          maxLines: 5,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: "Provide detailed information about the issue...",
            prefixIcon:
                Icon(Icons.description, color: Theme.of(context).primaryColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please describe the issue';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Submit button with loading state
  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isSubmitting ? null : _submitIssue,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isSubmitting
                ? [Colors.grey, Colors.grey.shade700]
                : [Theme.of(context).primaryColor, Colors.deepOrangeAccent],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: _isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : const Text(
                  "Submit Issue",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
        ),
      ).animate().scale(duration: 300.ms),
    );
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _fullNameController.dispose();
    _emailController.dispose();
    _issueDescriptionController.dispose();
    super.dispose();
  }
}
