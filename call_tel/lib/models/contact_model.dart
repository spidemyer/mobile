class Contact { //cria a classe de contato 
  final int? id;
  final String name;
  final String phone;
  final String email;
  final String address;

  Contact({ //o construtor da classe
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
  });

  Map<String, dynamic> toMap() { //mapeamento dos campos para o bd
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) { //mapeamento dos campos do bd para a classe
    return Contact(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      address: map['address'] as String,
    );
  }

  Contact copyWith({ //método para criar uma cópia do contato com campos opcionais para atualização
    int? id,
    String? name,
    String? phone,
    String? email,
    String? address,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }
}