/*markdown

## Tabelas de distribuição de frequência

As tabelas de distribuição de frequência podem ser utilizadas para representar a frequência de ocorrências de um conjunto de registros de variáveis quantitativas ou qualitativas.

- No caso das variáveis qualitativas, a tabela representa a **frequência de ocorrências de cada categoria da variável**.
- No caso das variáveis quantitativas discretas, a frequência de ocorrências é calculada para cada valor discreto da variável.
- No caso das variáveis quantitativas contínuas, os dados são agrupados em classes e, a partir daí, são calculadas as frequências de ocorrências para cada classe.

Uma tabela de distribuição de frequências compõem os seguintes cálculos:

- **Frequência Absoluta** $F_i$: Número de ocorrências para cada elemento $i$ na amostra.
- **Frequência Relativa** ($Fr_i$): Percentual relativo à frequência absoluta.
- **Frequência Acumulada** ($F_{ac}$): Soma de todas as ocorrências até o elemento analizado.
- **Frequência Relativa Acumulada** ($Fr_{ac}$): Percentual relativo à frequência acumulada.

*/

/*markdown
## Distribuição de frequências de variáveis qualitativas
*/

/*markdown
Variáveis qualitativas ou não métricas são representadas por tabelas de distribuição de frequências e não podem ser mensuradas por medidas de posição, dispersão ou variabilidade com exceção da moda, que fornece o valor mais recorrente em um conjunto de dado.   

Para exemplificar, a query abaixo projeta as frequências absoluta, relativa, acumulada e relativa acumulada das categorias de produtos: 
*/

select
    product_category_name as categoria
    ,count(*) as f_absoluta
    ,round(
        cast(count(*) as decimal) / (select count(*) from tb_products) * 100, 2
    ) as f_relativa
    ,sum(count(*)) over (order by product_category_name) as f_acumulada
    ,round(
        sum(count(*)) over (order by product_category_name) / (select count(*) from tb_products) * 100, 2
    ) as f_acumulada_relativa
from tb_products
group by 1
