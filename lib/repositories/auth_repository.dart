import '../core/auth/auth_repository.dart';
import '../config/macro_service_config.dart';
import '../core/storage/secure_key_value_store.dart';

export '../core/auth/auth_repository.dart';

class AuthRepository extends AuthRepositoryImpl {
  AuthRepository({SecureKeyValueStore? storage, MacroServiceConfig? config})
    : super(storage: storage, config: config);
}
