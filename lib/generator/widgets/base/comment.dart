import 'package:unify/generator/widgets/base/line.dart';
import 'package:unify/generator/widgets/code_unit.dart';
import 'package:unify/utils/constants.dart';

class CommentType {
  static const String commentDoubleBackSlash = '//';
  static const String commentTripleBackSlash = '///';
  static const String commentBlock = '/**/';
}

class Comment extends CodeUnit {
  Comment(
      {this.comments = const [],
      this.commentType = CommentType.commentDoubleBackSlash,
      this.blockContinuationToken = CodeUnit.space,
      int depth = 0})
      : super(depth);

  final List<String> comments;
  final String commentType;
  final String blockContinuationToken;

  @override
  String build() {
    if (commentType == CommentType.commentDoubleBackSlash) {
      return CodeUnit.join(comments
          .map((comment) =>
              OneLine(depth: depth, body: '//$blockContinuationToken$comment'))
          .toList());
    } else if (commentType == CommentType.commentTripleBackSlash) {
      return CodeUnit.join(comments
          .map((comment) =>
              OneLine(depth: depth, body: '///$blockContinuationToken$comment'))
          .toList());
    } else if (commentType == CommentType.commentBlock) {
      return CodeUnit.join([
        OneLine(depth: depth, body: '/*'),
        ...comments
            .map((comment) =>
                OneLine(depth: depth, body: blockContinuationToken + comment))
            .toList(),
        OneLine(depth: depth, body: '*/')
      ]);
    }

    throw UnimplementedError();
  }
}

class CommentUniAPI extends Comment {
  CommentUniAPI({int depth = 0})
      : super(comments: [
          '=================================================',
          fileHeaderComments,
          '================================================='
        ], commentType: CommentType.commentDoubleBackSlash, depth: depth);
}
