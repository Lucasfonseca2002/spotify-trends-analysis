-- ====================================================================
-- 1. ESTRUTURA E QUALIDADE DOS DADOS DO DATASET
-- ====================================================================

-- VERIFICANDO AS COLUNAS E TIPOS DISPONÍVEIS NO DATASET
SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'spotify_tracks'
ORDER BY ordinal_position;

-- DOCUMENTAÇÃO:
-- O que faz: Lista todas as colunas da tabela 'spotify_tracks', seus respectivos tipos de dados e se aceitam valores nulos.
-- Como funciona: Consulta o 'information_schema', um dicionário de metadados padrão em bancos de dados SQL.
-- Por que é importante: É o primeiro passo para entender a estrutura dos dados (dicionário de dados). Ajuda a identificar potenciais problemas, como colunas numéricas armazenadas como texto.
-- Insights esperados: Compreensão da estrutura da tabela, identificação de tipos de dados que podem precisar de conversão e verificação de quais campos permitem valores nulos.


-- VISÃO GERAL NOS DADOS
SELECT
    COUNT(*) AS total_tracks,
    COUNT(DISTINCT track_id) AS unique_tracks,
    COUNT(DISTINCT artists) AS unique_artists,
    COUNT(DISTINCT album_name) AS unique_albuns,
    COUNT(DISTINCT track_genre) AS unique_genres
FROM spotify_tracks;

-- DOCUMENTAÇÃO:
-- O que faz: Fornece uma contagem geral de faixas totais e distintas, além da quantidade de artistas, álbuns e gêneros únicos.
-- Como funciona: Utiliza as funções de agregação COUNT(*) para contagem total e COUNT(DISTINCT ...) para contagem de valores únicos.
-- Por que é importante: Oferece uma visão macro da escala e da diversidade do dataset.
-- Insights esperados: Entender o volume de dados e a variedade de entidades. Por exemplo, uma grande diferença entre 'total_tracks' e 'unique_tracks' poderia indicar duplicatas.


-- VERIFICANDO SE HÁ DUPLICATAS NO DATASET
SELECT
    track_name,
    artists,
    COUNT(*) AS duplicatas
FROM spotify_tracks
GROUP BY track_name, artists
HAVING COUNT(*) > 1
ORDER BY duplicatas DESC
LIMIT 10;

-- DOCUMENTAÇÃO:
-- O que faz: Identifica músicas que aparecem mais de uma vez no dataset, com base na combinação de nome da faixa e artista.
-- Como funciona: Agrupa as linhas por 'track_name' e 'artists' e usa a cláusula HAVING para filtrar os grupos com contagem maior que 1.
-- Por que é importante: A verificação de duplicatas é um passo crucial na limpeza de dados, pois registros duplicados podem distorcer médias e outras análises agregadas.
-- Insights esperados: Listar as músicas mais duplicadas, o que pode indicar a necessidade de um processo de ETL para limpar os dados ou que a mesma música está em múltiplos gêneros.


-- ====================================================================
-- 2. VERIFICAÇÃO DA COMPLETUDE DOS DADOS E VALORES NULOS
-- ====================================================================

SELECT
    'track_name' AS campo,
    COUNT(*) - COUNT(track_name) as NULOS,
    ROUND(100.0 * (COUNT(*) - COUNT(track_name)) / COUNT(*), 4)::TEXT || '%' AS percentual_nulos
FROM spotify_tracks
UNION ALL
SELECT
    'artists',
    COUNT(*) - COUNT(artists),
    ROUND(100.0 * (COUNT(*) - COUNT(artists)) / COUNT(*), 4)::TEXT || '%'
FROM spotify_tracks
UNION ALL
SELECT
    'popularity',
    COUNT(*) - COUNT(popularity),
    ROUND(100.0 * (COUNT(*) - COUNT(popularity)) / COUNT(*), 4)::TEXT || '%'
FROM spotify_tracks;

