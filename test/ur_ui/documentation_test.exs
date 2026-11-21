defmodule UrUi.DocumentationTest do
  use ExUnit.Case, async: true

  defp project_file(path), do: File.read!(Path.expand("../../#{path}", __DIR__))

  test "README credits shadcn/ui and its MIT license" do
    readme = project_file("README.md")

    assert readme =~ "shadcn/ui"
    assert readme =~ "MIT"
    assert readme =~ "https://github.com/shadcn-ui/ui"
  end

  test "README gives Tailwind v4 consumers the dependency source line" do
    readme = project_file("README.md")

    assert readme =~ ~s(@source "../../deps/ur_ui";)
    assert readme =~ "assets/css/app.css"
  end

  test "the complete shadcn MIT notice is included" do
    license = project_file("LICENSES/shadcn-ui-LICENSE.md")

    assert license =~ "Copyright (c) 2023 shadcn"
    assert license =~ "Permission is hereby granted, free of charge"
    assert license =~ "THE SOFTWARE IS PROVIDED \"AS IS\""
  end

  test "library documentation has no legacy UR design rules" do
    text =
      ["README.md", "USAGE.md", "mix.exs", "lib/ur_ui.ex"]
      |> Enum.map_join("\n", &project_file/1)

    refute text =~ "--ur-wifes-"
    refute text =~ "UR black"
    refute text =~ "black/red/white"
    refute text =~ "outline-only"
    refute text =~ "UR red"
  end
end
