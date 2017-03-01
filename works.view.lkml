view: works {
  dimension: id {
    primary_key: yes
    hidden: yes
  }

  dimension: catalog_name {}

  dimension: collection_id {
    hidden: yes
  }

  dimension_group: composed {
    type: time
    timeframes: [year]
    sql: makedate(${TABLE}.composed_year, 1) ;;
  }

  measure: started {
    type: min
    value_format: "0"
    sql: ${composed_year} ;;
  }

  measure: completed {
    type: max
    value_format: "0"
    sql: ${composed_year} ;;
  }

  measure: composition_span {
    type: number
    sql: ${completed} - ${started} ;;
  }

  dimension: period {
    case: {
      when: {
        sql: ${TABLE}.composed_year <= 476 ;;
        label: "ancient"
      }

      when: {
        sql: ${TABLE}.composed_year BETWEEN 477 AND 1400 ;;
        label: "medieval"
      }

      when: {
        sql: ${TABLE}.composed_year BETWEEN 1401 AND 1600 ;;
        label: "renassaince"
      }

      when: {
        sql: ${TABLE}.composed_year BETWEEN 1600 AND 1750 ;;
        label: "baroque"
      }

      when: {
        sql: ${TABLE}.composed_year BETWEEN 1751 AND 1820 ;;
        label: "classical"
      }

      when: {
        sql: ${TABLE}.composed_year BETWEEN 1821 AND 1910 ;;
        label: "romantic"
      }

      when: {
        sql: ${TABLE}.composed_year BETWEEN 1910 AND YEAR(NOW()) ;;
        label: "modern"
      }
    }
  }

  dimension: composer_id {
    hidden: yes
  }

  dimension: difficulty {
    type: number
  }

  dimension: instrument_id {
    hidden: yes
  }

  dimension: instrument {
    sql: ${instruments.name} ;;
  }

  dimension: key {
    sql: ${TABLE}.key_area ;;
  }

  dimension: op {
    sql: ${TABLE}.opus ;;
  }

  dimension: op_num {
    sql: ${TABLE}.opus_num ;;
  }

  dimension: title {
    required_fields: [works.url]
    html: <a href="//www.classicalmusicdb.com{{row["works.url"]}}" target="new">
        <img
          src="://www.classicalmusicdb.com/CMDB_favicon.gif"
          style="height: 16px; width: 16px"
        >
        {{rendered_value}}
      </a>
      ;;
  }

  dimension: type_id {
    hidden: yes
  }

  dimension: url {
    hidden: yes
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: ancient_count {
    type: count

    filters: {
      field: period
      value: "ancient"
    }
  }

  measure: medieval_count {
    type: count

    filters: {
      field: period
      value: "medieval"
    }
  }

  measure: baroque_count {
    type: count

    filters: {
      field: period
      value: "baroque"
    }
  }

  measure: classical_count {
    type: count

    filters: {
      field: period
      value: "classical"
    }
  }

  measure: romantic_count {
    type: count

    filters: {
      field: period
      value: "romantic"
    }
  }

  measure: modern_count {
    type: count

    filters: {
      field: period
      value: "modern"
    }
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [title, catalog_name, collections.title, composers.full_name]
  }
}