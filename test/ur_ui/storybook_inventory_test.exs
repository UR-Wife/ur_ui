defmodule UrUi.StorybookInventoryTest do
  use ExUnit.Case, async: true

  @moduledoc """
  `e2e/scripts/report.mjs` enumerates every ported component for the conformance
  report. Keep that list in lock-step with `storybook/ur_ui/*.story.exs` so a
  ported component can't silently disappear from the report.
  """

  test "report.mjs covers every storybook component" do
    stories =
      Path.wildcard(Path.expand("../../storybook/ur_ui/*.story.exs", __DIR__))
      |> Enum.map(&(&1 |> Path.basename(".story.exs") |> String.replace("_", "-")))
      |> Enum.sort()

    source = File.read!(Path.expand("../../e2e/scripts/report.mjs", __DIR__))

    [_, list] = Regex.run(~r/const componentNames = \[([\s\S]*?)\]/s, source)

    reported =
      Regex.scan(~r/'([^']+)'/, list)
      |> Enum.map(fn [_, name] -> name end)
      |> Enum.sort()

    assert reported == stories
  end
end
