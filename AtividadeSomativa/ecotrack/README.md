# Controle de Hábitos Sustentáveis 🌿

Aplicativo Flutter desenvolvido para auxiliar usuários na gestão de hábitos eco-friendly, promovendo a conscientização ambiental através do acompanhamento de metas diárias.

## 📋 Especificação de Requisitos (ISO 29148)

### Requisitos Funcionais (RF)
- **RF01 - Gerenciamento de Hábitos:** O sistema deve listar hábitos sustentáveis pré-definidos.
- **RF02 - Marcar Conclusão:** O usuário deve ser capaz de marcar um hábito como "concluído".
- **RF03 - Dashboard de Impacto:** O sistema deve exibir um resumo estatístico (hábitos concluídos vs. pendentes).
- **RF04 - Navegação por Abas:** O app deve separar hábitos concluídos de pendentes usando `TabBarView`.
- **RF05 - Transição de Telas:** O usuário deve conseguir navegar entre a tela inicial, lista de hábitos e dashboard.

### Requisitos Não Funcionais (RNF)
- **RNF01 - Gerenciamento de Estado:** Deve utilizar o padrão `Provider` para garantir reatividade e performance.
- **RNF02 - Interface (UI):** Deve seguir os princípios de Material Design com temática focada em tons de verde (sustentabilidade).
- **RNF03 - Responsividade:** A interface deve se adaptar corretamente a diferentes tamanhos de tela (smartphones e tablets) usando widgets flexíveis.
- **RNF04 - Usabilidade:** O tempo de resposta para ações de clique (como concluir hábito) deve ser imperceptível (< 100ms).

### Protótipo

https://www.figma.com/design/kq1Fh35yd2rFMc6knq8uE4/Untitled?node-id=1-231&t=qAkzMLLu01vlowkV-0 

## 🏗️ Estrutura do Projeto (Arquitetura)

```text
lib/
├── models/    # Entidades de dados (Habito)
├── providers/ # Lógica de negócio e estado global (EcoProvider)
├── screens/   # Telas principais da aplicação
├── widgets/   # Componentes reutilizáveis
└── main.dart  # Ponto de entrada e configuração do Provider
