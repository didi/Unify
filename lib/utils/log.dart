const debug = false;

void log(String content, {dynamic value = ''}) {
  if (debug) {
    printf('$content ==> $value');
  }
}

void printf(Object? content) => print(content);
