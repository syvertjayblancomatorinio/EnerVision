import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final IconData? prefixIcon;
  final int? maxLength;
  final bool showCounter;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final TextInputType? inputType;

  const MyTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.prefixIcon,
    this.maxLength,
    this.showCounter = true,
    this.onSaved,
    this.validator,
    this.onFieldSubmitted,
    this.onChanged,
    this.inputType,
  }) : super(key: key);

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool _showClearIcon = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateClearIconVisibility);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateClearIconVisibility);
    super.dispose();
  }

  void _updateClearIconVisibility() {
    setState(() {
      _showClearIcon = widget.controller.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              maxLength: widget.maxLength,
              buildCounter: (_,
                      {required currentLength,
                      required isFocused,
                      maxLength}) =>
                  null, // Hide the built-in counter
              onChanged: widget.onChanged,
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
                          widget.onChanged?.call('');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
              ),
            ),
          ),
        ),
        if (widget.maxLength != null && widget.showCounter)
          Padding(
            padding: const EdgeInsets.only(left: 25.0, top: 4.0),
            child: Text(
              '${widget.controller.text.length}/${widget.maxLength}',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey[500],
              ),
            ),
          ),
      ],
    );
  }
}
