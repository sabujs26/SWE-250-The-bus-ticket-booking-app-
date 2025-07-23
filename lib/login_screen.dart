validator: (value) {
  if (value == null || value.isEmpty) return 'Please enter your password';
  if (value.length < 6) return 'Password must be at least 6 characters';
  if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#\$&*~]).{6,}$').hasMatch(value)) {
    return 'Use letters, numbers & special characters (!@#\$&*~)';
  }
  return null;
},
