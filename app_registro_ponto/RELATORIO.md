# Relatório de Implementação

## 1. Visão geral

O Registro de Ponto é um aplicativo Flutter criado para simular o controle de jornada de funcionários. O usuário autentica sua identidade, confirma a biometria no momento do registro e só consegue salvar o ponto quando está a até 100 metros do local de trabalho.

O projeto atende ao uso de recursos de hardware por meio da biometria e da localização do aparelho. Os registros ficam no Cloud Firestore e podem ser acompanhados em tempo real na tela de histórico.

## 2. Funcionalidades implementadas

### Autenticação

A autenticação por e-mail ou NIF e senha é feita pelo Firebase Authentication em `lib/services/auth_service.dart`. Quando o identificador não contém `@`, o serviço procura o e-mail associado na coleção `usuarios`. A sessão é observada com `authStateChanges()` em `lib/main.dart`, permitindo que o aplicativo abra diretamente a tela adequada quando o usuário já estiver autenticado.

A biometria é usada em dois momentos: como acesso alternativo depois do primeiro login com senha e como confirmação adicional antes de cada registro de ponto. Essa segunda confirmação reduz o risco de registrar um ponto sem a presença do usuário.

### Geolocalização

`lib/services/location_service.dart` verifica se o GPS está ativo, solicita as permissões necessárias e obtém a posição atual. A distância até o local da empresa é calculada com `Geolocator.distanceBetween`.

O limite padrão é de 100 metros. O registro é recusado quando a distância é maior que esse valor.

### Registro de entrada e saída

A tela `lib/views/home_view.dart` permite selecionar entre entrada e saída. Cada registro salva:

- Identificador do registro;
- Identificador do usuário Firebase;
- Data e hora em formato ISO 8601;
- Latitude e longitude;
- Tipo do ponto;
- Distância calculada até o local de trabalho.

### Histórico em tempo real

A classe `FirebaseService` expõe o método `streamPontos`, que acompanha a coleção `registros_ponto` usando snapshots do Firestore. A tela `lib/views/historico_view.dart` apresenta os pontos do usuário autenticado sem precisar atualizar manualmente a página.

A ordenação é feita no Dart para evitar a necessidade de um índice composto no Firestore durante a configuração inicial.

## 3. Organização do código

O projeto separa responsabilidades em três grupos:

- `views/`: telas e interação com o usuário;
- `services/`: autenticação, localização e acesso ao Firebase;
- `models/`: formato dos dados de ponto.

Essa divisão facilita a manutenção e permite trocar uma integração sem misturar regras de negócio com a interface.

## 4. Pacotes e APIs

- `firebase_core`: inicialização do Firebase;
- `firebase_auth`: login, sessão e logout;
- `cloud_firestore`: armazenamento e consulta em tempo real;
- `geolocator`: GPS, permissões e cálculo de distância;
- `local_auth`: autenticação biométrica do dispositivo;
- `intl`: formatação de data e hora.

## 5. Decisões de design

O tema usa Material 3 com tons roxos para criar uma identidade visual consistente. O botão de registro possui estados de carregamento e mensagens claras para diferenciar sucesso, falta de permissão, biometria recusada e distância fora do limite.

A sessão não é controlada por navegação manual depois do login. O `StreamBuilder` de autenticação decide se a tela inicial deve ser o login ou a tela de registro. Dessa forma, o logout também funciona automaticamente ao encerrar a sessão Firebase.

A biometria é confirmada antes da localização para evitar coletar a posição quando a identidade não foi confirmada. A mesma posição é usada tanto para validar o raio quanto para salvar o registro.

## 6. Desafios e soluções

### Firebase sem configuração completa

O aplicativo depende do projeto Firebase e do arquivo `google-services.json` no Android. A inicialização usa `Firebase.initializeApp()` para que o plugin nativo leia essa configuração.

### Biometria no Android

O `local_auth` exige `FlutterFragmentActivity`, por isso `MainActivity.kt` utiliza essa classe. As permissões de biometria e localização também foram declaradas no manifesto Android.

### Tipos numéricos do Firestore

Coordenadas podem chegar como `int` ou `double`. O modelo converte os valores por meio de `num.toDouble()` para evitar erros de conversão ao ler documentos.

### Teste de localização

Em um emulador, é necessário simular uma localização próxima das coordenadas configuradas da empresa. Em um aparelho físico, o GPS deve estar ativo e a permissão precisa ser aceita.

## 7. Segurança e limitações

As regras do Firestore devem exigir autenticação e comparar `userId` com `request.auth.uid`. A coleção `usuarios` também precisa de regras que evitem a leitura de dados de outros funcionários; em uma aplicação real, essa conversão deve ser feita por uma função backend.

As coordenadas de exemplo devem ser substituídas pelas coordenadas reais da empresa antes da apresentação. O cadastro de novos usuários ainda é feito pelo Firebase Console.

## 8. Melhorias futuras

- Criar uma tela de cadastro de funcionários;
- Implementar login por NIF com uma função backend;
- Permitir múltiplos locais de trabalho;
- Adicionar filtros por período no histórico;
- Criar testes de widget para os principais fluxos;
- Adicionar uma tela administrativa para relatórios de jornada.
