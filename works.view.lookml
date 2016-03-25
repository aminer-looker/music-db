- view: works
  fields:

  - dimension: id
    primary_key: true
    hidden: true

  - dimension: catalog_name

  - dimension: collection_id
    hidden: true

  - dimension_group: composed
    type: time
    timeframes: [year]
    sql: makedate(${TABLE}.composed_year, 1)
  
  - measure: started
    type: min
    value_format: '0'
    sql: ${composed_year}
  
  - measure: completed
    type: max
    value_format: '0'
    sql: ${composed_year}
  
  - measure: composition_span
    sql: ${completed} - ${started}
  
  - dimension: period
    sql_case:
      ancient: ${TABLE}.composed_year <= 476
      medieval: ${TABLE}.composed_year BETWEEN 477 AND 1400
      renassaince: ${TABLE}.composed_year BETWEEN 1401 AND 1600
      baroque: ${TABLE}.composed_year BETWEEN 1600 AND 1750
      classical: ${TABLE}.composed_year BETWEEN 1751 AND 1820
      romantic: ${TABLE}.composed_year BETWEEN 1821 AND 1910
      modern: ${TABLE}.composed_year BETWEEN 1910 AND YEAR(NOW())

  - dimension: composer_id
    hidden: true

  - dimension: difficulty
    type: number

  - dimension: instrument_id
    hidden: true
  
  - dimension: instrument
    sql: ${instruments.name}

  - dimension: key
    sql: ${TABLE}.key_area

  - dimension: op
    sql: ${TABLE}.opus

  - dimension: op_num
    sql: ${TABLE}.opus_num

  - dimension: title
    required_fields: [works.url]
    html: |
      <a href="//www.classicalmusicdb.com{{row["works.url"]}}" target="new">
        <img
          src="://www.classicalmusicdb.com/CMDB_favicon.gif"
          style="height: 16px; width: 16px"
        >
        {{rendered_value}}
      </a>

  - dimension: type_id
    hidden: true

  - dimension: url
    hidden: true

  - measure: count
    type: count
    drill_fields: detail*


  # ----- Sets of fields for drilling ------
  sets:
    detail:
    - title
    - catalog_name
    - collections.title
    - composers.full_name
