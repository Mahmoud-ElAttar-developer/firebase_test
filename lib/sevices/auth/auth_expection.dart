// login expections
class UserNotFoundAuthException implements Exception {}

class WrongPasswordAuthExpection implements Exception {}



// register expections
class WeakPasswordAuthExpection implements Exception {}

class EmailAlreadyInUseAuthExpection implements Exception {}

class InvalidEmailAuthExpection implements Exception {}


// Generic expections

class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}