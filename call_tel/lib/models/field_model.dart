class AdditionalField { // um campo adicional para o contato
  final int? id;
  final int? contactId;
  final String fieldType;
  final String fieldValue;

  AdditionalField({ // construtor da classe
    this.id,
    this.contactId,
    required this.fieldType,
    required this.fieldValue,
  });

  Map<String, dynamic> toMap() { // mapeamento dos campos para o bd
    return {
      'id': id,
      'contact_id': contactId,
      'field_type': fieldType,
      'field_value': fieldValue,
    };
  }

  factory AdditionalField.fromMap(Map<String, dynamic> map) {
    return AdditionalField(
      id: map['id'] as int?,
      contactId: map['contact_id'] as int?,
      fieldType: map['field_type'] as String,
      fieldValue: map['field_value'] as String,
    );
  }
}
