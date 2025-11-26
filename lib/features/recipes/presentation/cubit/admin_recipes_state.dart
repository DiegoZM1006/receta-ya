part of 'admin_recipes_cubit.dart';

enum AdminRecipesStatus { initial, loading, success, failure }

class AdminRecipesState {
  final AdminRecipesStatus status;
  final String? errorMessage;
  final String? successMessage;

  const AdminRecipesState._({
    required this.status,
    this.errorMessage,
    this.successMessage,
  });

  const AdminRecipesState.initial() : this._(status: AdminRecipesStatus.initial);

  AdminRecipesState copyWith({
    AdminRecipesStatus? status,
    String? errorMessage,
    String? successMessage,
  }) {
    return AdminRecipesState._(
      status: status ?? this.status,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
