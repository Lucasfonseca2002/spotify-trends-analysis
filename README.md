# 🎵 Análise de Tendências Musicais Spotify

## 📋 Visão Geral do Projeto

Este projeto realiza uma análise abrangente de tendências musicais utilizando um dataset de **114.000 músicas do Spotify**, explorando padrões de popularidade, características sonoras e comportamentos por gênero musical. O objetivo é revelar insights sobre o que torna uma música popular e como diferentes gêneros se comportam em termos de atributos musicais.

### 🎯 Objetivos Principais
- Identificar padrões de sucesso em atributos musicais
- Analisar comportamento por gênero musical
- Explorar correlações entre características sonoras e popularidade
- Criar visualizações interativas dos insights descobertos

## 🌐 Demo Online

**🚀 [Acesse o Dashboard Interativo](https://lucasfonseca2002.github.io/spotify-trends-analysis/presentation/)**

> O dashboard está hospedado no GitHub Pages e pode ser acessado diretamente pelo navegador.

## 📊 Dataset

### Fonte dos Dados
- **Origem**: [Spotify Tracks Dataset (Kaggle)](https://www.kaggle.com/datasets/maharshipandya/-spotify-tracks-dataset)
- **Tamanho**: 114.000 faixas musicais
- **Período**: Dados históricos do Spotify

### Estrutura do Dataset
O dataset contém **21 colunas** com informações detalhadas sobre cada faixa:

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `track_id` | String | Identificador único da música no Spotify |
| `artists` | String | Nome do(s) artista(s) |
| `album_name` | String | Nome do álbum |
| `track_name` | String | Nome da música |
| `popularity` | Integer | Pontuação de popularidade (0-100) |
| `duration_ms` | Integer | Duração da música em milissegundos |
| `explicit` | Boolean | Indica se a música contém conteúdo explícito |
| `danceability` | Float | Quão adequada a música é para dançar (0.0-1.0) |
| `energy` | Float | Medida de intensidade e energia (0.0-1.0) |
| `key` | Integer | Tonalidade da música |
| `loudness` | Float | Volume geral da música em decibéis |
| `mode` | Integer | Modalidade (maior = 1, menor = 0) |
| `speechiness` | Float | Presença de palavras faladas (0.0-1.0) |
| `acousticness` | Float | Medida de acústica (0.0-1.0) |
| `instrumentalness` | Float | Predição se a música é instrumental (0.0-1.0) |
| `liveness` | Float | Detecção de presença de audiência ao vivo (0.0-1.0) |
| `valence` | Float | Positividade musical (0.0-1.0) |
| `tempo` | Float | Tempo estimado em BPM |
| `time_signature` | Integer | Assinatura de tempo |
| `track_genre` | String | Gênero musical |

### Estatísticas Gerais
- **Total de faixas**: 114.000
- **Faixas únicas**: 89.740
- **Artistas únicos**: 31.962
- **Álbuns únicos**: 67.648
- **Gêneros únicos**: 114

## 🔍 Metodologia de Análise

### Fase 1: Análise Exploratória
**Arquivos**: `analysis/01 - exploratory/`

#### 1.1 Estrutura e Qualidade dos Dados (`basic_exploration.sql`)
- **Objetivo**: Compreender a estrutura do dataset e avaliar a qualidade dos dados
- **Análises realizadas**:
  - Verificação de tipos de dados e valores nulos
  - Contagem de registros únicos por categoria
  - Distribuição de popularidade por faixas
  - Ranking das músicas e artistas mais populares

#### 1.2 Tendências por Gênero (`genre_trends.sql`)
- **Objetivo**: Criar perfis sonoros para cada gênero musical
- **Análises realizadas**:
  - Perfil sonoro dos 10 gêneros mais populares
  - Comparação de características de áudio entre gêneros
  - Análise de correlação entre atributos musicais

#### 1.3 Análise de Popularidade (`popularity_analysis.sql`)
- **Objetivo**: Investigar fatores que influenciam a popularidade
- **Análises realizadas**:
  - Correlação entre duração e popularidade
  - Impacto do modo musical (maior/menor) no sucesso
  - Análise de completude dos dados por faixa de popularidade

### Fase 2: Análises Avançadas
**Arquivos**: `analysis/02 - advanced/`

#### 2.1 Design de Schema Normalizado (`schema_design.sql`)
- **Objetivo**: Criar um modelo de dados normalizado para análises mais complexas
- **Estrutura criada**:
  - Tabela `genres` (gêneros musicais)
  - Tabela `artists` (artistas)
  - Tabela `albums` (álbuns)
  - Tabela `tracks` (faixas musicais)
  - Tabela `tracks_artists` (relacionamento N:N entre faixas e artistas)

#### 2.2 Processo ETL (`etl_process.sql`)
- **Objetivo**: Migrar dados do modelo flat para o modelo normalizado
- **Etapas do processo**:
  1. Criação das tabelas normalizadas
  2. Extração e inserção de gêneros únicos
  3. Processamento de artistas (tratamento de colaborações)
  4. Migração de álbuns
  5. Transferência de faixas com relacionamentos
  6. Criação de relacionamentos artista-faixa

#### 2.3 Análises Complexas (`complex_analytics.sql`)
- **Objetivo**: Realizar análises avançadas usando o modelo normalizado
- **Análises realizadas**:
  - Análise de colaborações entre artistas
  - Medição de versatilidade de artistas (quantos gêneros)
  - Consistência de álbuns (variação de popularidade)
  - Ranking de produtividade por gênero
  - Comparação de características sonoras normalizadas

## 📈 Principais Insights Descobertos

### 🎵 Músicas Mais Populares
As 10 músicas com maior popularidade (score 100):
1. **Heat Waves** - Glass Animals (Pop)
2. **Stay** - The Kid LAROI, Justin Bieber (Pop)
3. **Industry Baby** - Lil Nas X, Jack Harlow (Hip-Hop)
4. **Bad Habits** - Ed Sheeran (Pop)
5. **Good 4 U** - Olivia Rodrigo (Pop)

### 🎭 Análise por Gêneros

#### Gêneros Mais Populares (média de popularidade):
1. **Pop**: 64.2 (5.507 músicas)
2. **Hip-Hop**: 58.7 (3.009 músicas)
3. **Rock**: 55.3 (4.951 músicas)
4. **Dance**: 53.8 (2.896 músicas)
5. **Electronic**: 52.1 (3.240 músicas)

#### Gêneros Mais Energéticos:
1. **Metal**: 0.824 energia média
2. **Punk**: 0.798 energia média
3. **Rock**: 0.721 energia média
4. **Electronic**: 0.678 energia média
5. **Dance**: 0.672 energia média

### 🎼 Características Sonoras
- **Danceability**: Pop e Dance lideram com maior dançabilidade
- **Valence** (positividade): Pop apresenta maior positividade musical
- **Acousticness**: Folk e Acoustic dominam características acústicas
- **Energy**: Metal e Rock apresentam maior energia

## 🛠️ Tecnologias Utilizadas

### Análise de Dados
- **SQL**: Linguagem principal para análise de dados
- **PostgreSQL**: Sistema de gerenciamento de banco de dados
- **CSV**: Formato de dados de entrada

### Apresentação
- **HTML5**: Estrutura da apresentação web
- **CSS3**: Estilização e design responsivo
- **JavaScript**: Interatividade e funcionalidades dinâmicas
- **Syntax Highlighting**: Visualização de código SQL

## 📁 Estrutura do Projeto

```
Project - Analise de Tendências Musicais Spotify/
│
├── analysis/                          # Análises SQL
│   ├── 01 - exploratory/             # Análises exploratórias
│   │   ├── basic_exploration.sql     # Estrutura e qualidade dos dados
│   │   ├── genre_trends.sql          # Tendências por gênero
│   │   └── popularity_analysis.sql   # Análise de popularidade
│   │
│   ├── 02 - advanced/                # Análises avançadas
│   │   ├── schema_design.sql         # Design do schema normalizado
│   │   ├── etl_process.sql          # Processo de ETL
│   │   └── complex_analytics.sql     # Análises complexas
│   
│
├── data/                             # Dados do projeto
│   └── raw/
│       └── dataset.csv              # Dataset original do Spotify
│
├── presentation/                     # Apresentação web
│   ├── index.html                   # Dashboard interativo
│
└── README.md                        
```

## 🚀 Como Executar o Projeto

### Pré-requisitos
- PostgreSQL instalado
- Navegador web moderno
- Dataset do Spotify (incluído no projeto)

### Opção 1: Acesso Online (Recomendado)
```
🌐 Acesse diretamente: https://lucasfonseca2002.github.io/spotify-trends-analysis/presentation/
```

### Opção 2: Execução Local

1. **Clone o repositório**
```bash
git clone https://github.com/Lucasfonseca2002/spotify-trends-analysis.git
cd spotify-trends-analysis
```

2. **Visualize o dashboard**
```bash
# Opção A: Abrir diretamente no navegador
# Abra o arquivo presentation/index.html

# Opção B: Servidor local (recomendado)
cd presentation
python -m http.server 8000
# Acesse: http://localhost:8000
```

3. **Para executar as análises SQL (opcional)**
```sql
-- Configure um banco PostgreSQL
CREATE DATABASE spotify_analysis;

-- Importe o dataset: data/raw/dataset.csv
-- Execute os scripts na ordem:
-- 1. analysis/01 - exploratory/
-- 2. analysis/02 - advanced/
```

## 📊 Dashboard Interativo

O projeto inclui um dashboard web interativo que apresenta:

### Funcionalidades
- **Interface Responsiva**: Adaptável a diferentes dispositivos
- **Visualização de Código SQL**: Syntax highlighting para melhor legibilidade
- **Resultados Tabulares**: Apresentação organizada dos insights
- **Navegação por Abas**: Organização das diferentes análises

### Seções do Dashboard
1. **Estrutura dos Dados**: Visão geral do dataset
2. **Top Músicas**: Ranking das músicas mais populares
3. **Análise de Gêneros**: Comparação entre gêneros musicais
4. **Gêneros Energéticos**: Ranking de energia por gênero
5. **Comparativo de Popularidade**: Análise de fatores de sucesso

## 👨‍💻 Autor

**Lucas Fonseca**
- LinkedIn: [lucas-fonseca-21080a203](https://www.linkedin.com/in/lucas-fonseca-21080a203/)
- GitHub: [Lucasfonseca2002](https://github.com/Lucasfonseca2002)


## 🙏 Agradecimentos

- **Kaggle**: Pela disponibilização do dataset
- **Spotify**: Pelos dados de áudio features
- **Comunidade Open Source**: Pelas ferramentas utilizadas

---

*Este projeto foi desenvolvido como parte de um estudo de análise de dados musicais, demonstrando técnicas de SQL, ETL e visualização de dados.*
