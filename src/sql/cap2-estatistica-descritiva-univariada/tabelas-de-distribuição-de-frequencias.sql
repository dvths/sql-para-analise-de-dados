/*markdown
## Tabelas de distribuição de frequência
*/

/*markdown
As tabelas de distribuição de frequência podem ser utilizadas para representar a frequência de ocorrências de um conjunto de registros de variáveis quantitativas ou qualitativas.
*/

/*markdown
- No caso das variáveis qualitativas, a tabela representa a **frequência de ocorrências de cada categoria da variável**.
- No caso das variáveis quantitativas discretas, a frequência de ocorrências é calculada para cada valor discreto da variável.
- No caso das variáveis quantitativas contínuas, os dados são agrupados em classes e, a partir daí, são calculadas as frequências de ocorrências para cada classe.
*/

/*markdown
Uma tabela de distribuição de frequências compõem os seguintes cálculos:
*/

/*markdown
- **Frequência Absoluta** $F_i$: Número de ocorrências para cada elemento $i$ na amostra.
- **Frequência Relativa** ($Fr_i$): Percentual relativo à frequência absoluta.
- **Frequência Acumulada** ($F_{ac}$): Soma de todas as ocorrências até o elemento analizado.
- **Frequência Relativa Acumulada** ($Fr_{ac}$): Percentual relativo à frequência acumulada.
*/

/*markdown
## Distribuição de frequências de variáveis qualitativas
*/

/*markdown
Variáveis qualitativas ou não métricas são representadas por tabelas de distribuição da frequência de ocorrência de cada categoria da variável. Esse tipo de variável não pode ser mensurada por medidas de posição, dispersão ou variabilidade, com exceção da moda, que fornece o valor mais recorrente em um conjunto de dados.   
*/

/*markdown
Para exemplificar, a query abaixo projeta as frequências absoluta, relativa, acumulada e relativa acumulada das categorias de produtos:
*/

select
    product_category_name as categoria
    ,count(*) as f_absoluta -- #1
    ,round(
        cast(count(*) as decimal) / (select count(*) from tb_products) * 100, 2
    ) as f_relativa -- #2
    ,sum(count(*)) over (order by product_category_name) as f_acumulada -- #3
    ,round(
        sum(count(*)) 
        over (order by product_category_name) / (select count(*) from tb_products) * 100, 2
    ) as f_acumulada_relativa -- #4
from tb_products
group by 1 -- #5

/*markdown
1. Para obter a frequência absoluta de uma variável qualitativa apenas preciso encontrar o número de linhas para cada categoria. Quando utilizo uma função de agregação, como `count()`, preciso informar _o que será agregado_, nesse caso, quero agregar essa contagem pelos valores categóricos de `product_name_category`.     
2. Para obter a frequência relativa, preciso dividir o valor agregado de cada categoria pelo valor total de observações da variável `product_name_category` e, por fim, multiplicá-lo por 100:
   1. A função `round()` é responsável por _arredondar_ um número real para um número de casas decimais fornecido. Ela recebe como parâmetro um número real (ou uma expressão que resulta em um número real) e um número inteiro que representa a quantidade de casas decimais que desejo. 
   2. Sendo assim, passo como argumento a divisão do **total de linhas para cada categoria** (`count(*)`: o asterisco, nesse caso, sempre se refere a variável `product_name_category`) pela contagem de todas linhas(`(select count(*) from tb_products)`: uma _subquery_ que retorna o total de observações).
   3. Como essa operação precisa resultar em um número real, uso a função `cast()`, que converte o resultado para um tipo real, no caso `decimal`. Se converter qualquer um dos elementos da divisão em um tipo real usando `cast()`, o resultado da operação consequentemente será real. Por fim, forneço  2 como segundo argumento para `round()` para determinar a quantidade de casas decimais.
3. Para obter a frequência acumulada, faço uso de uma função de janela (ou função analítica).
   1. Diferentemente da maioria das funções SQL, que só podem operar com a linha de dados atual, as **funções de janela** fazem cálculos que se estendem por várias linhas (o que é chamado de janela). A função pode ser qualquer função de agregação (`sum`, `avg`, `count`, `min`, `max`) assim como outras funções especias (`rank`, `first_value` e `ntile`).
   2. Esse tipo de função tem uma sintaxe específica que sempre incluirá uma cláusula `over` que é usada para determinar as linhas incluídas na operação (a janela), a ordem e/ou a partição dessas linhas. 
   3. No meu caso, aplico a soma sobre todas as observações ordenando por categoria (nesse caso a ordenação padrão é a ordem alfabética das categorias nominais de `product_category_name`). Isso fará com que o total de observações de uma categoria seja somada ao total da próxima, resultado no total acumulado até o último elemento analisado. Isso significa que, o total da última categoria analisada deve ser igual ao total de observações da variável.
4. A frequência relativa acumulada segue, basicamente, a lógica do cálculo anterior. 
   1. Faço a soma sobre o total de observações da variável ordenada pelo total de observações de cada categoria dividido pelo total geral de observações multiplicado por 100. 
   2. Isso resultará na soma do percentual de uma categoria ao percentual da próxima, ou seja acumulando esse percentual a medida que cada categoria é processada. 
   3. Utilizo as funções `cast()` e  `round()` para converter os valores para um tipo real e para determinar a quantidade de casas decimais, que, nesse caso, também é 2.
5. Por fim, determino que todas as agregações são feitas para cada categoria da variável `product_category_name`, fornecendo à cláusula `group by` a posição que variável ocupa na projeção da query, isto é na cláudula `select`.
*/

