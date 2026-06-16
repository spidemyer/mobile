# Call Tel — Gerenciador de Contatos Telefônicos

*Aplicativo móvel desenvolvido em Flutter com persistência relacional SQLite local por meio da biblioteca sqflite. O sistema implementa de forma modular e altamente reativa o gerenciamento de contatos, subelementos dinâmicos associados e suporte nativo a múltiplos temas visuais.*

---

## 📋 Especificação de Engenharia de Requisitos 

### 1. Requisitos Funcionais (RF)

| ID | Requisito | Descrição |
| :--- | :--- | :--- |
| **RF-001** | Cadastro Inicial do Item Principal | O sistema deve permitir a inserção de um contato contendo obrigatoriamente: Nome Completo, Telefone Principal, E-mail e Endereço. |
| **RF-002** | Persistência de Dados Local | Toda a inclusão, edição e remoção de dados deve ser realizada localmente em banco de dados relacional SQLite de forma assíncrona. |
| **RF-003** | Visualização Expandida na Listagem | A tela de listagem geral deve exibir diretamente no card de cada contato o seu Nome, Telefone Principal, E-mail e Endereço, eliminando a necessidade de clique prévio para leitura dos dados básicos. |
| **RF-004** | Visualização do Registro Detalhado e Histórico | O sistema deve apresentar uma tela detalhada para o contato selecionado, exibindo suas informações estruturadas internas e a lista de campos adicionais dinâmicos. |
| **RF-005** | Adição de Elementos Relacionados | A partir da tela de detalhes, o usuário deve ser capaz de associar múltiplos elementos adicionais (Subtabelas/Campos Dinâmicos) como: Outros Telefones, Datas de Aniversário e Observações em formato chave-valor. |
| **RF-006** | Ordenação Alfabética Automática | A listagem completa dos contatos salvos deve ser renderizada e ordenada nativamente de forma ascendente de A-Z. |
| **RF-007** | Filtragem de Registros | Deve ser provido um campo de busca capaz de filtrar em tempo real os contatos por correspondência de nome. |
| **RF-008** | Exclusão com Integridade Cascata | Ao deletar um contato principal, o banco de dados deve remover automaticamente todos os campos adicionais vinculados a ele (`ON DELETE CASCADE`). |
| **RF-009** | Alternância de Tema Dinâmico | O usuário deve ser capaz de alternar a interface entre os modos claro e escuro a partir de um único clique na tela inicial, aplicando a mudança de cores imediatamente em todas as telas e formulários. |

---

### 2. Requisitos Não Funcionais (RNF)

| ID | Categoria | Descrição |
| :--- | :--- | :--- |
| **RNF-001** | Arquitetura | O código-fonte deve respeitar a separação lógica de responsabilidades através do padrão arquitetural de camadas (`Models`, `Controllers`, `Database`, `Screens`). |
| **RNF-002** | Estado | A reatividade da aplicação (mudanças de dados e troca de temas) deve ser gerenciada centralizadamente utilizando o padrão `ChangeNotifier` com o pacote `Provider`. |
| **RNF-003** | UI/UX | A paleta cromática deve manter a consistência com os protótipos fornecidos: gradientes azul/roxo, botões de salvar lilás (`#D946EF`), e o ícone de telefone (`Icons.phone_android_rounded`). |
| **RNF-004** | Acessibilidade | No modo escuro, os backgrounds dos formulários e inputs devem migrar para tons escuros (`#0F172A`, `#1E293B`), garantindo alto contraste com textos brancos. |
| **RNF-005** | Robustez | Quaisquer operações de I/O em banco de dados devem ser englobadas em blocos `try-catch` com tratamento correto e feedback claro por `SnackBars`. |

---

## 🛠️ Tecnologias Utilizadas

*- Flutter SDK: ^3.0.0 (ou superior)*

*- Dart Language: Fortemente tipada, suporte a Null-Safety*

*- sqflite: ^2.3.3+1 (Banco de dados local)*

*- provider: ^6.1.2 (Gerenciamento de estado e tema)*

*- path: ^1.9.0 (Manipulação de caminhos de arquivos)*