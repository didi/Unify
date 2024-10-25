class Error {
  Error({
    required this.message,
    this.filename,
    this.lineNumber,
  });

  String message;

  String? filename;

  int? lineNumber;

  @override
  String toString() =>
      '(Error message:"$message" filename:"$filename" lineNumber:$lineNumber)';
}