/*markdown
## Distribuição de frequências de variáveis quantitativas discretas
*/

/*markdown
 Variáveis discretas podem assumir um conjunto finito ou enumerável de valores que são provenientes, frequentemente, de uma contagem. 
*/

/*markdown
Para criar uma tabela de distribuição de frequências para esse tipo de dado, irei montar uma consulta que retorna a distribuição de itens contidos em cada pedido por cliente. 
*/

/*markdown
A tabela deve fornecer a quantidade de itens nos pedidos feitos por cada cliente organizados de forma decrescente e exibir os primeiros 10 resultados por uma questão de praticidade.
*/

select 
    a.customer_id as clientes
    ,count(order_item_id) as  num_itens
from tb_customers a
join tb_orders b 
    on a.customer_id = b.customer_id
join tb_order_items c 
    on c.order_id = b.order_id
group by 1
order by 2 desc
limit 10

/*markdown
A contagem acima é o que preciso para montar a distribuição da frequência com que uma quantidade determinada de clientes realizou uma quantidade específica de pedidos. Para construir essa tabela, precisei fazer a junção de 3 tabelas diferentes: 
*/

/*markdown
- `tb_customers`: que tem como chave primaria o campo `customer_id`.
- `tb_orders`: que se relaciona com `tb_customer` e `tb_order_items` pelas chaves estrangeiras `customer_id` e `order_item_id`, respectivamente.  
- `tb_order_items`: que se relaciona com a tabela `tb_orders` pela chave estrangeira `order_id`. 
*/

/*markdown
Basicamente, para obter a quantidade de itens em um pedido feito por cada cliente, precisei cruzar o pedido atrelado a cada cliente, para, a partir daí, contar a quantidade de itens atrelados a esse pedido e, por fim, agrupar por cliente. 
*/

/*markdown
Essa é a tabela que fornece os dados discretos que preciso para montar a distribuição de frequências de itens X cliente.
*/

select 
    items as qtd_items_pedidos
    ,count(*) as f_abs_clientes
from (
    select 
        a.customer_id as clientes
        ,count(order_item_id) as  items
    from tb_customers a
    join tb_orders b 
        on a.customer_id = b.customer_id
    join tb_order_items c 
        on c.order_id = b.order_id
    group by 1
) a
group by 1
order by 1

/*markdown
Obtemos a frequência absoluta de clientes que realizou uma quantidade determinada de itens em cada pedidos. Utilizamos a primeira query como uma subquery. A partir dela, projetamos a contagem de itens e a contagem de linhas (que sabemos que representam os clientes). Então agrupei pela contagem dos items e organizei de maneira decrescente. Com isso, fico sabendo que parte expressiva da base (88.863 clientes) realizou o pedido de apenas 1 item, enquanto 1 cliente foi responsável pela maior quantidade de itens em um pedido (21).  
*/

/*markdown
Com esta tabela, posso começar a calcular as frequências relativa, acumulada e relativa acumulada de clientes que realizou uma quantidade determinada de items em cada pedido. Para isso utilizarei um recurso chamado CTE (Common Table Expressions) em vez da subquery: 
*/

with items_count as (
    select 
            a.customer_id as clientes 
            ,count(order_item_id) as itens
        from tb_customers a
        join tb_orders b 
            on a.customer_id = b.customer_id
        join tb_order_items c 
            on c.order_id = b.order_id
        group by 1
)
select
    itens as qtd_itens 
    ,count(*) as f_cli_abs
    ,round(
        cast(count(*) as decimal)/(select count(*) from items_count) * 100, 2
    ) as f_cli_rel
    ,sum(count(*)) over (order by itens) as f_cli_acc
    ,round(
        sum(count(*)) over (order by itens)/(select count(*) from items_count) * 100, 2
    ) as f_clie_rel_acc
from items_count
group by 1