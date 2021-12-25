part of 'declaration.dart';

abstract class ViewDeclaration extends Declaration {}

abstract class ViewDeclarationWithSql implements ViewDeclaration {
  /// The `CREATE VIEW` statement used to create this view.
  String get createSql;

  /// The parsed statement creating this view.
  CreateViewStatement get creatingStatement;
}

class DartViewDeclaration implements ViewDeclaration, DartDeclaration {
  @override
  final SourceRange declaration;

  @override
  final ClassElement element;

  final List<TableReferenceInDartView> staticReferences;

  DartViewDeclaration._(this.declaration, this.element, this.staticReferences);

  factory DartViewDeclaration(ClassElement element, FoundFile file,
      List<TableReferenceInDartView> staticReferences) {
    return DartViewDeclaration._(
      SourceRange.fromElementAndFile(element, file),
      element,
      staticReferences,
    );
  }
}

class TableReferenceInDartView {
  final MoorTable table;
  final String name;
  final String declaration;

  TableReferenceInDartView(this.table, this.name, this.declaration);
}

class MoorViewDeclaration
    implements ViewDeclaration, MoorDeclaration, ViewDeclarationWithSql {
  @override
  final SourceRange declaration;

  @override
  final CreateViewStatement node;

  MoorViewDeclaration._(this.declaration, this.node);

  factory MoorViewDeclaration(CreateViewStatement node, FoundFile file) {
    return MoorViewDeclaration._(
      SourceRange.fromNodeAndFile(node, file),
      node,
    );
  }

  @override
  String get createSql => node.span!.text;

  @override
  CreateViewStatement get creatingStatement => node;
}
