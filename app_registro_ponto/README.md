# Registro de Ponto

Aplicativo mobile desenvolvido em Flutter para registrar o ponto de trabalho com autenticação, biometria e geolocalização.

O registro só é aceito quando o funcionário está a, no máximo, 100 metros do local definido para a empresa. Depois da validação, o ponto é salvo no Cloud Firestore com usuário, data, hora e coordenadas.

## Funcionalidades

- Login com e-mail e senha usando Firebase Authentication.
- Login biométrico usando a biometria disponível no aparelho.
- Confirmação biométrica antes de cada registro de ponto.
- Solicitação de permissão de localização durante o registro.
- Cálculo da distância até o local de trabalho.
- Bloqueio do registro para quem estiver fora do raio permitido.
- Registro separado de entrada e saída.
- Histórico dos registros atualizado em tempo real pelo Cloud Firestore.
- Salvamento da distância e das coordenadas do registro.
- Sessão persistente e logout.
- Interface com Material 3 e identidade visual em tons roxos.

## Tecnologias utilizadas

- Flutter e Dart
- Firebase Core
- Firebase Authentication
- Cloud Firestore
- Geolocator
- Local Auth
- Intl

## Pré-requisitos

Antes de começar, instale:

- Flutter SDK compatível com Dart 3.12 ou superior.
- Android Studio com Android SDK e um emulador configurado, ou um celular Android conectado.
- Uma conta Google para criar e configurar o projeto Firebase.
- FlutterFire CLI, instalado com:

```bash
dart pub global activate flutterfire_cli
```

Confira a instalação com:

```bash
flutter doctor
flutterfire --version
```

## Configuração do Firebase

### 1. Criar o projeto

