import 'package:flutter/material.dart';

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
    required this.keyboardType, // default value set to false
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _showClearIcon = false;

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
          obscureText: widget.obscureText, // use the passed obscureText value
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          onChanged: (value) {
            setState(() {
              _showClearIcon = value.isNotEmpty;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
          },
          validator: widget.validator,
          decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(4.0),
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
                    },
                    icon: const Icon(Icons.clear),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class oldCustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final String? hintText;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final bool obscureText;
  final bool isEmail;
  final bool isNumber;

  oldCustomTextField({
    required this.controller,
    this.onChanged,
    this.hintText,
    this.validator,
    this.prefixIcon,
    this.obscureText = false,
    this.isEmail = false,
    this.isNumber = false,
  });

  @override
  _oldCustomTextFieldState createState() => _oldCustomTextFieldState();
}

class _oldCustomTextFieldState extends State<oldCustomTextField> {
  bool _showClearIcon = false;

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
          controller: widget.controller,
          obscureText: widget.obscureText,
          onChanged: (value) {
            setState(() {
              _showClearIcon = value.isNotEmpty;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
          },
          validator: widget.validator,
          decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(4.0),
            ),
            fillColor: Colors.white70,
            filled: true,
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontFamily: 'ProductSans',
              fontSize: 12.0,
            ),
            prefixIcon:
                widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
            suffixIcon: _showClearIcon
                ? IconButton(
                    onPressed: () {
                      widget.controller.clear();
                      setState(() {
                        _showClearIcon = false;
                      });
                    },
                    icon: const Icon(Icons.clear),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
