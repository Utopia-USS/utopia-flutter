# utopia_utils

Basic, miscellaneous utils.

## Highlights

### Reporter

Abstraction of logging/error reporting. Messages, apart from printing them to the console, can be piped e.g. to
Crashlytics.

### runAppWithReporterAndUiErrors

Wrap your whole `main()` function to catch all uncaught errors. Send them to your `Reporter` and notify your user about
them.

### Value/MutableValue

Abstraction around the concept of objects containing a (mutable) value.