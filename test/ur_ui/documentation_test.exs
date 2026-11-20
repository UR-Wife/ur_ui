defmodule UrUi.DocumentationTest do
  use ExUnit.Case, async: true

  test "README credits shadcn/ui and its MIT license" do
    readme = File.read!(Path.expand("../../README.md", __DIR__))

    assert readme =~ "shadcn/ui"
    assert readme =~ "MIT"
    assert readme =~ "https://github.com/shadcn-ui/ui"
  end
end