-- DOCUMENTAÇÃO:
-- O que faz: Calcula a quantidade total e o percentual de valores nulos para os campos mais importantes: 'track_name', 'artists' e 'popularity'.
-- Como funciona: Usa a diferença entre COUNT(*) e COUNT(column_name) para encontrar nulos. O UNION ALL combina os resultados de três consultas separadas em uma única visão.
-- Por que é importante: Avalia a qualidade e a completude dos dados. Campos com alta porcentagem de nulos podem ser inutilizáveis ou exigir tratamento especial (imputação).
-- Insights esperados: Determinar se os dados estão completos o suficiente para uma análise confiável e identificar quais colunas podem precisar de limpeza.


-- ====================================================================
-- 3. RANKING BÁSICO
-- ====================================================================

-- TOP 15 MUSICAS MAIS POPULARES
SELECT
    track_name,
    artists,
    popularity,
    track_genre
FROM spotify_tracks
WHERE popularity IS NOT NULL
ORDER BY popularity DESC
LIMIT 15;

-- DOCUMENTAÇÃO:
-- O que faz: Lista as 15 músicas com a maior pontuação de popularidade no dataset.
-- Como funciona: Ordena a tabela em ordem decrescente pela coluna 'popularity' e retorna as 15 primeiras linhas usando LIMIT.
-- Por que é importante: Ajuda a identificar rapidamente os maiores sucessos presentes no dataset, servindo como um bom ponto de partida para análises de tendências.
-- Insights esperados: Descobrir quais são as faixas e artistas de maior sucesso global e em quais gêneros eles se concentram.


-- TOP 10 ARTISTAS POR POPULARIDADE MÉDIA
SELECT
    artists,
    COUNT(*) AS total_tracks,
    ROUND(AVG(popularity),1) AS media_popularidade,
    MAX(popularity) AS popularidade_maxima
FROM spotify_tracks
WHERE popularity IS NOT NULL
GROUP BY artists
HAVING COUNT(*) >= 2 -- TRAZ APENAS ARTISTAS COM MAIS DE DUAS MUSICAS
ORDER BY media_popularidade DESC
LIMIT 10;

-- DOCUMENTAÇÃO:
-- O que faz: Rankeia os 10 artistas com a maior média de popularidade, considerando apenas artistas com pelo menos 2 músicas no dataset.
-- Como funciona: Agrupa os dados por artista, calcula a média e o máximo de popularidade, filtra com HAVING para garantir um número mínimo de faixas e ordena o resultado.
-- Por que é importante: Mede a consistência do sucesso de um artista, em vez de apenas um único hit. A cláusula HAVING evita que artistas de "one-hit wonder" com uma única música muito popular distorçam o ranking.
-- Insights esperados: Identificar artistas que mantêm um alto nível de popularidade em todo o seu catálogo de músicas presente no dataset.

-- DISTRIBUIÇÃO DE POPULARIDADE
SELECT
    CASE
        WHEN popularity >= 80 THEN 'Muito Popular (80-100)'
        WHEN popularity >= 60 THEN  'Popular (60-79)'
        WHEN popularity >= 40 THEN 'Moderada (40-59)'
        WHEN popularity >= 20 THEN 'Baixa (20-39)'
        ELSE 'Muito Baixa (0-19)'
        END AS faixa_de_popularidade,
    COUNT(*) AS quantidade,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM spotify_tracks WHERE popularity IS NOT NULL),2) ::TEXT || '%' AS porcentagem
FROM spotify_tracks
WHERE popularity IS NOT NULL
GROUP BY 1
ORDER BY MIN(popularity) DESC;

-- DOCUMENTAÇÃO:
-- O que faz: Agrupa as músicas em faixas de popularidade (de 'Muito Baixa' a 'Muito Popular') e calcula a quantidade e o percentual de músicas em cada faixa.
-- Como funciona: Usa a expressão CASE WHEN para categorizar a popularidade. Uma subconsultas no SELECT calcula o total de faixas para obter o percentual.
-- Por que é importante: Ajuda a entender a distribuição geral do sucesso no dataset. A maioria das músicas é de nicho ou de grande sucesso?
-- Insights esperados: Visualizar a concentração de músicas em cada nível de popularidade. É comum que a grande maioria das músicas se concentre nas faixas mais baixas.


