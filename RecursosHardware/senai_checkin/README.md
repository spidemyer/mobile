# 📱 SENAI Check-in

Aplicativo multiplataforma desenvolvido em **Flutter** para o gerenciamento de check-ins de localização e diário de campo, voltado para as necessidades e unidades do **SENAI**. O aplicativo permite a captura de fotos via câmera, obtenção de coordenadas geográficas via GPS, visualização de mapas e persistência local dos dados utilizando SQLite.

---

## 🚀 Tecnologias e Pacotes Utilizados

* **[Flutter](https://flutter.dev/)** - Framework multiplataforma para desenvolvimento de interfaces nativas.
* **[Dart](https://dart.dev/)** - Linguagem de programação orientada a objetos.
* **[Google Fonts](https://pub.dev/packages/google_fonts)** (`^6.1.0`) - Tipografia moderna utilizando as fontes *Poppins* e *Roboto*.
* **[Google Maps Flutter](https://pub.dev/packages/google_maps_flutter)** (`^2.5.3`) - Exibição e interação com mapas.
* **[Permission Handler](https://pub.dev/packages/permission_handler)** - Gerenciamento inteligente de permissões de hardware (Câmera e Localização).
* **[Image Picker](https://pub.dev/packages/image_picker)** - Captura de fotos utilizando a câmera do dispositivo móvel.
* **[Geolocator](https://pub.dev/packages/geolocator)** - Obtenção de coordenadas de latitude e longitude via GPS em tempo real.
* **[SQFlite](https://pub.dev/packages/sqflite)** - Banco de dados SQLite local para armazenamento e persistência segura dos check-ins.

---

## 🎨 Identidade Visual e Design

O projeto adota uma paleta de cores moderna e elegante baseada em **tons de roxo claro e lavanda**, proporcionando uma experiência de usuário limpa e intuitiva:

* **Cor Primária:** Roxo Intenso / Material Purple (`#9C27B0`)
* **Cor Secundária / Lavanda:** Lilás Suave (`#E1BEE7`)
* **Fundo das Telas:** Roxo bem claro de fundo (`#F3E5F5`)
* **Textos em Destaque:** Roxo escuro para forte contraste (`#4A148C`)

---

## 📂 Arquitetura e Estrutura de Telas

O projeto está organizado de forma modular, facilitando a manutenção e a escalabilidade:

1. **`HomeScreen` (Tela Inicial / Menu Principal):**
* Exibe um cabeçalho de boas-vindas personalizado.
* Contém o painel de **Ações Rápidas** com cartões interativos em relevo (*Cards*).
* Atalhos diretos para *Novo Check-in*, *Ver Registros* e *Ver Mapa do SENAI*.


2. **`NovoRegistroScreen` (Tela de Cadastro de Ponto):**
* Inicializa automaticamente as verificações de permissões de Câmera e GPS.
* Abre a câmera para captura da foto do local/atividade.
* Captura coordenadas de geolocalização em tempo real.
* Campo de observação / diário de campo e salvamento direto no banco de dados local (`SQFlite`).


3. **`ListaRegistrosScreen` (Histórico de Check-ins):**
* Consulta assíncrona ao banco de dados local.
* Exibe em formato de lista os registros salvos, contendo a miniatura da foto, data/hora, observação e coordenadas geográficas resumidas.


4. **`MapaScreen` (Visualização Geográfica):**
* Integração com o Google Maps para navegação e marcação dos pontos das unidades do SENAI.



---

## ⚙️ Pré-requisitos e Instalação

Certifique-se de ter o ambiente Flutter configurado em sua máquina antes de prosseguir.

1. Clone o repositório ou baixe o código-fonte:
```bash
git clone <url-do-repositorio>
cd senai_checkin

```


2. Instale as dependências do projeto:
```bash
flutter pub get

```


3. Execute o aplicativo em um dispositivo conectado ou emulador:
```bash
flutter run

```

---

## 🔒 Configurações de Permissões Nativas

Para o funcionamento correto do app, verifique se as permissões estão devidamente declaradas nos arquivos de configuração nativa:

* **Android (`android/app/src/main/AndroidManifest.xml`):**
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

```

