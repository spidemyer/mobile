# Projeto Biblioteca APP Json

## 1. Identificação do Projeto

- **Nome do Projeto**: Biblioteca App
- **Descrição**: Aplicativo móvel multiplataforma (Flutter) para gerenciamento de bibliotecas, com funcionalidade de CRUD (Criar, Ler, Atualizar, Deletar) para Usuários, livros e empréstimos.

## 2. Propósito e Escopo

O Sisteam tem como Objetivo digitalizar e simplificar a gestão de acervos bibliotecários. Ele permite o cadastro e controle de livros, usuários e empréstimos, oferecendo uma interface intuitiva para administradores. o escopo atual inclui operações básicas de gerenciamento, com dados persistidos em um backend simulado via Json Server.

## 3. Requisitos Funcionais (RF)

| ID | Requisito | Descrição |
| - | - | - |
| RF01 | Gerenciar Livros | Listar, Cadastrar, editar e excluir livros do acervo |
| RF02 | Gerenciar Usuários | Listar, Cadastrar, Editar e Excluir usuários do sistema |
| RF03 | Gerenciar Empréstimos de Livros | Visualizar e gerenciar empréstimos de livros |
| RF04 | Navegação | Interface com Navegação para abas ( Livros, Empréstimos, Usuários) |

## 4. Requisitos Não Funcionais (RNF)

| ID | Requisito | Descrição |
| - | - | - |
| RNF01 | Arquitetura | Baseada em camadas ( Model, Service, Controllers, Views) seguindo o padrão MVC. |
| RNF02 | Persistência | Utiliza um arquivo db.json como fonte de dados acessando via APIREST |
| RNF03 | Tecnologia | Desenvolvimento em Flutter/Dart, com consumo de APi via pacote http |
| RNF04 | Comunicação | A Comunicação com o backend é feita através de requisições HTTP sincronas (GET, POST, PUT, DELETE) |

## 5. Endpoints da API (BackEnd)

| Método | Endpoint | Descrição |
| - | - | - |
| GET | /users | Lista todos os usuários |
| GET | /users/{id} | Busca um usuário po ID |
| POST | /users | Cria um novo Usuário |
| PUT | /users/{id} | Atualiza um usuário |
| DELETE | /users/{id} | Remove um usuário |
| GET | /books | Lista todos os livros |
| GET | /books/{id} | Busca um livro po ID |
| POST | /books | Cria um novo livro |
| PUT | /books/{id} | Atualiza um livro |
| DELETE | /books/{id} | Remove um livro |
| GET | /loans | Lista todos os empréstimos |
| POST | /loans | Registra um novo Empréstimo |

## 6. Diagramas

### 6.1 Diagramas de Entidade Relacional (DER)

```mermaid

erDiagram
    USER {
        int id PK
        string name
        string email
    }

    BOOK {
        int id PK
        string title
        string author
        boolean avaliable
    }

    LOAN {
        int id PK
        int userId FK
        int bookId FK
        date startDate
        date dueDate
        boolean returned
    }

    USER ||--o{ LOAN : "do" 
    BOOK ||--o{ LOAN : "is loan in "  

```

### 6.2 Diagrama de Classe

```mermaid

classDiagram
    class ApiService{
        <<static>>
        _String _baseURL
        +getList(String path) Future~List~
        +getOne(String path, String id) Future~Map~
        +post(String path, Map body) Future~Map~
        +put(String path, Map body, String id) Future~Map~
        +delete(String path, String id) Future~void~
    }

    class UserModel {

    }

    class BookModel {

    }

    class LoanModel {

    }


```