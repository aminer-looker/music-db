- dashboard: works_dashboard
  title: Works Dashboard
  layout: tile
  tile_size: 100

  elements:

  - name: works
    type: single_value
    model: classical_music_db
    explore: works
    measures: [works.count]