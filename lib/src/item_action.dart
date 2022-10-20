import 'package:hexabase/src/base.dart';

class HexabaseItemAction extends HexabaseBase {
  final String? name;
  final String? id;
  final String? idLabel;
  final String? nameLabel;
  final String? description;
  late int? crudType;
  late String? nextStatusId;
  late int? displayOrder;

  HexabaseItemAction(
      {this.name,
      this.id,
      this.idLabel,
      this.nameLabel,
      this.description,
      this.crudType,
      this.nextStatusId,
      this.displayOrder})
      : super();
}
