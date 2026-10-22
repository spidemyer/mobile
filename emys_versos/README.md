# Emy's Versos — Book Nook

Aplicativo móvel de estante digital desenvolvido em Flutter e Firebase. O
projeto permite pesquisar livros, organizar leituras em estantes pessoais,
acompanhar páginas lidas e consultar estatísticas atualizadas no Firestore por
Cloud Functions.

## Funcionalidades

- Cadastro e login com e-mail e senha.
- Login com conta Google.
- Pesquisa de livros por título ou autor usando Google Books e Open Library.
- Inclusão de livros encontrados na estante ou cadastro manual.
- Organização dos livros nas categorias **Quero Ler**, **Lendo** e **Lidos**.
- Atualização do total de páginas e do progresso de leitura.
- Remoção de livros.
- Abertura de links de prévia/leitura quando disponibilizados pelas fontes.
- Estatísticas de livros concluídos e páginas lidas, recalculadas no backend
  quando um livro é criado, alterado ou removido.
- Dados individuais protegidos por regras do Cloud Firestore.

## Tecnologias

- Flutter e Dart
- Provider para gerenciamento de estado
- Firebase Authentication
- Cloud Firestore
- Cloud Functions for Firebase (Node.js 22)
- Google Books API e Open Library API

## Organização do projeto

```text
lib/
  models/       Modelo e conversão dos dados de livros
  services/     Integrações com Firebase e APIs de livros
  viewmodels/   Estado e ações da aplicação
  views/        Telas de login, busca, estantes e estatísticas
functions/
  index.js      Atualização das estatísticas no backend
firestore.rules Regras de acesso ao Firestore
```

## Requisitos

- Flutter instalado e configurado para desenvolvimento Android.
- Node.js 22 e npm para instalar e implantar as Cloud Functions.
- Firebase CLI instalado e autenticado.
- Um projeto Firebase com Cloud Firestore e Firebase Authentication.
- Plano Firebase Blaze para implantar Cloud Functions. O uso de serviços
  Firebase pode gerar custos; consulte os limites e preços do seu projeto.

## Configuração do Firebase

1. Crie ou selecione um projeto no [console do Firebase](https://console.firebase.google.com/).
2. Ative **Authentication** e habilite os provedores **E-mail/senha** e
   **Google**.
3. Crie o banco **Cloud Firestore** em modo nativo.
4. Configure o app Android no projeto Firebase com o mesmo application ID do
   projeto Flutter.
5. Gere/atualize os arquivos de configuração com FlutterFire:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure --project SEU_PROJECT_ID --platforms android
   ```

   O comando gera `lib/firebase_options.dart` e atualiza a configuração Android.
   Não substitua esses arquivos pelos de outro projeto sem conferir o
   application ID.
6. Para login Google no Android, registre as chaves SHA-1 e SHA-256 do
   certificado de desenvolvimento no Firebase. Atualize a configuração Android
   depois de registrar as chaves.
7. Faça login no Firebase CLI e associe o diretório ao projeto:

   ```bash
   firebase login
   firebase use --add
   ```

   Se preferir, passe o ID explicitamente em cada comando:
   `firebase deploy --project SEU_PROJECT_ID ...`.

> `firebase_options.dart` e `google-services.json` contêm identificadores de
> configuração do aplicativo, não substituem regras de segurança. Não inclua
> chaves privadas, senhas ou credenciais de serviço no repositório.

## Instalação e execução

Na raiz do projeto:

```bash
flutter pub get
flutter run
```

Para validar o código Flutter:

```bash
flutter analyze
```

O repositório ainda não contém testes automatizados; adicione testes em
`test/` para validar novas funcionalidades com `flutter test`.

## Implantação do backend

As estatísticas são calculadas por uma função acionada por alterações em
`users/{userId}/books/{bookId}`. A função atualiza
`users/{userId}/stats/general`; o aplicativo lê esse documento em tempo real e
não grava estatísticas diretamente.

Instale as dependências das funções e implante as regras e funções:

```bash
npm --prefix functions install
firebase deploy --only firestore:rules,functions
```

Use o mesmo projeto Firebase configurado para o aplicativo. A atualização das
estatísticas é assíncrona: após uma alteração na estante, pode haver um breve
intervalo até a função concluir e os novos totais aparecerem.

## Modelo de dados no Firestore

Cada conta possui uma coleção própria de livros:

```text
users/{uid}/books/{bookId}
  title: string
  authors: array<string>
  description: string | null
  pageCount: number
  pagesRead: number
  thumbnailUrl: string | null
  status: "Quero Ler" | "Lendo" | "Lidos"
  previewLink: string | null
  updatedAt: string

users/{uid}/stats/general
  livrosLidos: number
  paginasLidas: number
  updatedAt: timestamp
```

As regras em `firestore.rules` permitem que cada pessoa leia e altere apenas os
próprios livros. As estatísticas podem ser lidas pelo titular, mas somente o
backend (que usa o Admin SDK) pode gravá-las.

## Fontes de livros

As pesquisas são feitas em paralelo na Google Books API e na Open Library. As
APIs públicas podem impor limites, ficar indisponíveis ou retornar informações
incompletas; por isso, alguns livros podem não ter capa, número de páginas ou
link de prévia.

## Escopo e evolução

Este repositório corresponde ao cenário **A Estante de Livros Digital
("Book Nook")**: gerenciamento de estado no Flutter e lógica de backend com
Cloud Functions. A integração de Firebase Storage, geolocalização,
relacionamentos musicais e receitas pertence a outros cenários da atividade e
não faz parte deste aplicativo.
