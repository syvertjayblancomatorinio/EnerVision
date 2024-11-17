import 'package:flutter/material.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Icon prefixIcon;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.onChanged,
    this.validator,
    this.obscureText = false,
    required this.keyboardType,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _showClearIcon = false;
  bool _isValid = true;
  String? _errorText;

  void _validateField(String value) {
    setState(() {
      if (value.isEmpty) {
        _isValid = false;
        _errorText = "This field cannot be empty.";
      } else if (widget.validator != null) {
        final validationResult = widget.validator!(value);
        _isValid = validationResult == null;
        _errorText = validationResult;
      } else {
        _isValid = true;
        _errorText = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFD1D1D1),
            offset: Offset(0.0, 5.0),
            blurRadius: 5.0,
            spreadRadius: 2.0,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(0.0, 0.0),
            blurRadius: 0.0,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          obscureText: widget.obscureText,
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          onChanged: (value) {
            setState(() {
              _showClearIcon = value.isNotEmpty;
            });
            _validateField(value); // Validate field on change
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
          },
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: _isValid ? Colors.transparent : Colors.red,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: _isValid ? Colors.transparent : Colors.red,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(4.0),
            ),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2.0),
            ),
            fillColor: Colors.white70,
            filled: true,
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontFamily: 'ProductSans',
              fontSize: 12.0,
            ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: _showClearIcon
                ? IconButton(
                    onPressed: () {
                      widget.controller.clear();
                      setState(() {
                        _showClearIcon = false;
                      });
                      _validateField(
                          ''); // Trigger validation with empty string
                    },
                    icon: const Icon(Icons.clear),
                  )
                : null,
            errorText: _errorText,
          ),
        ),
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Icon prefixIcon;
  final Function(String)? onChanged;

  const PasswordField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.onChanged,
  }) : super(key: key);

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _showClearIcon = false;
  bool _isValid = true;
  bool _hasStartedTyping = false; // Tracks whether the user has started typing
  String? _errorText;

  final Map<String, bool> _passwordRequirements = {
    "At least 8 characters": false,
    "At least one special character": false,
    "At least one uppercase character": false,
  };

  void _validatePassword(String value) {
    setState(() {
      _hasStartedTyping = value.isNotEmpty;

      _passwordRequirements["At least 8 characters"] = value.length >= 8;
      _passwordRequirements["At least one special character"] =
          RegExp(r'[!@#\$&*~]').hasMatch(value);
      _passwordRequirements["At least one uppercase character"] =
          RegExp(r'[A-Z]').hasMatch(value);

      _isValid = _passwordRequirements.values.every((req) => req);

      if (value.isEmpty) {
        _isValid = false;
        _errorText = null; // No error when the field is empty
      } else if (!_isValid) {
        _errorText = "Password must meet all requirements.";
      } else {
        _errorText = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFD1D1D1),
            offset: Offset(0.0, 5.0),
            blurRadius: 5.0,
            spreadRadius: 2.0,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(0.0, 0.0),
            blurRadius: 0.0,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              obscureText: true,
              controller: widget.controller,
              onChanged: (value) {
                setState(() {
                  _showClearIcon = value.isNotEmpty;
                });
                _validatePassword(value);
                if (widget.onChanged != null) {
                  widget.onChanged!(value);
                }
              },
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _isValid ? Colors.transparent : Colors.red,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _isValid ? Colors.transparent : Colors.red,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2.0),
                ),
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontFamily: 'ProductSans',
                  fontSize: 12.0,
                ),
                prefixIcon: widget.prefixIcon,
                suffixIcon: _showClearIcon
                    ? IconButton(
                        onPressed: () {
                          widget.controller.clear();
                          setState(() {
                            _showClearIcon = false;
                            _hasStartedTyping = false;
                          });
                          _validatePassword('');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                errorText: _errorText,
              ),
            ),
            const SizedBox(height: 8),
            // Show unmet requirements only after the user starts typing
            if (_hasStartedTyping)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _passwordRequirements.entries
                    .where(
                        (entry) => !entry.value) // Only show unmet requirements
                    .map(
                      (entry) => Row(
                        children: [
                          const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            entry.key,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