-- ====================================================================
-- 4. ANÁLISE DE GÊNEROS MUSICAIS
-- ====================================================================

-- PANORAMA POR GÊNERO MUSICAL (LIMITADO POR 20)
SELECT
    track_genre,
    COUNT(*) AS total_trilhas,
    CONCAT(ROUND(AVG(popularity)::numeric, 1), '%')  AS media_popularidade
FROM spotify_tracks
WHERE track_genre IS NOT NULL
GROUP BY track_genre
ORDER BY media_popularidade DESC
LIMIT 20;

-- DOCUMENTAÇÃO:
-- O que faz: Lista os 20 gêneros musicais com a maior média de popularidade.
-- Como funciona: Agrupa os dados por 'track_genre', calcula a média de popularidade para cada um e ordena os resultados de forma decrescente.
-- Por que é importante: Identifica quais gêneros musicais têm, em média, o maior apelo comercial e sucesso junto ao público.
-- Insights esperados: Descobrir os gêneros que dominam as paradas de sucesso e entender onde a popularidade média é mais alta.


-- TOP 10 GÊNEROS MAIS ENÉRGICOS
SELECT
    track_genre,
    COUNT(*) AS trilhas,
    CONCAT(ROUND(AVG(energy::numeric), 3), '%') AS media_energia,
    CONCAT(ROUND(AVG(loudness::numeric), 2), '%') AS media_intensidade_sonora,
    ROUND(AVG(popularity), 1) AS media_populariadade
FROM spotify_tracks
WHERE energy IS NOT NULL AND track_genre IS NOT NULL
GROUP BY track_genre
ORDER BY AVG(energy::numeric) DESC
LIMIT 10;

-- DOCUMENTAÇÃO:
-- O que faz: Identifica os 10 gêneros musicais com a maior média de "energia" (energy), uma métrica de áudio do Spotify.
-- Como funciona: Agrupa por gênero, calcula a média de 'energy' (após conversão para numérico), e ordena para encontrar os mais energéticos.
-- Por que é importante: Permite a criação de playlists e recomendações baseadas no humor ou na intensidade da música, como para atividades físicas.
-- Insights esperados: Descobrir quais gêneros são ideais para contextos de alta energia (ex: Hardstyle, Techno) e analisar sua popularidade média.


-- TOP 10 GÊNEROS MUSICAIS MAIS RELAXANTES
SELECT
    track_genre,
    COUNT(*) AS trilhas,
    CONCAT(ROUND(AVG(energy::numeric), 3), '%') AS media_energia,
    CONCAT(ROUND(AVG(acousticness::numeric), 3), '%') AS media_acustica,
    ROUND((AVG(acousticness::numeric) - AVG(energy::numeric)), 3) AS pontuação_relaxamento
FROM spotify_tracks
WHERE energy IS NOT NULL AND acousticness IS NOT NULL AND track_genre IS NOT NULL
GROUP BY track_genre
HAVING COUNT(*) >= 30
ORDER BY pontuação_relaxamento DESC
LIMIT 10;

-- DOCUMENTAÇÃO:
-- O que faz: Rankeia os 10 gêneros mais "relaxantes" com base em uma pontuação criada (alta acusticidade e baixa energia).
-- Como funciona: Calcula a média de 'acousticness' e 'energy' por gênero e cria a 'pontuação_relaxamento' subtraindo a energia da acusticidade. Ordena pela maior pontuação.
-- Por que é importante: Análise criativa que define um "índice de relaxamento", útil para recomendações de músicas para foco, estudo ou sono.
-- Insights esperados: Identificar gêneros como 'Classical', 'Ambient' ou 'Acoustic' que se encaixam em um perfil de baixa energia e alta acusticidade.


