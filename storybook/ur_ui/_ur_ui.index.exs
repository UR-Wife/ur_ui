defmodule Storybook.UrUi do
  use PhoenixStorybook.Index

  def folder_open?, do: true

  def entry("button"), do: [icon: {:fa, "rectangle-ad", :thin}]
  def entry("badge"), do: [icon: {:fa, "tag", :thin}]
  def entry("label"), do: [icon: {:fa, "font", :thin}]
  def entry("separator"), do: [icon: {:fa, "minus", :thin}]
  def entry("skeleton"), do: [icon: {:fa, "square-dashed", :thin}]
  def entry("avatar"), do: [icon: {:fa, "circle-user", :thin}]
  def entry("card"), do: [icon: {:fa, "square", :thin}]
  def entry("alert"), do: [icon: {:fa, "bell", :thin}]
  def entry("table"), do: [icon: {:fa, "table", :thin}]
end
