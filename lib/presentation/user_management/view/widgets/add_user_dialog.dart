import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/user.dart';
import '../../bloc/user_management_bloc.dart';
import '../../bloc/user_management_event.dart';
import '../../bloc/user_management_state.dart';

class AddUserDialog extends StatefulWidget {
  final User? user; // If provided, this is an edit operation

  const AddUserDialog({super.key, this.user});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  UserRole _selectedRole = UserRole.sales;
  bool _requiresPassword = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      // Edit mode
      _nameController.text = widget.user!.name;
      _selectedRole = widget.user!.role;
      _requiresPassword = widget.user!.requiresPassword;
      _passwordController.text = widget.user!.password ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserManagementBloc, UserManagementState>(
      listener: (context, state) {
        if (state is UserCreated || state is UserUpdated) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state is UserCreated ? 'User created successfully' : 'User updated successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is UserManagementError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: AlertDialog(
        title: Text(widget.user != null ? 'Edit User' : 'Add User'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Role dropdown
                DropdownButtonFormField<UserRole>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                      // Admin users should require password
                      if (value == UserRole.admin) {
                        _requiresPassword = true;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Password requirement checkbox
                CheckboxListTile(
                  title: const Text('Requires Password'),
                  value: _requiresPassword,
                  onChanged: _selectedRole == UserRole.admin ? null : (value) {
                    setState(() {
                      _requiresPassword = value!;
                      if (!value) {
                        _passwordController.clear();
                      }
                    });
                  },
                  subtitle: _selectedRole == UserRole.admin 
                      ? const Text('Admin users always require password')
                      : null,
                ),
                
                // Password field (if required)
                if (_requiresPassword) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (_requiresPassword && (value == null || value.isEmpty)) {
                        return 'Please enter a password';
                      }
                      if (_requiresPassword && value!.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _saveUser,
            child: Text(widget.user != null ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _saveUser() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final password = _requiresPassword ? _passwordController.text : null;
      
      if (widget.user != null) {
        // Edit mode
        final updatedUser = widget.user!.copyWith(
          name: name,
          role: _selectedRole,
          requiresPassword: _requiresPassword,
          password: password,
        );
        context.read<UserManagementBloc>().add(UpdateUserEvent(user: updatedUser));
      } else {
        // Add mode
        context.read<UserManagementBloc>().add(CreateUserEvent(
          name: name,
          role: _selectedRole,
          requiresPassword: _requiresPassword,
          password: password,
        ));
      }
    }
  }
} 