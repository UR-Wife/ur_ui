import Config

# JUnit XML report for RWX per-test results (.rwx/tasks.yml `outputs.test-results`).
config :junit_formatter,
  report_dir: Path.expand("../tmp/junit", __DIR__),
  report_file: "ur-ui-test-junit-report.xml",
  project_dir: Path.expand("..", __DIR__),
  automatic_create_dir?: true,
  print_report_file: true,
  include_filename?: true,
  include_file_line?: true

config :logger, level: :warning