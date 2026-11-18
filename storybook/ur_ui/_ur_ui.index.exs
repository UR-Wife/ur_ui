defmodule Storybook.UrUi do
  use PhoenixStorybook.Index

  def folder_open?, do: true

  def entry("button"), do: [icon: {:fa, "rectangle-ad", :thin}]
  def entry("badge"), do: [icon: {:fa, "tag", :thin}]
  def entry("label"), do: [icon: {:fa, "font", :thin}]
  def entry("separator"), do: [icon: {:fa, "minus", :thin}]
  def entry("skeleton"), do: [icon: {:fa, "square-dashed", :thin}]
end