1. Acesse o [Firebase Console](https://console.firebase.google.com/).
2. Crie um projeto para o aplicativo.
3. Ative o **Authentication**.
4. Em **Sign-in method**, ative o provedor **E-mail/senha**.
5. Crie um usuário de teste em **Authentication > Users**.
6. Crie o banco **Cloud Firestore** em modo de teste durante o desenvolvimento.
7. Para login por NIF, crie a coleção `usuarios` com documentos contendo `nif` e `email`.

### 2. Conectar o Flutter ao Firebase

Na raiz do projeto, execute:

```bash
flutterfire configure
```

Selecione o projeto Firebase e a plataforma Android. O arquivo `google-services.json` deve ficar em `android/app/`. O projeto Android já possui o plugin Google Services configurado e inicializa o Firebase usando esse arquivo.

Para iOS, adicione o `GoogleService-Info.plist` gerado pelo Firebase ao projeto Xcode. As permissões de Face ID e localização já estão declaradas em `ios/Runner/Info.plist`.

Se o comando não for encontrado, feche e abra o terminal depois de instalar o FlutterFire CLI. Se nenhum projeto aparecer, confirme que a conta usada no terminal tem acesso ao projeto Firebase.

O aplicativo chama `Firebase.initializeApp()` antes de abrir a tela de login. Por isso, o `google-services.json` precisa estar configurado antes de executar no Android.

## Instalação e execução

Na raiz do projeto:

```bash
flutter pub get
flutter analyze
flutter run
```

Para listar os dispositivos disponíveis:

```bash
flutter devices
```

Para usar um dispositivo específico:

```bash
flutter run -d ID_DO_DISPOSITIVO
```

## Configurar o local de trabalho

Abra `lib/services/location_service.dart` e altere estas constantes:

```dart
static const double empresaLatitude = -23.550520;
static const double empresaLongitude = -46.633308;
static const double raioPermitidoMetros = 100.0;
```

As coordenadas acima são apenas um exemplo. Use a latitude e a longitude reais da empresa. O raio pode ser alterado, mas o requisito da avaliação é de 100 metros.

## Como usar

1. Abra o aplicativo.
2. Entre com um usuário criado no Firebase Authentication.
3. Na primeira vez, permita o uso da biometria quando solicitado pelo aparelho.
4. Na tela inicial, toque em **Bater Ponto**.
5. Permita o acesso à localização.
6. Aguarde a validação da distância.
7. Se estiver dentro do raio, confirme sua biometria.
8. O ponto será salvo no Firestore.
9. Consulte os registros em **Ver histórico**.

Para usar a biometria, faça primeiro um login com e-mail e senha. Isso mantém uma sessão Firebase válida para associar o registro ao usuário correto.

## Estrutura do projeto

```text
lib/
├── main.dart                         # Inicialização do app e tema
├── models/
│   └── ponto_model.dart               # Modelo dos registros de ponto
├── services/
│   ├── auth_service.dart              # Autenticação e sessão
│   ├── firebase_service.dart          # Persistência no Firestore
│   └── location_service.dart          # Permissões e cálculo de distância
└── views/
	├── home_view.dart                 # Registro do ponto
	├── historico_view.dart             # Histórico em tempo real
	└── login_view.dart                # Login por senha ou biometria
```

Também fazem parte da entrega o [RELATORIO.md](RELATORIO.md), com as decisões técnicas da implementação, e o teste em `test/widget_test.dart`.

## Dados salvos

Os registros são criados na coleção `registros_ponto` com este formato:

```text
id       identificador do registro
userId   identificador do usuário Firebase
dataHora data e hora em formato ISO 8601
latitude latitude obtida no momento do registro
longitude longitude obtida no momento do registro
tipo     `entrada` ou `saida`
distanciaMetros distância até o local da empresa
```

## Permissões Android

O arquivo `AndroidManifest.xml` já declara as permissões de localização precisa, localização aproximada e biometria. Mesmo assim, o usuário precisa aceitar a permissão de localização em tempo de execução.

Em um emulador, configure uma localização simulada próxima das coordenadas da empresa. Em um aparelho real, o GPS deve estar ligado.

## Regras de segurança do Firestore

Durante o desenvolvimento, o Firestore pode ser iniciado em modo de teste. Antes de publicar, restrinja a coleção para que cada usuário só leia e escreva os próprios registros. Um exemplo inicial de regra é:

```text
match /registros_ponto/{registroId} {
	allow create: if request.auth != null
		&& request.resource.data.userId == request.auth.uid;
	allow read: if request.auth != null
		&& resource.data.userId == request.auth.uid;
}
```

Revise as regras com cuidado antes de usar o aplicativo em produção.

## Limitações atuais

- O login por NIF depende da coleção `usuarios`, que deve ser protegida pelas regras do Firestore.
- As coordenadas da empresa ainda precisam ser configuradas para o endereço real.
- Ainda não existe uma tela de criação de usuários; eles devem ser cadastrados pelo Firebase Console.
- O teste automatizado atual cobre a conversão do modelo para o formato salvo no Firestore.

## Solução de problemas

### `flutterfire configure` falha

Verifique se o FlutterFire CLI está instalado, se o comando está no `PATH` e se a conta autenticada tem acesso ao projeto Firebase.

### O app fecha ao iniciar

Confira se o `google-services.json` está em `android/app/` e se o plugin Google Services está configurado nos arquivos Gradle. Depois execute `flutter clean`, `flutter pub get` e `flutter run` novamente.

### A localização é recusada

Ative o GPS, aceite a permissão e confira se ela não está marcada como negada permanentemente nas configurações do Android.

### O ponto não é salvo

Confirme se o login foi feito com um usuário Firebase válido, se o aparelho está dentro dos 100 metros e se o Firestore está habilitado.

## Objetivos da avaliação

Este projeto demonstra:

- Competência técnica com Flutter, Firebase e APIs de hardware.
- Autenticação por senha e biometria.
- Uso de geolocalização com regra de distância.
- Persistência de dados em tempo real no Firestore.
- Organização por telas, serviços e modelo de dados.
- Interface e experiência de uso voltadas para um fluxo real de registro de ponto.