-- TOP 10 GÊNEROS MUSICAIS MAIS 'FELIZES' (valance + danceability)
SELECT
    track_genre,
    COUNT(*) AS trilhas,
    CONCAT(ROUND(AVG(valence::numeric), 3), '%') AS media_positividade,
    CONCAT(ROUND(AVG(danceability::numeric), 3), '%') AS media_dança,
    ROUND((AVG(valence::numeric) + AVG(danceability::numeric)) / 2,  3) AS pontuação_humor
FROM spotify_tracks
WHERE valence IS NOT NULL AND danceability IS NOT NULL AND track_genre IS NOT NULL
GROUP BY track_genre
HAVING COUNT(*) >= 25
ORDER BY pontuação_humor DESC
LIMIT 10;

-- DOCUMENTAÇÃO:
-- O que faz: Identifica os 10 gêneros mais "felizes" ou "alto astral" através de uma pontuação que combina positividade (valence) e dançabilidade (danceability).
-- Como funciona: Agrupa por gênero e calcula a média das métricas 'valence' e 'danceability', combinando-as em uma 'pontuação_humor' e ordenando o resultado.
-- Por que é importante: Permite a criação de playlists temáticas para festas, momentos de celebração ou para melhorar o humor.
-- Insights esperados: Descobrir gêneros dançantes e positivos como 'Salsa', 'Disco' ou 'Pop', que provavelmente estarão no topo deste ranking.


-- GÊNEROS MUSICAIS MAIS 'MELANCÓLICOS' (baixa valence)
SELECT
    track_genre,
    COUNT(*) AS trilhas,
    CONCAT(ROUND(AVG(valence::numeric), 3), '%') AS media_positivdade,
    CONCAT(ROUND(AVG(acousticness::numeric), 3), '%') AS media_acustica,
    CONCAT(ROUND(AVG(energy::numeric), 3), '%') AS media_energia
FROM spotify_tracks
WHERE valence IS NOT NULL AND track_genre IS NOT NULL
GROUP BY track_genre
HAVING COUNT(*) >= 25
ORDER BY media_positivdade ASC
LIMIT 10;

-- DOCUMENTAÇÃO:
-- O que faz: Lista os 10 gêneros com a menor média de 'valence' (positividade), que podem ser considerados mais melancólicos ou tristes.
-- Como funciona: Agrupa por gênero e ordena pela 'media_positividade' em ordem ascendente (ASC) para encontrar os menores valores.
-- Por que é importante: Ajuda a compreender o espectro emocional dos gêneros musicais, sendo útil para recomendações a públicos que buscam músicas mais introspectivas.
-- Insights esperados: Identificar gêneros como 'Sad', 'Emo' ou certos subgêneros de 'Metal' e 'Ambient' que tendem a ter uma valência mais baixa.


-- COMPARATIVO AGRUPADO: GÊNEROS POPULARES vs GÊNEROS DE NICHO
SELECT
    track_genre,
    ROUND(AVG(popularity), 1) as media_populariade,
    COUNT(*) as total_musicas,
    CASE
        WHEN AVG(popularity) >= 50 THEN 'Gêneros Populares'
        ELSE 'Gêneros de Nicho'
        END as categoria_genero
FROM spotify_tracks
WHERE track_genre IS NOT NULL
GROUP BY track_genre
HAVING COUNT(*) >= 10
ORDER BY categoria_genero DESC, media_populariade DESC;

-- DOCUMENTAÇÃO:
-- O que faz: Classifica cada gênero como 'Popular' (média de popularidade >= 50) ou 'de Nicho' (< 50) e lista suas características.
-- Como funciona: Usa CASE WHEN sobre uma função de agregação (AVG) para criar a categoria. A cláusula HAVING garante que apenas gêneros com um número mínimo de músicas sejam considerados.
-- Por que é importante: Segmenta o universo de gêneros em dois grandes grupos, permitindo análises comparativas sobre o que diferencia o sucesso comercial do apelo de nicho.
-- Insights esperados: Obter uma lista clara de quais gêneros atingem o mainstream e quais permanecem mais underground, junto com suas respectivas contagens de faixas e médias de popularidade.