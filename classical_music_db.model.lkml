connection: "classical_music_db"

# include all the views
include: "*.view"

# include all the dashboards
include: "*.dashboard"

explore: composers {}

explore: works {
  always_filter: {
    filters: {
      field: composed_year
      value: "-NULL"
    }
  }

  join: instruments {
    foreign_key: instrument_id
  }

  join: types {
    foreign_key: type_id
  }

  join: composers {
    foreign_key: composer_id
  }

  join: collections {
    foreign_key: collection_id
  }

  join: piano_composers {
    foreign_key: composer_id
  }
}
